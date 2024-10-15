import 'package:horizon/domain/entities/compose_dispense.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeDispenseParamsModel extends ComposeDispenseParams {
  ComposeDispenseParamsModel({
    required super.address,
    required super.dispenser,
    required super.quantity,
  });

  ComposeDispenseParams toDomain() {
    return ComposeDispenseParams(
      address: address,
      dispenser: dispenser,
      quantity: quantity,
    );
  }

  factory ComposeDispenseParamsModel.fromJson(Map<String, String> json) =>
      _$ComposeDispenseParamsModelFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeDispenseResponseParamsModel extends ComposeDispenseResponseParams {
  ComposeDispenseResponseParamsModel({
    required super.source,
    required super.destination,
    required super.quantity,
    // required super.quantityNormalized,
  });

  // JSON serialization methods
  factory ComposeDispenseResponseParamsModel.fromJson(
          Map<String, dynamic> json) =>
      _$ComposeDispenseResponseParamsModelFromJson(json);
  Map<String, dynamic> toJson() =>
      _$ComposeDispenseResponseParamsModelToJson(this);

  // Domain conversion function
  ComposeDispenseResponseParams toDomain() {
    return ComposeDispenseResponseParams(
      source: source,
      destination: destination,
      quantity: quantity,
      // quantityNormalized: quantityNormalized,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeDispenseResponseModel extends ComposeDispenseResponse {
  @override
  final ComposeDispenseResponseParamsModel params;

  ComposeDispenseResponseModel({
    required this.params,
    required super.rawtransaction,
    required super.name,
    required super.btcIn,
    required super.btcOut,
    required super.btcChange,
    required super.btcFee,
    // required super.data,
  }) : super(params: params);

  factory ComposeDispenseResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeDispenseResponseModelFromJson(json);

  // Domain conversion function
  ComposeDispenseResponse toDomain() {
    return ComposeDispenseResponse(
      rawtransaction: rawtransaction,
      params: params.toDomain(),
      name: name,
      btcIn: btcIn,
      btcOut: btcOut,
      btcChange: btcChange,
      btcFee: btcFee,
      // data: data,
    );
  }
}
