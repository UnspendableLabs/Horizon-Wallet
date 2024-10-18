import 'package:horizon/data/models/asset_info.dart';
import 'package:horizon/domain/entities/compose_fairmint.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose_fairmint.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeFairmintVerboseModel {
  final String name;
  final String data;
  final int btcIn;
  final int btcOut;
  final int btcChange;
  final int btcFee;
  final String rawtransaction;
  final ComposeFairmintVerboseParamsModel params;
  // final FairmintUnpackedVerbose unpackedData;

  ComposeFairmintVerboseModel({
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

  factory ComposeFairmintVerboseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeFairmintVerboseModelFromJson(json);

  ComposeFairmintResponse toDomain() => ComposeFairmintResponse(
        rawtransaction: rawtransaction,
        name: name,
        data: data,
        btcIn: btcIn,
        btcOut: btcOut,
        btcChange: btcChange,
        btcFee: btcFee,
        params: params.toDomain(),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeFairmintVerboseParamsModel {
  final String source;
  final String asset;
  final int quantity;
  final String quantityNormalized;
  final AssetInfoModel assetInfo;

  ComposeFairmintVerboseParamsModel({
    required this.source,
    required this.asset,
    required this.quantity,
    required this.quantityNormalized,
    required this.assetInfo,
  });

  factory ComposeFairmintVerboseParamsModel.fromJson(
          Map<String, dynamic> json) =>
      _$ComposeFairmintVerboseParamsModelFromJson(json);

  ComposeFairmintParams toDomain() => ComposeFairmintParams(
        source: source,
        asset: asset,
        quantity: quantity,
        quantityNormalized: quantityNormalized,
        assetInfo: assetInfo.toDomain(),
      );
}
