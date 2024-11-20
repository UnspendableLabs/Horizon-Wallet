import "package:horizon/domain/repositories/config_repository.dart";
import "package:horizon/domain/repositories/version_repository.dart";
import "package:horizon/core/logging/logger.dart";
import 'package:pub_semver/pub_semver.dart';
import "package:horizon/domain/entities/version_info.dart";
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';

class VersionRepositoryExtensionImpl implements VersionRepository {
  final Config config;
  final Logger logger;
  Dio dio;

  VersionInfo? _cache;

  VersionRepositoryExtensionImpl({required this.config, required this.logger})
      : dio = Dio(BaseOptions(
          baseUrl: config.versionInfoEndpoint,
        ));

  @override
  TaskEither<String, VersionInfo> get() {
    return TaskEither.tryCatch(
      _get,
      (error, stacktrace) {
        logger.error("Error fetching version info: ${error.toString()}", null,
            stacktrace);
        return "Error fetching version info: ${error.toString()}";
      },
    );
  }

  Future<VersionInfo> _get() async {

    if (_cache != null) {
      return _cache!;
    }

    final response = await dio.get("");

    final versionInfo = _parseVersionInfo(response);

    _cache = versionInfo;

    return versionInfo;
  }

  VersionInfo _parseVersionInfo(Response<dynamic> response) {
    try {
      // Access the actual data from the response
      final data = response.data as Map<String, dynamic>;
      final walletData = data['wallet'] as Map<String, dynamic>;
      final latestVersionStr = walletData['latest'] as String;
      final minVersionStr = walletData['min'] as String;
      final latestVersion = Version.parse(latestVersionStr);
      final minVersion = Version.parse(minVersionStr);
      return VersionInfo(latest: latestVersion, min: minVersion);
    } catch (e) {
      throw Exception('Error parsing version info: $e');
    }
  }
}
