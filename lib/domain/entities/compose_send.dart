import 'package:horizon/domain/entities/asset_info.dart';

class ComposeSendParams {
  final String source;
  final String destination;
  final String asset;
  final double quantity;
  final bool useEnhancedSend;
  final AssetInfo assetInfo;
  final String quantityNormalized;

  const ComposeSendParams({
    required this.source,
    required this.destination,
    required this.asset,
    required this.quantity,
    required this.useEnhancedSend,
    required this.assetInfo,
    required this.quantityNormalized,
  });
}

class ComposeSend {
  final String rawtransaction;
  final ComposeSendParams params;
  final String name;

  const ComposeSend({
    required this.rawtransaction,
    required this.params,
    required this.name,
  });
}
