// import "./compose_response.dart";
import "package:horizon/domain/entities/asset_info.dart";
import "package:horizon/domain/entities/compose_response.dart";

import "./compose_fn.dart";

class ComposeAttachUtxoParams extends ComposeParams {
  final String address;
  final String asset;
  final int quantity;
  final int utxoValue;

  ComposeAttachUtxoParams({
    required this.address,
    required this.asset,
    required this.quantity,
    required this.utxoValue,
  });

  @override
  List<Object> get props => [address, asset, quantity];
}

class ComposeAttachUtxoResponse implements ComposeResponse {
  @override
  final String rawtransaction;
  @override
  final int btcFee;
  @override
  final SignedTxEstimatedSize signedTxEstimatedSize;
  final String data;
  final String name;

  final ComposeAttachUtxoResponseParams params;

  ComposeAttachUtxoResponse({
    required this.rawtransaction,
    required this.btcFee,
    required this.signedTxEstimatedSize,
    required this.data,
    required this.name,
    required this.params,
  });
}

class ComposeAttachUtxoResponseParams {
  final String source;
  final String asset;
  final int quantity;
  final String quantityNormalized;
  final String? destinationVout;
  final AssetInfo assetInfo;
  final int? utxoValue;
  ComposeAttachUtxoResponseParams(
      {required this.source,
      required this.asset,
      required this.quantity,
      required this.quantityNormalized,
      this.destinationVout,
      required this.assetInfo,
      this.utxoValue});
}
