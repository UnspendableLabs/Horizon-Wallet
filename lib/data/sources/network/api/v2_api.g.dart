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
      nextCursor: (json['nextCursor'] as num?)?.toInt(),
      resultCount: (json['resultCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ResponseToJson<T>(
  Response<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'result': _$nullableGenericToJson(instance.result, toJsonT),
      'nextCursor': instance.nextCursor,
      'resultCount': instance.resultCount,
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
      txIndex: (json['tx_index'] as num).toInt(),
      txlistHash: json['txlist_hash'] as String?,
      blockIndex: (json['block_index'] as num).toInt(),
      blockHash: json['block_hash'] as String?,
      blockTime: (json['block_time'] as num).toInt(),
      source: json['source'] as String,
      destination: json['destination'] as String?,
      btcAmount: (json['btc_amount'] as num).toDouble(),
      fee: (json['fee'] as num).toInt(),
      data: json['data'] as String,
      supported: json['supported'] as bool,
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'tx_hash': instance.txHash,
      'tx_index': instance.txIndex,
      'txlist_hash': instance.txlistHash,
      'block_index': instance.blockIndex,
      'block_hash': instance.blockHash,
      'block_time': instance.blockTime,
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'supported': instance.supported,
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

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      eventIndex: (json['event_index'] as num).toInt(),
      event: json['event'] as String,
      params: json['params'],
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'event_index': instance.eventIndex,
      'event': instance.event,
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

AssetInfo _$AssetInfoFromJson(Map<String, dynamic> json) => AssetInfo(
      assetLongname: json['asset_longname'] as String,
      description: json['description'] as String,
      divisible: json['divisible'] as bool,
      locked: json['locked'] as bool,
      issuer: json['issuer'] as String?,
    );

Map<String, dynamic> _$AssetInfoToJson(AssetInfo instance) => <String, dynamic>{
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

Unpack _$UnpackFromJson(Map<String, dynamic> json) => Unpack(
      messageType: json['message_type'] as String,
      messageTypeId: (json['message_type_id'] as num).toInt(),
      messageData: json['message_data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$UnpackToJson(Unpack instance) => <String, dynamic>{
      'message_type': instance.messageType,
      'message_type_id': instance.messageTypeId,
      'message_data': instance.messageData,
    };

Info _$InfoFromJson(Map<String, dynamic> json) => Info(
      source: json['source'] as String,
      destination: json['destination'] as String,
      btcAmount: (json['btc_amount'] as num).toDouble(),
      fee: (json['fee'] as num).toInt(),
      data: json['data'] as String,
      unpackedData:
          Unpack.fromJson(json['unpacked_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InfoToJson(Info instance) => <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'unpacked_data': instance.unpackedData.toJson(),
    };

UTXO _$UTXOFromJson(Map<String, dynamic> json) => UTXO(
      vout: (json['vout'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      value: (json['value'] as num).toInt(),
      confirmations: (json['confirmations'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      txid: json['txid'] as String,
    );

Map<String, dynamic> _$UTXOToJson(UTXO instance) => <String, dynamic>{
      'vout': instance.vout,
      'height': instance.height,
      'value': instance.value,
      'confirmations': instance.confirmations,
      'amount': instance.amount,
      'txid': instance.txid,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _V2Api implements V2Api {
  _V2Api(
    this._dio, {
    this.baseUrl,
  }) {
    baseUrl ??= 'http://localhost:14000/v2';
  }

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
    final value = Response<String>.fromJson(
      _result.data!,
      (json) => json as String,
    );
    return value;
  }

  @override
  Future<Response<List<Balance>>> getBalancesByAddress(
    String address,
    bool verbose, [
    int? cursor,
    int? limit,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'verbose': verbose,
      r'cursor': cursor,
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
    final value = Response<List<Balance>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Balance>((i) => Balance.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<List<Block>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Block>((i) => Block.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<Block>.fromJson(
      _result.data!,
      (json) => Block.fromJson(json as Map<String, dynamic>),
    );
    return value;
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
    final value = Response<List<Transaction>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Transaction>(
                  (i) => Transaction.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<List<Event>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Event>((i) => Event.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<List<EventCount>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<EventCount>(
                  (i) => EventCount.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<List<Event>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Event>((i) => Event.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<List<Credit>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Credit>((i) => Credit.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<List<Debit>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Debit>((i) => Debit.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<List<Expiration>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Expiration>(
                  (i) => Expiration.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<List<Cancel>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Cancel>((i) => Cancel.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<List<Destruction>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Destruction>(
                  (i) => Destruction.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<Info>.fromJson(
      _result.data!,
      (json) => Info.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<Response<Unpack>> unpackTransaction(String datahex) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'datahex': datahex};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<Response<Unpack>>(Options(
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
    final value = Response<Unpack>.fromJson(
      _result.data!,
      (json) => Unpack.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<Response<SendTx>> composeSend(
    String address,
    String destination,
    String asset,
    double quantity, [
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
    final value = Response<SendTx>.fromJson(
      _result.data!,
      (json) => SendTx.fromJson(json as Map<String, dynamic>),
    );
    return value;
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
    final value = Response<List<Send>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Send>((i) => Send.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<List<Issuance>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Issuance>(
                  (i) => Issuance.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
  }

  @override
  Future<Response<ComposeIssuance>> composeIssuance(
    String address,
    String asset,
    double quantity, [
    String? transferDestination,
    bool? divisible,
    bool? lock,
    bool? reset,
    String? description,
    bool? verbose,
    int? limit,
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
      r'verbose': verbose,
      r'limit': limit,
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
    final value = Response<ComposeIssuance>.fromJson(
      _result.data!,
      (json) => ComposeIssuance.fromJson(json as Map<String, dynamic>),
    );
    return value;
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
    final value = Response<List<Transaction>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<Transaction>(
                  (i) => Transaction.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
    final value = Response<List<UTXO>>.fromJson(
      _result.data!,
      (json) => json is List<dynamic>
          ? json
              .map<UTXO>((i) => UTXO.fromJson(i as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
    return value;
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
