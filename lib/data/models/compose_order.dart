import 'package:horizon/domain/entities/compose_order.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose_order.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeOrderResponseModel {
  final String name;
  final String data;
  final int btcIn;
  final int btcOut;
  final int btcChange;
  final int btcFee;
  final String rawtransaction;
  final ComposeOrderResponseParamsModel params;
  // final OrderUnpackedVerbose unpackedData;

  ComposeOrderResponseModel({
    required this.rawtransaction,
    required this.params,
    required this.name,
    // required this.unpackedData,
    required this.btcIn,
    required this.btcOut,
    required this.btcChange,
    required this.btcFee,
    required this.data,
  });

  factory ComposeOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeOrderResponseModelFromJson(json);

  ComposeOrderResponse toDomain() => ComposeOrderResponse(
        rawtransaction: rawtransaction,
        btcFee: btcFee,
        params: params.toDomain(),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeOrderResponseParamsModel {
  final String source;
  final String giveAsset;
  final int giveQuantity;
  final String giveQuantityNormalized;
  final int getQuantity;
  final String getQuantityNormalized;
  final String getAsset;

  ComposeOrderResponseParamsModel(
      {required this.source,
      required this.giveAsset,
      required this.giveQuantity,
      required this.giveQuantityNormalized,
      required this.getQuantity,
      required this.getQuantityNormalized,
      required this.getAsset});

  factory ComposeOrderResponseParamsModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeOrderResponseParamsModelFromJson(json);

  ComposeOrderResponseParams toDomain() => ComposeOrderResponseParams(
        source: source,
        giveAsset: giveAsset,
        giveQuantity: giveQuantity,
        giveQuantityNormalized: giveQuantityNormalized,
        getAsset: getAsset,
        getQuantity: getQuantity,
        getQuantityNormalized: getQuantityNormalized,
      );
}
