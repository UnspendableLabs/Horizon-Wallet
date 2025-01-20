import 'package:horizon/domain/entities/asset_info.dart';
import "./compose_response.dart";
import "./compose_fn.dart";

class ComposeSendParams extends ComposeParams {
  final String source;
  final String destination;
  final String asset;
  final int quantity;

  ComposeSendParams({
    required this.source,
    required this.destination,
    required this.asset,
    required this.quantity,
  });

  @override
  List<Object> get props => [
        source,
        destination,
        asset,
        quantity,
      ];
}

class ComposeSendResponseParams {
  final String source;
  final String destination;
  final String asset;
  final int quantity;
  final bool useEnhancedSend;
  final AssetInfo assetInfo;
  final String quantityNormalized;

  ComposeSendResponseParams(
      {required this.source,
      required this.destination,
      required this.asset,
      required this.quantity,
      required this.useEnhancedSend,
      required this.assetInfo,
      required this.quantityNormalized});
}

class ComposeSendResponse extends ComposeResponse {
  @override
  final String rawtransaction;
  @override
  final int btcFee;
  @override
  final SignedTxEstimatedSize signedTxEstimatedSize;
  final ComposeSendResponseParams params;
  final String name;

  ComposeSendResponse({
    required this.rawtransaction,
    required this.params,
    required this.name,
    required this.btcFee,
    required this.signedTxEstimatedSize,
  });
}
