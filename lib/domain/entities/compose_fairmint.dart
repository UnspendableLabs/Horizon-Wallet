import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/domain/entities/compose_response.dart';

class ComposeFairmintParams extends ComposeParams {
  final String source;
  final String asset;
  final int? quantity;
  final AssetInfo? assetInfo;
  final String? quantityNormalized;

  ComposeFairmintParams({
    required this.source,
    required this.asset,
    this.quantity,
    this.assetInfo,
    this.quantityNormalized,
  });

  @override
  List<Object> get props => [
        source,
        asset,
      ];
}

class ComposeFairmintResponse extends ComposeResponse {
  final ComposeFairmintParams params;
  final String name;
  final String data;
  final int btcIn;
  final int btcOut;
  final int btcChange;
  final int btcFee;
  @override
  final String rawtransaction;

  ComposeFairmintResponse({
    required this.params,
    required this.name,
    required this.data,
    required this.btcIn,
    required this.btcOut,
    required this.btcChange,
    required this.btcFee,
    required this.rawtransaction,
  });
}