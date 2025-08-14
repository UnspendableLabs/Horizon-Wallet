import 'package:dio/dio.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import 'package:horizon/domain/entities/atomic_swap/on_chain_payment.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'horizon_explorer_client.g.dart';

@JsonSerializable(
    genericArgumentFactories: true, fieldRename: FieldRename.snake)
class DataWrapper<T> {
  final T data;

  DataWrapper({
    required this.data,
  });

  factory DataWrapper.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$DataWrapperFromJson(json, fromJsonT);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AtomicSwapSaleResponse {
  final String id;

  AtomicSwapSaleResponse({
    required this.id,
  });

  factory AtomicSwapSaleResponse.fromJson(Map<String, dynamic> json) =>
      _$AtomicSwapSaleResponseFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AtomicSwapBuyResponse {
  final AtomicSwapBuyResponseSwap atomicSwap;
  final String buyerAddress;
  final String txId;

  AtomicSwapBuyResponse({
    required this.atomicSwap,
    required this.buyerAddress,
    required this.txId,
  });

  factory AtomicSwapBuyResponse.fromJson(Map<String, dynamic> json) =>
      _$AtomicSwapBuyResponseFromJson(json);
}

@JsonSerializable()
class AtomicSwapBuyResponseSwap {
  final String id;

  AtomicSwapBuyResponseSwap({required this.id});

  factory AtomicSwapBuyResponseSwap.fromJson(Map<String, dynamic> json) =>
      _$AtomicSwapBuyResponseSwapFromJson(json);
}

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

@JsonSerializable()
class UtxosWithOpenSwapsResponse {
  final Map<String, bool> map;

  UtxosWithOpenSwapsResponse({required this.map});

  factory UtxosWithOpenSwapsResponse.fromJson(Map<String, dynamic> json) =>
      UtxosWithOpenSwapsResponse(
        map: json.map((key, value) => MapEntry(key, value as bool)),
      );

  Map<String, dynamic> toJson() => map;
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
      pendingSales: pending,
      sellerAddress: sellerAddress,
      assetName: assetName,
      assetUtxoValue: assetUtxoValue,
      assetUtxoId: UtxoID(
        txid: assetUtxoId.split(':')[0],
        vout: int.parse(assetUtxoId.split(':')[1]),
      ),
      assetQuantity: AssetQuantity(
        quantity: BigInt.from(assetQuantity),
        divisible:
            true, // all quantities from atomic swaps are considered divisible ( e.g. expressed in sats)
      ),
      price: AssetQuantity(
        quantity: BigInt.from(price),
        divisible:
            true, // all quantities from atomic swaps are considered divisible ( e.g. expressed in sats)
      ),
      pricePerUnit:
          AssetQuantity(quantity: BigInt.from(pricePerUnit), divisible: true));
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

@JsonSerializable(fieldRename: FieldRename.snake)
class AtomicSwapCreateResponseData {
  final String id;
  AtomicSwapCreateResponseData({
    required this.id,
  });
  factory AtomicSwapCreateResponseData.fromJson(Map<String, dynamic> json) {
    return _$AtomicSwapCreateResponseDataFromJson(json);
  }
}

@JsonSerializable()
class UtxoSwapMapResponse {
  final Map<String, bool> map;

  UtxoSwapMapResponse({required this.map});

  factory UtxoSwapMapResponse.fromJson(Map<String, dynamic> json) =>
      UtxoSwapMapResponse(
        map: json.map((key, value) => MapEntry(key, value as bool)),
      );

  Map<String, dynamic> toJson() => map;
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
  Future<DataWrapper<OnChainPaymentModel>> _createOnChainPayment(
      @Body() Map<String, dynamic> body);

  @POST('/atomic-swaps')
  Future<DataWrapper<AtomicSwapCreateResponseData>> _createSwap(
    @Body() Map<String, dynamic> body,
  );

  @GET('/atomic-swaps/asset-utxo-id')
  Future<DataWrapper<UtxoSwapMapResponse>> getUtxoSwapMap(
      @Query('seller_address') String sellerAddressk);

  @GET('/atomic-swaps')
  Future<DataWrapper<AtomicSwapListResponseData>> _getAtomicSwapsRaw([
    @Query('asset_name') String? assetName,
    @Query('order_by') String? orderBy,
    @Query('order') String? order,
  ]);

  @PUT('/atomic-swaps/{id}/multi-buy')
  Future<DataWrapper<AtomicSwapBuyResponse>> _atomicSwapBuy(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @POST('/atomic-swaps')
  Future<DataWrapper<AtomicSwapSaleResponse>> _atomicSwapSale(
    @Body() Map<String, dynamic> body,
  );
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

  Future<DataWrapper<UtxoSwapMapResponse>> getUtxoSwapMap({
    required String sellerAddress,
  }) {
    return _api.getUtxoSwapMap(sellerAddress);
  }

  Future<List<AssetSearchResult>> searchAssets({required String query}) async {
    final json = await _api._searchAssetsRaw(query);
    return json.results.map((a) => a.toEntity()).toList();
  }

  Future<DataWrapper<OnChainPaymentModel>> createOnChainPayment({
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

  Future<DataWrapper<AtomicSwapCreateResponseData>> createAtomicSwap({
    required String psbtHex,
    required String sellerAddress,
    required String assetUtxoId,
    required int assetUtxoValue,
    required String assetName,
    required int assetQuantity,
    required int price,
    required DateTime? expiresAt,
    required String feePaymentId,
    required String feePaymentPsbtHex,
    required bool divisible,
  }) async {
    final body = {
      "data": {
        'data': {
          'psbt_hex': psbtHex,
          'seller_address': sellerAddress,
          'asset_utxo_id': assetUtxoId, // e.g. "txid:vout"
          'asset_utxo_value': assetUtxoValue, // in sats
          'asset_name': assetName,
          'asset_quantity': divisible
              ? assetQuantity
              : assetQuantity * 1e8, // always 1 for atomic swaps
          'price': price, // in sats
          'expires_at': expiresAt?.toUtc().toIso8601String(),
        },
        "payment": {
          "feePaymentId": feePaymentId,
          "psbtHex": feePaymentPsbtHex,
        }
      }
    };

    return await _api._createSwap(body);
  }

// TODO: this is a misnomer
  Future<DataWrapper<AtomicSwapListResponseData>> getAtomicSwaps(
      {String? assetName, String? orderBy, String? order}) async {
    return await _api._getAtomicSwapsRaw(assetName, orderBy, order);
  }

  Future<DataWrapper<AtomicSwapBuyResponse>> atomicSwapBuy({
    required String id,
    required String buyerAddress,
    required String psbtHex,
  }) async {
    final body = {
      'data': {
        'buyer_address': buyerAddress,
        'psbt_hex': psbtHex,
      }
    };

    return await _api._atomicSwapBuy(id, body);
  }

  // public async atomicSwapAssetUtxoIdReadAll(
  //   seller_address: string,
  // ): Promise<Record<string, true>> {
  //   return this.request(
  //     "GET",
  //     `/atomic-swaps/asset-utxo-id?seller_address=${seller_address}`,
  //   );
  // }
  // Future<DataWrapper<AtomicSwapSaleResponse>> atomicSwapSale(
  //     {required String psbtHex,
  //     required String sellerAddress,
  //     required UtxoID assetUtxoId,
  //     required BigInt assetUtxoValue,
  //     required String assetName,
  //     required BigInt assetQuantity,
  //     required BigInt price,
  //     required DateTime expiresAt,
  //     required String feePaymentId,
  //     required String feeHex}) async {
  //   print("\n\n\n\n\n");
  //   print("expiresAt: $expiresAt");
  //   print("expiresAt UTC: ${expiresAt.toUtc()}");
  //   print("expiresAt 8601: ${expiresAt.toIso8601String()}");
  //   print("expiresAt UTC - 8601: ${expiresAt.toUtc().toIso8601String()}");
  //
  //   final body = {
  //     'data': {
  //       'psbt_hex': psbtHex,
  //       'seller_address': sellerAddress,
  //       "asset_utxo_id": assetUtxoId.toString(),
  //       "asset_utxo_value": assetUtxoValue,
  //       "asset_name": assetName,
  //       "asset_quantity": assetQuantity.toString(),
  //       "price": price.toString(),
  //       "expires_at": expiresAt.toUtc().toIso8601String(),
  //     },
  //     "payment": {
  //       "feePaymentId": feePaymentId,
  //       "psbtHex": feeHex,
  //     }
  //   };
  //
  //   return await _api._atomicSwapSale(body);
  // }
}
