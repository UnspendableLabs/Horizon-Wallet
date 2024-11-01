// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jsonrpc_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonRpcRequest<T> _$JsonRpcRequestFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    JsonRpcRequest<T>(
      method: json['method'] as String,
      params: fromJsonT(json['params']),
      jsonrpc: json['jsonrpc'] as String? ?? "2.0",
      id: (json['id'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$JsonRpcRequestToJson<T>(
  JsonRpcRequest<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'method': instance.method,
      'params': toJsonT(instance.params),
      'jsonrpc': instance.jsonrpc,
      'id': instance.id,
    };
