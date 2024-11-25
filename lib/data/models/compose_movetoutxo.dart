import 'package:horizon/domain/entities/compose_movetoutxo.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose_movetoutxo.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeMoveToUtxoResponseModel {
  final String name;
  final String? data;
  final int btcIn;
  final int btcOut;
  final int btcChange;
  final int btcFee;
  final String rawtransaction;
  final ComposeMoveToUtxoResponseParamsModel params;
  // final OrderUnpackedVerbose unpackedData;

  ComposeMoveToUtxoResponseModel({
    required this.rawtransaction,
    required this.params,
    required this.name,
    // required this.unpackedData,
    required this.btcIn,
    required this.btcOut,
    required this.btcChange,
    required this.btcFee,
    this.data,
  });

  factory ComposeMoveToUtxoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeMoveToUtxoResponseModelFromJson(json);

  ComposeMoveToUtxoResponse toDomain() => ComposeMoveToUtxoResponse(
        name: name,
        data: data,
        rawtransaction: rawtransaction,
        btcFee: btcFee,
        params: params.toDomain(),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeMoveToUtxoResponseParamsModel {
  final String source;
  final String destination;
  final bool skipValidation;

  ComposeMoveToUtxoResponseParamsModel({
    required this.source,
    required this.destination,
    required this.skipValidation,
  });

  factory ComposeMoveToUtxoResponseParamsModel.fromJson(
          Map<String, dynamic> json) =>
      _$ComposeMoveToUtxoResponseParamsModelFromJson(json);

  ComposeMoveToUtxoResponseParams toDomain() => ComposeMoveToUtxoResponseParams(
        source: source,
        destination: destination,
        skipValidation: skipValidation,
      );
}
