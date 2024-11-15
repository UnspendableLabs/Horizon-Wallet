// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      txIndex: (json['tx_index'] as num?)?.toInt(),
      txHash: json['tx_hash'] as String,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      source: json['source'] as String,
      giveAsset: json['give_asset'] as String,
      giveQuantity: (json['give_quantity'] as num).toInt(),
      giveRemaining: (json['give_remaining'] as num).toInt(),
      getAsset: json['get_asset'] as String,
      getQuantity: (json['get_quantity'] as num).toInt(),
      getRemaining: (json['get_remaining'] as num).toInt(),
      expiration: (json['expiration'] as num).toInt(),
      expireIndex: (json['expire_index'] as num).toInt(),
      feeRequired: (json['fee_required'] as num).toInt(),
      feeRequiredRemaining: (json['fee_required_remaining'] as num).toInt(),
      feeProvided: (json['fee_provided'] as num).toInt(),
      feeProvidedRemaining: (json['fee_provided_remaining'] as num).toInt(),
      status: json['status'] as String,
      givePrice: (json['give_price'] as num).toInt(),
      getPrice: (json['get_price'] as num).toInt(),
      confirmed: json['confirmed'] as bool,
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'tx_index': instance.txIndex,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'source': instance.source,
      'give_asset': instance.giveAsset,
      'give_quantity': instance.giveQuantity,
      'give_remaining': instance.giveRemaining,
      'get_asset': instance.getAsset,
      'get_quantity': instance.getQuantity,
      'get_remaining': instance.getRemaining,
      'expiration': instance.expiration,
      'expire_index': instance.expireIndex,
      'fee_required': instance.feeRequired,
      'fee_required_remaining': instance.feeRequiredRemaining,
      'fee_provided': instance.feeProvided,
      'fee_provided_remaining': instance.feeProvidedRemaining,
      'status': instance.status,
      'give_price': instance.givePrice,
      'get_price': instance.getPrice,
      'confirmed': instance.confirmed,
    };

OrderVerbose _$OrderVerboseFromJson(Map<String, dynamic> json) => OrderVerbose(
      txIndex: (json['tx_index'] as num?)?.toInt(),
      txHash: json['tx_hash'] as String,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      source: json['source'] as String,
      giveAsset: json['give_asset'] as String,
      giveQuantity: (json['give_quantity'] as num).toInt(),
      giveRemaining: (json['give_remaining'] as num).toInt(),
      getAsset: json['get_asset'] as String,
      getQuantity: (json['get_quantity'] as num).toInt(),
      getRemaining: (json['get_remaining'] as num).toInt(),
      expiration: (json['expiration'] as num).toInt(),
      expireIndex: (json['expire_index'] as num).toInt(),
      feeRequired: (json['fee_required'] as num).toInt(),
      feeRequiredRemaining: (json['fee_required_remaining'] as num).toInt(),
      feeProvided: (json['fee_provided'] as num).toInt(),
      feeProvidedRemaining: (json['fee_provided_remaining'] as num).toInt(),
      status: json['status'] as String,
      givePrice: (json['give_price'] as num).toInt(),
      getPrice: (json['get_price'] as num).toInt(),
      confirmed: json['confirmed'] as bool,
      giveQuantityNormalized: json['give_quantity_normalized'] as String,
      getQuantityNormalized: json['get_quantity_normalized'] as String,
      getRemainingNormalized: json['get_remaining_normalized'] as String,
      giveRemainingNormalized: json['give_remaining_normalized'] as String,
      feeProvidedNormalized: json['fee_provided_normalized'] as String,
      feeRequiredNormalized: json['fee_required_normalized'] as String,
      feeRequiredRemainingNormalized:
          json['fee_required_remaining_normalized'] as String,
      feeProvidedRemainingNormalized:
          json['fee_provided_remaining_normalized'] as String,
      givePriceNormalized: json['give_price_normalized'] as String,
      getPriceNormalized: json['get_price_normalized'] as String,
    );

Map<String, dynamic> _$OrderVerboseToJson(OrderVerbose instance) =>
    <String, dynamic>{
      'tx_index': instance.txIndex,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'source': instance.source,
      'give_asset': instance.giveAsset,
      'give_quantity': instance.giveQuantity,
      'give_remaining': instance.giveRemaining,
      'get_asset': instance.getAsset,
      'get_quantity': instance.getQuantity,
      'get_remaining': instance.getRemaining,
      'expiration': instance.expiration,
      'expire_index': instance.expireIndex,
      'fee_required': instance.feeRequired,
      'fee_required_remaining': instance.feeRequiredRemaining,
      'fee_provided': instance.feeProvided,
      'fee_provided_remaining': instance.feeProvidedRemaining,
      'status': instance.status,
      'give_price': instance.givePrice,
      'get_price': instance.getPrice,
      'confirmed': instance.confirmed,
      'give_quantity_normalized': instance.giveQuantityNormalized,
      'get_quantity_normalized': instance.getQuantityNormalized,
      'get_remaining_normalized': instance.getRemainingNormalized,
      'give_remaining_normalized': instance.giveRemainingNormalized,
      'fee_provided_normalized': instance.feeProvidedNormalized,
      'fee_required_normalized': instance.feeRequiredNormalized,
      'fee_required_remaining_normalized':
          instance.feeRequiredRemainingNormalized,
      'fee_provided_remaining_normalized':
          instance.feeProvidedRemainingNormalized,
      'give_price_normalized': instance.givePriceNormalized,
      'get_price_normalized': instance.getPriceNormalized,
    };
