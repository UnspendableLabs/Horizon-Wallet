import 'package:horizon/domain/entities/asset_info.dart';

class Send {
  final int txIndex;
  final String txHash;
  final int blockIndex;
  final String source;
  final String destination;
  final String asset;
  final int quantity;
  final String status;
  final int msgIndex;
  final String? memo;
  final AssetInfo assetInfo;
  final String quantityNormalized;

  const Send({
    required this.txIndex,
    required this.txHash,
    required this.blockIndex,
    required this.source,
    required this.destination,
    required this.asset,
    required this.quantity,
    required this.status,
    required this.msgIndex,
    this.memo,
    required this.assetInfo,
    required this.quantityNormalized,
  });
}
