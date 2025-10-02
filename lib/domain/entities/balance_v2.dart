import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/utxo.dart';

class AssetBalanceSummaryQuantity {
  final AssetQuantity mempool;
  final AssetQuantity confirmed;

  const AssetBalanceSummaryQuantity({
    required this.mempool,
    required this.confirmed,
  });

  AssetQuantity get total => mempool + confirmed;
}

class AssetBalanceSummary {
  final String asset;
  final String? assetLongname;
  final String? description;
  final AssetBalanceSummaryQuantity balance;
  final List<BalanceV2> balances;

  const AssetBalanceSummary(
      {required this.asset,
      this.assetLongname,
      required this.balance,
      required this.balances,
      this.description});

  @override
  String toString() {
    return 'AssetBalanceSummary{ asset: $asset, assetLongname: $assetLongname, balance: $balance, balances: $balances}';
  }
}

sealed class BalanceV2 {
  final bool confirmed;
  final String asset;
  final String? assetLongname;
  final String address;
  final AssetQuantity quantity;
  final String? description;

  BalanceV2(
      {required this.confirmed,
      required this.asset,
      this.description,
      this.assetLongname,
      required this.address,
      required this.quantity});

  @override
  String toString() {
    return 'BalanceV2{ confirmed: $confirmed, asset: $asset, assetLongname: $assetLongname, address: $address, quantity: $quantity}';
  }
}

class AddressBalance extends BalanceV2 {
  AddressBalance(
      {required super.confirmed,
      required super.asset,
      super.assetLongname,
      super.description,
      required super.address,
      required super.quantity});

  @override
  String toString() {
    return 'AddressBalance{ confirmed: $confirmed, asset: $asset, assetLongname: $assetLongname, address: $address, quantity: $quantity}';
  }
}

class UtxoBalance extends BalanceV2 {
  final UtxoID utxoId;

  UtxoBalance({
    required this.utxoId,
    required super.asset,
    super.assetLongname,
    super.description,
    required super.address,
    required super.quantity,
    required super.confirmed,
  });

  @override
  String toString() {
    return 'UtxoBalance{ confirmed: $confirmed, asset: $asset, assetLongname: $assetLongname, address: $address, quantity: $quantity, utxoId: $utxoId}';
  }
}

extension BalanceListSummaryX on List<BalanceV2> {
  List<AssetBalanceSummary> summarizeOrdered() {
    final out = summarize(); // reuse your existing logic

    final prioritized = ['BTC', 'XPC'];
    final ordered = <AssetBalanceSummary>[];

    for (final symbol in prioritized) {
      if (out.containsKey(symbol)) {
        ordered.add(out[symbol]!);
      }
    }

    final remaining = out.keys.where((k) => !prioritized.contains(k)).toList()
      ..sort();

    for (final k in remaining) {
      ordered.add(out[k]!);
    }

    return ordered;
  }

  Map<String, AssetBalanceSummary> summarize() {
    // First pass: gather per-asset metadata + sums.
    final assetLongname = <String, String?>{};
    final description = <String, String?>{};
    final confirmedSum = <String, AssetQuantity>{};
    final mempoolSum = <String, AssetQuantity>{};

    for (final b in this) {
      assetLongname.putIfAbsent(b.asset, () => b.assetLongname);
      description.putIfAbsent(b.asset, () => b.description);
      confirmedSum.putIfAbsent(
          b.asset, () => AssetQuantity.empty(divisible: b.quantity.divisible));
      mempoolSum.putIfAbsent(
          b.asset, () => AssetQuantity.empty(divisible: b.quantity.divisible));
      if (b.confirmed) {
        confirmedSum[b.asset] = (confirmedSum[b.asset]! + b.quantity);
      } else {
        mempoolSum[b.asset] = (mempoolSum[b.asset]! + b.quantity);
      }
    }

    // Second pass: attach the filtered rows per asset.
    final out = <String, AssetBalanceSummary>{};
    final rowsByAsset = <String, List<BalanceV2>>{};
    for (final b in this) {
      rowsByAsset.putIfAbsent(b.asset, () => <BalanceV2>[]).add(b);
    }

    for (final asset in rowsByAsset.keys) {
      final qty = AssetBalanceSummaryQuantity(
        confirmed: confirmedSum[asset]!,
        mempool: mempoolSum[asset]!,
      );
      out[asset] = AssetBalanceSummary(
        asset: asset,
        assetLongname: assetLongname[asset],
        balance: qty,
        balances: rowsByAsset[asset]!,
      );
    }

    return out;
  }
}
