import 'package:horizon/domain/entities/node_info.dart';
import 'package:json_annotation/json_annotation.dart';

part "node_info.g.dart";

@JsonSerializable(fieldRename: FieldRename.snake)
class NodeInfoModel {
  final bool serverReady;
  final String network;
  final String version;
  final int backendHeight;
  final int counterpartyHeight;
  final String documentation;
  final String routes;
  final String blueprint;

  const NodeInfoModel({
    required this.serverReady,
    required this.network,
    required this.version,
    required this.backendHeight,
    required this.counterpartyHeight,
    required this.documentation,
    required this.routes,
    required this.blueprint,
  });

  factory NodeInfoModel.fromJson(Map<String, dynamic> json) =>
      _$NodeInfoModelFromJson(json);

  NodeInfo toDomain() {
    return NodeInfo(
      serverReady: serverReady,
      network: network,
      version: version,
      backendHeight: backendHeight,
      counterpartyHeight: counterpartyHeight,
      documentation: documentation,
      routes: routes,
      blueprint: blueprint,
    );
  }
}
