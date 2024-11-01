import 'package:json_annotation/json_annotation.dart';

part 'create_send_params.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SendAssetParams {
  final String source;
  final String destination;
  final String asset;
  final int quantity;

  const SendAssetParams({
    required this.source,
    required this.destination,
    required this.asset,
    required this.quantity,
  });

  factory SendAssetParams.fromJson(Map<String, dynamic> json) =>
      _$SendAssetParamsFromJson(json);

  Map<String, dynamic> toJson() => _$SendAssetParamsToJson(this);
}
