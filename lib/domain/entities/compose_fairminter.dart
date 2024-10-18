import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/domain/entities/compose_response.dart';

class ComposeFairminterParams extends ComposeParams {
  final String source;
  final String asset;
  final String? assetParent;
  final int? price;
  final int? quantityByPrice;
  final int? maxMintPerTx;
  final int? hardCap;
  final int? premintQuantity;
  final int? startBlock;
  final int? endBlock;
  final int? softCap;
  final int? softCapDeadlineBlock;
  final int? mintedAssetCommission;
  final bool? burnPayment;
  final bool? lockDescription;
  final bool? lockQuantity;
  final bool? divisible;
  final String? description;

  ComposeFairminterParams({
    required this.source,
    required this.asset,
    this.assetParent,
    this.price,
    this.quantityByPrice,
    this.maxMintPerTx,
    this.hardCap,
    this.premintQuantity,
    this.startBlock,
    this.endBlock,
    this.softCap,
    this.softCapDeadlineBlock,
    this.mintedAssetCommission,
    this.burnPayment,
    this.lockDescription,
    this.lockQuantity,
    this.divisible,
    this.description,
  });

  @override
  List<Object?> get props => [
        source,
        asset,
        assetParent,
        price,
        quantityByPrice,
        maxMintPerTx,
        hardCap,
      ];
}

class ComposeFairminterResponse extends ComposeResponse {
  final ComposeFairminterParams params;
  final String name;
  final String data;
  final int btcIn;
  final int btcOut;
  final int btcChange;
  final int btcFee;
  @override
  final String rawtransaction;

  ComposeFairminterResponse({
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
