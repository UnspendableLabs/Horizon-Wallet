import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/compose_response.dart';

part 'signed_tx_estimated_size.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SignedTxEstimatedSizeModel {
  final int vsize;
  final int adjustedVsize;
  final int sigopsCount;

  SignedTxEstimatedSizeModel({
    required this.vsize,
    required this.adjustedVsize,
    required this.sigopsCount,
  });

  factory SignedTxEstimatedSizeModel.fromJson(Map<String, dynamic> json) =>
      _$SignedTxEstimatedSizeModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignedTxEstimatedSizeModelToJson(this);

  SignedTxEstimatedSize toDomain() => SignedTxEstimatedSize(
        virtualSize: vsize,
        adjustedVirtualSize: adjustedVsize,
        sigopsCount: sigopsCount,
      );
}
