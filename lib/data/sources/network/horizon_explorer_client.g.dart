// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horizon_explorer_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetSrcResponse _$AssetSrcResponseFromJson(Map<String, dynamic> json) =>
    AssetSrcResponse(
      src: json['src'] as String?,
    );

Map<String, dynamic> _$AssetSrcResponseToJson(AssetSrcResponse instance) =>
    <String, dynamic>{
      'src': instance.src,
    };

AssetSearchResultModelHit _$AssetSearchResultModelHitFromJson(
        Map<String, dynamic> json) =>
    AssetSearchResultModelHit(
      asset: json['asset'] as String,
      assetLongname: json['asset_longname'] as String,
      description: json['description'] as String,
      issuer: json['issuer'] as String,
      source: json['source'] as String,
    );

Map<String, dynamic> _$AssetSearchResultModelHitToJson(
        AssetSearchResultModelHit instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'asset_longname': instance.assetLongname,
      'description': instance.description,
      'issuer': instance.issuer,
      'source': instance.source,
    };

AssetSearchResultModel _$AssetSearchResultModelFromJson(
        Map<String, dynamic> json) =>
    AssetSearchResultModel(
      type: json['type'] as String,
      href: json['href'] as String,
      hit: AssetSearchResultModelHit.fromJson(
          json['hit'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AssetSearchResultModelToJson(
        AssetSearchResultModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'href': instance.href,
      'hit': instance.hit,
    };

AssetSearchResponse _$AssetSearchResponseFromJson(Map<String, dynamic> json) =>
    AssetSearchResponse(
      results: (json['results'] as List<dynamic>)
          .map(
              (e) => AssetSearchResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AssetSearchResponseToJson(
        AssetSearchResponse instance) =>
    <String, dynamic>{
      'results': instance.results,
    };

OnChainPaymentModel _$OnChainPaymentModelFromJson(Map<String, dynamic> json) =>
    OnChainPaymentModel(
      psbt: json['psbt'] as String,
      inputsToSign: (json['inputsToSign'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      rawtransaction: json['rawtransaction'] as String,
      feePaymentId: json['feePaymentId'] as String,
    );

Map<String, dynamic> _$OnChainPaymentModelToJson(
        OnChainPaymentModel instance) =>
    <String, dynamic>{
      'psbt': instance.psbt,
      'inputsToSign': instance.inputsToSign,
      'rawtransaction': instance.rawtransaction,
      'feePaymentId': instance.feePaymentId,
    };

OnChainPaymentResponse _$OnChainPaymentResponseFromJson(
        Map<String, dynamic> json) =>
    OnChainPaymentResponse(
      data: OnChainPaymentModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OnChainPaymentResponseToJson(
        OnChainPaymentResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

AtomicSwapModel _$AtomicSwapModelFromJson(Map<String, dynamic> json) =>
    AtomicSwapModel(
      id: json['id'] as String,
      funded: json['funded'] as bool,
      filled: json['filled'] as bool,
      delisted: json['delisted'] as bool,
      expired: json['expired'] as bool,
      pending: json['pending'] as bool,
      anomalous: json['anomalous'] as bool,
      confirmed: json['confirmed'] as bool,
      txId: json['tx_id'] as String?,
      sellerDelisted: json['seller_delisted'] as bool,
      sellerAddress: json['seller_address'] as String,
      buyerAddress: json['buyer_address'] as String?,
      assetUtxoId: json['asset_utxo_id'] as String,
      assetUtxoValue: (json['asset_utxo_value'] as num).toInt(),
      assetName: json['asset_name'] as String,
      assetQuantity: (json['asset_quantity'] as num).toInt(),
      price: json['price'] as num,
      pricePerUnit: json['price_per_unit'] as num,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$AtomicSwapModelToJson(AtomicSwapModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'funded': instance.funded,
      'filled': instance.filled,
      'delisted': instance.delisted,
      'expired': instance.expired,
      'pending': instance.pending,
      'anomalous': instance.anomalous,
      'confirmed': instance.confirmed,
      'tx_id': instance.txId,
      'seller_delisted': instance.sellerDelisted,
      'seller_address': instance.sellerAddress,
      'buyer_address': instance.buyerAddress,
      'asset_utxo_id': instance.assetUtxoId,
      'asset_utxo_value': instance.assetUtxoValue,
      'asset_name': instance.assetName,
      'asset_quantity': instance.assetQuantity,
      'price': instance.price,
      'price_per_unit': instance.pricePerUnit,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
    };

AtomicSwapListResponse _$AtomicSwapListResponseFromJson(
        Map<String, dynamic> json) =>
    AtomicSwapListResponse(
      data: AtomicSwapListResponseData.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AtomicSwapListResponseToJson(
        AtomicSwapListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

AtomicSwapListResponseData _$AtomicSwapListResponseDataFromJson(
        Map<String, dynamic> json) =>
    AtomicSwapListResponseData(
      atomicSwaps: (json['atomic_swaps'] as List<dynamic>)
          .map((e) => AtomicSwapModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$AtomicSwapListResponseDataToJson(
        AtomicSwapListResponseData instance) =>
    <String, dynamic>{
      'atomic_swaps': instance.atomicSwaps,
      'count': instance.count,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element

class _HorizonExplorerApii implements HorizonExplorerApii {
  _HorizonExplorerApii(
    this._dio, {
    this.baseUrl,
    this.errorLogger,
  });

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<AssetSrcResponse> getAssetSrc(
    String asset,
    String? description,
    bool? showLarge,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'asset': asset,
      r'description': description,
      r'show_large': showLarge,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<AssetSrcResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/explorer/asset-src',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late AssetSrcResponse _value;
    try {
      _value = AssetSrcResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<AssetSearchResponse> _searchAssetsRaw(String query) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r's': query};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<AssetSearchResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/explorer/search',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late AssetSearchResponse _value;
    try {
      _value = AssetSearchResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<OnChainPaymentResponse> _createOnChainPayment(
      Map<String, dynamic> body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final _options = _setStreamType<OnChainPaymentResponse>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/on-chain-payment',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late OnChainPaymentResponse _value;
    try {
      _value = OnChainPaymentResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<AtomicSwapListResponse> _getAtomicSwapsRaw([String? assetName]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'asset_name': assetName};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<AtomicSwapListResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/atomic-swaps',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late AtomicSwapListResponse _value;
    try {
      _value = AtomicSwapListResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
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
