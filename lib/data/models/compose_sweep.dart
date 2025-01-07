import 'package:horizon/domain/entities/compose_sweep.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compose_sweep.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeSweepResponseModel {
  final String name;
  final String? data;
  final int btcIn;
  final int btcOut;
  final int btcChange;
  final int btcFee;
  final String rawtransaction;
  final ComposeSweepParamsModel params;

  ComposeSweepResponseModel({
    required this.rawtransaction,
    required this.params,
    required this.name,
    required this.btcIn,
    required this.btcOut,
    required this.btcChange,
    required this.btcFee,
    this.data,
  });

  factory ComposeSweepResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeSweepResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComposeSweepResponseModelToJson(this);

  ComposeSweepResponse toDomain() => ComposeSweepResponse(
        name: name,
        data: data,
        rawtransaction: rawtransaction,
        btcFee: btcFee,
        params: params.toDomain(),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeSweepParamsModel {
  final String source;
  final String destination;
  final int flags;
  final String memo;
  final bool skipValidation;

  ComposeSweepParamsModel({
    required this.source,
    required this.destination,
    required this.flags,
    required this.memo,
    required this.skipValidation,
  });

  factory ComposeSweepParamsModel.fromJson(Map<String, dynamic> json) =>
      _$ComposeSweepParamsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComposeSweepParamsModelToJson(this);

  ComposeSweepResponseParams toDomain() => ComposeSweepResponseParams(
        source: source,
        destination: destination,
        flags: flags,
        memo: memo,
        skipValidation: skipValidation,
      );
}
