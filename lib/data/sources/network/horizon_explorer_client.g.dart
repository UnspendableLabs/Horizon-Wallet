// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horizon_explorer_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataWrapper<T> _$DataWrapperFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    DataWrapper<T>(
      data: fromJsonT(json['data']),
    );

Map<String, dynamic> _$DataWrapperToJson<T>(
  DataWrapper<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'data': toJsonT(instance.data),
    };

AtomicSwapSaleResponse _$AtomicSwapSaleResponseFromJson(
        Map<String, dynamic> json) =>
    AtomicSwapSaleResponse(
      id: json['id'] as String,
    );

Map<String, dynamic> _$AtomicSwapSaleResponseToJson(
        AtomicSwapSaleResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
    };

AtomicSwapBuyResponse _$AtomicSwapBuyResponseFromJson(
        Map<String, dynamic> json) =>
    AtomicSwapBuyResponse(
      atomicSwap: AtomicSwapBuyResponseSwap.fromJson(
          json['atomic_swap'] as Map<String, dynamic>),
      buyerAddress: json['buyer_address'] as String,
      txId: json['tx_id'] as String,
    );

Map<String, dynamic> _$AtomicSwapBuyResponseToJson(
        AtomicSwapBuyResponse instance) =>
    <String, dynamic>{
      'atomic_swap': instance.atomicSwap,
      'buyer_address': instance.buyerAddress,
      'tx_id': instance.txId,
    };

AtomicSwapBuyResponseSwap _$AtomicSwapBuyResponseSwapFromJson(
        Map<String, dynamic> json) =>
    AtomicSwapBuyResponseSwap(
      id: json['id'] as String,
    );

Map<String, dynamic> _$AtomicSwapBuyResponseSwapToJson(
        AtomicSwapBuyResponseSwap instance) =>
    <String, dynamic>{
      'id': instance.id,
    };

AssetSrcResponse _$AssetSrcResponseFromJson(Map<String, dynamic> json) =>
    AssetSrcResponse(
      src: json['src'] as String?,
    );

Map<String, dynamic> _$AssetSrcResponseToJson(AssetSrcResponse instance) =>
    <String, dynamic>{
      'src': instance.src,
    };

AssetSearchResultModel _$AssetSearchResultModelFromJson(
        Map<String, dynamic> json) =>
    AssetSearchResultModel(
      name: json['name'] as String,
      href: json['href'] as String,
      image: json['image'] as String?,
      collectionName: json['collection_name'] as String?,
      collectionSlug: json['collection_slug'] as String?,
    );

Map<String, dynamic> _$AssetSearchResultModelToJson(
        AssetSearchResultModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'href': instance.href,
      'image': instance.image,
      'collection_name': instance.collectionName,
      'collection_slug': instance.collectionSlug,
    };

SearchResults _$SearchResultsFromJson(Map<String, dynamic> json) =>
    SearchResults(
      assets: (json['assets'] as List<dynamic>)
          .map(
              (e) => AssetSearchResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchResultsToJson(SearchResults instance) =>
    <String, dynamic>{
      'assets': instance.assets,
    };

SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) =>
    SearchResponse(
      results: SearchResults.fromJson(json['results'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchResponseToJson(SearchResponse instance) =>
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

UtxosWithOpenSwapsResponse _$UtxosWithOpenSwapsResponseFromJson(
        Map<String, dynamic> json) =>
    UtxosWithOpenSwapsResponse(
      map: Map<String, bool>.from(json['map'] as Map),
    );

Map<String, dynamic> _$UtxosWithOpenSwapsResponseToJson(
        UtxosWithOpenSwapsResponse instance) =>
    <String, dynamic>{
      'map': instance.map,
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

AtomicSwapCreateResponseData _$AtomicSwapCreateResponseDataFromJson(
        Map<String, dynamic> json) =>
    AtomicSwapCreateResponseData(
      id: json['id'] as String,
    );

Map<String, dynamic> _$AtomicSwapCreateResponseDataToJson(
        AtomicSwapCreateResponseData instance) =>
    <String, dynamic>{
      'id': instance.id,
    };

UtxoSwapMapResponse _$UtxoSwapMapResponseFromJson(Map<String, dynamic> json) =>
    UtxoSwapMapResponse(
      map: Map<String, bool>.from(json['map'] as Map),
    );

Map<String, dynamic> _$UtxoSwapMapResponseToJson(
        UtxoSwapMapResponse instance) =>
    <String, dynamic>{
      'map': instance.map,
    };

RoyaltyByAssetResponse _$RoyaltyByAssetResponseFromJson(
        Map<String, dynamic> json) =>
    RoyaltyByAssetResponse(
      royalty: (json['royalty'] as num).toInt(),
      issuerAddress: json['issuer_address'] as String,
    );

Map<String, dynamic> _$RoyaltyByAssetResponseToJson(
        RoyaltyByAssetResponse instance) =>
    <String, dynamic>{
      'royalty': instance.royalty,
      'issuer_address': instance.issuerAddress,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _HorizonExplorerApii implements HorizonExplorerApii {
  _HorizonExplorerApii(this._dio, {this.baseUrl, this.errorLogger});

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
    final _options = _setStreamType<AssetSrcResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/explorer/asset-src',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
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
  Future<String> _searchAssetsRaw(String query) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r's': query};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<String>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/explorer/search',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<String>(_options);
    late String _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DataWrapper<OnChainPaymentModel>> _createOnChainPayment(
    Map<String, dynamic> body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final _options = _setStreamType<DataWrapper<OnChainPaymentModel>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/on-chain-payment',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DataWrapper<OnChainPaymentModel> _value;
    try {
      _value = DataWrapper<OnChainPaymentModel>.fromJson(
        _result.data!,
        (json) => OnChainPaymentModel.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DataWrapper<AtomicSwapCreateResponseData>> _createSwap(
    Map<String, dynamic> body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final _options = _setStreamType<DataWrapper<AtomicSwapCreateResponseData>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/atomic-swaps',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DataWrapper<AtomicSwapCreateResponseData> _value;
    try {
      _value = DataWrapper<AtomicSwapCreateResponseData>.fromJson(
        _result.data!,
        (json) =>
            AtomicSwapCreateResponseData.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DataWrapper<UtxoSwapMapResponse>> getUtxoSwapMap(
    String sellerAddressk,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'seller_address': sellerAddressk,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<DataWrapper<UtxoSwapMapResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/atomic-swaps/asset-utxo-id',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DataWrapper<UtxoSwapMapResponse> _value;
    try {
      _value = DataWrapper<UtxoSwapMapResponse>.fromJson(
        _result.data!,
        (json) => UtxoSwapMapResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DataWrapper<AtomicSwapListResponseData>> _getAtomicSwapsRaw([
    String? assetName,
    String? orderBy,
    String? order,
    String? search,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'asset_name': assetName,
      r'order_by': orderBy,
      r'order': order,
      r'search': search,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<DataWrapper<AtomicSwapListResponseData>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/atomic-swaps',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DataWrapper<AtomicSwapListResponseData> _value;
    try {
      _value = DataWrapper<AtomicSwapListResponseData>.fromJson(
        _result.data!,
        (json) =>
            AtomicSwapListResponseData.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DataWrapper<RoyaltyByAssetResponse?>> _getRoyaltyByAsset([
    String? assetName,
  ]) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<DataWrapper<RoyaltyByAssetResponse?>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/royalties/${assetName}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DataWrapper<RoyaltyByAssetResponse?> _value;
    try {
      _value = DataWrapper<RoyaltyByAssetResponse?>.fromJson(
        _result.data!,
        (json) => json == null
            ? null
            : RoyaltyByAssetResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DataWrapper<List<AtomicSwapBuyResponse>>> _atomicSwapBuy(
    String id,
    Map<String, dynamic> body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final _options = _setStreamType<DataWrapper<List<AtomicSwapBuyResponse>>>(
      Options(method: 'PUT', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/atomic-swaps/${id}/multi-buy',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DataWrapper<List<AtomicSwapBuyResponse>> _value;
    try {
      _value = DataWrapper<List<AtomicSwapBuyResponse>>.fromJson(
        _result.data!,
        (json) => json is List<dynamic>
            ? json
                .map<AtomicSwapBuyResponse>(
                  (i) => AtomicSwapBuyResponse.fromJson(
                    i as Map<String, dynamic>,
                  ),
                )
                .toList()
            : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DataWrapper<AtomicSwapSaleResponse>> _atomicSwapSale(
    Map<String, dynamic> body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final _options = _setStreamType<DataWrapper<AtomicSwapSaleResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/atomic-swaps',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DataWrapper<AtomicSwapSaleResponse> _value;
    try {
      _value = DataWrapper<AtomicSwapSaleResponse>.fromJson(
        _result.data!,
        (json) => AtomicSwapSaleResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
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

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
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
