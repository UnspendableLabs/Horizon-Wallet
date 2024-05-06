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
      result: fromJsonT(json['result']),
    );

Map<String, dynamic> _$ResponseToJson<T>(
  Response<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'result': toJsonT(instance.result),
    };

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
      txIndex: (json['tx_index'] as num).toInt(),
      txlistHash: json['txlist_hash'] as String,
      blockIndex: (json['block_index'] as num).toInt(),
      blockHash: json['block_hash'] as String,
      blockTime: DateTime.parse(json['block_time'] as String),
      source: json['source'] as String,
      destination: json['destination'] as String,
      btcAmount: (json['btc_amount'] as num).toDouble(),
      fee: (json['fee'] as num).toInt(),
      data: json['data'] as String,
      supported: (json['supported'] as num).toInt(),
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'tx_index': instance.txIndex,
      'txlist_hash': instance.txlistHash,
      'block_index': instance.blockIndex,
      'block_hash': instance.blockHash,
      'block_time': instance.blockTime.toIso8601String(),
      'source': instance.source,
      'destination': instance.destination,
      'btc_amount': instance.btcAmount,
      'fee': instance.fee,
      'data': instance.data,
      'supported': instance.supported,
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
    baseUrl ??= 'https://api.counterparty.io/api/v2';
  }

  final Dio _dio;

  String? baseUrl;

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
