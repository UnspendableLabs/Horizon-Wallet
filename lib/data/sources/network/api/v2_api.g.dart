// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response<T> _$ResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    Response<T>(
      result: _$nullableGenericFromJson(json['result'], fromJsonT),
      error: json['error'] as String?,
      nextCursor: json['next_cursor'] == null
          ? null
          : CursorModel.fromJson(json['next_cursor']),
      resultCount: (json['result_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ResponseToJson<T>(
  Response<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'result': _$nullableGenericToJson(instance.result, toJsonT),
      'next_cursor': instance.nextCursor,
      'result_count': instance.resultCount,
      'error': instance.error,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

Block _$BlockFromJson(Map<String, dynamic> json) => Block(
      blockIndex: (json['block_index'] as num).toInt(),
      blockTime: DateTime.parse(json['block_time'] as String),
      blockHash: json['block_hash'] as String,
      previousBlockHash: json['previous_block_hash'] as String,
      difficulty: (json['difficulty'] as num).toDouble(),
      ledgerHash: json['ledger_hash'] as String,
      txlistHash: json['txlist_hash'] as String,
      messagesHash: json['messages_hash'] as String,
    );

Map<String, dynamic> _$BlockToJson(Block instance) => <String, dynamic>{
      'block_index': instance.blockIndex,
      'block_hash': instance.blockHash,
      'block_time': instance.blockTime.toIso8601String(),
      'previous_block_hash': instance.previousBlockHash,
      'difficulty': instance.difficulty,
      'ledger_hash': instance.ledgerHash,
      'txlist_hash': instance.txlistHash,
      'messages_hash': instance.messagesHash,
    };

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num?)?.toInt(),
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockHash: json['block_hash'] as String?,
      blockTime: (json['block_time'] as num?)?.toInt(),
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num).toInt(),
      fee: (json['fee'] as num).toInt(),
      data: json['data'] as String,
      supported: json['supported'] as bool,
      confirmed: json['confirmed'] as bool,
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'tx_index': instance.txIndex,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_hash': instance.blockHash,
      'block_time': instance.blockTime,
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'supported': instance.supported,
      'confirmed': instance.confirmed,
    };

TransactionVerbose _$TransactionVerboseFromJson(Map<String, dynamic> json) =>
    TransactionVerbose(
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num?)?.toInt(),
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockHash: json['block_hash'] as String?,
      blockTime: (json['block_time'] as num?)?.toInt(),
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num).toInt(),
      fee: (json['fee'] as num).toInt(),
      data: json['data'] as String,
      supported: json['supported'] as bool,
      confirmed: json['confirmed'] as bool,
      unpackedData: TransactionUnpacked.fromJson(
          json['unpacked_data'] as Map<String, dynamic>),
      btcAmountNormalized: json['btc_amount_normalized'] as String,
    );

Map<String, dynamic> _$TransactionVerboseToJson(TransactionVerbose instance) =>
    <String, dynamic>{
      'tx_index': instance.txIndex,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_hash': instance.blockHash,
      'block_time': instance.blockTime,
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'supported': instance.supported,
      'confirmed': instance.confirmed,
      'unpacked_data': instance.unpackedData,
      'btc_amount_normalized': instance.btcAmountNormalized,
    };

Balance _$BalanceFromJson(Map<String, dynamic> json) => Balance(
      address: json['address'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      asset: json['asset'] as String,
    );

Map<String, dynamic> _$BalanceToJson(Balance instance) => <String, dynamic>{
      'address': instance.address,
      'quantity': instance.quantity,
      'asset': instance.asset,
    };

BalanceVerbose _$BalanceVerboseFromJson(Map<String, dynamic> json) =>
    BalanceVerbose(
      address: json['address'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      asset: json['asset'] as String,
      assetInfo: AssetInfo.fromJson(json['asset_info'] as Map<String, dynamic>),
      quantityNormalized: json['quantity_normalized'] as String,
    );

Map<String, dynamic> _$BalanceVerboseToJson(BalanceVerbose instance) =>
    <String, dynamic>{
      'address': instance.address,
      'quantity': instance.quantity,
      'asset': instance.asset,
      'quantity_normalized': instance.quantityNormalized,
      'asset_info': instance.assetInfo,
    };

MultiBalance _$MultiBalanceFromJson(Map<String, dynamic> json) => MultiBalance(
      address: json['address'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$MultiBalanceToJson(MultiBalance instance) =>
    <String, dynamic>{
      'address': instance.address,
      'quantity': instance.quantity,
    };

MultiBalanceVerbose _$MultiBalanceVerboseFromJson(Map<String, dynamic> json) =>
    MultiBalanceVerbose(
      address: json['address'] as String,
      quantity: (json['quantity'] as num).toInt(),
      quantityNormalized: json['quantity_normalized'] as String,
    );

Map<String, dynamic> _$MultiBalanceVerboseToJson(
        MultiBalanceVerbose instance) =>
    <String, dynamic>{
      'address': instance.address,
      'quantity': instance.quantity,
      'quantity_normalized': instance.quantityNormalized,
    };

MultiAddressBalance _$MultiAddressBalanceFromJson(Map<String, dynamic> json) =>
    MultiAddressBalance(
      asset: json['asset'] as String,
      total: (json['total'] as num).toInt(),
      addresses: (json['addresses'] as List<dynamic>)
          .map((e) => MultiBalance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MultiAddressBalanceToJson(
        MultiAddressBalance instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'total': instance.total,
      'addresses': instance.addresses,
    };

MultiAddressBalanceVerbose _$MultiAddressBalanceVerboseFromJson(
        Map<String, dynamic> json) =>
    MultiAddressBalanceVerbose(
      asset: json['asset'] as String,
      total: (json['total'] as num).toInt(),
      addresses: (json['addresses'] as List<dynamic>)
          .map((e) => MultiBalanceVerbose.fromJson(e as Map<String, dynamic>))
          .toList(),
      assetInfo: AssetInfo.fromJson(json['asset_info'] as Map<String, dynamic>),
      totalNormalized: json['total_normalized'] as String,
    );

Map<String, dynamic> _$MultiAddressBalanceVerboseToJson(
        MultiAddressBalanceVerbose instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'total': instance.total,
      'addresses': instance.addresses,
      'asset_info': instance.assetInfo,
      'total_normalized': instance.totalNormalized,
    };

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
    };

EnhancedSendParams _$EnhancedSendParamsFromJson(Map<String, dynamic> json) =>
    EnhancedSendParams(
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      destination: json['destination'] as String,
      memo: json['memo'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      source: json['source'] as String,
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
    );

Map<String, dynamic> _$EnhancedSendParamsToJson(EnhancedSendParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'destination': instance.destination,
      'memo': instance.memo,
      'quantity': instance.quantity,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
    };

CreditParams _$CreditParamsFromJson(Map<String, dynamic> json) => CreditParams(
      address: json['address'] as String,
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      callingFunction: json['calling_function'] as String,
      event: json['event'] as String,
      quantity: (json['quantity'] as num).toInt(),
      txIndex: (json['tx_index'] as num).toInt(),
    );

Map<String, dynamic> _$CreditParamsToJson(CreditParams instance) =>
    <String, dynamic>{
      'address': instance.address,
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'calling_function': instance.callingFunction,
      'event': instance.event,
      'quantity': instance.quantity,
      'tx_index': instance.txIndex,
    };

DebitParams _$DebitParamsFromJson(Map<String, dynamic> json) => DebitParams(
      action: json['action'] as String,
      address: json['address'] as String,
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      event: json['event'] as String,
      quantity: (json['quantity'] as num).toInt(),
      txIndex: (json['tx_index'] as num).toInt(),
    );

Map<String, dynamic> _$DebitParamsToJson(DebitParams instance) =>
    <String, dynamic>{
      'action': instance.action,
      'address': instance.address,
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'event': instance.event,
      'quantity': instance.quantity,
      'tx_index': instance.txIndex,
    };

NewTransactionParams _$NewTransactionParamsFromJson(
        Map<String, dynamic> json) =>
    NewTransactionParams(
      blockHash: json['block_hash'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      btcAmount: (json['btc_amount'] as num).toInt(),
      data: json['data'] as String,
      destination: json['destination'] as String,
      fee: (json['fee'] as num).toInt(),
      source: json['source'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
    );

Map<String, dynamic> _$NewTransactionParamsToJson(
        NewTransactionParams instance) =>
    <String, dynamic>{
      'block_hash': instance.blockHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'btc_amount': instance.btcAmount,
      'data': instance.data,
      'destination': instance.destination,
      'fee': instance.fee,
      'source': instance.source,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
    };

EnhancedSendEvent _$EnhancedSendEventFromJson(Map<String, dynamic> json) =>
    EnhancedSendEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params:
          EnhancedSendParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EnhancedSendEventToJson(EnhancedSendEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

CreditEvent _$CreditEventFromJson(Map<String, dynamic> json) => CreditEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params: CreditParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreditEventToJson(CreditEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

DebitEvent _$DebitEventFromJson(Map<String, dynamic> json) => DebitEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params: DebitParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DebitEventToJson(DebitEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

NewTransactionEvent _$NewTransactionEventFromJson(Map<String, dynamic> json) =>
    NewTransactionEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params:
          NewTransactionParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NewTransactionEventToJson(
        NewTransactionEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

AssetIssuanceParams _$AssetIssuanceParamsFromJson(Map<String, dynamic> json) =>
    AssetIssuanceParams(
      asset: json['asset'] as String,
      assetLongname: json['asset_longname'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      source: json['source'] as String,
    );

Map<String, dynamic> _$AssetIssuanceParamsToJson(
        AssetIssuanceParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'asset_longname': instance.assetLongname,
      'quantity': instance.quantity,
      'source': instance.source,
    };

VerboseAssetIssuanceParams _$VerboseAssetIssuanceParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseAssetIssuanceParams(
      asset: json['asset'] as String,
      assetLongname: json['asset_longname'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      source: json['source'] as String,
      blockTime: (json['block_time'] as num).toInt(),
      quantityNormalized: json['quantity_normalized'] as String,
      feePaidNormalized: json['fee_paid_normalized'] as String,
    );

Map<String, dynamic> _$VerboseAssetIssuanceParamsToJson(
        VerboseAssetIssuanceParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'asset_longname': instance.assetLongname,
      'quantity': instance.quantity,
      'source': instance.source,
      'block_time': instance.blockTime,
      'quantity_normalized': instance.quantityNormalized,
      'fee_paid_normalized': instance.feePaidNormalized,
    };

AssetIssuanceEvent _$AssetIssuanceEventFromJson(Map<String, dynamic> json) =>
    AssetIssuanceEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params:
          AssetIssuanceParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AssetIssuanceEventToJson(AssetIssuanceEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

VerboseAssetIssuanceEvent _$VerboseAssetIssuanceEventFromJson(
        Map<String, dynamic> json) =>
    VerboseAssetIssuanceEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      params: VerboseAssetIssuanceParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseAssetIssuanceEventToJson(
        VerboseAssetIssuanceEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

DispenseParams _$DispenseParamsFromJson(Map<String, dynamic> json) =>
    DispenseParams(
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      btcAmount: (json['btc_amount'] as num).toInt(),
      destination: json['destination'] as String,
      dispenseIndex: (json['dispense_index'] as num).toInt(),
      dispenseQuantity: (json['dispense_quantity'] as num).toInt(),
      dispenserTxHash: json['dispenser_tx_hash'] as String,
      source: json['source'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
    );

Map<String, dynamic> _$DispenseParamsToJson(DispenseParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'btc_amount': instance.btcAmount,
      'destination': instance.destination,
      'dispense_index': instance.dispenseIndex,
      'dispense_quantity': instance.dispenseQuantity,
      'dispenser_tx_hash': instance.dispenserTxHash,
      'source': instance.source,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
    };

VerboseDispenseParams _$VerboseDispenseParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseDispenseParams(
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      btcAmount: (json['btc_amount'] as num).toInt(),
      destination: json['destination'] as String,
      dispenseIndex: (json['dispense_index'] as num).toInt(),
      dispenseQuantity: (json['dispense_quantity'] as num).toInt(),
      dispenserTxHash: json['dispenser_tx_hash'] as String,
      source: json['source'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      dispenseQuantityNormalized:
          json['dispense_quantity_normalized'] as String,
      btcAmountNormalized: json['btc_amount_normalized'] as String,
    );

Map<String, dynamic> _$VerboseDispenseParamsToJson(
        VerboseDispenseParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'btc_amount': instance.btcAmount,
      'destination': instance.destination,
      'dispense_index': instance.dispenseIndex,
      'dispense_quantity': instance.dispenseQuantity,
      'dispenser_tx_hash': instance.dispenserTxHash,
      'source': instance.source,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'dispense_quantity_normalized': instance.dispenseQuantityNormalized,
      'btc_amount_normalized': instance.btcAmountNormalized,
    };

DispenseEvent _$DispenseEventFromJson(Map<String, dynamic> json) =>
    DispenseEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params: DispenseParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DispenseEventToJson(DispenseEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

VerboseDispenseEvent _$VerboseDispenseEventFromJson(
        Map<String, dynamic> json) =>
    VerboseDispenseEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      params: VerboseDispenseParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseDispenseEventToJson(
        VerboseDispenseEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseEnhancedSendParams _$VerboseEnhancedSendParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseEnhancedSendParams(
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      destination: json['destination'] as String,
      memo: json['memo'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      source: json['source'] as String,
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      assetInfo: AssetInfo.fromJson(json['asset_info'] as Map<String, dynamic>),
      quantityNormalized: json['quantity_normalized'] as String,
    );

Map<String, dynamic> _$VerboseEnhancedSendParamsToJson(
        VerboseEnhancedSendParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'destination': instance.destination,
      'memo': instance.memo,
      'quantity': instance.quantity,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'block_time': instance.blockTime,
      'asset_info': instance.assetInfo,
      'quantity_normalized': instance.quantityNormalized,
    };

VerboseCreditParams _$VerboseCreditParamsFromJson(Map<String, dynamic> json) =>
    VerboseCreditParams(
      address: json['address'] as String,
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      callingFunction: json['calling_function'] as String,
      event: json['event'] as String,
      quantity: (json['quantity'] as num).toInt(),
      txIndex: (json['tx_index'] as num).toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      assetInfo: AssetInfo.fromJson(json['asset_info'] as Map<String, dynamic>),
      quantityNormalized: json['quantity_normalized'] as String,
    );

Map<String, dynamic> _$VerboseCreditParamsToJson(
        VerboseCreditParams instance) =>
    <String, dynamic>{
      'address': instance.address,
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'calling_function': instance.callingFunction,
      'event': instance.event,
      'quantity': instance.quantity,
      'tx_index': instance.txIndex,
      'block_time': instance.blockTime,
      'asset_info': instance.assetInfo,
      'quantity_normalized': instance.quantityNormalized,
    };

VerboseDebitParams _$VerboseDebitParamsFromJson(Map<String, dynamic> json) =>
    VerboseDebitParams(
      action: json['action'] as String,
      address: json['address'] as String,
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      event: json['event'] as String,
      quantity: (json['quantity'] as num).toInt(),
      txIndex: (json['tx_index'] as num).toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      assetInfo: AssetInfo.fromJson(json['asset_info'] as Map<String, dynamic>),
      quantityNormalized: json['quantity_normalized'] as String,
    );

Map<String, dynamic> _$VerboseDebitParamsToJson(VerboseDebitParams instance) =>
    <String, dynamic>{
      'action': instance.action,
      'address': instance.address,
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'event': instance.event,
      'quantity': instance.quantity,
      'tx_index': instance.txIndex,
      'block_time': instance.blockTime,
      'asset_info': instance.assetInfo,
      'quantity_normalized': instance.quantityNormalized,
    };

VerboseNewTransactionParams _$VerboseNewTransactionParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseNewTransactionParams(
      blockHash: json['block_hash'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      btcAmount: (json['btc_amount'] as num).toInt(),
      data: json['data'] as String,
      destination: json['destination'] as String,
      fee: (json['fee'] as num).toInt(),
      source: json['source'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      unpackedData: json['unpacked_data'] as Map<String, dynamic>,
      btcAmountNormalized: json['btc_amount_normalized'] as String,
    );

Map<String, dynamic> _$VerboseNewTransactionParamsToJson(
        VerboseNewTransactionParams instance) =>
    <String, dynamic>{
      'block_hash': instance.blockHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'btc_amount': instance.btcAmount,
      'data': instance.data,
      'destination': instance.destination,
      'fee': instance.fee,
      'source': instance.source,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'unpacked_data': instance.unpackedData,
      'btc_amount_normalized': instance.btcAmountNormalized,
    };

AssetInfo _$AssetInfoFromJson(Map<String, dynamic> json) => AssetInfo(
      divisible: json['divisible'] as bool,
      assetLongname: json['asset_longname'] as String?,
      description: json['description'] as String,
      locked: json['locked'] as bool,
      issuer: json['issuer'] as String?,
    );

Map<String, dynamic> _$AssetInfoToJson(AssetInfo instance) => <String, dynamic>{
      'divisible': instance.divisible,
      'asset_longname': instance.assetLongname,
      'description': instance.description,
      'locked': instance.locked,
      'issuer': instance.issuer,
    };

VerboseEvent _$VerboseEventFromJson(Map<String, dynamic> json) => VerboseEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num).toInt(),
    );

Map<String, dynamic> _$VerboseEventToJson(VerboseEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
    };

VerboseEnhancedSendEvent _$VerboseEnhancedSendEventFromJson(
        Map<String, dynamic> json) =>
    VerboseEnhancedSendEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      params: VerboseEnhancedSendParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseEnhancedSendEventToJson(
        VerboseEnhancedSendEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseCreditEvent _$VerboseCreditEventFromJson(Map<String, dynamic> json) =>
    VerboseCreditEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      params:
          VerboseCreditParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseCreditEventToJson(VerboseCreditEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseDebitEvent _$VerboseDebitEventFromJson(Map<String, dynamic> json) =>
    VerboseDebitEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      params:
          VerboseDebitParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseDebitEventToJson(VerboseDebitEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseNewTransactionEvent _$VerboseNewTransactionEventFromJson(
        Map<String, dynamic> json) =>
    VerboseNewTransactionEvent(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      params: VerboseNewTransactionParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseNewTransactionEventToJson(
        VerboseNewTransactionEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

EventCount _$EventCountFromJson(Map<String, dynamic> json) => EventCount(
      event: json['event'] as String,
      eventCount: (json['event_count'] as num).toInt(),
    );

Map<String, dynamic> _$EventCountToJson(EventCount instance) =>
    <String, dynamic>{
      'event': instance.event,
      'event_count': instance.eventCount,
    };

Asset _$AssetFromJson(Map<String, dynamic> json) => Asset(
      asset: json['asset'] as String,
      assetLongname: json['asset_longname'] as String,
      description: json['description'] as String,
      divisible: json['divisible'] as bool,
      locked: json['locked'] as bool,
      issuer: json['issuer'] as String?,
    );

Map<String, dynamic> _$AssetToJson(Asset instance) => <String, dynamic>{
      'asset': instance.asset,
      'asset_longname': instance.assetLongname,
      'description': instance.description,
      'issuer': instance.issuer,
      'divisible': instance.divisible,
      'locked': instance.locked,
    };

Credit _$CreditFromJson(Map<String, dynamic> json) => Credit(
      blockIndex: json['block_index'] as String,
      address: json['address'] as String,
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      callingFunction: json['calling_function'] as String,
      event: json['event'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      assetInfo: AssetInfo.fromJson(json['asset_info'] as Map<String, dynamic>),
      quantityNormalized: json['quantity_normalized'] as String,
    );

Map<String, dynamic> _$CreditToJson(Credit instance) => <String, dynamic>{
      'block_index': instance.blockIndex,
      'address': instance.address,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'calling_function': instance.callingFunction,
      'event': instance.event,
      'tx_index': instance.txIndex,
      'asset_info': instance.assetInfo,
      'quantity_normalized': instance.quantityNormalized,
    };

Debit _$DebitFromJson(Map<String, dynamic> json) => Debit(
      blockIndex: (json['block_index'] as num).toInt(),
      address: json['address'] as String,
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      action: json['action'] as String,
      event: json['event'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      assetInfo: AssetInfo.fromJson(json['asset_info'] as Map<String, dynamic>),
      quantityNormalized: json['quantity_normalized'] as String,
    );

Map<String, dynamic> _$DebitToJson(Debit instance) => <String, dynamic>{
      'block_index': instance.blockIndex,
      'address': instance.address,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'action': instance.action,
      'event': instance.event,
      'tx_index': instance.txIndex,
      'asset_info': instance.assetInfo,
      'quantity_normalized': instance.quantityNormalized,
    };

Expiration _$ExpirationFromJson(Map<String, dynamic> json) => Expiration(
      type: json['type'] as String,
      objectId: json['object_id'] as String,
    );

Map<String, dynamic> _$ExpirationToJson(Expiration instance) =>
    <String, dynamic>{
      'type': instance.type,
      'object_id': instance.objectId,
    };

Cancel _$CancelFromJson(Map<String, dynamic> json) => Cancel(
      txIndex: (json['tx_index'] as num).toInt(),
      txHash: json['tx_hash'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      source: json['source'] as String,
      offerHash: json['offer_hash'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$CancelToJson(Cancel instance) => <String, dynamic>{
      'tx_index': instance.txIndex,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'source': instance.source,
      'offer_hash': instance.offerHash,
      'status': instance.status,
    };

Destruction _$DestructionFromJson(Map<String, dynamic> json) => Destruction(
      txIndex: (json['tx_index'] as num).toInt(),
      txHash: json['tx_hash'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      source: json['source'] as String,
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      tag: json['tag'] as String,
      status: json['status'] as String,
      assetInfo: AssetInfo.fromJson(json['asset_info'] as Map<String, dynamic>),
      quantityNormalized: json['quantity_normalized'] as String,
    );

Map<String, dynamic> _$DestructionToJson(Destruction instance) =>
    <String, dynamic>{
      'tx_index': instance.txIndex,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'source': instance.source,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'tag': instance.tag,
      'status': instance.status,
      'asset_info': instance.assetInfo,
      'quantity_normalized': instance.quantityNormalized,
    };

Issuance _$IssuanceFromJson(Map<String, dynamic> json) => Issuance(
      txIndex: (json['tx_index'] as num).toInt(),
      txHash: json['tx_hash'] as String,
      msgIndex: (json['msg_index'] as num).toInt(),
      blockIndex: (json['block_index'] as num).toInt(),
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      divisible: (json['divisible'] as num).toInt(),
      source: json['source'] as String,
      issuer: json['issuer'] as String,
      transfer: (json['transfer'] as num).toInt(),
      callable: (json['callable'] as num).toInt(),
      callDate: (json['call_date'] as num).toInt(),
      callPrice: (json['call_price'] as num).toDouble(),
      description: json['description'] as String,
      feePaid: (json['fee_paid'] as num).toInt(),
      locked: (json['locked'] as num).toInt(),
      status: json['status'] as String,
      assetLongname: json['asset_longname'] as String?,
      reset: (json['reset'] as num).toInt(),
    );

Map<String, dynamic> _$IssuanceToJson(Issuance instance) => <String, dynamic>{
      'tx_index': instance.txIndex,
      'tx_hash': instance.txHash,
      'msg_index': instance.msgIndex,
      'block_index': instance.blockIndex,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'divisible': instance.divisible,
      'source': instance.source,
      'issuer': instance.issuer,
      'transfer': instance.transfer,
      'callable': instance.callable,
      'call_date': instance.callDate,
      'call_price': instance.callPrice,
      'description': instance.description,
      'fee_paid': instance.feePaid,
      'locked': instance.locked,
      'status': instance.status,
      'asset_longname': instance.assetLongname,
      'reset': instance.reset,
    };

ComposeIssuance _$ComposeIssuanceFromJson(Map<String, dynamic> json) =>
    ComposeIssuance(
      rawtransaction: json['rawtransaction'] as String,
      params: ComposeIssuanceParams.fromJson(
          json['params'] as Map<String, dynamic>),
      name: json['name'] as String,
    );

Map<String, dynamic> _$ComposeIssuanceToJson(ComposeIssuance instance) =>
    <String, dynamic>{
      'rawtransaction': instance.rawtransaction,
      'params': instance.params,
      'name': instance.name,
    };

ComposeIssuanceParams _$ComposeIssuanceParamsFromJson(
        Map<String, dynamic> json) =>
    ComposeIssuanceParams(
      source: json['source'] as String,
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      divisible: json['divisible'] as bool,
      lock: json['lock'] as bool,
      description: json['description'] as String?,
      transferDestination: json['transferDestination'] as String?,
    );

Map<String, dynamic> _$ComposeIssuanceParamsToJson(
        ComposeIssuanceParams instance) =>
    <String, dynamic>{
      'source': instance.source,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'divisible': instance.divisible,
      'lock': instance.lock,
      'description': instance.description,
      'transferDestination': instance.transferDestination,
    };

ComposeIssuanceVerbose _$ComposeIssuanceVerboseFromJson(
        Map<String, dynamic> json) =>
    ComposeIssuanceVerbose(
      rawtransaction: json['rawtransaction'] as String,
      name: json['name'] as String,
      params: ComposeIssuanceVerboseParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ComposeIssuanceVerboseToJson(
        ComposeIssuanceVerbose instance) =>
    <String, dynamic>{
      'rawtransaction': instance.rawtransaction,
      'name': instance.name,
      'params': instance.params,
    };

ComposeIssuanceVerboseParams _$ComposeIssuanceVerboseParamsFromJson(
        Map<String, dynamic> json) =>
    ComposeIssuanceVerboseParams(
      source: json['source'] as String,
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      divisible: json['divisible'] as bool,
      lock: json['lock'] as bool,
      description: json['description'] as String?,
      transferDestination: json['transfer_destination'] as String?,
      quantityNormalized: json['quantity_normalized'] as String,
    );

Map<String, dynamic> _$ComposeIssuanceVerboseParamsToJson(
        ComposeIssuanceVerboseParams instance) =>
    <String, dynamic>{
      'source': instance.source,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'divisible': instance.divisible,
      'lock': instance.lock,
      'description': instance.description,
      'transfer_destination': instance.transferDestination,
      'quantity_normalized': instance.quantityNormalized,
    };

Send _$SendFromJson(Map<String, dynamic> json) => Send(
      txIndex: (json['tx_index'] as num).toInt(),
      txHash: json['tx_hash'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      source: json['source'] as String,
      destination: json['destination'] as String,
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      status: json['status'] as String,
      msgIndex: (json['msg_index'] as num).toInt(),
      memo: json['memo'] as String?,
      assetInfo: AssetInfo.fromJson(json['asset_info'] as Map<String, dynamic>),
      quantityNormalized: json['quantity_normalized'] as String,
    );

Map<String, dynamic> _$SendToJson(Send instance) => <String, dynamic>{
      'tx_index': instance.txIndex,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'source': instance.source,
      'destination': instance.destination,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'status': instance.status,
      'msg_index': instance.msgIndex,
      'memo': instance.memo,
      'asset_info': instance.assetInfo,
      'quantity_normalized': instance.quantityNormalized,
    };

Dispenser _$DispenserFromJson(Map<String, dynamic> json) => Dispenser(
      txIndex: (json['tx_index'] as num).toInt(),
      blockIndex: (json['block_index'] as num).toInt(),
      source: json['source'] as String,
      giveQuantity: (json['give_quantity'] as num).toInt(),
      escrowQuantity: (json['escrow_quantity'] as num).toInt(),
      satoshiRate: (json['satoshi_rate'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      giveRemaining: (json['give_remaining'] as num).toInt(),
      oracleAddress: json['oracle_address'] as String?,
      lastStatusTxHash: json['last_status_tx_hash'] as String?,
      origin: json['origin'] as String,
      dispenseCount: (json['dispense_count'] as num).toInt(),
      giveQuantityNormalized: json['give_quantity_normalized'] as String,
      giveRemainingNormalized: json['give_remaining_normalized'] as String,
      escrowQuantityNormalized: json['escrow_quantity_normalized'] as String,
    );

Map<String, dynamic> _$DispenserToJson(Dispenser instance) => <String, dynamic>{
      'tx_index': instance.txIndex,
      'block_index': instance.blockIndex,
      'source': instance.source,
      'give_quantity': instance.giveQuantity,
      'escrow_quantity': instance.escrowQuantity,
      'satoshi_rate': instance.satoshiRate,
      'status': instance.status,
      'give_remaining': instance.giveRemaining,
      'oracle_address': instance.oracleAddress,
      'last_status_tx_hash': instance.lastStatusTxHash,
      'origin': instance.origin,
      'dispense_count': instance.dispenseCount,
      'give_quantity_normalized': instance.giveQuantityNormalized,
      'give_remaining_normalized': instance.giveRemainingNormalized,
      'escrow_quantity_normalized': instance.escrowQuantityNormalized,
    };

Dispense _$DispenseFromJson(Map<String, dynamic> json) => Dispense(
      txIndex: (json['tx_index'] as num).toInt(),
      dispenseIndex: (json['dispense_index'] as num).toInt(),
      txHash: json['tx_hash'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      source: json['source'] as String,
      destination: json['destination'] as String,
      asset: json['asset'] as String,
      dispenseQuantity: (json['dispense_quantity'] as num).toInt(),
      dispenserTxHash: json['dispenser_tx_hash'] as String,
      dispenser: Dispenser.fromJson(json['dispenser'] as Map<String, dynamic>),
      assetInfo: AssetInfo.fromJson(json['asset_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DispenseToJson(Dispense instance) => <String, dynamic>{
      'tx_index': instance.txIndex,
      'dispense_index': instance.dispenseIndex,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'source': instance.source,
      'destination': instance.destination,
      'asset': instance.asset,
      'dispense_quantity': instance.dispenseQuantity,
      'dispenser_tx_hash': instance.dispenserTxHash,
      'dispenser': instance.dispenser,
      'asset_info': instance.assetInfo,
    };

Sweep _$SweepFromJson(Map<String, dynamic> json) => Sweep(
      txIndex: (json['tx_index'] as num).toInt(),
      txHash: json['tx_hash'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      source: json['source'] as String,
      destination: json['destination'] as String,
      flags: (json['flags'] as num).toInt(),
      status: json['status'] as String,
      memo: json['memo'] as String?,
      feePaid: (json['fee_paid'] as num).toInt(),
    );

Map<String, dynamic> _$SweepToJson(Sweep instance) => <String, dynamic>{
      'tx_index': instance.txIndex,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'source': instance.source,
      'destination': instance.destination,
      'flags': instance.flags,
      'status': instance.status,
      'memo': instance.memo,
      'fee_paid': instance.feePaid,
    };

SendTxParams _$SendTxParamsFromJson(Map<String, dynamic> json) => SendTxParams(
      source: json['source'] as String,
      destination: json['destination'] as String,
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      memo: json['memo'] as String?,
      memoIsHex: json['memo_is_hex'] as bool,
      useEnhancedSend: json['use_enhanced_send'] as bool,
    );

Map<String, dynamic> _$SendTxParamsToJson(SendTxParams instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'memo': instance.memo,
      'memo_is_hex': instance.memoIsHex,
      'use_enhanced_send': instance.useEnhancedSend,
    };

SendTx _$SendTxFromJson(Map<String, dynamic> json) => SendTx(
      rawtransaction: json['rawtransaction'] as String,
      params: SendTxParams.fromJson(json['params'] as Map<String, dynamic>),
      name: json['name'] as String,
    );

Map<String, dynamic> _$SendTxToJson(SendTx instance) => <String, dynamic>{
      'rawtransaction': instance.rawtransaction,
      'params': instance.params,
      'name': instance.name,
    };

SendTxParamsVerbose _$SendTxParamsVerboseFromJson(Map<String, dynamic> json) =>
    SendTxParamsVerbose(
      source: json['source'] as String,
      destination: json['destination'] as String,
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      memo: json['memo'] as String?,
      memoIsHex: json['memo_is_hex'] as bool,
      useEnhancedSend: json['use_enhanced_send'] as bool,
      assetInfo: AssetInfo.fromJson(json['asset_info'] as Map<String, dynamic>),
      quantityNormalized: json['quantity_normalized'] as String,
    );

Map<String, dynamic> _$SendTxParamsVerboseToJson(
        SendTxParamsVerbose instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'memo': instance.memo,
      'memo_is_hex': instance.memoIsHex,
      'use_enhanced_send': instance.useEnhancedSend,
      'asset_info': instance.assetInfo,
      'quantity_normalized': instance.quantityNormalized,
    };

SendTxVerbose _$SendTxVerboseFromJson(Map<String, dynamic> json) =>
    SendTxVerbose(
      params:
          SendTxParamsVerbose.fromJson(json['params'] as Map<String, dynamic>),
      rawtransaction: json['rawtransaction'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$SendTxVerboseToJson(SendTxVerbose instance) =>
    <String, dynamic>{
      'rawtransaction': instance.rawtransaction,
      'name': instance.name,
      'params': instance.params,
    };

Info _$InfoFromJson(Map<String, dynamic> json) => Info(
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toInt(),
      data: json['data'] as String,
      decodedTx: json['decoded_tx'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$InfoToJson(Info instance) => <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'decoded_tx': instance.decodedTx,
    };

EnhancedSendInfoUnpackedData _$EnhancedSendInfoUnpackedDataFromJson(
        Map<String, dynamic> json) =>
    EnhancedSendInfoUnpackedData(
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      address: json['address'] as String,
      memo: json['memo'] as String?,
    );

Map<String, dynamic> _$EnhancedSendInfoUnpackedDataToJson(
        EnhancedSendInfoUnpackedData instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'quantity': instance.quantity,
      'address': instance.address,
      'memo': instance.memo,
    };

EnhancedSendInfo _$EnhancedSendInfoFromJson(Map<String, dynamic> json) =>
    EnhancedSendInfo(
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toInt(),
      data: json['data'] as String,
      decodedTx: json['decoded_tx'] as Map<String, dynamic>?,
      unpackedData: EnhancedSendUnpacked.fromJson(
          json['unpacked_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EnhancedSendInfoToJson(EnhancedSendInfo instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'decoded_tx': instance.decodedTx,
      'unpacked_data': instance.unpackedData,
    };

IssuanceUnpacked _$IssuanceUnpackedFromJson(Map<String, dynamic> json) =>
    IssuanceUnpacked(
      assetId: (json['asset_id'] as num).toInt(),
      asset: json['asset'] as String,
      subassetLongname: json['subasset_longname'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      divisible: json['divisible'] as bool,
      lock: json['lock'] as bool,
      reset: json['reset'] as bool,
      callable: json['callable'] as bool,
      callDate: (json['call_date'] as num).toInt(),
      callPrice: (json['call_price'] as num).toDouble(),
      description: json['description'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$IssuanceUnpackedToJson(IssuanceUnpacked instance) =>
    <String, dynamic>{
      'asset_id': instance.assetId,
      'asset': instance.asset,
      'subasset_longname': instance.subassetLongname,
      'quantity': instance.quantity,
      'divisible': instance.divisible,
      'lock': instance.lock,
      'reset': instance.reset,
      'callable': instance.callable,
      'call_date': instance.callDate,
      'call_price': instance.callPrice,
      'description': instance.description,
      'status': instance.status,
    };

IssuanceInfo _$IssuanceInfoFromJson(Map<String, dynamic> json) => IssuanceInfo(
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toInt(),
      data: json['data'] as String,
      decodedTx: json['decoded_tx'] as Map<String, dynamic>?,
      unpackedData: IssuanceUnpacked.fromJson(
          json['unpacked_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IssuanceInfoToJson(IssuanceInfo instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'decoded_tx': instance.decodedTx,
      'unpacked_data': instance.unpackedData,
    };

InfoVerbose _$InfoVerboseFromJson(Map<String, dynamic> json) => InfoVerbose(
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toInt(),
      data: json['data'] as String,
      decodedTx: json['decoded_tx'] as Map<String, dynamic>?,
      btcAmountNormalized: json['btc_amount_normalized'] as String,
    );

Map<String, dynamic> _$InfoVerboseToJson(InfoVerbose instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'decoded_tx': instance.decodedTx,
      'btc_amount_normalized': instance.btcAmountNormalized,
    };

EnhancedSendInfoVerbose _$EnhancedSendInfoVerboseFromJson(
        Map<String, dynamic> json) =>
    EnhancedSendInfoVerbose(
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toInt(),
      data: json['data'] as String,
      decodedTx: json['decoded_tx'] as Map<String, dynamic>?,
      btcAmountNormalized: json['btc_amount_normalized'] as String,
      unpackedData: EnhancedSendUnpackedVerbose.fromJson(
          json['unpacked_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EnhancedSendInfoVerboseToJson(
        EnhancedSendInfoVerbose instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'decoded_tx': instance.decodedTx,
      'btc_amount_normalized': instance.btcAmountNormalized,
      'unpacked_data': instance.unpackedData,
    };

IssuanceUnpackedVerbose _$IssuanceUnpackedVerboseFromJson(
        Map<String, dynamic> json) =>
    IssuanceUnpackedVerbose(
      assetId: (json['asset_id'] as num).toInt(),
      asset: json['asset'] as String,
      subassetLongname: json['subasset_longname'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      divisible: json['divisible'] as bool,
      lock: json['lock'] as bool,
      reset: json['reset'] as bool,
      callable: json['callable'] as bool,
      callDate: (json['call_date'] as num).toInt(),
      callPrice: (json['call_price'] as num).toDouble(),
      description: json['description'] as String,
      status: json['status'] as String,
      quantityNormalized: json['quantity_normalized'] as String,
    );

Map<String, dynamic> _$IssuanceUnpackedVerboseToJson(
        IssuanceUnpackedVerbose instance) =>
    <String, dynamic>{
      'asset_id': instance.assetId,
      'asset': instance.asset,
      'subasset_longname': instance.subassetLongname,
      'quantity': instance.quantity,
      'divisible': instance.divisible,
      'lock': instance.lock,
      'reset': instance.reset,
      'callable': instance.callable,
      'call_date': instance.callDate,
      'call_price': instance.callPrice,
      'description': instance.description,
      'status': instance.status,
      'quantity_normalized': instance.quantityNormalized,
    };

IssuanceInfoVerbose _$IssuanceInfoVerboseFromJson(Map<String, dynamic> json) =>
    IssuanceInfoVerbose(
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toInt(),
      data: json['data'] as String,
      decodedTx: json['decoded_tx'] as Map<String, dynamic>?,
      btcAmountNormalized: json['btc_amount_normalized'] as String,
      unpackedData: IssuanceUnpackedVerbose.fromJson(
          json['unpacked_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IssuanceInfoVerboseToJson(
        IssuanceInfoVerbose instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'decoded_tx': instance.decodedTx,
      'btc_amount_normalized': instance.btcAmountNormalized,
      'unpacked_data': instance.unpackedData,
    };

UTXO _$UTXOFromJson(Map<String, dynamic> json) => UTXO(
      vout: (json['vout'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      value: (json['value'] as num).toInt(),
      confirmations: (json['confirmations'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      txid: json['txid'] as String,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$UTXOToJson(UTXO instance) => <String, dynamic>{
      'vout': instance.vout,
      'height': instance.height,
      'value': instance.value,
      'confirmations': instance.confirmations,
      'amount': instance.amount,
      'txid': instance.txid,
      'address': instance.address,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element

class _V2Api implements V2Api {
  _V2Api(
    this._dio, {
    this.baseUrl,
  });

  final Dio _dio;

  String? baseUrl;

  @override
  Future<Response<String>> createTransaction(String signedhex) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'signedhex': signedhex};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<Response<String>>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/bitcoin/transactions',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<String>.fromJson(
      _result.data!,
      (json) => json as String,
    );
    return _value;
  }

  @override
  Future<Response<List<Balance>>> getBalancesByAddress(
    String address,
    bool verbose, [
    CursorModel? cursor,
    int? limit,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'verbose': verbose,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Balance>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/balances',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Balance>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Balance>((i) => Balance.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<BalanceVerbose>>> getBalancesByAddressVerbose(
    String address, [
    CursorModel? cursor,
    int? limit,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'cursor': cursor?.toJson(),
      r'limit': limit,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<BalanceVerbose>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/balances?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<BalanceVerbose>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<BalanceVerbose>(
                  (i) => BalanceVerbose.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<MultiAddressBalance>>> getBalancesByAddresses(
    String addresses, [
    CursorModel? cursor,
    int? limit,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'addresses': addresses,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<MultiAddressBalance>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/balances',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<MultiAddressBalance>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<MultiAddressBalance>((i) =>
                  MultiAddressBalance.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<MultiAddressBalanceVerbose>>>
      getBalancesByAddressesVerbose(
    String addresses, [
    CursorModel? cursor,
    int? limit,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'addresses': addresses,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<MultiAddressBalanceVerbose>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/balances?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<MultiAddressBalanceVerbose>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<MultiAddressBalanceVerbose>((i) =>
                  MultiAddressBalanceVerbose.fromJson(
                      i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<Block>>> getBlocks(
    int limit,
    int last,
    bool verbose,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'limit': limit,
      r'last': last,
      r'verbose': verbose,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Block>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/blocks',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Block>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Block>((i) => Block.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<Block>> getBlock(
    int blockIndex,
    bool verbose,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'verbose': verbose};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<Response<Block>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/blocks/${blockIndex}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<Block>.fromJson(
      _result.data!,
      (json) => Block.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<List<Transaction>>> getTransactionsByAddressByBlock(
    int blockIndex,
    bool verbose,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'verbose': verbose};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Transaction>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/blocks/${blockIndex}/transactions',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Transaction>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Transaction>(
                  (i) => Transaction.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<Event>>> getEventsByBlock(
    int blockIndex,
    bool verbose,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'verbose': verbose};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Event>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/blocks/${blockIndex}/events',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Event>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Event>((i) => Event.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<EventCount>>> getEventCountsByBlock(
    int blockIndex,
    bool verbose,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'verbose': verbose};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<EventCount>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/blocks/${blockIndex}/events/counts',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<EventCount>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<EventCount>(
                  (i) => EventCount.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<Event>>> getEventsByBlockAndEvent(
    int blockIndex,
    String event,
    bool verbose,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'verbose': verbose};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Event>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/blocks/${blockIndex}/events/${event}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Event>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Event>((i) => Event.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<Credit>>> getCreditsByBlock(
    int blockIndex,
    bool verbose,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'verbose': verbose};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Credit>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/blocks/${blockIndex}/credits',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Credit>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Credit>((i) => Credit.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<Debit>>> getDebitsByBlock(
    int blockIndex,
    bool verbose,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'verbose': verbose};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Debit>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/blocks/${blockIndex}/debits',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Debit>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Debit>((i) => Debit.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<Expiration>>> getExpirations(
    int blockIndex,
    bool verbose,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'verbose': verbose};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Expiration>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/blocks/${blockIndex}/expirations',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Expiration>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Expiration>(
                  (i) => Expiration.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<Cancel>>> getCancels(
    int blockIndex,
    bool verbose,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'verbose': verbose};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Cancel>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/blocks/${blockIndex}/cancels',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Cancel>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Cancel>((i) => Cancel.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<Destruction>>> getDestructions(
    int blockIndex,
    bool verbose,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'verbose': verbose};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Destruction>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/blocks/${blockIndex}/destructions',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Destruction>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Destruction>(
                  (i) => Destruction.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<Info>> getTransactionInfo(String rawtransaction) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'rawtransaction': rawtransaction
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<Response<Info>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/transactions/info',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<Info>.fromJson(
      _result.data!,
      (json) => Info.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<InfoVerbose>> getTransactionInfoVerbose(
      String rawtransaction) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'rawtransaction': rawtransaction
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<InfoVerbose>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/transactions/info?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<InfoVerbose>.fromJson(
      _result.data!,
      (json) => InfoVerbose.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<TransactionUnpacked>> unpackTransaction(
      String datahex) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'datahex': datahex};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<TransactionUnpacked>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/transactions/unpack',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<TransactionUnpacked>.fromJson(
      _result.data!,
      (json) => TransactionUnpacked.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<TransactionUnpackedVerbose>> unpackTransactionVerbose(
      String datahex) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'datahex': datahex};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<TransactionUnpackedVerbose>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/transactions/unpack?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<TransactionUnpackedVerbose>.fromJson(
      _result.data!,
      (json) =>
          TransactionUnpackedVerbose.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<SendTx>> composeSend(
    String address,
    String destination,
    String asset,
    int quantity, [
    bool? allowUnconfirmedInputs,
    int? fee,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'destination': destination,
      r'asset': asset,
      r'quantity': quantity,
      r'allow_unconfirmed_inputs': allowUnconfirmedInputs,
      r'fee': fee,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<Response<SendTx>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/compose/send',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<SendTx>.fromJson(
      _result.data!,
      (json) => SendTx.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<SendTxVerbose>> composeSendVerbose(
    String address,
    String destination,
    String asset,
    int quantity, [
    bool? allowUnconfirmedInputs,
    int? fee,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'destination': destination,
      r'asset': asset,
      r'quantity': quantity,
      r'allow_unconfirmed_inputs': allowUnconfirmedInputs,
      r'fee': fee,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<SendTxVerbose>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/compose/send?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<SendTxVerbose>.fromJson(
      _result.data!,
      (json) => SendTxVerbose.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<List<Send>>> getSendsByAddress(
    String address, [
    bool? verbose,
    int? limit,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'verbose': verbose,
      r'limit': limit,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Send>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/sends',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Send>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Send>((i) => Send.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<Issuance>>> getIssuancesByAddress(
    String address, [
    bool? verbose,
    int? limit,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'verbose': verbose,
      r'limit': limit,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Issuance>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/issuances',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Issuance>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Issuance>(
                  (i) => Issuance.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<ComposeIssuance>> composeIssuance(
    String address,
    String asset,
    int quantity, [
    String? transferDestination,
    bool? divisible,
    bool? lock,
    bool? reset,
    String? description,
    bool? unconfirmed,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'asset': asset,
      r'quantity': quantity,
      r'transferDestination': transferDestination,
      r'divisible': divisible,
      r'lock': lock,
      r'reset': reset,
      r'description': description,
      r'unconfirmed': unconfirmed,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<ComposeIssuance>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/compose/issuance',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<ComposeIssuance>.fromJson(
      _result.data!,
      (json) => ComposeIssuance.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<ComposeIssuanceVerbose>> composeIssuanceVerbose(
    String address,
    String asset,
    int quantity, [
    String? transferDestination,
    bool? divisible,
    bool? lock,
    bool? reset,
    String? description,
    bool? unconfirmed,
    int? fee,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'asset': asset,
      r'quantity': quantity,
      r'transferDestination': transferDestination,
      r'divisible': divisible,
      r'lock': lock,
      r'reset': reset,
      r'description': description,
      r'unconfirmed': unconfirmed,
      r'fee': fee,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<ComposeIssuanceVerbose>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/compose/issuance?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<ComposeIssuanceVerbose>.fromJson(
      _result.data!,
      (json) => ComposeIssuanceVerbose.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<List<Transaction>>> getTransactionsByAddress(
    String address, [
    bool? verbose,
    int? limit,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'verbose': verbose,
      r'limit': limit,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Transaction>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/transactions',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Transaction>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Transaction>(
                  (i) => Transaction.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<TransactionVerbose>>> getTransactionsByAddressesVerbose(
    String addresses, [
    CursorModel? cursor,
    int? limit,
    bool? showUnconfirmed,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'addresses': addresses,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
      r'show_unconfirmed': showUnconfirmed,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<TransactionVerbose>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/transactions?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<TransactionVerbose>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<TransactionVerbose>(
                  (i) => TransactionVerbose.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<Event>>> getEventsByAddresses(
    String addresses, [
    CursorModel? cursor,
    int? limit,
    bool? showUnconfirmed,
    String? eventName,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'addresses': addresses,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
      r'show_unconfirmed': showUnconfirmed,
      r'event_name': eventName,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Event>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/events',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Event>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Event>((i) => Event.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<VerboseEvent>>> getEventsByAddressesVerbose(
    String addresses, [
    CursorModel? cursor,
    int? limit,
    bool? showUnconfirmed,
    String? eventName,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'addresses': addresses,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
      r'show_unconfirmed': showUnconfirmed,
      r'event_name': eventName,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<VerboseEvent>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/events?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<VerboseEvent>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<VerboseEvent>(
                  (i) => VerboseEvent.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<UTXO>>> getUnspentUTXOs(
    String address, [
    bool? unconfirmed,
    String? unspentTxHash,
    bool? verbose,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'unconfirmed': unconfirmed,
      r'unspent_tx_hash': unspentTxHash,
      r'verbose': verbose,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<UTXO>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/bitcoin/addresses/${address}/utxos',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<UTXO>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<UTXO>((i) => UTXO.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<UTXO>>> getUnspentUTXOsByAddresses(
    String addresses, [
    bool? unconfirmed,
    bool? verbose,
    int? limit,
    CursorModel? cursor,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'addresses': addresses,
      r'unconfirmed': unconfirmed,
      r'verbose': verbose,
      r'limit': limit,
      r'cursor': cursor?.toJson(),
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<UTXO>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/bitcoin/addresses/utxos',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<UTXO>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<UTXO>((i) => UTXO.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<Asset>> getAsset(String asset) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<Response<Asset>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/assets/${asset}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<Asset>.fromJson(
      _result.data!,
      (json) => Asset.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(
    String dioBaseUrl,
    String? baseUrl,
  ) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
