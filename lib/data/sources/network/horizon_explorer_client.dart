import 'package:dio/dio.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import 'package:horizon/domain/entities/atomic_swap/on_chain_payment.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'horizon_explorer_client.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetSrcResponse {
  final String? src;

  AssetSrcResponse({
    this.src,
  });

  factory AssetSrcResponse.fromJson(Map<String, dynamic> json) =>
      _$AssetSrcResponseFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetSearchResultModelHit {
  final String asset;
  final String assetLongname;
  final String description;
  final String issuer;
  final String source;

  AssetSearchResultModelHit({
    required this.asset,
    required this.assetLongname,
    required this.description,
    required this.issuer,
    required this.source,
  });

  factory AssetSearchResultModelHit.fromJson(Map<String, dynamic> json) {
    return _$AssetSearchResultModelHitFromJson(json);
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetSearchResultModel {
  final String type;
  final String href;
  final AssetSearchResultModelHit hit;

  AssetSearchResultModel(
      {required this.type, required this.href, required this.hit});

  factory AssetSearchResultModel.fromJson(Map<String, dynamic> json) {
    return _$AssetSearchResultModelFromJson(json);
  }

  AssetSearchResult toEntity() {
    return AssetSearchResult(
      name: hit.asset,
      description: hit.description,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetSearchResponse {
  final List<AssetSearchResultModel> results;
  AssetSearchResponse({required this.results});

  factory AssetSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$AssetSearchResponseFromJson(json);
}

@JsonSerializable()
class OnChainPaymentModel {
  final String psbt;
  final List<int> inputsToSign;
  final String rawtransaction;
  final String feePaymentId;

  OnChainPaymentModel({
    required this.psbt,
    required this.inputsToSign,
    required this.rawtransaction,
    required this.feePaymentId,
  });

  factory OnChainPaymentModel.fromJson(Map<String, dynamic> json) {
    return _$OnChainPaymentModelFromJson(json);
  }

  OnChainPayment toEntity() {
    return OnChainPayment(
      psbt: psbt,
      inputsToSign: inputsToSign,
      rawTransaction: rawtransaction,
      feePaymentId: feePaymentId,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OnChainPaymentResponse {
  final OnChainPaymentModel data;

  OnChainPaymentResponse({
    required this.data,
  });

  factory OnChainPaymentResponse.fromJson(Map<String, dynamic> json) {
    return _$OnChainPaymentResponseFromJson(json);
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AtomicSwapModel {
  final String id;
  final bool funded;
  final bool filled;
  final bool delisted;
  final bool expired;
  final bool pending;
  final bool anomalous;
  final bool confirmed;
  final String? txId;
  final bool sellerDelisted;
  final String sellerAddress;
  final String? buyerAddress;
  final String assetUtxoId;
  final int assetUtxoValue;
  final String assetName;
  final int assetQuantity;
  final num price;
  final num pricePerUnit;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  AtomicSwapModel({
    required this.id,
    required this.funded,
    required this.filled,
    required this.delisted,
    required this.expired,
    required this.pending,
    required this.anomalous,
    required this.confirmed,
    required this.txId,
    required this.sellerDelisted,
    required this.sellerAddress,
    required this.buyerAddress,
    required this.assetUtxoId,
    required this.assetUtxoValue,
    required this.assetName,
    required this.assetQuantity,
    required this.price,
    required this.pricePerUnit,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
  });

  factory AtomicSwapModel.fromJson(Map<String, dynamic> json) {
    return _$AtomicSwapModelFromJson(json);
  }

  AtomicSwap toEntity() => AtomicSwap(
      id: id,
      assetName: assetName,
      assetQuantity: BigInt.from(assetQuantity),
      price: BigInt.from(price),
      pricePerUnit: BigInt.from(pricePerUnit));
}

@JsonSerializable()
class AtomicSwapListResponse {
  final AtomicSwapListResponseData data;

  AtomicSwapListResponse({
    required this.data,
  });

  factory AtomicSwapListResponse.fromJson(Map<String, dynamic> json) {
    return _$AtomicSwapListResponseFromJson(json);
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AtomicSwapListResponseData {
  final List<AtomicSwapModel> atomicSwaps;
  final int count;
  AtomicSwapListResponseData({
    required this.atomicSwaps,
    required this.count,
  });
  factory AtomicSwapListResponseData.fromJson(Map<String, dynamic> json) {
    return _$AtomicSwapListResponseDataFromJson(json);
  }
}

@RestApi()
abstract class HorizonExplorerApii {
  factory HorizonExplorerApii(Dio dio, {String baseUrl}) = _HorizonExplorerApii;

  @GET('/explorer/asset-src')
  Future<AssetSrcResponse> getAssetSrc(
    @Query('asset') String asset,
    @Query('description') String? description,
    @Query('show_large') bool? showLarge,
  );

  @GET('/explorer/search')
  Future<AssetSearchResponse> _searchAssetsRaw(@Query('s') String query);

  @POST('/on-chain-payment')
  Future<OnChainPaymentResponse> _createOnChainPayment(
      @Body() Map<String, dynamic> body);

  @GET('/atomic-swaps')
  Future<AtomicSwapListResponse> _getAtomicSwapsRaw([
    @Query('asset_name') String? assetName,
    @Query('order_by') String? orderBy,
    @Query('order') String? order,
  ]);
}

class HorizonExplorerApi {
  final HorizonExplorerApii _api;

  HorizonExplorerApi(Dio dio)
      : _api = HorizonExplorerApii(dio, baseUrl: dio.options.baseUrl);

  Future<AssetSrcResponse> getAssetSrc({
    required String asset,
    String? description,
    bool? showLarge,
  }) {
    return _api.getAssetSrc(asset, description, showLarge);
  }

  Future<List<AssetSearchResult>> searchAssets({required String query}) async {
    final json = await _api._searchAssetsRaw(query);
    return json.results.map((a) => a.toEntity()).toList();
  }

  Future<OnChainPaymentResponse> createOnChainPayment({
    required String address,
    required List<String> utxoSetIds,
    required num satsPerVbyte,
  }) async {
    final body = {
      'data': {
        'address': address,
        'utxoSetIds': utxoSetIds,
        'satsPerVbyte': satsPerVbyte,
      }
    };
    return await _api._createOnChainPayment(body);
  }

// TODO: this is a misnomer
  Future<AtomicSwapListResponse> getAtomicSwaps(
      {String? assetName, String? orderBy, String? order}) async {
    return await _api._getAtomicSwapsRaw(assetName, orderBy, order);
  }
}
