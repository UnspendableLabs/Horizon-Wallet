import 'package:horizon/data/models/signed_tx_estimated_size.dart';
import 'package:horizon/domain/entities/compose_cancel.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose_cancel.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeCancelResponseModel {
  final String name;
  final String data;
  final int btcIn;
  final int btcOut;
  final int btcChange;
  final int btcFee;
  final String rawtransaction;
  final String psbt;
  final ComposeCancelResponseParamsModel params;
  final SignedTxEstimatedSizeModel signedTxEstimatedSize;
  // final CancelUnpackedVerbose unpackedData;

  ComposeCancelResponseModel({
    required this.rawtransaction,
    required this.psbt,
    required this.params,
    required this.name,
    // required this.unpackedData,
    required this.btcIn,
    required this.btcOut,
    required this.btcChange,
    required this.btcFee,
    required this.data,
    required this.signedTxEstimatedSize,
  });

  factory ComposeCancelResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeCancelResponseModelFromJson(json);

  ComposeCancelResponse toDomain() => ComposeCancelResponse(
        psbt: psbt,
        rawtransaction: rawtransaction,
        btcFee: btcFee,
        params: params.toDomain(),
        signedTxEstimatedSize: signedTxEstimatedSize.toDomain(),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeCancelResponseParamsModel {
  final String source;
  final String offerHash;

  ComposeCancelResponseParamsModel(
      {required this.source, required this.offerHash});

  factory ComposeCancelResponseParamsModel.fromJson(
          Map<String, dynamic> json) =>
      _$ComposeCancelResponseParamsModelFromJson(json);

  ComposeCancelResponseParams toDomain() => ComposeCancelResponseParams(
        source: source,
        offerHash: offerHash,
      );
}
