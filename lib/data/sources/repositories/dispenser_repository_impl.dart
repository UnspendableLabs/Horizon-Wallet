import "package:fpdart/fpdart.dart";
import "package:horizon/domain/repositories/dispenser_repository.dart";
import "package:horizon/domain/entities/dispenser.dart" as e;
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/core/logging/logger.dart';

class DispenserRepositoryImpl implements DispenserRepository {
  final V2Api api;
  final Logger? logger;
  DispenserRepositoryImpl({required this.api, this.logger});
  @override
  TaskEither<String, List<e.Dispenser>> getDispensersByAddress(String address) {
    return TaskEither.tryCatch(() => _getDispensersByAddress(address),
        (error, stacktrace) {
      logger?.error(
          "DispenserRepositoryImpl.getDispensersByAddress", null, stacktrace);

      return "GetDispensersByAddress failure";
    });
  }

  Future<List<e.Dispenser>> _getDispensersByAddress(String address) async {
    final response = await api.getDispensersByAddress(
        address,
        true,     // verbose
        "open"    // status
        );

    if (response.result == null) {
      throw Exception();
    }

    return response.result!.map((d) => d.toDomain()).toList();
  }
}
