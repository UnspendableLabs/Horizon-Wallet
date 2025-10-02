import 'package:collection/collection.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:test/test.dart';

import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/balance_v2.dart';
import 'package:horizon/domain/entities/utxo.dart';

import 'package:horizon/domain/entities/event.dart';

import 'package:horizon/domain/usecases/get_all_balances.dart';

// ---------- helpers ----------

AssetQuantity qTen8(int whole, {bool divisible = true}) => AssetQuantity(
    divisible: divisible,
    quantity: BigInt.from(whole) * TenToTheEigth.bigIntValue);

UtxoBalance ub({
  required String asset,
  required String utxo, // "txid:vout"
  required String address,
  required AssetQuantity q,
  String? assetLongname,
}) =>
    UtxoBalance(
      confirmed: true,
      asset: asset,
      assetLongname: assetLongname,
      utxoId: UtxoID.fromString(utxo),
      address: address,
      quantity: q,
    );

AddressBalance ab({
  required String asset,
  required String address,
  required AssetQuantity q,
  String? assetLongname,
}) =>
    AddressBalance(
      confirmed: true,
      asset: asset,
      assetLongname: assetLongname,
      address: address,
      quantity: q,
    );

// A tiny factory to make a "mempool" verbose event envelope with minimal noise.
T _memVerbose<T extends VerboseEvent>({
  required T Function({
    required EventState state,
    required int? eventIndex,
    required String event,
    required String? txHash,
    required int? blockIndex,
    required int? blockTime,
  }) ctorShell,
  required T fill(T shell),
}) {
  final shell = ctorShell(
    state: EventStateMempool(),
    eventIndex: 0,
    event: 'MEMPOOL',
    txHash: 'tx',
    blockIndex: 9999999,
    blockTime: 0,
  );
  return fill(shell);
}

// You provided VerboseAttachToUtxoEvent with VerboseAttachToUtxoParams,
// which requires an AssetInfo. If your AssetInfo has a different ctor,
// tweak this builder accordingly.
AssetInfo _dummyAssetInfo({required bool divisible}) => AssetInfo(
      assetLongname: null,
      description: '',
      issuer: 'issuer',
      divisible: divisible,
      locked: false,
      owner: 'owner',
    );

VerboseAttachToUtxoEvent attachEvt({
  required String txHash,
  required int txIndex,
  required String asset,
  required bool divisible,
  required String source, // address
  required String destination, // "txid:vout"
  required int rawQty, // e.g. 300000000 for 3.0
  required String normalizedQty, // "3.00000000"
}) {
  return VerboseAttachToUtxoEvent(
    state: EventStateMempool(),
    eventIndex: 0,
    event: 'ATTACH_TO_UTXO',
    txHash: txHash,
    blockIndex: 9999999,
    blockTime: 0,
    params: VerboseAttachToUtxoParams(
      asset: asset,
      blockIndex: 9999999,
      destination: destination,
      feePaid: 0,
      source: source,
      quantity: rawQty,
      assetInfo: _dummyAssetInfo(divisible: divisible),
      quantityNormalized: normalizedQty,
      feePaidNormalized: '0.00000000',
    ),
  );
}

VerboseDebitEvent debitEvt({
  required String txHash,
  required int txIndex,
  required String asset,
  required String address,
  required int rawQty,
  required String normalizedQty,
  String action = 'attach to utxo',
}) {
  return VerboseDebitEvent(
    state: EventStateMempool(),
    eventIndex: 0,
    event: 'DEBIT',
    txHash: txHash,
    blockIndex: 9999999,
    blockTime: 0,
    params: VerboseDebitParams(
      action: action,
      address: address,
      asset: asset,
      blockIndex: 9999999,
      event: txHash,
      quantity: rawQty,
      txIndex: txIndex,
      blockTime: 0,
      quantityNormalized: normalizedQty,
    ),
  );
}

VerboseDetachFromUtxoEvent detachEvt({
  required String txHash,
  required String asset,
  required String sourceUtxo, // "txid:vout"
  required String destAddress, // credit address
  required String normalizedQty, // e.g. "4.00000000"
}) {
  return VerboseDetachFromUtxoEvent(
    state: EventStateMempool(),
    eventIndex: 0,
    event: 'DETACH_FROM_UTXO',
    txHash: txHash,
    blockIndex: 9999999,
    blockTime: 0,
    params: VerboseDetachFromUtxoParams(
      source: sourceUtxo,
      asset: asset,
      blockIndex: 9999999,
      destination: destAddress,
      feePaid: 0,
      quantityNormalized: normalizedQty,
      feePaidNormalized: '0.00000000',
    ),
  );
}

// ---------- tests ----------

void main() {
  group('BalancesSet.projected – ATTACH credit-only (DEBIT provides the debit)',
      () {
    const asset = 'A7863636638512758948';
    const addr = 'bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2';
    const utxo0 =
        '6697246a7d43951a37a35797d126020ff498465b3a0a6404b6b67e6aaf7bed39:0';
    const utxoA =
        '02d6950c58fdd0f30eb04bc34bfc11c2054947ab5c2e2088bdb203799bde3183:0';
    const utxoB =
        '7de5f2235eda2a7db4ec2b4b8367836d457910442c11e598f078db53d7be8b2e:0';

    test('Address ends at 45, utxo0 stays 50, new UTXOs +3 and +2; totals 100',
        () {
      // Confirmed snapshot: Address 50, UTXO0 50
      final confirmed = <BalanceV2>[
        ab(asset: asset, address: addr, q: qTen8(50)),
        ub(asset: asset, address: addr, utxo: utxo0, q: qTen8(50)),
      ];

      // Two attaches: +3 to utxoA, +2 to utxoB (credit-only here)
      final attaches = <VerboseAttachToUtxoEvent>[
        attachEvt(
          txHash: 'txA',
          txIndex: 3092541,
          asset: asset,
          divisible: true,
          source: addr,
          destination: utxoA,
          rawQty: 300000000,
          normalizedQty: '3.00000000',
        ),
        attachEvt(
          txHash: 'txB',
          txIndex: 3092538,
          asset: asset,
          divisible: true,
          source: addr,
          destination: utxoB,
          rawQty: 200000000,
          normalizedQty: '2.00000000',
        ),
      ];

      // Paired debits from the address
      final debits = <VerboseDebitEvent>[
        debitEvt(
          txHash: 'txA',
          txIndex: 3092541,
          asset: asset,
          address: addr,
          rawQty: 300000000,
          normalizedQty: '3.00000000',
        ),
        debitEvt(
          txHash: 'txB',
          txIndex: 3092538,
          asset: asset,
          address: addr,
          rawQty: 200000000,
          normalizedQty: '2.00000000',
        ),
      ];

      final mempool = BalancesSetMempoolData(
        attaches: attaches,
        detaches: const [],
        moves: const [],
        credits: const [],
        debits: debits,
      );

      final set = BalancesSet(confirmed: confirmed, mempoolData: mempool);
      final out = set.projected;

      BigInt amt(String? utxo) {
        if (utxo == null) {
          return out
              .whereType<AddressBalance>()
              .firstWhere((b) => b.address == addr)
              .quantity
              .quantity;
        }
        return out
            .whereType<UtxoBalance>()
            .firstWhere((b) => b.utxoId.toString() == utxo)
            .quantity
            .quantity;
      }

      UtxoBalance getUtxoBalance(String utxo) {
        return out
            .whereType<UtxoBalance>()
            .firstWhere((b) => b.address == addr);
      }

      expect(amt(null),
          equals(BigInt.from(45) * TenToTheEigth.bigIntValue)); // 50 - 3 - 2
      expect(amt(utxo0),
          equals(BigInt.from(50) * TenToTheEigth.bigIntValue)); // unchanged
      expect(
          amt(utxoA), equals(BigInt.from(3) * TenToTheEigth.bigIntValue)); // +3
      expect(
          amt(utxoB), equals(BigInt.from(2) * TenToTheEigth.bigIntValue)); // +2

      expect(getUtxoBalance(utxoA).confirmed, isFalse);
      expect(getUtxoBalance(utxoB).confirmed, isFalse);

      final total =
          out.fold<BigInt>(BigInt.zero, (acc, b) => acc + b.quantity.quantity);
      expect(total, equals(BigInt.from(100) * TenToTheEigth.bigIntValue));
    });

    test('Guardrail: catch double-debit if ATTACH loop reintroduces a debit',
        () {
      final confirmed = <BalanceV2>[
        ab(asset: asset, address: addr, q: qTen8(50)),
        ub(asset: asset, address: addr, utxo: utxo0, q: qTen8(50)),
      ];

      final attaches = <VerboseAttachToUtxoEvent>[
        attachEvt(
          txHash: 'txA',
          txIndex: 111,
          asset: asset,
          divisible: true,
          source: addr,
          destination: utxoA,
          rawQty: 300000000,
          normalizedQty: '3.00000000',
        ),
      ];

      final debits = <VerboseDebitEvent>[
        debitEvt(
          txHash: 'txA',
          txIndex: 111,
          asset: asset,
          address: addr,
          rawQty: 300000000,
          normalizedQty: '3.00000000',
        ),
      ];

      final mempool = BalancesSetMempoolData(
        attaches: attaches,
        detaches: const [],
        moves: const [],
        credits: const [],
        debits: debits,
      );

      final set = BalancesSet(confirmed: confirmed, mempoolData: mempool);
      final out = set.projected;

      final addrQty = out
          .whereType<AddressBalance>()
          .firstWhere((b) => b.address == addr)
          .quantity
          .quantity;

      expect(
          addrQty, isNot(equals(BigInt.from(44) * TenToTheEigth.bigIntValue)));
    });
  });

  group('BalancesSet.projected – DETACH (utxo -> addr)', () {
    const asset = 'A1';
    const addr = 'bc1x';
    const utxo0 = 'tx0:0';

    test('Debits UTXO, credits address, totals preserved', () {
      final confirmed = <BalanceV2>[
        ub(
            asset: asset,
            address: addr,
            utxo: utxo0,
            q: AssetQuantity(
                divisible: true,
                quantity: BigInt.from(10) * TenToTheEigth.bigIntValue)),
      ];

      final detaches = <VerboseDetachFromUtxoEvent>[
        detachEvt(
          txHash: 'txD',
          asset: asset,
          sourceUtxo: utxo0,
          destAddress: addr,
          normalizedQty: "10.00000000",
        ),
      ];

      final mempool = BalancesSetMempoolData(
        attaches: const [],
        detaches: detaches,
        moves: const [],
        credits: const [],
        debits: const [],
      );

      final set = BalancesSet(confirmed: confirmed, mempoolData: mempool);

      final out = set.projected;

      final utxoQty = out
          .whereType<UtxoBalance>()
          .firstWhereOrNull((b) => b.utxoId.toString() == utxo0);
      final addrQty = out
          .whereType<AddressBalance>()
          .firstWhere((b) => b.address == addr)
          .quantity
          .quantity;

      expect(utxoQty, null);
      expect(addrQty, equals(BigInt.from(10) * TenToTheEigth.bigIntValue));

      final total =
          out.fold<BigInt>(BigInt.zero, (acc, b) => acc + b.quantity.quantity);
      expect(total, equals(BigInt.from(10) * TenToTheEigth.bigIntValue));
    });
  });

  group('BalancesSet.projected – pure SEND (addr -> addr) via CREDIT/DEBIT',
      () {
    const asset = 'A2';
    const a1 = 'bc1a';
    const a2 = 'bc1b';

    test('Address A1 -5, Address A2 +5, totals preserved', () {
      final confirmed = <BalanceV2>[
        ab(asset: asset, address: a1, q: qTen8(12)),
        ab(asset: asset, address: a2, q: qTen8(8)),
      ];

      final credits = <VerboseCreditEvent>[
        VerboseCreditEvent(
          state: EventStateMempool(),
          eventIndex: 0,
          event: 'CREDIT',
          txHash: 'txS',
          blockIndex: 9999999,
          blockTime: 0,
          params: VerboseCreditParams(
            address: a2,
            asset: asset,
            blockIndex: 9999999,
            callingFunction: 'send',
            event: 'txS',
            quantity: (BigInt.from(5) * TenToTheEigth.bigIntValue).toInt(),
            txIndex: 1,
            blockTime: 0,
            quantityNormalized: '5.00000000',
          ),
        ),
      ];
      final debits = <VerboseDebitEvent>[
        VerboseDebitEvent(
          state: EventStateMempool(),
          eventIndex: 0,
          event: 'DEBIT',
          txHash: 'txS',
          blockIndex: 9999999,
          blockTime: 0,
          params: VerboseDebitParams(
            action: 'send',
            address: a1,
            asset: asset,
            blockIndex: 9999999,
            event: 'txS',
            quantity: (BigInt.from(5) * TenToTheEigth.bigIntValue).toInt(),
            txIndex: 1,
            blockTime: 0,
            quantityNormalized: '5.00000000',
          ),
        ),
      ];

      final mempool = BalancesSetMempoolData(
        attaches: const [],
        detaches: const [],
        moves: const [],
        credits: credits,
        debits: debits,
      );

      final set = BalancesSet(confirmed: confirmed, mempoolData: mempool);
      final out = set.projected;

      BigInt bal(String adr) => out
          .whereType<AddressBalance>()
          .firstWhere((b) => b.address == adr)
          .quantity
          .quantity;

      expect(bal(a1), equals(BigInt.from(7) * TenToTheEigth.bigIntValue));
      expect(bal(a2), equals(BigInt.from(13) * TenToTheEigth.bigIntValue));

      final total =
          out.fold<BigInt>(BigInt.zero, (acc, b) => acc + b.quantity.quantity);
      expect(total, equals(BigInt.from(20) * TenToTheEigth.bigIntValue));
    });
  });
}
