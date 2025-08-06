import 'package:horizon/data/models/signed_tx_estimated_size.dart';
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
  final String psbt;
  final ComposeMoveToUtxoResponseParamsModel params;
  final SignedTxEstimatedSizeModel signedTxEstimatedSize;

  ComposeMoveToUtxoResponseModel({
    required this.rawtransaction,
    required this.psbt,
    required this.params,
    required this.name,
    required this.btcIn,
    required this.btcOut,
    required this.btcChange,
    required this.btcFee,
    this.data,
    required this.signedTxEstimatedSize,
  });

  factory ComposeMoveToUtxoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeMoveToUtxoResponseModelFromJson(json);

  ComposeMoveToUtxoResponse toDomain() => ComposeMoveToUtxoResponse(
        name: name,
        data: data,
        rawtransaction: rawtransaction,
        psbt: psbt,
        btcFee: btcFee,
        params: params.toDomain(),
        signedTxEstimatedSize: signedTxEstimatedSize.toDomain(),
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
