import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/domain/entities/compose_response.dart';

class ComposeDestroyParams extends ComposeParams {
  final String source;
  final String asset;
  final int quantity;
  final String tag;
  ComposeDestroyParams({
    required this.source,
    required this.asset,
    required this.quantity,
    required this.tag,
  });

  @override
  List<Object> get props => [source, asset, quantity, tag];
}

class ComposeDestroyResponse implements ComposeResponse {
  @override
  final String rawtransaction;
  @override
  final int btcFee;
  final String? data;
  final String name;

  final ComposeDestroyResponseParams params;

  ComposeDestroyResponse({
    required this.rawtransaction,
    required this.btcFee,
    required this.data,
    required this.name,
    required this.params,
  });
}

class ComposeDestroyResponseParams {
  final String source;
  final String asset;
  final int quantity;
  final String quantityNormalized;
  final String tag;
  final bool skipValidation;
  final AssetInfo assetInfo;

  ComposeDestroyResponseParams({
    required this.source,
    required this.asset,
    required this.quantity,
    required this.quantityNormalized,
    required this.tag,
    required this.skipValidation,
    required this.assetInfo,
  });
}
