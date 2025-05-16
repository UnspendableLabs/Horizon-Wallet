import "package:fpdart/fpdart.dart";
import 'package:get_it/get_it.dart';
import "package:horizon/domain/repositories/dispenser_repository.dart";
import "package:horizon/domain/entities/dispenser.dart" as e;
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';
import 'package:horizon/domain/entities/http_config.dart';

class DispenserRepositoryImpl implements DispenserRepository {
  final Logger? logger;
  final CounterpartyClientFactory _counterpartyClientFactory;
  DispenserRepositoryImpl({
    this.logger,
    CounterpartyClientFactory? counterpartyClientFactory,
  }) : _counterpartyClientFactory =
            counterpartyClientFactory ?? GetIt.I<CounterpartyClientFactory>();

  @override
  TaskEither<String, List<e.Dispenser>> getDispensersByAddress(
      String address, HttpConfig httpConfig) {
    return TaskEither.tryCatch(
        () => _getDispensersByAddress(address, httpConfig),
        (error, stacktrace) {
      logger?.error(
          "DispenserRepositoryImpl.getDispensersByAddress", null, stacktrace);

      return "GetDispensersByAddress failure";
    });
  }

  Future<List<e.Dispenser>> _getDispensersByAddress(
      String address, HttpConfig httpConfig) async {
    final response = await _counterpartyClientFactory
        .getClient(httpConfig)
        .getDispensersByAddress(
            address,
            true, // verbose
            "open" // status
            );

    if (response.result == null) {
      throw Exception();
    }

    return response.result!.map((d) => d.toDomain()).toList();
  }
}
