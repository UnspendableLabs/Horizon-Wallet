// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispenser.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispenserModel _$DispenserModelFromJson(Map<String, dynamic> json) =>
    DispenserModel(
      txIndex: (json['tx_index'] as num).toInt(),
      txHash: json['tx_hash'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      source: json['source'] as String,
      asset: json['asset'] as String,
      giveQuantity: (json['give_quantity'] as num).toInt(),
      escrowQuantity: (json['escrow_quantity'] as num).toInt(),
      satoshirate: (json['satoshirate'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      giveRemaining: (json['give_remaining'] as num).toInt(),
      price: (json['price'] as num?)?.toInt(),
      oracleAddress: json['oracle_address'] as String?,
      lastStatusTxHash: json['last_status_tx_hash'] as String?,
      closeBlockIndex: json['close_block_index'] as String?,
      origin: json['origin'] as String,
      dispenseCount: (json['dispense_count'] as num).toInt(),
      lastStatusTxSource: json['last_status_tx_source'] as String?,
      confirmed: json['confirmed'] as bool?,
      blockTime: (json['block_time'] as num?)?.toInt(),
      giveQuantityNormalized: json['give_quantity_normalized'] as String,
      giveRemainingNormalized: json['give_remaining_normalized'] as String,
      escrowQuantityNormalized: json['escrow_quantity_normalized'] as String,
      satoshirateNormalized: json['satoshirate_normalized'] as String,
      satoshiPriceNormalized: json['satoshi_price_normalized'] as String?,
      priceNormalized: json['price_normalized'] as String?,
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DispenserModelToJson(DispenserModel instance) =>
    <String, dynamic>{
      'tx_index': instance.txIndex,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'source': instance.source,
      'asset': instance.asset,
      'give_quantity': instance.giveQuantity,
      'escrow_quantity': instance.escrowQuantity,
      'satoshirate': instance.satoshirate,
      'status': instance.status,
      'give_remaining': instance.giveRemaining,
      'price': instance.price,
      'oracle_address': instance.oracleAddress,
      'last_status_tx_hash': instance.lastStatusTxHash,
      'close_block_index': instance.closeBlockIndex,
      'origin': instance.origin,
      'dispense_count': instance.dispenseCount,
      'last_status_tx_source': instance.lastStatusTxSource,
      'confirmed': instance.confirmed,
      'block_time': instance.blockTime,
      'give_quantity_normalized': instance.giveQuantityNormalized,
      'give_remaining_normalized': instance.giveRemainingNormalized,
      'escrow_quantity_normalized': instance.escrowQuantityNormalized,
      'satoshirate_normalized': instance.satoshirateNormalized,
      'satoshi_price_normalized': instance.satoshiPriceNormalized,
      'price_normalized': instance.priceNormalized,
      'asset_info': instance.assetInfo,
    };
