import 'package:horizon/domain/entities/compose_detach_utxo.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose_detach_utxo.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeDetachUtxoResponseModel {
  final String name;
  final String data;
  final int btcIn;
  final int btcOut;
  final int? btcChange;
  final int btcFee;
  final String rawtransaction;
  final ComposeDetachUtxoResponseParamsModel params;
  // final OrderUnpackedVerbose unpackedData;

  ComposeDetachUtxoResponseModel({
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

  factory ComposeDetachUtxoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeDetachUtxoResponseModelFromJson(json);

  ComposeDetachUtxoResponse toDomain() => ComposeDetachUtxoResponse(
        name: name,
        data: data,
        rawtransaction: rawtransaction,
        btcFee: btcFee,
        params: params.toDomain(),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeDetachUtxoResponseParamsModel {
  final String source;
  final String destination;
  final bool skipValidation;

  ComposeDetachUtxoResponseParamsModel(
      {required this.source,
      required this.destination,
      required this.skipValidation});

  factory ComposeDetachUtxoResponseParamsModel.fromJson(
          Map<String, dynamic> json) =>
      _$ComposeDetachUtxoResponseParamsModelFromJson(json);

  ComposeDetachUtxoResponseParams toDomain() => ComposeDetachUtxoResponseParams(
        source: source,
        destination: destination,
        skipValidation: skipValidation,
      );
}
