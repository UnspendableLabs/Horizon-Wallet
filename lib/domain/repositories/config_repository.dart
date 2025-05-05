import 'package:pub_semver/pub_semver.dart';
import "package:horizon/domain/entities/network.dart";
export "package:horizon/domain/entities/network.dart";

abstract class Config {
  Version get version;
  String get versionInfoEndpoint;
  Network get network;
  String get counterpartyApiBase;
  String get counterpartyApiUsername;
  String get counterpartyApiPassword;
  String get esploraBase;
  // String get blockCypherBase;
  String get horizonExplorerBase;
  String get btcExplorerBase;
  bool get isDatabaseViewerEnabled;
  bool get isAnalyticsEnabled;
  bool get isWebExtension;
  String get sentryDsn;
  double get sentrySampleRate;
  bool get isSentryEnabled;
}
