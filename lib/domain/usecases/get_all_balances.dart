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

// balances_set_projection.dart

extension BalancesSetProjection on BalancesSet {
  /// Apply mempool deltas to `confirmed` and return a **new** BalancesSet.
  /// - Totals are correct.
  /// - Per-UTXO redistribution from UTXO_MOVE is skipped (insufficient source info).
  List<BalanceV2> get projected {
    // 1) Build a baseline state and an asset->divisible lookup from confirmed
    final Map<_Key, AssetQuantity> state = {};
    final Map<String, bool> assetDivisibility = {}; // asset -> divisible

    void _seed(BalanceV2 b) {
      final key = _Key(
        asset: b.asset,
        address: b.address,
        utxoId: (b is UtxoBalance) ? b.utxoId : null,
        assetLongname: b.assetLongname,
      );
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
    }

    for (final b in confirmed) {
      _seed(b);
    }

    // 2) Aggregate deltas from mempool events
    final Map<_Key, BigInt> deltas = {};

    void _addDelta(_Key key, BigInt dq) {
      if (dq == BigInt.zero) return;
      deltas.update(key, (v) => v + dq, ifAbsent: () => dq);
    }

    // Helpers
    bool _divisibleFor(String asset, {bool? fallback}) =>
        assetDivisibility[asset] ?? fallback ?? true;

    BigInt _rawFromNormalized(String normalized, bool divisible) {
      final d = Decimal.parse(normalized);
      final scale =
          divisible ? Decimal.fromInt(1).scale + 8 : Decimal.zero.scale;
      // For non-divisible, normalized should be an int; we round toward zero
      if (!divisible) return BigInt.from(d.toBigInt().toInt());
      // divisible => multiply by 10^8 and round to integer
      final scaled = (d * TenToTheEigth.decimal);
      // round half away from zero to be safe on UI-origin decimals
      return BigInt.parse(scaled.round().toString());
    }

    BigInt _chooseRaw({
      BigInt? raw,
      String? normalized,
      required String asset,
      bool? explicitDivisible,
    }) {
      if (raw != null) return raw;
      if (normalized == null) return BigInt.zero;
      final div = explicitDivisible ?? _divisibleFor(asset);
      return _rawFromNormalized(normalized, div);
    }

    // CREDIT: address += quantity
    for (final e in _mempoolData.credits) {
      final p = e.params;
      final dq = _chooseRaw(
        raw: BigInt.from(p.quantity), // BigInt from your mapper
        normalized: p.quantityNormalized, // present in mapper
        asset: p.asset,
      );
      _addDelta(_Key(asset: p.asset, address: p.address), dq);
    }

    // DEBIT: address -= quantity
    for (final e in _mempoolData.debits) {
      final p = e.params;
      final dq = _chooseRaw(
        raw: BigInt.from(p.quantity),
        normalized: p.quantityNormalized,
        asset: p.asset,
      );
      // we can to this not null assertion here because definitionally
      // we are querying events on an address
      _addDelta(_Key(asset: p.asset, address: p.address!), -dq);
    }

    // ATTACH_TO_UTXO: debit address (source) -> credit UTXO (destination)
    for (final e in _mempoolData.attaches) {
      final p = e.params;
      final divisible = p.assetInfo.divisible; // provided here
      assetDivisibility[p.asset] = divisible; // ensure known
      final dq = _chooseRaw(
        raw: BigInt.from(p.quantity), // BigInt available
        normalized: p.quantityNormalized,
        asset: p.asset,
        explicitDivisible: divisible,
      );
      final addrKey = _Key(asset: p.asset, address: p.source);
      final utxoKey = _Key(
        asset: p.asset,
        address: p.destination,
        utxoId: UtxoID.fromString(p.destination),
      );
      _addDelta(addrKey, -dq);
      _addDelta(utxoKey, dq);
    }

    // DETACH_FROM_UTXO: debit UTXO (source) -> credit address (destination)
    for (final e in _mempoolData.detaches) {
      final p = e.params;
      // no raw quantity in mapper; convert normalized using known divisibility
      final dq = _chooseRaw(
        normalized: p.quantityNormalized,
        asset: p.asset,
      );
      final utxoKey = _Key(
        asset: p.asset,
        address: p.source,
        utxoId: UtxoID.fromString(p.source),
      );
      final addrKey = _Key(asset: p.asset, address: p.destination);
      _addDelta(utxoKey, -dq);
      _addDelta(addrKey, dq);
    }

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

    // 4) Rebuild List<BalanceV2>
    final List<BalanceV2> out = [];
    for (final entry in state.entries) {
      final key = entry.key;
      final q = entry.value;
      if (q.quantity == BigInt.zero) continue;

      if (key.utxoId == null) {
        out.add(AddressBalance(
          confirmed: true, // projected as "current view"
          asset: key.asset,
          assetLongname: key.assetLongname,
          address: key.address,
          quantity: q,
        ));
      } else {
        out.add(UtxoBalance(
          confirmed: true,
          utxoId: key.utxoId!,
          asset: key.asset,
          assetLongname: key.assetLongname,
          address: key.address,
          quantity: q,
        ));
      }
    }

    // stable ordering
    out.sort((a, b) {
      final c1 = a.asset.compareTo(b.asset);
      if (c1 != 0) return c1;
      final c2 = a.address.compareTo(b.address);
      if (c2 != 0) return c2;
      final u1 = (a is UtxoBalance) ? a.utxoId.toString() : '';
      final u2 = (b is UtxoBalance) ? b.utxoId.toString() : '';
      return u1.compareTo(u2);
    });

    return out;
  }
}

// === internals ===
class _Key {
  final String asset;
  final String address;
  final UtxoID? utxoId; // null => address balance; non-null => UTXO row
  final String? assetLongname;

  const _Key({
    required this.asset,
    required this.address,
    this.utxoId,
    this.assetLongname,
  });

  @override
  bool operator ==(Object other) =>
      other is _Key &&
      asset == other.asset &&
      address == other.address &&
      (utxoId?.toString() ?? '') == (other.utxoId?.toString() ?? '');

  @override
  int get hashCode => Object.hash(asset, address, utxoId?.toString());
}

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
          .getBalancesForAddressesT(
            httpConfig: params.httpConfig,
            addresses: params.addresses,
            onError: (_, __) =>
                "Failed to read confirmed balances for ${params.addresses}",
          )
          .map<List<BalanceV2>>((balances) => balances
              .map<List<BalanceV2>>((MultiAddressBalance balance) =>
                  balance.entries.map<BalanceV2>((entry) {
                    return entry.utxo != null
                        ? UtxoBalance(
                            confirmed: true,
                            asset: balance.asset,
                            assetLongname: balance.assetInfo.assetLongname,
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

      print("before sequence");

      try {
        await $(TaskEither.sequenceList([confirmedTask, mempoolTask]));
      } catch (e, callstack) {
        print("e $e");
        print("callstack $callstack");
      }

      final result =
          await $(TaskEither.sequenceList([confirmedTask, mempoolTask]));

      print("before ");

      final confirmed = result[0] as List<BalanceV2>;
      final mempoolEvents = result[1] as List<VerboseEvent>;

      print("after ");

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
