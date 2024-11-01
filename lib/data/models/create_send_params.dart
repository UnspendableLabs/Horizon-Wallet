import 'package:json_annotation/json_annotation.dart';

part 'create_send_params.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateSendParams {
  final String source;
  final String destination;
  final String asset;
  final int quantity;

  const CreateSendParams({
    required this.source,
    required this.destination,
    required this.asset,
    required this.quantity,
  });

  factory CreateSendParams.fromJson(Map<String, dynamic> json) =>
      _$CreateSendParamsFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSendParamsToJson(this);
}
