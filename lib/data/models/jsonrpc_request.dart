import 'package:json_annotation/json_annotation.dart';

part 'jsonrpc_request.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class JsonRpcRequest<T> {
  final String method;
  final T params;
  final String jsonrpc;
  final int id;

  const JsonRpcRequest({
    required this.method,
    required this.params,
    this.jsonrpc = "2.0",
    this.id = 0,
  });

  factory JsonRpcRequest.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$JsonRpcRequestFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$JsonRpcRequestToJson(this, toJsonT);
}
