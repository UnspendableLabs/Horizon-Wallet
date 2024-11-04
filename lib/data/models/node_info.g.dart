// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeInfoModel _$NodeInfoModelFromJson(Map<String, dynamic> json) =>
    NodeInfoModel(
      serverReady: json['server_ready'] as bool,
      network: json['network'] as String,
      version: json['version'] as String,
      backendHeight: (json['backend_height'] as num).toInt(),
      counterpartyHeight: (json['counterparty_height'] as num).toInt(),
      documentation: json['documentation'] as String,
      routes: json['routes'] as String,
      blueprint: json['blueprint'] as String,
    );

Map<String, dynamic> _$NodeInfoModelToJson(NodeInfoModel instance) =>
    <String, dynamic>{
      'server_ready': instance.serverReady,
      'network': instance.network,
      'version': instance.version,
      'backend_height': instance.backendHeight,
      'counterparty_height': instance.counterpartyHeight,
      'documentation': instance.documentation,
      'routes': instance.routes,
      'blueprint': instance.blueprint,
    };
