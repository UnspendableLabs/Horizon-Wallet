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
      blockTime: (json['block_time'] as num).toInt(),
      blockHash: json['block_hash'] as String,
      previousBlockHash: json['previous_block_hash'] as String,
      difficulty: (json['difficulty'] as num).toInt(),
      ledgerHash: json['ledger_hash'] as String,
      txlistHash: json['txlist_hash'] as String,
      messagesHash: json['messages_hash'] as String,
      transactionCount: (json['transaction_count'] as num).toInt(),
      confirmed: json['confirmed'] as bool,
    );

Map<String, dynamic> _$BlockToJson(Block instance) => <String, dynamic>{
      'block_index': instance.blockIndex,
      'block_hash': instance.blockHash,
      'block_time': instance.blockTime,
      'previous_block_hash': instance.previousBlockHash,
      'difficulty': instance.difficulty,
      'ledger_hash': instance.ledgerHash,
      'txlist_hash': instance.txlistHash,
      'messages_hash': instance.messagesHash,
      'transaction_count': instance.transactionCount,
      'confirmed': instance.confirmed,
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
      address: json['address'] as String?,
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
      address: json['address'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      asset: json['asset'] as String,
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
      quantityNormalized: json['quantity_normalized'] as String,
      utxo: json['utxo'] as String?,
      utxoAddress: json['utxo_address'] as String?,
    );

Map<String, dynamic> _$BalanceVerboseToJson(BalanceVerbose instance) =>
    <String, dynamic>{
      'address': instance.address,
      'quantity': instance.quantity,
      'asset': instance.asset,
      'quantity_normalized': instance.quantityNormalized,
      'asset_info': instance.assetInfo,
      'utxo': instance.utxo,
      'utxo_address': instance.utxoAddress,
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
      address: json['address'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      quantityNormalized: json['quantity_normalized'] as String,
      utxo: json['utxo'] as String?,
      utxoAddress: json['utxo_address'] as String?,
    );

Map<String, dynamic> _$MultiBalanceVerboseToJson(
        MultiBalanceVerbose instance) =>
    <String, dynamic>{
      'address': instance.address,
      'quantity': instance.quantity,
      'quantity_normalized': instance.quantityNormalized,
      'utxo': instance.utxo,
      'utxo_address': instance.utxoAddress,
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
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
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
      eventIndex: (json['event_index'] as num?)?.toInt(),
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
      eventIndex: (json['event_index'] as num?)?.toInt(),
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
      eventIndex: (json['event_index'] as num?)?.toInt(),
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
      eventIndex: (json['event_index'] as num?)?.toInt(),
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
      eventIndex: (json['event_index'] as num?)?.toInt(),
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
      asset: json['asset'] as String?,
      assetLongname: json['asset_longname'] as String?,
      assetEvents: json['asset_events'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      source: json['source'] as String,
      status: json['status'] as String,
      transfer: json['transfer'] as bool,
    );

Map<String, dynamic> _$AssetIssuanceParamsToJson(
        AssetIssuanceParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'asset_longname': instance.assetLongname,
      'asset_events': instance.assetEvents,
      'quantity': instance.quantity,
      'source': instance.source,
      'status': instance.status,
      'transfer': instance.transfer,
    };

VerboseAssetIssuanceParams _$VerboseAssetIssuanceParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseAssetIssuanceParams(
      asset: json['asset'] as String?,
      assetLongname: json['asset_longname'] as String?,
      assetEvents: json['asset_events'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      source: json['source'] as String,
      status: json['status'] as String,
      transfer: json['transfer'] as bool,
      blockTime: (json['block_time'] as num?)?.toInt(),
      quantityNormalized: json['quantity_normalized'] as String?,
      feePaidNormalized: json['fee_paid_normalized'] as String,
    );

Map<String, dynamic> _$VerboseAssetIssuanceParamsToJson(
        VerboseAssetIssuanceParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'asset_longname': instance.assetLongname,
      'asset_events': instance.assetEvents,
      'quantity': instance.quantity,
      'source': instance.source,
      'status': instance.status,
      'transfer': instance.transfer,
      'block_time': instance.blockTime,
      'quantity_normalized': instance.quantityNormalized,
      'fee_paid_normalized': instance.feePaidNormalized,
    };

ResetIssuanceEvent _$ResetIssuanceEventFromJson(Map<String, dynamic> json) =>
    ResetIssuanceEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params:
          AssetIssuanceParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResetIssuanceEventToJson(ResetIssuanceEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

AssetIssuanceEvent _$AssetIssuanceEventFromJson(Map<String, dynamic> json) =>
    AssetIssuanceEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
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
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
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

OpenDispenserEvent _$OpenDispenserEventFromJson(Map<String, dynamic> json) =>
    OpenDispenserEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params:
          OpenDispenserParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenDispenserEventToJson(OpenDispenserEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

VerboseResetIssuanceEvent _$VerboseResetIssuanceEventFromJson(
        Map<String, dynamic> json) =>
    VerboseResetIssuanceEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseAssetIssuanceParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseResetIssuanceEventToJson(
        VerboseResetIssuanceEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

NewFairminterEvent _$NewFairminterEventFromJson(Map<String, dynamic> json) =>
    NewFairminterEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params:
          NewFairminterParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NewFairminterEventToJson(NewFairminterEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

NewFairminterParams _$NewFairminterParamsFromJson(Map<String, dynamic> json) =>
    NewFairminterParams(
      asset: json['asset'] as String?,
      assetLongname: json['asset_longname'] as String?,
      assetParent: json['asset_parent'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      burnPayment: json['burn_payment'] as bool?,
      description: json['description'] as String?,
      divisible: json['divisible'] as bool?,
      endBlock: (json['end_block'] as num?)?.toInt(),
      hardCap: (json['hard_cap'] as num?)?.toInt(),
      lockDescription: json['lock_description'] as bool?,
      lockQuantity: json['lock_quantity'] as bool?,
      maxMintPerTx: (json['max_mint_per_tx'] as num?)?.toInt(),
      mintedAssetCommissionInt:
          (json['minted_asset_commission_int'] as num?)?.toInt(),
      preMinted: json['pre_minted'] as bool?,
      premintQuantity: (json['premint_quantity'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toInt(),
      quantityByPrice: (json['quantity_by_price'] as num?)?.toInt(),
      softCap: (json['soft_cap'] as num?)?.toInt(),
      softCapDeadlineBlock: (json['soft_cap_deadline_block'] as num?)?.toInt(),
      source: json['source'] as String?,
      startBlock: (json['start_block'] as num?)?.toInt(),
      status: json['status'] as String?,
      txHash: json['tx_hash'] as String?,
      txIndex: (json['tx_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NewFairminterParamsToJson(
        NewFairminterParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'asset_longname': instance.assetLongname,
      'asset_parent': instance.assetParent,
      'block_index': instance.blockIndex,
      'burn_payment': instance.burnPayment,
      'description': instance.description,
      'divisible': instance.divisible,
      'end_block': instance.endBlock,
      'hard_cap': instance.hardCap,
      'lock_description': instance.lockDescription,
      'lock_quantity': instance.lockQuantity,
      'max_mint_per_tx': instance.maxMintPerTx,
      'minted_asset_commission_int': instance.mintedAssetCommissionInt,
      'pre_minted': instance.preMinted,
      'premint_quantity': instance.premintQuantity,
      'price': instance.price,
      'quantity_by_price': instance.quantityByPrice,
      'soft_cap': instance.softCap,
      'soft_cap_deadline_block': instance.softCapDeadlineBlock,
      'source': instance.source,
      'start_block': instance.startBlock,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'block_time': instance.blockTime,
    };

VerboseNewFairminterEvent _$VerboseNewFairminterEventFromJson(
        Map<String, dynamic> json) =>
    VerboseNewFairminterEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseNewFairminterParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseNewFairminterEventToJson(
        VerboseNewFairminterEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseNewFairminterParams _$VerboseNewFairminterParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseNewFairminterParams(
      asset: json['asset'] as String?,
      assetLongname: json['asset_longname'] as String?,
      assetParent: json['asset_parent'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      burnPayment: json['burn_payment'] as bool?,
      description: json['description'] as String?,
      divisible: json['divisible'] as bool?,
      endBlock: (json['end_block'] as num?)?.toInt(),
      hardCap: (json['hard_cap'] as num?)?.toInt(),
      lockDescription: json['lock_description'] as bool?,
      lockQuantity: json['lock_quantity'] as bool?,
      maxMintPerTx: (json['max_mint_per_tx'] as num?)?.toInt(),
      mintedAssetCommissionInt:
          (json['minted_asset_commission_int'] as num?)?.toInt(),
      preMinted: json['pre_minted'] as bool?,
      premintQuantity: (json['premint_quantity'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toInt(),
      quantityByPrice: (json['quantity_by_price'] as num?)?.toInt(),
      softCap: (json['soft_cap'] as num?)?.toInt(),
      softCapDeadlineBlock: (json['soft_cap_deadline_block'] as num?)?.toInt(),
      source: json['source'] as String?,
      startBlock: (json['start_block'] as num?)?.toInt(),
      status: json['status'] as String?,
      txHash: json['tx_hash'] as String?,
      txIndex: (json['tx_index'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VerboseNewFairminterParamsToJson(
        VerboseNewFairminterParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'asset_longname': instance.assetLongname,
      'asset_parent': instance.assetParent,
      'block_index': instance.blockIndex,
      'burn_payment': instance.burnPayment,
      'description': instance.description,
      'divisible': instance.divisible,
      'end_block': instance.endBlock,
      'hard_cap': instance.hardCap,
      'lock_description': instance.lockDescription,
      'lock_quantity': instance.lockQuantity,
      'max_mint_per_tx': instance.maxMintPerTx,
      'minted_asset_commission_int': instance.mintedAssetCommissionInt,
      'pre_minted': instance.preMinted,
      'premint_quantity': instance.premintQuantity,
      'price': instance.price,
      'quantity_by_price': instance.quantityByPrice,
      'soft_cap': instance.softCap,
      'soft_cap_deadline_block': instance.softCapDeadlineBlock,
      'source': instance.source,
      'start_block': instance.startBlock,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
    };

NewFairmintEvent _$NewFairmintEventFromJson(Map<String, dynamic> json) =>
    NewFairmintEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params:
          NewFairmintParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NewFairmintEventToJson(NewFairmintEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

NewFairmintParams _$NewFairmintParamsFromJson(Map<String, dynamic> json) =>
    NewFairmintParams(
      asset: json['asset'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      commission: (json['commission'] as num?)?.toInt(),
      earnQuantity: (json['earn_quantity'] as num?)?.toInt(),
      fairminterTxHash: json['fairminter_tx_hash'] as String?,
      paidQuantity: (json['paid_quantity'] as num?)?.toInt(),
      source: json['source'] as String?,
      status: json['status'] as String?,
      txHash: json['tx_hash'] as String?,
      txIndex: (json['tx_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NewFairmintParamsToJson(NewFairmintParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'commission': instance.commission,
      'earn_quantity': instance.earnQuantity,
      'fairminter_tx_hash': instance.fairminterTxHash,
      'paid_quantity': instance.paidQuantity,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'block_time': instance.blockTime,
    };

VerboseNewFairmintEvent _$VerboseNewFairmintEventFromJson(
        Map<String, dynamic> json) =>
    VerboseNewFairmintEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseNewFairmintParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseNewFairmintEventToJson(
        VerboseNewFairmintEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseNewFairmintParams _$VerboseNewFairmintParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseNewFairmintParams(
      asset: json['asset'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      commission: (json['commission'] as num?)?.toInt(),
      earnQuantity: (json['earn_quantity'] as num?)?.toInt(),
      fairminterTxHash: json['fairminter_tx_hash'] as String?,
      paidQuantity: (json['paid_quantity'] as num?)?.toInt(),
      source: json['source'] as String?,
      status: json['status'] as String?,
      txHash: json['tx_hash'] as String?,
      txIndex: (json['tx_index'] as num?)?.toInt(),
      assetInfo: json['asset_info'] == null
          ? null
          : AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseNewFairmintParamsToJson(
        VerboseNewFairmintParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'commission': instance.commission,
      'earn_quantity': instance.earnQuantity,
      'fairminter_tx_hash': instance.fairminterTxHash,
      'paid_quantity': instance.paidQuantity,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'asset_info': instance.assetInfo,
    };

OpenDispenserParams _$OpenDispenserParamsFromJson(Map<String, dynamic> json) =>
    OpenDispenserParams(
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      escrowQuantity: (json['escrow_quantity'] as num).toInt(),
      giveQuantity: (json['give_quantity'] as num).toInt(),
      giveRemaining: (json['give_remaining'] as num).toInt(),
      oracleAddress: json['oracle_address'] as String?,
      origin: json['origin'] as String,
      satoshirate: (json['satoshirate'] as num).toInt(),
      source: json['source'] as String,
      status: (json['status'] as num).toInt(),
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
    );

Map<String, dynamic> _$OpenDispenserParamsToJson(
        OpenDispenserParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'escrow_quantity': instance.escrowQuantity,
      'give_quantity': instance.giveQuantity,
      'give_remaining': instance.giveRemaining,
      'oracle_address': instance.oracleAddress,
      'origin': instance.origin,
      'satoshirate': instance.satoshirate,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
    };

VerboseOpenDispenserEvent _$VerboseOpenDispenserEventFromJson(
        Map<String, dynamic> json) =>
    VerboseOpenDispenserEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseOpenDispenserParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseOpenDispenserEventToJson(
        VerboseOpenDispenserEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseOpenDispenserParams _$VerboseOpenDispenserParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseOpenDispenserParams(
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      escrowQuantity: (json['escrow_quantity'] as num).toInt(),
      giveQuantity: (json['give_quantity'] as num).toInt(),
      giveRemaining: (json['give_remaining'] as num).toInt(),
      oracleAddress: json['oracle_address'] as String?,
      origin: json['origin'] as String,
      satoshirate: (json['satoshirate'] as num).toInt(),
      source: json['source'] as String,
      status: (json['status'] as num).toInt(),
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      giveQuantityNormalized: json['give_quantity_normalized'] as String,
      giveRemainingNormalized: json['give_remaining_normalized'] as String,
      escrowQuantityNormalized: json['escrow_quantity_normalized'] as String,
      satoshirateNormalized: json['satoshirate_normalized'] as String,
    );

Map<String, dynamic> _$VerboseOpenDispenserParamsToJson(
        VerboseOpenDispenserParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'escrow_quantity': instance.escrowQuantity,
      'give_quantity': instance.giveQuantity,
      'give_remaining': instance.giveRemaining,
      'oracle_address': instance.oracleAddress,
      'origin': instance.origin,
      'satoshirate': instance.satoshirate,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'give_quantity_normalized': instance.giveQuantityNormalized,
      'give_remaining_normalized': instance.giveRemainingNormalized,
      'escrow_quantity_normalized': instance.escrowQuantityNormalized,
      'satoshirate_normalized': instance.satoshirateNormalized,
    };

OpenOrderEvent _$OpenOrderEventFromJson(Map<String, dynamic> json) =>
    OpenOrderEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params: OpenOrderParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenOrderEventToJson(OpenOrderEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

OpenOrderParams _$OpenOrderParamsFromJson(Map<String, dynamic> json) =>
    OpenOrderParams(
      blockIndex: (json['block_index'] as num).toInt(),
      expiration: (json['expiration'] as num).toInt(),
      expireIndex: (json['expire_index'] as num).toInt(),
      feeProvided: (json['fee_provided'] as num).toInt(),
      feeProvidedRemaining: (json['fee_provided_remaining'] as num).toInt(),
      feeRequired: (json['fee_required'] as num).toInt(),
      feeRequiredRemaining: (json['fee_required_remaining'] as num).toInt(),
      getAsset: json['get_asset'] as String,
      getQuantity: (json['get_quantity'] as num).toInt(),
      getRemaining: (json['get_remaining'] as num).toInt(),
      giveAsset: json['give_asset'] as String,
      giveQuantity: (json['give_quantity'] as num).toInt(),
      giveRemaining: (json['give_remaining'] as num).toInt(),
      source: json['source'] as String,
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
    );

Map<String, dynamic> _$OpenOrderParamsToJson(OpenOrderParams instance) =>
    <String, dynamic>{
      'block_index': instance.blockIndex,
      'expiration': instance.expiration,
      'expire_index': instance.expireIndex,
      'fee_provided': instance.feeProvided,
      'fee_provided_remaining': instance.feeProvidedRemaining,
      'fee_required': instance.feeRequired,
      'fee_required_remaining': instance.feeRequiredRemaining,
      'get_asset': instance.getAsset,
      'get_quantity': instance.getQuantity,
      'get_remaining': instance.getRemaining,
      'give_asset': instance.giveAsset,
      'give_quantity': instance.giveQuantity,
      'give_remaining': instance.giveRemaining,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
    };

VerboseOpenOrderEvent _$VerboseOpenOrderEventFromJson(
        Map<String, dynamic> json) =>
    VerboseOpenOrderEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseOpenOrderParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseOpenOrderEventToJson(
        VerboseOpenOrderEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseOpenOrderParams _$VerboseOpenOrderParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseOpenOrderParams(
      blockIndex: (json['block_index'] as num).toInt(),
      expiration: (json['expiration'] as num).toInt(),
      expireIndex: (json['expire_index'] as num).toInt(),
      feeProvided: (json['fee_provided'] as num).toInt(),
      feeProvidedRemaining: (json['fee_provided_remaining'] as num).toInt(),
      feeRequired: (json['fee_required'] as num).toInt(),
      feeRequiredRemaining: (json['fee_required_remaining'] as num).toInt(),
      getAsset: json['get_asset'] as String,
      getQuantity: (json['get_quantity'] as num).toInt(),
      getRemaining: (json['get_remaining'] as num).toInt(),
      giveAsset: json['give_asset'] as String,
      giveQuantity: (json['give_quantity'] as num).toInt(),
      giveRemaining: (json['give_remaining'] as num).toInt(),
      source: json['source'] as String,
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
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
      giveAssetInfo: AssetInfoModel.fromJson(
          json['give_asset_info'] as Map<String, dynamic>),
      getAssetInfo: AssetInfoModel.fromJson(
          json['get_asset_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseOpenOrderParamsToJson(
        VerboseOpenOrderParams instance) =>
    <String, dynamic>{
      'block_index': instance.blockIndex,
      'expiration': instance.expiration,
      'expire_index': instance.expireIndex,
      'fee_provided': instance.feeProvided,
      'fee_provided_remaining': instance.feeProvidedRemaining,
      'fee_required': instance.feeRequired,
      'fee_required_remaining': instance.feeRequiredRemaining,
      'get_asset': instance.getAsset,
      'get_quantity': instance.getQuantity,
      'get_remaining': instance.getRemaining,
      'give_asset': instance.giveAsset,
      'give_quantity': instance.giveQuantity,
      'give_remaining': instance.giveRemaining,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
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
      'give_asset_info': instance.giveAssetInfo,
      'get_asset_info': instance.getAssetInfo,
    };

OrderMatchEvent _$OrderMatchEventFromJson(Map<String, dynamic> json) =>
    OrderMatchEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params: OrderMatchParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderMatchEventToJson(OrderMatchEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

OrderMatchParams _$OrderMatchParamsFromJson(Map<String, dynamic> json) =>
    OrderMatchParams(
      backwardAsset: json['backward_asset'] as String,
      backwardQuantity: (json['backward_quantity'] as num).toInt(),
      blockIndex: (json['block_index'] as num).toInt(),
      feePaid: (json['fee_paid'] as num).toInt(),
      forwardAsset: json['forward_asset'] as String,
      forwardQuantity: (json['forward_quantity'] as num).toInt(),
      id: json['id'] as String,
      matchExpireIndex: (json['match_expire_index'] as num).toInt(),
      status: json['status'] as String,
      tx0Address: json['tx0_address'] as String,
      tx0BlockIndex: (json['tx0_block_index'] as num).toInt(),
      tx0Expiration: (json['tx0_expiration'] as num).toInt(),
      tx0Hash: json['tx0_hash'] as String,
      tx0Index: (json['tx0_index'] as num).toInt(),
      tx1Address: json['tx1_address'] as String,
      tx1BlockIndex: (json['tx1_block_index'] as num).toInt(),
      tx1Expiration: (json['tx1_expiration'] as num).toInt(),
      tx1Hash: json['tx1_hash'] as String,
      tx1Index: (json['tx1_index'] as num).toInt(),
    );

Map<String, dynamic> _$OrderMatchParamsToJson(OrderMatchParams instance) =>
    <String, dynamic>{
      'backward_asset': instance.backwardAsset,
      'backward_quantity': instance.backwardQuantity,
      'block_index': instance.blockIndex,
      'fee_paid': instance.feePaid,
      'forward_asset': instance.forwardAsset,
      'forward_quantity': instance.forwardQuantity,
      'id': instance.id,
      'match_expire_index': instance.matchExpireIndex,
      'status': instance.status,
      'tx0_address': instance.tx0Address,
      'tx0_block_index': instance.tx0BlockIndex,
      'tx0_expiration': instance.tx0Expiration,
      'tx0_hash': instance.tx0Hash,
      'tx0_index': instance.tx0Index,
      'tx1_address': instance.tx1Address,
      'tx1_block_index': instance.tx1BlockIndex,
      'tx1_expiration': instance.tx1Expiration,
      'tx1_hash': instance.tx1Hash,
      'tx1_index': instance.tx1Index,
    };

VerboseOrderMatchEvent _$VerboseOrderMatchEventFromJson(
        Map<String, dynamic> json) =>
    VerboseOrderMatchEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseOrderMatchParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseOrderMatchEventToJson(
        VerboseOrderMatchEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseOrderMatchParams _$VerboseOrderMatchParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseOrderMatchParams(
      backwardAsset: json['backward_asset'] as String,
      backwardQuantity: (json['backward_quantity'] as num).toInt(),
      blockIndex: (json['block_index'] as num).toInt(),
      feePaid: (json['fee_paid'] as num).toInt(),
      forwardAsset: json['forward_asset'] as String,
      forwardQuantity: (json['forward_quantity'] as num).toInt(),
      id: json['id'] as String,
      matchExpireIndex: (json['match_expire_index'] as num).toInt(),
      status: json['status'] as String,
      tx0Address: json['tx0_address'] as String,
      tx0BlockIndex: (json['tx0_block_index'] as num).toInt(),
      tx0Expiration: (json['tx0_expiration'] as num).toInt(),
      tx0Hash: json['tx0_hash'] as String,
      tx0Index: (json['tx0_index'] as num).toInt(),
      tx1Address: json['tx1_address'] as String,
      tx1BlockIndex: (json['tx1_block_index'] as num).toInt(),
      tx1Expiration: (json['tx1_expiration'] as num).toInt(),
      tx1Hash: json['tx1_hash'] as String,
      tx1Index: (json['tx1_index'] as num).toInt(),
      forwardQuantityNormalized: json['forward_quantity_normalized'] as String,
      backwardQuantityNormalized:
          json['backward_quantity_normalized'] as String,
      feePaidNormalized: json['fee_paid_normalized'] as String,
      forwardAssetInfo: AssetInfoModel.fromJson(
          json['forward_asset_info'] as Map<String, dynamic>),
      backwardAssetInfo: AssetInfoModel.fromJson(
          json['backward_asset_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseOrderMatchParamsToJson(
        VerboseOrderMatchParams instance) =>
    <String, dynamic>{
      'backward_asset': instance.backwardAsset,
      'backward_quantity': instance.backwardQuantity,
      'block_index': instance.blockIndex,
      'fee_paid': instance.feePaid,
      'forward_asset': instance.forwardAsset,
      'forward_quantity': instance.forwardQuantity,
      'id': instance.id,
      'match_expire_index': instance.matchExpireIndex,
      'status': instance.status,
      'tx0_address': instance.tx0Address,
      'tx0_block_index': instance.tx0BlockIndex,
      'tx0_expiration': instance.tx0Expiration,
      'tx0_hash': instance.tx0Hash,
      'tx0_index': instance.tx0Index,
      'tx1_address': instance.tx1Address,
      'tx1_block_index': instance.tx1BlockIndex,
      'tx1_expiration': instance.tx1Expiration,
      'tx1_hash': instance.tx1Hash,
      'tx1_index': instance.tx1Index,
      'forward_quantity_normalized': instance.forwardQuantityNormalized,
      'backward_quantity_normalized': instance.backwardQuantityNormalized,
      'fee_paid_normalized': instance.feePaidNormalized,
      'forward_asset_info': instance.forwardAssetInfo,
      'backward_asset_info': instance.backwardAssetInfo,
    };

OrderUpdateEvent _$OrderUpdateEventFromJson(Map<String, dynamic> json) =>
    OrderUpdateEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params:
          OrderUpdateParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderUpdateEventToJson(OrderUpdateEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

OrderUpdateParams _$OrderUpdateParamsFromJson(Map<String, dynamic> json) =>
    OrderUpdateParams(
      feeProvidedRemaining: (json['fee_provided_remaining'] as num).toInt(),
      feeRequiredRemaining: (json['fee_required_remaining'] as num).toInt(),
      getRemaining: (json['get_remaining'] as num).toInt(),
      giveRemaining: (json['give_remaining'] as num).toInt(),
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
    );

Map<String, dynamic> _$OrderUpdateParamsToJson(OrderUpdateParams instance) =>
    <String, dynamic>{
      'fee_provided_remaining': instance.feeProvidedRemaining,
      'fee_required_remaining': instance.feeRequiredRemaining,
      'get_remaining': instance.getRemaining,
      'give_remaining': instance.giveRemaining,
      'status': instance.status,
      'tx_hash': instance.txHash,
    };

VerboseOrderUpdateEvent _$VerboseOrderUpdateEventFromJson(
        Map<String, dynamic> json) =>
    VerboseOrderUpdateEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VerboseOrderUpdateEventToJson(
        VerboseOrderUpdateEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
    };

VerboseOrderUpdateParams _$VerboseOrderUpdateParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseOrderUpdateParams(
      feeProvidedRemaining: (json['fee_provided_remaining'] as num).toInt(),
      feeRequiredRemaining: (json['fee_required_remaining'] as num).toInt(),
      getRemaining: (json['get_remaining'] as num).toInt(),
      giveRemaining: (json['give_remaining'] as num).toInt(),
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
      feeProvidedRemainingNormalized:
          json['fee_provided_remaining_normalized'] as String,
      feeRequiredRemainingNormalized:
          json['fee_required_remaining_normalized'] as String,
      getRemainingNormalized: json['get_remaining_normalized'] as String,
      giveRemainingNormalized: json['give_remaining_normalized'] as String,
    );

Map<String, dynamic> _$VerboseOrderUpdateParamsToJson(
        VerboseOrderUpdateParams instance) =>
    <String, dynamic>{
      'fee_provided_remaining': instance.feeProvidedRemaining,
      'fee_required_remaining': instance.feeRequiredRemaining,
      'get_remaining': instance.getRemaining,
      'give_remaining': instance.giveRemaining,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'fee_provided_remaining_normalized':
          instance.feeProvidedRemainingNormalized,
      'fee_required_remaining_normalized':
          instance.feeRequiredRemainingNormalized,
      'get_remaining_normalized': instance.getRemainingNormalized,
      'give_remaining_normalized': instance.giveRemainingNormalized,
    };

OrderFilledEvent _$OrderFilledEventFromJson(Map<String, dynamic> json) =>
    OrderFilledEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params:
          OrderFilledParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderFilledEventToJson(OrderFilledEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

DetachFromUtxoEvent _$DetachFromUtxoEventFromJson(Map<String, dynamic> json) =>
    DetachFromUtxoEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params:
          DetachFromUtxoParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DetachFromUtxoEventToJson(
        DetachFromUtxoEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

DetachFromUtxoParams _$DetachFromUtxoParamsFromJson(
        Map<String, dynamic> json) =>
    DetachFromUtxoParams(
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      destination: json['destination'] as String,
      feePaid: (json['fee_paid'] as num).toInt(),
      msgIndex: (json['msg_index'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      source: json['source'] as String,
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      blockTime: (json['block_time'] as num).toInt(),
    );

Map<String, dynamic> _$DetachFromUtxoParamsToJson(
        DetachFromUtxoParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'destination': instance.destination,
      'fee_paid': instance.feePaid,
      'msg_index': instance.msgIndex,
      'quantity': instance.quantity,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'block_time': instance.blockTime,
    };

VerboseDetachFromUtxoEvent _$VerboseDetachFromUtxoEventFromJson(
        Map<String, dynamic> json) =>
    VerboseDetachFromUtxoEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseDetachFromUtxoParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseDetachFromUtxoEventToJson(
        VerboseDetachFromUtxoEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseDetachFromUtxoParams _$VerboseDetachFromUtxoParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseDetachFromUtxoParams(
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      destination: json['destination'] as String,
      feePaid: (json['fee_paid'] as num).toInt(),
      msgIndex: (json['msg_index'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      source: json['source'] as String,
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
      quantityNormalized: json['quantity_normalized'] as String,
      feePaidNormalized: json['fee_paid_normalized'] as String,
    );

Map<String, dynamic> _$VerboseDetachFromUtxoParamsToJson(
        VerboseDetachFromUtxoParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'destination': instance.destination,
      'fee_paid': instance.feePaid,
      'msg_index': instance.msgIndex,
      'quantity': instance.quantity,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'block_time': instance.blockTime,
      'asset_info': instance.assetInfo,
      'quantity_normalized': instance.quantityNormalized,
      'fee_paid_normalized': instance.feePaidNormalized,
    };

AttachToUtxoEvent _$AttachToUtxoEventFromJson(Map<String, dynamic> json) =>
    AttachToUtxoEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params:
          AttachToUtxoParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AttachToUtxoEventToJson(AttachToUtxoEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

AttachToUtxoParams _$AttachToUtxoParamsFromJson(Map<String, dynamic> json) =>
    AttachToUtxoParams(
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      destination: json['destination'] as String,
      feePaid: (json['fee_paid'] as num).toInt(),
      msgIndex: (json['msg_index'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      source: json['source'] as String,
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      blockTime: (json['block_time'] as num).toInt(),
    );

Map<String, dynamic> _$AttachToUtxoParamsToJson(AttachToUtxoParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'destination': instance.destination,
      'fee_paid': instance.feePaid,
      'msg_index': instance.msgIndex,
      'quantity': instance.quantity,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'block_time': instance.blockTime,
    };

OrderFilledParams _$OrderFilledParamsFromJson(Map<String, dynamic> json) =>
    OrderFilledParams(
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
    );

Map<String, dynamic> _$OrderFilledParamsToJson(OrderFilledParams instance) =>
    <String, dynamic>{
      'status': instance.status,
      'tx_hash': instance.txHash,
    };

VerboseOrderFilledEvent _$VerboseOrderFilledEventFromJson(
        Map<String, dynamic> json) =>
    VerboseOrderFilledEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseOrderFilledParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseOrderFilledEventToJson(
        VerboseOrderFilledEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseOrderFilledParams _$VerboseOrderFilledParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseOrderFilledParams(
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
    );

Map<String, dynamic> _$VerboseOrderFilledParamsToJson(
        VerboseOrderFilledParams instance) =>
    <String, dynamic>{
      'status': instance.status,
      'tx_hash': instance.txHash,
    };

CancelOrderEvent _$CancelOrderEventFromJson(Map<String, dynamic> json) =>
    CancelOrderEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params:
          CancelOrderParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CancelOrderEventToJson(CancelOrderEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

CancelOrderParams _$CancelOrderParamsFromJson(Map<String, dynamic> json) =>
    CancelOrderParams(
      blockIndex: (json['block_index'] as num).toInt(),
      offerHash: json['offer_hash'] as String,
      source: json['source'] as String,
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
    );

Map<String, dynamic> _$CancelOrderParamsToJson(CancelOrderParams instance) =>
    <String, dynamic>{
      'block_index': instance.blockIndex,
      'offer_hash': instance.offerHash,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
    };

VerboseCancelOrderEvent _$VerboseCancelOrderEventFromJson(
        Map<String, dynamic> json) =>
    VerboseCancelOrderEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseCancelOrderParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseCancelOrderEventToJson(
        VerboseCancelOrderEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseCancelOrderParams _$VerboseCancelOrderParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseCancelOrderParams(
      blockIndex: (json['block_index'] as num).toInt(),
      offerHash: json['offer_hash'] as String,
      source: json['source'] as String,
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
    );

Map<String, dynamic> _$VerboseCancelOrderParamsToJson(
        VerboseCancelOrderParams instance) =>
    <String, dynamic>{
      'block_index': instance.blockIndex,
      'offer_hash': instance.offerHash,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
    };

OrderExpirationEvent _$OrderExpirationEventFromJson(
        Map<String, dynamic> json) =>
    OrderExpirationEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params: OrderExpirationParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderExpirationEventToJson(
        OrderExpirationEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

OrderExpirationParams _$OrderExpirationParamsFromJson(
        Map<String, dynamic> json) =>
    OrderExpirationParams(
      blockIndex: (json['block_index'] as num).toInt(),
      orderHash: json['order_hash'] as String,
      source: json['source'] as String,
      blockTime: (json['block_time'] as num).toInt(),
    );

Map<String, dynamic> _$OrderExpirationParamsToJson(
        OrderExpirationParams instance) =>
    <String, dynamic>{
      'block_index': instance.blockIndex,
      'order_hash': instance.orderHash,
      'source': instance.source,
      'block_time': instance.blockTime,
    };

VerboseOrderExpirationEvent _$VerboseOrderExpirationEventFromJson(
        Map<String, dynamic> json) =>
    VerboseOrderExpirationEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseOrderExpirationParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseOrderExpirationEventToJson(
        VerboseOrderExpirationEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseOrderExpirationParams _$VerboseOrderExpirationParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseOrderExpirationParams(
      blockIndex: (json['block_index'] as num).toInt(),
      orderHash: json['order_hash'] as String,
      source: json['source'] as String,
      blockTime: (json['block_time'] as num).toInt(),
    );

Map<String, dynamic> _$VerboseOrderExpirationParamsToJson(
        VerboseOrderExpirationParams instance) =>
    <String, dynamic>{
      'block_index': instance.blockIndex,
      'order_hash': instance.orderHash,
      'source': instance.source,
      'block_time': instance.blockTime,
    };

VerboseAttachToUtxoEvent _$VerboseAttachToUtxoEventFromJson(
        Map<String, dynamic> json) =>
    VerboseAttachToUtxoEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseAttachToUtxoParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseAttachToUtxoEventToJson(
        VerboseAttachToUtxoEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseAttachToUtxoParams _$VerboseAttachToUtxoParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseAttachToUtxoParams(
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      destination: json['destination'] as String,
      feePaid: (json['fee_paid'] as num).toInt(),
      msgIndex: (json['msg_index'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      source: json['source'] as String,
      status: json['status'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      blockTime: (json['block_time'] as num).toInt(),
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
      quantityNormalized: json['quantity_normalized'] as String,
      feePaidNormalized: json['fee_paid_normalized'] as String,
    );

Map<String, dynamic> _$VerboseAttachToUtxoParamsToJson(
        VerboseAttachToUtxoParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'destination': instance.destination,
      'fee_paid': instance.feePaid,
      'msg_index': instance.msgIndex,
      'quantity': instance.quantity,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'block_time': instance.blockTime,
      'asset_info': instance.assetInfo,
      'quantity_normalized': instance.quantityNormalized,
      'fee_paid_normalized': instance.feePaidNormalized,
    };

DispenserUpdateEvent _$DispenserUpdateEventFromJson(
        Map<String, dynamic> json) =>
    DispenserUpdateEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params: DispenserUpdateParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DispenserUpdateEventToJson(
        DispenserUpdateEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

DispenserUpdateParams _$DispenserUpdateParamsFromJson(
        Map<String, dynamic> json) =>
    DispenserUpdateParams(
      asset: json['asset'] as String,
      closeBlockIndex: (json['close_block_index'] as num?)?.toInt(),
      lastStatusTxHash: json['last_status_tx_hash'] as String?,
      lastStatusTxSource: json['last_status_tx_source'] as String?,
      source: json['source'] as String,
      status: (json['status'] as num).toInt(),
      txHash: json['tx_hash'] as String?,
      giveRemaining: (json['give_remaining'] as num?)?.toInt(),
      dispenseCount: (json['dispense_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DispenserUpdateParamsToJson(
        DispenserUpdateParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'close_block_index': instance.closeBlockIndex,
      'last_status_tx_hash': instance.lastStatusTxHash,
      'last_status_tx_source': instance.lastStatusTxSource,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'give_remaining': instance.giveRemaining,
      'dispense_count': instance.dispenseCount,
    };

VerboseDispenserUpdateEvent _$VerboseDispenserUpdateEventFromJson(
        Map<String, dynamic> json) =>
    VerboseDispenserUpdateEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseDispenserUpdateParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseDispenserUpdateEventToJson(
        VerboseDispenserUpdateEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseDispenserUpdateParams _$VerboseDispenserUpdateParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseDispenserUpdateParams(
      asset: json['asset'] as String,
      closeBlockIndex: (json['close_block_index'] as num?)?.toInt(),
      lastStatusTxHash: json['last_status_tx_hash'] as String?,
      lastStatusTxSource: json['last_status_tx_source'] as String?,
      source: json['source'] as String,
      status: (json['status'] as num).toInt(),
      txHash: json['tx_hash'] as String?,
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseDispenserUpdateParamsToJson(
        VerboseDispenserUpdateParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'close_block_index': instance.closeBlockIndex,
      'last_status_tx_hash': instance.lastStatusTxHash,
      'last_status_tx_source': instance.lastStatusTxSource,
      'source': instance.source,
      'status': instance.status,
      'tx_hash': instance.txHash,
      'asset_info': instance.assetInfo,
    };

RefillDispenserEvent _$RefillDispenserEventFromJson(
        Map<String, dynamic> json) =>
    RefillDispenserEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      params: RefillDispenserParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RefillDispenserEventToJson(
        RefillDispenserEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'params': instance.params,
    };

RefillDispenserParams _$RefillDispenserParamsFromJson(
        Map<String, dynamic> json) =>
    RefillDispenserParams(
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      destination: json['destination'] as String,
      dispenseQuantity: (json['dispense_quantity'] as num).toInt(),
      dispenserTxHash: json['dispenser_tx_hash'] as String,
      source: json['source'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
    );

Map<String, dynamic> _$RefillDispenserParamsToJson(
        RefillDispenserParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'destination': instance.destination,
      'dispense_quantity': instance.dispenseQuantity,
      'dispenser_tx_hash': instance.dispenserTxHash,
      'source': instance.source,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
    };

VerboseRefillDispenserEvent _$VerboseRefillDispenserEventFromJson(
        Map<String, dynamic> json) =>
    VerboseRefillDispenserEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
      params: VerboseRefillDispenserParams.fromJson(
          json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseRefillDispenserEventToJson(
        VerboseRefillDispenserEvent instance) =>
    <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
      'tx_hash': instance.txHash,
      'block_index': instance.blockIndex,
      'block_time': instance.blockTime,
      'params': instance.params,
    };

VerboseRefillDispenserParams _$VerboseRefillDispenserParamsFromJson(
        Map<String, dynamic> json) =>
    VerboseRefillDispenserParams(
      asset: json['asset'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      destination: json['destination'] as String,
      dispenseQuantity: (json['dispense_quantity'] as num).toInt(),
      dispenserTxHash: json['dispenser_tx_hash'] as String,
      source: json['source'] as String,
      txHash: json['tx_hash'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      dispenseQuantityNormalized:
          json['dispense_quantity_normalized'] as String,
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerboseRefillDispenserParamsToJson(
        VerboseRefillDispenserParams instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'block_index': instance.blockIndex,
      'destination': instance.destination,
      'dispense_quantity': instance.dispenseQuantity,
      'dispenser_tx_hash': instance.dispenserTxHash,
      'source': instance.source,
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'dispense_quantity_normalized': instance.dispenseQuantityNormalized,
      'asset_info': instance.assetInfo,
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
      eventIndex: (json['event_index'] as num?)?.toInt(),
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
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
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
      blockTime: (json['block_time'] as num?)?.toInt(),
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
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
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
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
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
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

VerboseEvent _$VerboseEventFromJson(Map<String, dynamic> json) => VerboseEvent(
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
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
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
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
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
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
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
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
      eventIndex: (json['event_index'] as num?)?.toInt(),
      event: json['event'] as String,
      txHash: json['tx_hash'] as String?,
      blockIndex: (json['block_index'] as num?)?.toInt(),
      blockTime: (json['block_time'] as num?)?.toInt(),
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

AssetVerbose _$AssetVerboseFromJson(Map<String, dynamic> json) => AssetVerbose(
      asset: json['asset'] as String,
      assetLongname: json['asset_longname'] as String?,
      description: json['description'] as String?,
      divisible: json['divisible'] as bool?,
      locked: json['locked'] as bool?,
      issuer: json['issuer'] as String?,
      owner: json['owner'] as String?,
      supply: (json['supply'] as num?)?.toInt(),
      confirmed: json['confirmed'] as bool?,
      supplyNormalized: json['supply_normalized'] as String?,
    );

Map<String, dynamic> _$AssetVerboseToJson(AssetVerbose instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'asset_longname': instance.assetLongname,
      'description': instance.description,
      'issuer': instance.issuer,
      'owner': instance.owner,
      'divisible': instance.divisible,
      'locked': instance.locked,
      'supply': instance.supply,
      'confirmed': instance.confirmed,
      'supply_normalized': instance.supplyNormalized,
    };

Credit _$CreditFromJson(Map<String, dynamic> json) => Credit(
      blockIndex: json['block_index'] as String,
      address: json['address'] as String,
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      callingFunction: json['calling_function'] as String,
      event: json['event'] as String,
      txIndex: (json['tx_index'] as num).toInt(),
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
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
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
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
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
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
      reset: json['reset'] as bool,
      description: json['description'] as String?,
      transferDestination: json['transfer_destination'] as String?,
    );

Map<String, dynamic> _$ComposeIssuanceParamsToJson(
        ComposeIssuanceParams instance) =>
    <String, dynamic>{
      'source': instance.source,
      'asset': instance.asset,
      'quantity': instance.quantity,
      'divisible': instance.divisible,
      'lock': instance.lock,
      'reset': instance.reset,
      'description': instance.description,
      'transfer_destination': instance.transferDestination,
    };

ComposeIssuanceVerbose _$ComposeIssuanceVerboseFromJson(
        Map<String, dynamic> json) =>
    ComposeIssuanceVerbose(
      rawtransaction: json['rawtransaction'] as String,
      name: json['name'] as String,
      params: ComposeIssuanceVerboseParams.fromJson(
          json['params'] as Map<String, dynamic>),
      btcFee: (json['btc_fee'] as num).toInt(),
    );

Map<String, dynamic> _$ComposeIssuanceVerboseToJson(
        ComposeIssuanceVerbose instance) =>
    <String, dynamic>{
      'rawtransaction': instance.rawtransaction,
      'name': instance.name,
      'params': instance.params,
      'btc_fee': instance.btcFee,
    };

ComposeIssuanceVerboseParams _$ComposeIssuanceVerboseParamsFromJson(
        Map<String, dynamic> json) =>
    ComposeIssuanceVerboseParams(
      source: json['source'] as String,
      asset: json['asset'] as String,
      quantity: (json['quantity'] as num).toInt(),
      divisible: json['divisible'] as bool,
      lock: json['lock'] as bool,
      reset: json['reset'] as bool,
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
      'reset': instance.reset,
      'description': instance.description,
      'transfer_destination': instance.transferDestination,
      'quantity_normalized': instance.quantityNormalized,
    };

ComposeDispenser _$ComposeDispenserFromJson(Map<String, dynamic> json) =>
    ComposeDispenser(
      rawtransaction: json['rawtransaction'] as String,
      params: ComposeDispenserParams.fromJson(
          json['params'] as Map<String, dynamic>),
      name: json['name'] as String,
    );

Map<String, dynamic> _$ComposeDispenserToJson(ComposeDispenser instance) =>
    <String, dynamic>{
      'rawtransaction': instance.rawtransaction,
      'params': instance.params,
      'name': instance.name,
    };

ComposeDispenserParams _$ComposeDispenserParamsFromJson(
        Map<String, dynamic> json) =>
    ComposeDispenserParams(
      source: json['source'] as String,
      asset: json['asset'] as String,
      giveQuantity: (json['give_quantity'] as num).toInt(),
      escrowQuantity: (json['escrow_quantity'] as num).toInt(),
      mainchainrate: (json['mainchainrate'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      openAddress: json['open_address'] as String?,
      oracleAddress: json['oracle_address'] as String?,
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
      giveQuantityNormalized: json['give_quantity_normalized'] as String,
      escrowQuantityNormalized: json['escrow_quantity_normalized'] as String,
    );

Map<String, dynamic> _$ComposeDispenserParamsToJson(
        ComposeDispenserParams instance) =>
    <String, dynamic>{
      'source': instance.source,
      'asset': instance.asset,
      'give_quantity': instance.giveQuantity,
      'escrow_quantity': instance.escrowQuantity,
      'mainchainrate': instance.mainchainrate,
      'status': instance.status,
      'open_address': instance.openAddress,
      'oracle_address': instance.oracleAddress,
      'asset_info': instance.assetInfo,
      'give_quantity_normalized': instance.giveQuantityNormalized,
      'escrow_quantity_normalized': instance.escrowQuantityNormalized,
    };

ComposeDispenserVerbose _$ComposeDispenserVerboseFromJson(
        Map<String, dynamic> json) =>
    ComposeDispenserVerbose(
      rawtransaction: json['rawtransaction'] as String,
      name: json['name'] as String,
      params: ComposeDispenserVerboseParams.fromJson(
          json['params'] as Map<String, dynamic>),
      btcIn: (json['btc_in'] as num).toInt(),
      btcOut: (json['btc_out'] as num).toInt(),
      btcChange: (json['btc_change'] as num?)?.toInt(),
      btcFee: (json['btc_fee'] as num).toInt(),
      data: json['data'] as String,
    );

Map<String, dynamic> _$ComposeDispenserVerboseToJson(
        ComposeDispenserVerbose instance) =>
    <String, dynamic>{
      'rawtransaction': instance.rawtransaction,
      'name': instance.name,
      'params': instance.params,
      'btc_in': instance.btcIn,
      'btc_out': instance.btcOut,
      'btc_change': instance.btcChange,
      'btc_fee': instance.btcFee,
      'data': instance.data,
    };

ComposeDispenserVerboseParams _$ComposeDispenserVerboseParamsFromJson(
        Map<String, dynamic> json) =>
    ComposeDispenserVerboseParams(
      source: json['source'] as String,
      asset: json['asset'] as String,
      giveQuantity: (json['give_quantity'] as num).toInt(),
      escrowQuantity: (json['escrow_quantity'] as num).toInt(),
      mainchainrate: (json['mainchainrate'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
      giveQuantityNormalized: json['give_quantity_normalized'] as String,
      escrowQuantityNormalized: json['escrow_quantity_normalized'] as String,
    );

Map<String, dynamic> _$ComposeDispenserVerboseParamsToJson(
        ComposeDispenserVerboseParams instance) =>
    <String, dynamic>{
      'source': instance.source,
      'asset': instance.asset,
      'give_quantity': instance.giveQuantity,
      'escrow_quantity': instance.escrowQuantity,
      'mainchainrate': instance.mainchainrate,
      'status': instance.status,
      'asset_info': instance.assetInfo,
      'give_quantity_normalized': instance.giveQuantityNormalized,
      'escrow_quantity_normalized': instance.escrowQuantityNormalized,
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
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
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
      satoshirate: (json['satoshirate'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      giveRemaining: (json['give_remaining'] as num).toInt(),
      oracleAddress: json['oracle_address'] as String?,
      lastStatusTxHash: json['last_status_tx_hash'] as String?,
      origin: json['origin'] as String,
      asset: json['asset'] as String,
      dispenseCount: (json['dispense_count'] as num).toInt(),
      giveQuantityNormalized: json['give_quantity_normalized'] as String?,
      giveRemainingNormalized: json['give_remaining_normalized'] as String?,
      escrowQuantityNormalized: json['escrow_quantity_normalized'] as String?,
    );

Map<String, dynamic> _$DispenserToJson(Dispenser instance) => <String, dynamic>{
      'tx_index': instance.txIndex,
      'block_index': instance.blockIndex,
      'source': instance.source,
      'give_quantity': instance.giveQuantity,
      'escrow_quantity': instance.escrowQuantity,
      'satoshirate': instance.satoshirate,
      'status': instance.status,
      'give_remaining': instance.giveRemaining,
      'asset': instance.asset,
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
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
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
      assetInfo:
          AssetInfoModel.fromJson(json['asset_info'] as Map<String, dynamic>),
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
      btcFee: (json['btc_fee'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$SendTxVerboseToJson(SendTxVerbose instance) =>
    <String, dynamic>{
      'rawtransaction': instance.rawtransaction,
      'name': instance.name,
      'params': instance.params,
      'btc_fee': instance.btcFee,
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

FairmintUnpackedVerbose _$FairmintUnpackedVerboseFromJson(
        Map<String, dynamic> json) =>
    FairmintUnpackedVerbose(
      asset: json['asset'] as String?,
      price: (json['price'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FairmintUnpackedVerboseToJson(
        FairmintUnpackedVerbose instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'price': instance.price,
    };

FairmintInfoVerbose _$FairmintInfoVerboseFromJson(Map<String, dynamic> json) =>
    FairmintInfoVerbose(
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toInt(),
      data: json['data'] as String,
      decodedTx: json['decoded_tx'] as Map<String, dynamic>?,
      btcAmountNormalized: json['btc_amount_normalized'] as String,
      unpackedData: FairmintUnpackedVerbose.fromJson(
          json['unpacked_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FairmintInfoVerboseToJson(
        FairmintInfoVerbose instance) =>
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

FairminterUnpackedVerbose _$FairminterUnpackedVerboseFromJson(
        Map<String, dynamic> json) =>
    FairminterUnpackedVerbose(
      asset: json['asset'] as String?,
    );

Map<String, dynamic> _$FairminterUnpackedVerboseToJson(
        FairminterUnpackedVerbose instance) =>
    <String, dynamic>{
      'asset': instance.asset,
    };

FairminterInfoVerbose _$FairminterInfoVerboseFromJson(
        Map<String, dynamic> json) =>
    FairminterInfoVerbose(
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toInt(),
      data: json['data'] as String,
      decodedTx: json['decoded_tx'] as Map<String, dynamic>?,
      btcAmountNormalized: json['btc_amount_normalized'] as String,
      unpackedData: FairminterUnpackedVerbose.fromJson(
          json['unpacked_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FairminterInfoVerboseToJson(
        FairminterInfoVerbose instance) =>
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

DispenserInfoVerbose _$DispenserInfoVerboseFromJson(
        Map<String, dynamic> json) =>
    DispenserInfoVerbose(
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toInt(),
      data: json['data'] as String,
      btcAmountNormalized: json['btc_amount_normalized'] as String,
      unpackedData: DispenserUnpackedVerbose.fromJson(
          json['unpacked_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DispenserInfoVerboseToJson(
        DispenserInfoVerbose instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'btc_amount_normalized': instance.btcAmountNormalized,
      'unpacked_data': instance.unpackedData,
    };

DispenseInfoVerbose _$DispenseInfoVerboseFromJson(Map<String, dynamic> json) =>
    DispenseInfoVerbose(
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toInt(),
      data: json['data'] as String,
      btcAmountNormalized: json['btc_amount_normalized'] as String,
      unpackedData: DispenseUnpackedVerbose.fromJson(
          json['unpacked_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DispenseInfoVerboseToJson(
        DispenseInfoVerbose instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'btc_amount_normalized': instance.btcAmountNormalized,
      'unpacked_data': instance.unpackedData,
    };

OrderUnpackedVerbose _$OrderUnpackedVerboseFromJson(
        Map<String, dynamic> json) =>
    OrderUnpackedVerbose(
      giveAsset: json['give_asset'] as String,
      giveQuantity: (json['give_quantity'] as num).toInt(),
      getAsset: json['get_asset'] as String,
      getQuantity: (json['get_quantity'] as num).toInt(),
      expiration: (json['expiration'] as num).toInt(),
      feeRequired: (json['fee_required'] as num).toInt(),
      status: json['status'] as String,
      giveQuantityNormalized: json['give_quantity_normalized'] as String,
      getQuantityNormalized: json['get_quantity_normalized'] as String,
      feeRequiredNormalized: json['fee_required_normalized'] as String,
    );

Map<String, dynamic> _$OrderUnpackedVerboseToJson(
        OrderUnpackedVerbose instance) =>
    <String, dynamic>{
      'give_asset': instance.giveAsset,
      'give_quantity': instance.giveQuantity,
      'get_asset': instance.getAsset,
      'get_quantity': instance.getQuantity,
      'expiration': instance.expiration,
      'fee_required': instance.feeRequired,
      'status': instance.status,
      'give_quantity_normalized': instance.giveQuantityNormalized,
      'get_quantity_normalized': instance.getQuantityNormalized,
      'fee_required_normalized': instance.feeRequiredNormalized,
    };

OrderInfoVerbose _$OrderInfoVerboseFromJson(Map<String, dynamic> json) =>
    OrderInfoVerbose(
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toInt(),
      data: json['data'] as String,
      decodedTx: json['decoded_tx'] as Map<String, dynamic>?,
      btcAmountNormalized: json['btc_amount_normalized'] as String,
      unpackedData: OrderUnpackedVerbose.fromJson(
          json['unpacked_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderInfoVerboseToJson(OrderInfoVerbose instance) =>
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

CancelInfoVerbose _$CancelInfoVerboseFromJson(Map<String, dynamic> json) =>
    CancelInfoVerbose(
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toInt(),
      data: json['data'] as String,
      btcAmountNormalized: json['btc_amount_normalized'] as String,
      decodedTx: json['decoded_tx'] as Map<String, dynamic>?,
      unpackedData: CancelUnpackedVerbose.fromJson(
          json['unpacked_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CancelInfoVerboseToJson(CancelInfoVerbose instance) =>
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

CancelUnpackedVerbose _$CancelUnpackedVerboseFromJson(
        Map<String, dynamic> json) =>
    CancelUnpackedVerbose(
      offerHash: json['offer_hash'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$CancelUnpackedVerboseToJson(
        CancelUnpackedVerbose instance) =>
    <String, dynamic>{
      'offer_hash': instance.offerHash,
      'status': instance.status,
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
  Future<Response<int>> estimateSmartFee(int confirmationTarget) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'conf_target': confirmationTarget
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<Response<int>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/bitcoin/estimatesmartfee',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<int>.fromJson(
      _result.data!,
      (json) => json as int,
    );
    return _value;
  }

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
  Future<Response<DecodedTxModel>> decodeTransaction(String rawtx) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'rawtx': rawtx};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<DecodedTxModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/bitcoin/transactions/decode',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<DecodedTxModel>.fromJson(
      _result.data!,
      (json) => DecodedTxModel.fromJson(json as Map<String, dynamic>),
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
  Future<Response<List<BalanceVerbose>>> getBalancesByUTXO(
    String utxo, [
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
              '/utxos/${utxo}/balances?verbose=true',
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
  Future<Response<Block>> getLastBlock() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
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
              '/blocks/last',
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
  Future<Response<Info>> getTransactionInfo(
    String rawtransaction, [
    int? blockIndex,
    bool? verbose,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'rawtransaction': rawtransaction,
      r'block_index': blockIndex,
      r'verbose': verbose,
    };
    queryParameters.removeWhere((k, v) => v == null);
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
    String rawtransaction, [
    int? blockIndex,
    bool? verbose,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'rawtransaction': rawtransaction,
      r'block_index': blockIndex,
      r'verbose': verbose,
    };
    queryParameters.removeWhere((k, v) => v == null);
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
    String datahex, [
    int? blockIndex,
    bool? verbose,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'datahex': datahex,
      r'block_index': blockIndex,
      r'verbose': verbose,
    };
    queryParameters.removeWhere((k, v) => v == null);
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
    String datahex, [
    int? blockIndex,
    bool? verbose,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'datahex': datahex,
      r'block_index': blockIndex,
      r'verbose': verbose,
    };
    queryParameters.removeWhere((k, v) => v == null);
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
  Future<Response<List<DispenserModel>>> getDispensersByAddress(
    String address, [
    bool? verbose,
    String? status,
    CursorModel? cursor,
    int? limit,
    int? offset,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'verbose': verbose,
      r'status': status,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
      r'offset': offset,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<DispenserModel>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/dispensers',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<DispenserModel>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<DispenserModel>(
                  (i) => DispenserModel.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
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
    int? feePerKB,
    String? inputsSet,
    bool? validate,
    bool? disableUtxoLocks,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'destination': destination,
      r'asset': asset,
      r'quantity': quantity,
      r'allow_unconfirmed_inputs': allowUnconfirmedInputs,
      r'exact_fee': fee,
      r'fee_per_kb': feePerKB,
      r'inputs_set': inputsSet,
      r'validate': validate,
      r'disable_utxo_locks': disableUtxoLocks,
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
      r'transfer_destination': transferDestination,
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
    String? inputsSet,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'asset': asset,
      r'quantity': quantity,
      r'transfer_destination': transferDestination,
      r'divisible': divisible,
      r'lock': lock,
      r'reset': reset,
      r'description': description,
      r'unconfirmed': unconfirmed,
      r'exact_fee': fee,
      r'inputs_set': inputsSet,
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
  Future<Response<List<OrderVerbose>>> getOrdersByAddressVerbose(
    String address, [
    String? status,
    bool? showUnconfirmed,
    CursorModel? cursor,
    int? limit,
    int? offset,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'status': status,
      r'show_unconfirmed': showUnconfirmed,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
      r'offset': offset,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<OrderVerbose>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/orders?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<OrderVerbose>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<OrderVerbose>(
                  (i) => OrderVerbose.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<FairminterModel>>> getAllFairminters([
    bool? showUnconfirmed,
    CursorModel? cursor,
    int? limit,
    int? offset,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'show_unconfirmed': showUnconfirmed,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
      r'offset': offset,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<FairminterModel>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/fairminters?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<FairminterModel>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<FairminterModel>(
                  (i) => FairminterModel.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<FairminterModel>>> getFairmintersByAddress(
    String address, [
    String? status,
    bool? showUnconfirmed,
    CursorModel? cursor,
    int? limit,
    int? offset,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'status': status,
      r'show_unconfirmed': showUnconfirmed,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
      r'offset': offset,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<FairminterModel>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/fairminters?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<FairminterModel>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<FairminterModel>(
                  (i) => FairminterModel.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<ComposeFairmintVerboseModel>> composeFairmintVerbose(
    String address,
    String asset, [
    int? fee,
    String? inputsSet,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'asset': asset,
      r'exact_fee': fee,
      r'inputs_set': inputsSet,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<ComposeFairmintVerboseModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/compose/fairmint?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<ComposeFairmintVerboseModel>.fromJson(
      _result.data!,
      (json) =>
          ComposeFairmintVerboseModel.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<ComposeFairminterVerboseModel>> composeFairminterVerbose(
    String address,
    String asset, [
    String? assetParent,
    bool? divisible,
    int? maxMintPerTx,
    int? hardCap,
    int? startBlock,
    int? endBlock,
    int? fee,
    bool? lockQuantity,
    String? inputsSet,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'asset': asset,
      r'asset_parent': assetParent,
      r'divisible': divisible,
      r'max_mint_per_tx': maxMintPerTx,
      r'hard_cap': hardCap,
      r'start_block': startBlock,
      r'end_block': endBlock,
      r'exact_fee': fee,
      r'lock_quantity': lockQuantity,
      r'inputs_set': inputsSet,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<ComposeFairminterVerboseModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/compose/fairminter?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<ComposeFairminterVerboseModel>.fromJson(
      _result.data!,
      (json) =>
          ComposeFairminterVerboseModel.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<ComposeDispenserVerbose>> composeDispenserVerbose(
    String address,
    String asset,
    int giveQuantity,
    int escrowQuantity,
    int mainchainrate,
    int status, [
    String? openAddress,
    String? oracleAddress,
    bool? allowUnconfirmedInputs,
    int? exactFee,
    String? inputsSet,
    bool? unconfirmed,
    bool? validate,
    bool? disableUtxoLocks,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'asset': asset,
      r'give_quantity': giveQuantity,
      r'escrow_quantity': escrowQuantity,
      r'mainchainrate': mainchainrate,
      r'status': status,
      r'open_address': openAddress,
      r'oracle_address': oracleAddress,
      r'allow_unconfirmed_inputs': allowUnconfirmedInputs,
      r'exact_fee': exactFee,
      r'inputs_set': inputsSet,
      r'unconfirmed': unconfirmed,
      r'validate': validate,
      r'disable_utxo_locks': disableUtxoLocks,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<ComposeDispenserVerbose>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/compose/dispenser?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<ComposeDispenserVerbose>.fromJson(
      _result.data!,
      (json) => ComposeDispenserVerbose.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<ComposeOrderResponseModel>> composeOrder(
    String address,
    String giveAsset,
    int giveQuantity,
    String getAsset,
    int getQuantity,
    int expiration,
    int feeRequired, [
    bool? allowUnconfirmedInputs,
    int? exactFee,
    String? inputsSet,
    bool? unconfirmed,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'give_asset': giveAsset,
      r'give_quantity': giveQuantity,
      r'get_asset': getAsset,
      r'get_quantity': getQuantity,
      r'expiration': expiration,
      r'fee_required': feeRequired,
      r'allow_unconfirmed_inputs': allowUnconfirmedInputs,
      r'exact_fee': exactFee,
      r'inputs_set': inputsSet,
      r'unconfirmed': unconfirmed,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<ComposeOrderResponseModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/compose/order?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<ComposeOrderResponseModel>.fromJson(
      _result.data!,
      (json) =>
          ComposeOrderResponseModel.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<ComposeCancelResponseModel>> composeCancel(
    String address,
    String giveAsset, [
    bool? allowUnconfirmedInputs,
    int? exactFee,
    String? inputsSet,
    bool? unconfirmed,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'offer_hash': giveAsset,
      r'allow_unconfirmed_inputs': allowUnconfirmedInputs,
      r'exact_fee': exactFee,
      r'inputs_set': inputsSet,
      r'unconfirmed': unconfirmed,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<ComposeCancelResponseModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/compose/cancel?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<ComposeCancelResponseModel>.fromJson(
      _result.data!,
      (json) =>
          ComposeCancelResponseModel.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<List<Dispenser>>> getDispenserByAddress(
    String address, [
    String? status,
    int? limit,
    CursorModel? cursor,
    bool? showUnconfirmed,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'status': status,
      r'limit': limit,
      r'cursor': cursor?.toJson(),
      r'show_unconfirmed': showUnconfirmed,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Dispenser>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/dispensers',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Dispenser>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Dispenser>(
                  (i) => Dispenser.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<ComposeDispenseResponseModel>> composeDispense(
    String address,
    String dispenser,
    int quantity, [
    bool? allowUnconfirmedInputs,
    int? exactFee,
    String? inputsSet,
    bool? unconfirmed,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'dispenser': dispenser,
      r'quantity': quantity,
      r'allow_unconfirmed_inputs': allowUnconfirmedInputs,
      r'exact_fee': exactFee,
      r'inputs_set': inputsSet,
      r'unconfirmed': unconfirmed,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<ComposeDispenseResponseModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/compose/dispense?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<ComposeDispenseResponseModel>.fromJson(
      _result.data!,
      (json) =>
          ComposeDispenseResponseModel.fromJson(json as Map<String, dynamic>),
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
  Future<Response<List<Asset>>> getValidAssetsByOwner(
    String address, [
    String? named,
    CursorModel? cursor,
    int? limit,
    int? offset,
    bool? showUnconfirmed,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'named': named,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
      r'offset': offset,
      r'show_unconfirmed': showUnconfirmed,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<Asset>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/assets/owned',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<Asset>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Asset>((i) => Asset.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return _value;
  }

  @override
  Future<Response<List<AssetVerbose>>> getValidAssetsByOwnerVerbose(
    String address, [
    String? named,
    CursorModel? cursor,
    int? limit,
    int? offset,
    bool? showUnconfirmed,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'named': named,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
      r'offset': offset,
      r'show_unconfirmed': showUnconfirmed,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<List<AssetVerbose>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/assets/owned?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<List<AssetVerbose>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<AssetVerbose>(
                  (i) => AssetVerbose.fromJson(i as Map<String, dynamic>))
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
  Future<Response<List<VerboseEvent>>> getMempoolEventsByAddressesVerbose(
    String addresses, [
    CursorModel? cursor,
    int? limit,
    String? eventName,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'addresses': addresses,
      r'cursor': cursor?.toJson(),
      r'limit': limit,
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
              '/addresses/mempool?verbose=true',
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
  Future<Response<ComposeAttachUtxoResponseModel>> composeAttachUtxo(
    String address,
    String asset,
    int quantity, [
    String? destinationVout,
    bool? skipValidation,
    bool? allowUnconfirmedInputs,
    int? exactFee,
    String? inputsSet,
    bool? unconfirmed,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'asset': asset,
      r'quantity': quantity,
      r'destination_vout': destinationVout,
      r'skip_validation': skipValidation,
      r'allow_unconfirmed_inputs': allowUnconfirmedInputs,
      r'exact_fee': exactFee,
      r'inputs_set': inputsSet,
      r'unconfirmed': unconfirmed,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<ComposeAttachUtxoResponseModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/addresses/${address}/compose/attach?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<ComposeAttachUtxoResponseModel>.fromJson(
      _result.data!,
      (json) =>
          ComposeAttachUtxoResponseModel.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<ComposeDetachUtxoResponseModel>> composeDetachUtxo(
    String utxo, [
    String? destination,
    bool? skipValidation,
    bool? allowUnconfirmedInputs,
    int? exactFee,
    String? inputsSet,
    bool? unconfirmed,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'destination': destination,
      r'skip_validation': skipValidation,
      r'allow_unconfirmed_inputs': allowUnconfirmedInputs,
      r'exact_fee': exactFee,
      r'inputs_set': inputsSet,
      r'unconfirmed': unconfirmed,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<ComposeDetachUtxoResponseModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/utxos/${utxo}/compose/detach?verbose=true',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<ComposeDetachUtxoResponseModel>.fromJson(
      _result.data!,
      (json) =>
          ComposeDetachUtxoResponseModel.fromJson(json as Map<String, dynamic>),
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

  @override
  Future<Response<AssetVerbose>> getAssetVerbose(
    String asset, [
    Options? options,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final newOptions = newRequestOptions(options);
    newOptions.extra.addAll(_extra);
    newOptions.headers.addAll(_dio.options.headers);
    newOptions.headers.addAll(_headers);
    final _result = await _dio.fetch<Map<String, dynamic>>(newOptions.copyWith(
      method: 'GET',
      baseUrl: baseUrl ?? _dio.options.baseUrl,
      queryParameters: queryParameters,
      path: '/assets/${asset}?verbose=true',
    )..data = _data);
    final _value = Response<AssetVerbose>.fromJson(
      _result.data!,
      (json) => AssetVerbose.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  @override
  Future<Response<List<BalanceVerbose>>> getBalancesForAddressAndAssetVerbose(
    String address,
    String asset,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
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
              '/addresses/${address}/balances/${asset}?verbose=true',
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
  Future<Response<NodeInfoModel>> getNodeInfo() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<Response<NodeInfoModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            ))));
    final _value = Response<NodeInfoModel>.fromJson(
      _result.data!,
      (json) => NodeInfoModel.fromJson(json as Map<String, dynamic>),
    );
    return _value;
  }

  RequestOptions newRequestOptions(Object? options) {
    if (options is RequestOptions) {
      return options as RequestOptions;
    }
    if (options is Options) {
      return RequestOptions(
        method: options.method,
        sendTimeout: options.sendTimeout,
        receiveTimeout: options.receiveTimeout,
        extra: options.extra,
        headers: options.headers,
        responseType: options.responseType,
        contentType: options.contentType.toString(),
        validateStatus: options.validateStatus,
        receiveDataWhenStatusError: options.receiveDataWhenStatusError,
        followRedirects: options.followRedirects,
        maxRedirects: options.maxRedirects,
        requestEncoder: options.requestEncoder,
        responseDecoder: options.responseDecoder,
        path: '',
      );
    }
    return RequestOptions(path: '');
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
