import 'package:pub_semver/pub_semver.dart';

class VersionInfo {
  final Version latest;
  final Version min;

  const VersionInfo({required this.latest, required this.min});
}
