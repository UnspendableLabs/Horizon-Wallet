import 'package:pub_semver/pub_semver.dart';
export "package:horizon/domain/entities/network.dart";

abstract class Config {
  Version get version;
  String get versionInfoEndpoint;
  bool get isDatabaseViewerEnabled;
  bool get isAnalyticsEnabled;
  bool get isWebExtension;
  String get sentryDsn;
  double get sentrySampleRate;
  bool get isSentryEnabled;
  int get defaultEnvelopeSize;
}
