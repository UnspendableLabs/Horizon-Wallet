import 'package:horizon/domain/entities/version_info.dart';
import 'package:fpdart/fpdart.dart';

abstract class VersionRepository {
  TaskEither<String, VersionInfo> get();
}
