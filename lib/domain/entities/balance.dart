import 'package:horizon/domain/entities/asset_info.dart';

class Balance {
  final String? address;
  final int quantity;
  final String quantityNormalized;
  final String? utxo;
  final String? utxoAddress;
  final String asset;
  final AssetInfo assetInfo;

  Balance(
      {required this.address,
      required this.quantity,
      required this.asset,
      required this.assetInfo,
      required this.quantityNormalized,
      this.utxo,
      this.utxoAddress});
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
