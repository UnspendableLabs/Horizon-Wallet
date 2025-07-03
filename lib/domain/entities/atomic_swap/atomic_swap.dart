import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/utxo.dart';

class AtomicSwap {
  final String id;

  final String sellerAddress;

  final String assetName;
  final AssetQuantity assetQuantity;
  final AssetQuantity price;
  final AssetQuantity pricePerUnit;
  final int assetUtxoValue;
  final UtxoID assetUtxoId;
  final bool pendingSales;

  AtomicSwap(
      {required this.id,
      required this.sellerAddress,
      required this.assetName,
      required this.assetQuantity,
      required this.price,
      required this.pricePerUnit,
      required this.assetUtxoValue,
      required this.assetUtxoId, 
      required this.pendingSales});

  @override
  String toString() {
    return 'AtomicSwap('
        'id: $id'
        'sellerAddress: $sellerAddress, '
        'assetName: $assetName, '
        'assetQuantity: $assetQuantity, '
        'price: $price, '
        'pricePerUnit: $pricePerUnit'
        'assetUtxoValue: $assetUtxoValue, '
        'assetUtxoId: $assetUtxoId'
        'pendingSales: $pendingSales'
        ')';
  }
}
