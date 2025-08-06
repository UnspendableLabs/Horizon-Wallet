// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_fairminter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeFairminterVerboseModel _$ComposeFairminterVerboseModelFromJson(
        Map<String, dynamic> json) =>
    ComposeFairminterVerboseModel(
      rawtransaction: json['rawtransaction'] as String,
      psbt: json['psbt'] as String,
      params: ComposeFairminterVerboseParamsModel.fromJson(
          json['params'] as Map<String, dynamic>),
      name: json['name'] as String,
      btcIn: (json['btc_in'] as num).toInt(),
      btcOut: (json['btc_out'] as num).toInt(),
      btcChange: (json['btc_change'] as num?)?.toInt(),
      btcFee: (json['btc_fee'] as num).toInt(),
      data: json['data'] as String,
      signedTxEstimatedSize: SignedTxEstimatedSizeModel.fromJson(
          json['signed_tx_estimated_size'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ComposeFairminterVerboseModelToJson(
        ComposeFairminterVerboseModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'data': instance.data,
      'btc_in': instance.btcIn,
      'btc_out': instance.btcOut,
      'btc_change': instance.btcChange,
      'btc_fee': instance.btcFee,
      'rawtransaction': instance.rawtransaction,
      'psbt': instance.psbt,
      'params': instance.params,
      'signed_tx_estimated_size': instance.signedTxEstimatedSize,
    };

ComposeFairminterVerboseParamsModel
    _$ComposeFairminterVerboseParamsModelFromJson(Map<String, dynamic> json) =>
        ComposeFairminterVerboseParamsModel(
          source: json['source'] as String,
          asset: json['asset'] as String,
          assetParent: json['asset_parent'] as String?,
          price: (json['price'] as num?)?.toInt(),
          quantityByPrice: (json['quantity_by_price'] as num?)?.toInt(),
          maxMintPerTx: (json['max_mint_per_tx'] as num?)?.toInt(),
          hardCap: (json['hard_cap'] as num?)?.toInt(),
          premintQuantity: (json['premint_quantity'] as num?)?.toInt(),
          startBlock: (json['start_block'] as num?)?.toInt(),
          endBlock: (json['end_block'] as num?)?.toInt(),
          softCap: (json['soft_cap'] as num?)?.toInt(),
          softCapDeadlineBlock:
              (json['soft_cap_deadline_block'] as num?)?.toInt(),
          mintedAssetCommission:
              (json['minted_asset_commission'] as num?)?.toInt(),
          burnPayment: json['burn_payment'] as bool?,
          lockDescription: json['lock_description'] as bool?,
          lockQuantity: json['lock_quantity'] as bool?,
          divisible: json['divisible'] as bool?,
          description: json['description'] as String?,
          maxMintPerTxNormalized: json['max_mint_per_tx_normalized'] as String?,
          hardCapNormalized: json['hard_cap_normalized'] as String?,
        );

Map<String, dynamic> _$ComposeFairminterVerboseParamsModelToJson(
        ComposeFairminterVerboseParamsModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'asset': instance.asset,
      'asset_parent': instance.assetParent,
      'price': instance.price,
      'quantity_by_price': instance.quantityByPrice,
      'max_mint_per_tx': instance.maxMintPerTx,
      'hard_cap': instance.hardCap,
      'premint_quantity': instance.premintQuantity,
      'start_block': instance.startBlock,
      'end_block': instance.endBlock,
      'soft_cap': instance.softCap,
      'soft_cap_deadline_block': instance.softCapDeadlineBlock,
      'minted_asset_commission': instance.mintedAssetCommission,
      'burn_payment': instance.burnPayment,
      'lock_description': instance.lockDescription,
      'lock_quantity': instance.lockQuantity,
      'divisible': instance.divisible,
      'description': instance.description,
      'max_mint_per_tx_normalized': instance.maxMintPerTxNormalized,
      'hard_cap_normalized': instance.hardCapNormalized,
    };
