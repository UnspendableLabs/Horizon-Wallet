import "package:horizon/domain/repositories/config_repository.dart";
import "package:horizon/domain/repositories/version_repository.dart";
import "package:horizon/domain/entities/version_info.dart";
import 'package:fpdart/fpdart.dart';

class VersionRepositoryImpl implements VersionRepository {
  final Config config;

  VersionRepositoryImpl({required this.config});

  @override
  TaskEither<String, VersionInfo> get() {
    return TaskEither.of(
        VersionInfo(latest: config.version, min: config.version));
  }
}
