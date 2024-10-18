// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fairminter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FairminterModel _$FairminterModelFromJson(Map<String, dynamic> json) =>
    FairminterModel(
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      blockIndex: (json['block_index'] as num?)?.toInt(),
      source: json['source'] as String,
      asset: json['asset'] as String,
      assetParent: json['asset_parent'] as String?,
      assetLongname: json['asset_longname'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toInt(),
      quantityByPrice: (json['quantity_by_price'] as num).toInt(),
      hardCap: (json['hard_cap'] as num).toInt(),
      burnPayment: json['burn_payment'] as bool?,
      maxMintPerTx: (json['max_mint_per_tx'] as num).toInt(),
      premintQuantity: (json['premint_quantity'] as num).toInt(),
      startBlock: (json['start_block'] as num).toInt(),
      endBlock: (json['end_block'] as num).toInt(),
      mintedAssetCommissionInt:
          (json['minted_asset_commission_int'] as num).toInt(),
      softCap: (json['soft_cap'] as num).toInt(),
      softCapDeadlineBlock: (json['soft_cap_deadline_block'] as num).toInt(),
      lockDescription: json['lock_description'] as bool?,
      lockQuantity: json['lock_quantity'] as bool?,
      divisible: json['divisible'] as bool?,
      preMinted: json['pre_minted'] as bool?,
      status: json['status'] as String?,
      earnedQuantity: (json['earned_quantity'] as num?)?.toInt(),
      commission: (json['commission'] as num?)?.toInt(),
      paidQuantity: (json['paid_quantity'] as num).toInt(),
      confirmed: json['confirmed'] as bool?,
      blockTime: (json['block_time'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FairminterModelToJson(FairminterModel instance) =>
    <String, dynamic>{
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'block_index': instance.blockIndex,
      'source': instance.source,
      'asset': instance.asset,
      'asset_parent': instance.assetParent,
      'asset_longname': instance.assetLongname,
      'description': instance.description,
      'price': instance.price,
      'quantity_by_price': instance.quantityByPrice,
      'hard_cap': instance.hardCap,
      'burn_payment': instance.burnPayment,
      'max_mint_per_tx': instance.maxMintPerTx,
      'premint_quantity': instance.premintQuantity,
      'start_block': instance.startBlock,
      'end_block': instance.endBlock,
      'minted_asset_commission_int': instance.mintedAssetCommissionInt,
      'soft_cap': instance.softCap,
      'soft_cap_deadline_block': instance.softCapDeadlineBlock,
      'lock_description': instance.lockDescription,
      'lock_quantity': instance.lockQuantity,
      'divisible': instance.divisible,
      'pre_minted': instance.preMinted,
      'status': instance.status,
      'earned_quantity': instance.earnedQuantity,
      'commission': instance.commission,
      'paid_quantity': instance.paidQuantity,
      'confirmed': instance.confirmed,
      'block_time': instance.blockTime,
    };
