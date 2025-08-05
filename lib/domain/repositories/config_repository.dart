import 'package:pub_semver/pub_semver.dart';
import 'package:fpdart/fpdart.dart';
export "package:horizon/domain/entities/network.dart";

class MeilisearchConfig {
  String api;
  String key;

  MeilisearchConfig({required this.api, required this.key});
}

abstract class Config {
  Version get version;
  String get versionInfoEndpoint;
  // Network get network;
  // String get counterpartyApiBase;
  // String get esploraBase;
  // String get blockCypherBase;
  bool get isDatabaseViewerEnabled;
  bool get isAnalyticsEnabled;
  bool get isWebExtension;
  String get sentryDsn;
  double get sentrySampleRate;
  bool get isSentryEnabled;
  int get defaultEnvelopeSize;
  bool get disableNativeOrders;

  Option<MeilisearchConfig> get meilisearchConfigMainnet;
  Option<MeilisearchConfig> get meilisearchConfigTestnet;
}
