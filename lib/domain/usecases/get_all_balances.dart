import 'package:decimal/decimal.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

import "./usecase.dart";
export "./usecase.dart";

import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';

import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/balance_v2.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/event.dart';
// attach => debit from the address, credit to the utxo
// detach => debit from the utxo, credit to the address
// move -> debit from the utxo, credit to the utxo
// send => debit from the address, credit to the address

// given this inputs, this algo is giving me the following results

// [
//   UtxoBalance(3, 02d69...)
//
//   UtxoBalance(2  73e5f...)
//   AddredssBalance(40)    should be 50?
//   UtxoBalance(50)
// ]

class BalancesSetMempoolData {
  final List<VerboseAttachToUtxoEvent> attaches;
  final List<VerboseDetachFromUtxoEvent> detaches;
  final List<VerboseMoveToUtxoEvent> moves;

  // credits and debits refer to the addresses true
  // meta protocol balance
  final List<VerboseCreditEvent> credits;
  final List<VerboseDebitEvent> debits;

  const BalancesSetMempoolData({
    required this.detaches,
    required this.attaches,
    required this.credits,
    required this.debits,
    required this.moves,
  });
}

class BalancesSet {
  final List<BalanceV2> confirmed;
  final BalancesSetMempoolData _mempoolData;

  const BalancesSet({
    required this.confirmed,
    required BalancesSetMempoolData mempoolData,
  }) : _mempoolData = mempoolData;
}

class GetAllBalancesUseCaseParams {
  final HttpConfig httpConfig;
  final List<String> addresses;
  const GetAllBalancesUseCaseParams({
    required this.httpConfig,
    required this.addresses,
  });
}

extension BalancesSetProjection on BalancesSet {
  List<BalanceV2> get projected {
    final Map<_Key, AssetQuantity> state = {};
    final Map<String, bool> assetDivisibility = {}; // asset -> divisible

    final Map<String, String> utxoAddressLabel = {};

    final Set<_Key> confirmedRowKeys = {};

    final Set<String> ownedAddresses = {};

    void seed(BalanceV2 b) {
      final key = (b is UtxoBalance)
          ? _kUtxo(b.asset, b.utxoId)
          : _kAddr(b.asset, b.address);

      final prev = state[key];
      if (prev == null) {
        state[key] = b.quantity;
      } else {
        state[key] = AssetQuantity(
          divisible: prev.divisible,
          quantity: prev.quantity + b.quantity.quantity,
        );
      }
      assetDivisibility.putIfAbsent(b.asset, () => b.quantity.divisible);

      ownedAddresses.add(b.address);

      if (b is UtxoBalance) {
        utxoAddressLabel[b.utxoId.toString()] = b.address;
      }
    }

    for (final b in confirmed) {
      final key = (b is UtxoBalance)
          ? _kUtxo(b.asset, b.utxoId)
          : _kAddr(b.asset, b.address);
      seed(b);
      confirmedRowKeys.add(key);
    }

    // ===== deltas =====
    final Map<_Key, BigInt> deltas = {};
    void addDelta(_Key key, BigInt dq) {
      if (dq == BigInt.zero) return;
      deltas.update(key, (v) => v + dq, ifAbsent: () => dq);
    }

    // helpers
    bool divisibleFor(String asset, {bool? fallback}) =>
        assetDivisibility[asset] ?? fallback ?? true;

    BigInt rawFromNormalized(String normalized, bool divisible) {
      final d = Decimal.parse(normalized);
      if (!divisible) return BigInt.from(d.toBigInt().toInt());
      final scaled = d * TenToTheEigth.decimal; // 10^8
      return BigInt.parse(scaled.round().toString());
    }

    BigInt chooseRaw({
      BigInt? raw,
      String? normalized,
      required String asset,
      bool? explicitDivisible,
    }) {
      if (raw != null) return raw;
      if (normalized == null) return BigInt.zero;
      final div = explicitDivisible ?? divisibleFor(asset);
      return rawFromNormalized(normalized, div);
    }

    BigInt effectiveQty(_Key key) {
      final base = state[key]?.quantity ?? BigInt.zero;
      final d = deltas[key] ?? BigInt.zero;
      return base + d;
    }

    // ===== CREDIT / DEBIT (addr <-> addr sends only) =====
    for (final e in _mempoolData.credits) {
      final p = e.params;
      final dq = chooseRaw(
        raw: BigInt.from(p.quantity),
        normalized: p.quantityNormalized,
        asset: p.asset,
      );
      addDelta(_kAddr(p.asset, p.address), dq);
    }
    for (final e in _mempoolData.debits) {
      final p = e.params;
      final dq = chooseRaw(
        raw: BigInt.from(p.quantity),
        normalized: p.quantityNormalized,
        asset: p.asset,
      );
      addDelta(_kAddr(p.asset, p.address!), -dq);
    }

    // ===== ATTACH (credit UTXO only; DEBIT covers the address) =====
    for (final e in _mempoolData.attaches) {
      final p = e.params;
      final divisible = p.assetInfo.divisible;
      assetDivisibility[p.asset] = divisible;
      final dq = chooseRaw(
        raw: BigInt.from(p.quantity),
        normalized: p.quantityNormalized,
        asset: p.asset,
        explicitDivisible: divisible,
      );

      final utxoId = UtxoID.fromString(p.destination); // "txid:vout"
      final utxoKey = _kUtxo(p.asset, utxoId);

      // we don’t have destination_address in your typedef, but your samples show it equals source
      utxoAddressLabel[_utxoIdStrFromKey(utxoKey)] = p.source;

      addDelta(utxoKey, dq);
    }

    for (final e in _mempoolData.detaches) {
      final p = e.params;

      final dqReq = chooseRaw(
        normalized: p.quantityNormalized, // DETACH has normalized
        asset: p.asset,
      );

      final utxoId = UtxoID.fromString(p.source);
      final utxoKey = _kUtxo(p.asset, utxoId); // <- SAME key shape as seed
      final available = (state[utxoKey]?.quantity ?? BigInt.zero) +
          (deltas[utxoKey] ?? BigInt.zero);
      final dq = dqReq <= available ? dqReq : available;
      if (dq == BigInt.zero) continue;

      addDelta(utxoKey, -dq);
      addDelta(_kAddr(p.asset, p.destination), dq);
    }

// ===== UTXO_MOVE (receiver-only): credit destination UTXO, unconfirmed =====
    for (final e in _mempoolData.moves) {
      final p = e.params;

      final dq = chooseRaw(
        normalized: p.quantityNormalized,
        asset: p.asset, // uses known divisibility or defaults to divisible=true
      );
      if (dq == BigInt.zero) continue;

      final utxoId = UtxoID.fromString(p.destination); // "txid:vout"
      final utxoKey = _kUtxo(p.asset, utxoId);

      final utxoIdSource = UtxoID.fromString(p.source); // "txid:vout"
      final utxoKeySource = _kUtxo(p.asset, utxoIdSource);

      if (state.containsKey(utxoKeySource)) {
        addDelta(utxoKeySource, -dq); // apply-deltas will create this new row
      } else {
        addDelta(utxoKey, dq); // apply-deltas will create this new row
      }
    }

    // ===== apply deltas =====
    deltas.forEach((key, dq) {
      final prev = state[key];
      final divisible = assetDivisibility[key.asset] ?? true;
      if (prev == null) {
        if (dq != BigInt.zero) {
          state[key] = AssetQuantity(divisible: divisible, quantity: dq);
        }
      } else {
        final nextQ = prev.quantity + dq;
        if (nextQ == BigInt.zero) {
          state.remove(key);
        } else {
          state[key] =
              AssetQuantity(divisible: prev.divisible, quantity: nextQ);
        }
      }
    });

    // ===== rebuild list =====
    final List<BalanceV2> out = [];
    for (final entry in state.entries) {
      final key = entry.key;
      final q = entry.value;

      // Keep zero UTXO rows if you want, but skip zero address rows
      if (q.quantity == BigInt.zero && _isAddrKey(key)) continue;

      final isConfirmedRow = confirmedRowKeys.contains(key);

      if (_isAddrKey(key)) {
        out.add(AddressBalance(
          confirmed: isConfirmedRow,
          asset: key.asset,
          assetLongname: null,
          address: _addrFromKey(key),
          quantity: q,
        ));
      } else if (_isUtxoKey(key)) {
        final utxoIdStr = _utxoIdStrFromKey(key);
        final utxoId = UtxoID.fromString(utxoIdStr);
        final labelAddr = utxoAddressLabel[utxoIdStr] ?? '';
        out.add(UtxoBalance(
          confirmed: isConfirmedRow,
          utxoId: utxoId,
          asset: key.asset,
          assetLongname: null,
          address: labelAddr,
          quantity: q,
        ));
      }
    }

    // stable ordering (asset, then value)
    out.sort((a, b) {
      final c1 = a.asset.compareTo(b.asset);
      if (c1 != 0) return c1;
      final v1 = (a is AddressBalance)
          ? 'addr:${a.address}'
          : 'utxo:${(a as UtxoBalance).utxoId}';
      final v2 = (b is AddressBalance)
          ? 'addr:${b.address}'
          : 'utxo:${(b as UtxoBalance).utxoId}';
      return v1.compareTo(v2);
    });

    return out;
  }
}

// === internals ===

class _Key {
  final String asset;

  /// "addr:<address>" or "utxo:<txid>:<vout>"
  final String value;
  const _Key({required this.asset, required this.value});

  @override
  bool operator ==(Object o) =>
      o is _Key && asset == o.asset && value == o.value;
  @override
  int get hashCode => Object.hash(asset, value);
}

_Key _kAddr(String asset, String address) =>
    _Key(asset: asset, value: 'addr:$address');
_Key _kUtxo(String asset, UtxoID id) =>
    _Key(asset: asset, value: 'utxo:${id.toString()}');
bool _isAddrKey(_Key k) => k.value.startsWith('addr:');
bool _isUtxoKey(_Key k) => k.value.startsWith('utxo:');
String _addrFromKey(_Key k) => k.value.substring(5);
String _utxoIdStrFromKey(_Key k) => k.value.substring(5);

class GetAllBalancesUseCase
    implements UseCaseTE<BalancesSet, GetAllBalancesUseCaseParams, String> {
  final BalanceRepository _balanceRepository;
  final EventsRepository _eventsRepository;

  GetAllBalancesUseCase(
      {BalanceRepository? balanceRepository,
      EventsRepository? eventsRepository})
      : _eventsRepository = eventsRepository ?? GetIt.I<EventsRepository>(),
        _balanceRepository = balanceRepository ?? GetIt.I<BalanceRepository>();

  @override
  TaskEither<String, BalancesSet> call(GetAllBalancesUseCaseParams params) {
    return TaskEither<String, BalancesSet>.Do(($) async {
      final confirmedTask = _balanceRepository
          .getBalancesForAddresses(
            httpConfig: params.httpConfig,
            addresses: params.addresses,
          )
          .map<List<BalanceV2>>((balances) => balances
              .map<List<BalanceV2>>((MultiAddressBalance balance) =>
                  balance.entries.map<BalanceV2>((entry) {
                    return entry.utxo != null
                        ? UtxoBalance(
                            confirmed: true,
                            asset: balance.asset,
                            assetLongname: balance.assetInfo.assetLongname,
                            description: balance.assetInfo.description,
                            utxoId: UtxoID.fromString(entry.utxo!),
                            address: entry.utxoAddress!,
                            quantity: AssetQuantity(
                              quantity: BigInt.from(entry.quantity),
                              divisible: balance.assetInfo.divisible,
                            ),
                          )
                        : AddressBalance(
                            confirmed: true,
                            asset: balance.asset,
                            assetLongname: balance.assetInfo.assetLongname,
                            description: balance.assetInfo.description,
                            address: entry.address!,
                            quantity: AssetQuantity(
                              quantity: BigInt.from(entry.quantity),
                              divisible: balance.assetInfo.divisible,
                            ));
                  }).toList())
              .expand((el) => el)
              .toList());

      final mempoolTask =
          _eventsRepository.getAllMempoolVerboseEventsForAddressesT(
        params.httpConfig,
        params.addresses,
        ["ATTACH_TO_UTXO", "DETACH_FROM_UTXO", "UTXO_MOVE", "CREDIT", "DEBIT"],
        (_, __) => "Failed to get mempool events ",
      );

      final result =
          await $(TaskEither.sequenceList([confirmedTask, mempoolTask]));

      final confirmed = result[0] as List<BalanceV2>;
      final mempoolEvents = result[1] as List<VerboseEvent>;

      return BalancesSet(
          confirmed: confirmed,
          mempoolData: BalancesSetMempoolData(
            attaches:
                mempoolEvents.whereType<VerboseAttachToUtxoEvent>().toList(),
            detaches:
                mempoolEvents.whereType<VerboseDetachFromUtxoEvent>().toList(),
            moves: mempoolEvents.whereType<VerboseMoveToUtxoEvent>().toList(),
            credits: mempoolEvents.whereType<VerboseCreditEvent>().toList(),
            debits: mempoolEvents.whereType<VerboseDebitEvent>().toList(),
          ));
    });
  }
}
