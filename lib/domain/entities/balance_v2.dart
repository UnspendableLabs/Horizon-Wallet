import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/utxo.dart';

sealed class BalanceV2 {
  final bool confirmed;
  final String asset;
  final String? assetLongname;
  final String address;
  final AssetQuantity quantity;

  BalanceV2(
      {required this.confirmed,
      required this.asset,
      this.assetLongname,
      required this.address,
      required this.quantity});
}

class AddressBalance extends BalanceV2 {
  AddressBalance(
      {required super.confirmed,
      required super.asset,
      super.assetLongname,
      required super.address,
      required super.quantity});
}

class UtxoBalance extends BalanceV2 {
  final UtxoID utxoId;

  UtxoBalance({
    required this.utxoId,
    required super.asset,
    super.assetLongname,
    required super.address,
    required super.quantity,
    required super.confirmed,
  });
}

// class UtxoBalance {
//   final bool confirmed;
//   final String asset;
//   final String? assetLongname;
//   final String address;
//   final AssetQuantity quantity;
//   final UtxoID utxoId;
//
//   const UtxoBalance({
//     required this.confirmed,
//     required this.asset,
//     this.assetLongname,
//     required this.address,
//     required this.quantity,
//     required this.utxoId,
//   });
//
//   @override
//   String toString() {
//     return 'UtxoBalance{ confirmed: $confirmed, asset: $asset, assetLongname: $assetLongname, address: $address, quantity: $quantity, utxoId: $utxoId}';
//   }
// }
