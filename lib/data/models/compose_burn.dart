import 'package:horizon/data/models/signed_tx_estimated_size.dart';
import 'package:horizon/domain/entities/compose_burn.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose_burn.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeBurnResponseModel {
  final String name;
  final String? data;
  final int btcIn;
  final int btcOut;
  final int? btcChange;
  final int btcFee;
  final String rawtransaction;
  final ComposeBurnParamsModel params;
  final SignedTxEstimatedSizeModel signedTxEstimatedSize;

  ComposeBurnResponseModel({
    required this.rawtransaction,
    required this.params,
    required this.name,
    required this.btcIn,
    required this.btcOut,
    this.btcChange,
    required this.btcFee,
    this.data,
    required this.signedTxEstimatedSize,
  });

  factory ComposeBurnResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeBurnResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComposeBurnResponseModelToJson(this);

  ComposeBurnResponse toDomain() => ComposeBurnResponse(
        rawtransaction: rawtransaction,
        name: name,
        data: data,
        btcIn: btcIn,
        btcOut: btcOut,
        btcChange: btcChange,
        btcFee: btcFee,
        params: params.toDomain(),
        signedTxEstimatedSize: signedTxEstimatedSize.toDomain(),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeBurnParamsModel {
  final String source;
  final int quantity;
  final bool overburn;
  final bool skipValidation;

  ComposeBurnParamsModel({
    required this.source,
    required this.quantity,
    required this.overburn,
    required this.skipValidation,
  });

  factory ComposeBurnParamsModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeBurnParamsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComposeBurnParamsModelToJson(this);

  ComposeBurnResponseParams toDomain() => ComposeBurnResponseParams(
        source: source,
        quantity: quantity,
        overburn: overburn,
        skipValidation: skipValidation,
      );
}
