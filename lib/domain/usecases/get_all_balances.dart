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

// {
//         "asset": "A7863636638512758948",
//         "asset_longname": null,
//         "total": 10000000000,
//         "addresses": [
//             {
//                 "address": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//                 "utxo": null,
//                 "utxo_address": null,
//                 "quantity": 5000000000,
//                 "quantity_normalized": "50.00000000"
//             },
//             {
//                 "address": null,
//                 "utxo": "6697246a7d43951a37a35797d126020ff498465b3a0a6404b6b67e6aaf7bed39:0",
//                 "utxo_address": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//                 "quantity": 5000000000,
//                 "quantity_normalized": "50.00000000"
//             }
//         ],

// {
//   "result": [
//     {
//       "tx_hash": "02d6950c58fdd0f30eb04bc34bfc11c2054947ab5c2e2088bdb203799bde3183",
//       "event": "ATTACH_TO_UTXO",
//       "params": {
//         "asset": "A7863636638512758948",
//         "block_index": 9999999,
//         "destination": "02d6950c58fdd0f30eb04bc34bfc11c2054947ab5c2e2088bdb203799bde3183:0",
//         "destination_address": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//         "fee_paid": 0,
//         "msg_index": 0,
//         "quantity": 300000000,
//         "send_type": "attach",
//         "source": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//         "status": "valid",
//         "tx_hash": "02d6950c58fdd0f30eb04bc34bfc11c2054947ab5c2e2088bdb203799bde3183",
//         "tx_index": 3092541,
//         "asset_info": {
//           "asset_longname": null,
//           "description": "",
//           "issuer": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//           "divisible": true,
//           "locked": false,
//           "owner": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2"
//         },
//         "quantity_normalized": "3.00000000",
//         "fee_paid_normalized": "0.00000000"
//       },
//       "timestamp": 1759420050.81948
//     },
//     {
//       "tx_hash": "02d6950c58fdd0f30eb04bc34bfc11c2054947ab5c2e2088bdb203799bde3183",
//       "event": "DEBIT",
//       "params": {
//         "action": "attach to utxo",
//         "address": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//         "asset": "A7863636638512758948",
//         "block_index": 917390,
//         "event": "02d6950c58fdd0f30eb04bc34bfc11c2054947ab5c2e2088bdb203799bde3183",
//         "quantity": 300000000,
//         "tx_index": 3092541,
//         "utxo": null,
//         "utxo_address": null,
//         "block_time": 1759418255,
//         "asset_info": {
//           "asset_longname": null,
//           "description": "",
//           "issuer": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//           "divisible": true,
//           "locked": false,
//           "owner": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2"
//         },
//         "quantity_normalized": "3.00000000"
//       },
//       "timestamp": 1759420050.81948
//     },
//     {
//       "tx_hash": "02d6950c58fdd0f30eb04bc34bfc11c2054947ab5c2e2088bdb203799bde3183",
//       "event": "NEW_TRANSACTION",
//       "params": {
//         "block_hash": "mempool",
//         "block_index": 9999999,
//         "block_time": 1759420050.81948,
//         "btc_amount": 546,
//         "data": "6541373836333633363633383531323735383934387c3330303030303030307c",
//         "destination": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//         "fee": 768,
//         "source": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//         "transaction_type": "attach",
//         "tx_hash": "02d6950c58fdd0f30eb04bc34bfc11c2054947ab5c2e2088bdb203799bde3183",
//         "tx_index": 3092541,
//         "utxos_info": " 02d6950c58fdd0f30eb04bc34bfc11c2054947ab5c2e2088bdb203799bde3183:0 3 1",
//         "btc_amount_normalized": "0.00000546"
//       },
//       "timestamp": 1759420050.81948
//     },
//     {
//       "tx_hash": "7de5f2235eda2a7db4ec2b4b8367836d457910442c11e598f078db53d7be8b2e",
//       "event": "ATTACH_TO_UTXO",
//       "params": {
//         "asset": "A7863636638512758948",
//         "block_index": 9999999,
//         "destination": "7de5f2235eda2a7db4ec2b4b8367836d457910442c11e598f078db53d7be8b2e:0",
//         "destination_address": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//         "fee_paid": 0,
//         "msg_index": 0,
//         "quantity": 200000000,
//         "send_type": "attach",
//         "source": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//         "status": "valid",
//         "tx_hash": "7de5f2235eda2a7db4ec2b4b8367836d457910442c11e598f078db53d7be8b2e",
//         "tx_index": 3092538,
//         "asset_info": {
//           "asset_longname": null,
//           "description": "",
//           "issuer": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//           "divisible": true,
//           "locked": false,
//           "owner": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2"
//         },
//         "quantity_normalized": "2.00000000",
//         "fee_paid_normalized": "0.00000000"
//       },
//       "timestamp": 1759419788.29308
//     },
//     {
//       "tx_hash": "7de5f2235eda2a7db4ec2b4b8367836d457910442c11e598f078db53d7be8b2e",
//       "event": "DEBIT",
//       "params": {
//         "action": "attach to utxo",
//         "address": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//         "asset": "A7863636638512758948",
//         "block_index": 917390,
//         "event": "7de5f2235eda2a7db4ec2b4b8367836d457910442c11e598f078db53d7be8b2e",
//         "quantity": 200000000,
//         "tx_index": 3092538,
//         "utxo": null,
//         "utxo_address": null,
//         "block_time": 1759418255,
//         "asset_info": {
//           "asset_longname": null,
//           "description": "",
//           "issuer": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//           "divisible": true,
//           "locked": false,
//           "owner": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2"
//         },
//         "quantity_normalized": "2.00000000"
//       },
//       "timestamp": 1759419788.29308
//     },
//     {
//       "tx_hash": "7de5f2235eda2a7db4ec2b4b8367836d457910442c11e598f078db53d7be8b2e",
//       "event": "NEW_TRANSACTION",
//       "params": {
//         "block_hash": "mempool",
//         "block_index": 9999999,
//         "block_time": 1759419788.29308,
//         "btc_amount": 546,
//         "data": "6541373836333633363633383531323735383934387c3230303030303030307c",
//         "destination": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//         "fee": 384,
//         "source": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
//         "transaction_type": "attach",
//         "tx_hash": "7de5f2235eda2a7db4ec2b4b8367836d457910442c11e598f078db53d7be8b2e",
//         "tx_index": 3092538,
//         "utxos_info": " 7de5f2235eda2a7db4ec2b4b8367836d457910442c11e598f078db53d7be8b2e:0 3 1",
//         "btc_amount_normalized": "0.00000546"
//       },
//       "timestamp": 1759419788.29308
//     }
//   ],
//   "next_cursor": null,
//   "result_count": 6
// }
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

// balances_set_projection.dart

extension BalancesSetProjection on BalancesSet {
  List<BalanceV2> get projected {
    // ===== baseline state =====
    final Map<_Key, AssetQuantity> state = {};
    final Map<String, bool> assetDivisibility = {}; // asset -> divisible

    // NEW: utxoId string -> label address for display & lookups
    final Map<String, String> utxoAddressLabel = {};

    void _seed(BalanceV2 b) {
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
      if (b is UtxoBalance) {
        utxoAddressLabel[b.utxoId.toString()] = b.address;
      }
    }

    for (final b in confirmed) {
      _seed(b);
    }

    // ===== deltas =====
    final Map<_Key, BigInt> deltas = {};
    void _addDelta(_Key key, BigInt dq) {
      if (dq == BigInt.zero) return;
      deltas.update(key, (v) => v + dq, ifAbsent: () => dq);
    }

    // helpers
    bool _divisibleFor(String asset, {bool? fallback}) =>
        assetDivisibility[asset] ?? fallback ?? true;

    BigInt _rawFromNormalized(String normalized, bool divisible) {
      final d = Decimal.parse(normalized);
      if (!divisible) return BigInt.from(d.toBigInt().toInt());
      final scaled = d * TenToTheEigth.decimal; // 10^8
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

    BigInt _effectiveQty(_Key key) {
      final base = state[key]?.quantity ?? BigInt.zero;
      final d = deltas[key] ?? BigInt.zero;
      return base + d;
    }

    // ===== CREDIT / DEBIT (addr <-> addr sends only) =====
    for (final e in _mempoolData.credits) {
      final p = e.params;
      final dq = _chooseRaw(
        raw: BigInt.from(p.quantity),
        normalized: p.quantityNormalized,
        asset: p.asset,
      );
      _addDelta(_kAddr(p.asset, p.address), dq);
    }
    for (final e in _mempoolData.debits) {
      final p = e.params;
      final dq = _chooseRaw(
        raw: BigInt.from(p.quantity),
        normalized: p.quantityNormalized,
        asset: p.asset,
      );
      _addDelta(_kAddr(p.asset, p.address!), -dq);
    }

    // ===== ATTACH (credit UTXO only; DEBIT covers the address) =====
    for (final e in _mempoolData.attaches) {
      final p = e.params;
      final divisible = p.assetInfo.divisible;
      assetDivisibility[p.asset] = divisible;
      final dq = _chooseRaw(
        raw: BigInt.from(p.quantity),
        normalized: p.quantityNormalized,
        asset: p.asset,
        explicitDivisible: divisible,
      );

      final utxoId = UtxoID.fromString(p.destination); // "txid:vout"
      final utxoKey = _kUtxo(p.asset, utxoId);

      // we don’t have destination_address in your typedef, but your samples show it equals source
      utxoAddressLabel[_utxoIdStrFromKey(utxoKey)] = p.source;

      _addDelta(utxoKey, dq);
    }

    for (final e in _mempoolData.detaches) {
      final p = e.params;

      final dqReq = _chooseRaw(
        normalized: p.quantityNormalized, // DETACH has normalized
        asset: p.asset,
      );

      final utxoId = UtxoID.fromString(p.source);
      final utxoKey = _kUtxo(p.asset, utxoId); // <- SAME key shape as seed
      final available = (state[utxoKey]?.quantity ?? BigInt.zero) +
          (deltas[utxoKey] ?? BigInt.zero);
      final dq = dqReq <= available ? dqReq : available;
      if (dq == BigInt.zero) continue;

      _addDelta(utxoKey, -dq);
      _addDelta(_kAddr(p.asset, p.destination), dq);
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
      if (q.quantity == BigInt.zero) continue;

      if (_isAddrKey(key)) {
        out.add(AddressBalance(
          confirmed: true,
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
          confirmed: true,
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
