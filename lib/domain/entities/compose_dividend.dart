import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/dividend_asset_info.dart';

class ComposeDividendParams extends ComposeParams {
  final String source;
  final String asset;
  final int quantityPerUnit;
  final String dividendAsset;

  ComposeDividendParams({
    required this.source,
    required this.asset,
    required this.quantityPerUnit,
    required this.dividendAsset,
  });

  @override
  List<Object> get props => [source, asset, quantityPerUnit, dividendAsset];
}

class ComposeDividendResponse implements ComposeResponse {
  @override
  final String psbt;
  @override
  final String rawtransaction;
  @override
  final int btcFee;
  @override
  final SignedTxEstimatedSize signedTxEstimatedSize;
  final String? data;
  final String name;

  final ComposeDividendResponseParams params;

  ComposeDividendResponse({
    required this.psbt,
    required this.rawtransaction,
    required this.btcFee,
    required this.data,
    required this.name,
    required this.params,
    required this.signedTxEstimatedSize,
  });
}

class ComposeDividendResponseParams {
  final String source;
  final String asset;
  final int quantityPerUnit;
  final String dividendAsset;
  final String quantityPerUnitNormalized;
  final DividendAssetInfo dividendAssetInfo;
  final AssetInfo assetInfo;

  ComposeDividendResponseParams({
    required this.source,
    required this.asset,
    required this.quantityPerUnit,
    required this.dividendAsset,
    required this.quantityPerUnitNormalized,
    required this.dividendAssetInfo,
    required this.assetInfo,
  });
}
