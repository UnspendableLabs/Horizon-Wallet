import 'package:get_it/get_it.dart';
import "package:fpdart/fpdart.dart";
import 'package:horizon/data/models/fairminter.dart';
import "package:horizon/domain/entities/fairminter.dart" as e;
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/fairminter_repository.dart';

import 'package:horizon/data/models/cursor.dart' as cursor_model;
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';

class FairminterRepositoryImpl implements FairminterRepository {
  final CounterpartyClientFactory _counterpartyClientFactory;
  final Logger? logger;
  FairminterRepositoryImpl({
    this.logger,
    CounterpartyClientFactory? counterpartyClientFactory,
  }) : _counterpartyClientFactory =
            counterpartyClientFactory ?? GetIt.I<CounterpartyClientFactory>();

  @override
  TaskEither<String, List<e.Fairminter>> getAllFairminters(
      HttpConfig httpConfig) {
    return TaskEither.tryCatch(() => _getAllFairminters(httpConfig),
        (error, stacktrace) {
      logger?.error(
          "FairmintRepositoryImpl.getAllFairminters", null, stacktrace);

      return "GetAllFairminters failure";
    });
  }

  Future<List<e.Fairminter>> _getAllFairminters(HttpConfig httpConfig) async {
    // int limit = 50;
    // cursor_model.CursorModel? cursor;

    // final response = await api.getAllFairminters(
    //     null, // cursor
    //     null, // limit
    //     );

    // if (response.result == null) {
    //   throw Exception();
    // }

    // return response.result!.map((d) => d.toDomain()).toList();

    final List<e.Fairminter> fairminters = [];
    int limit = 50;
    cursor_model.CursorModel? cursor;

    do {
      final response = await _counterpartyClientFactory
          .getClient(httpConfig)
          .getAllFairminters(cursor, limit);
      for (FairminterModel a in response.result ?? []) {
        fairminters.add(a.toDomain());
      }
      cursor = response.nextCursor;
    } while (cursor != null);

    return fairminters;
  }

  @override
  TaskEither<String, List<e.Fairminter>> getFairmintersByAddress(
      HttpConfig httpConfig, String address,
      [String? status]) {
    return TaskEither.tryCatch(
        () => _getFairmintersByAddress(address, status, httpConfig),
        (error, stacktrace) {
      logger?.error(
          "FairmintRepositoryImpl.getFairmintersByAddress", null, stacktrace);
      return "GetFairmintersByAddress failure";
    });
  }

  Future<List<e.Fairminter>> _getFairmintersByAddress(
      String address, String? status, HttpConfig httpConfig) async {
    int limit = 50;
    cursor_model.CursorModel? cursor;
    final List<e.Fairminter> fairminters = [];
    do {
      final response = await _counterpartyClientFactory
          .getClient(httpConfig)
          .getFairmintersByAddress(address, status, cursor, limit);
      for (FairminterModel a in response.result ?? []) {
        fairminters.add(a.toDomain());
      }
      cursor = response.nextCursor;
    } while (cursor != null);
    return fairminters;
  }

  @override
  TaskEither<String, List<e.Fairminter>> getFairmintersByAsset(
      HttpConfig httpConfig, String asset,
      [String? status]) {
    return TaskEither.tryCatch(
        () => _getFairmintersByAsset(asset, status, httpConfig),
        (error, stacktrace) {
      logger?.error(
          "FairmintRepositoryImpl.getFairmintersByAsset", null, stacktrace);
      return "GetFairmintersByAsset failure";
    });
  }

  Future<List<e.Fairminter>> _getFairmintersByAsset(
      String asset, String? status, HttpConfig httpConfig) async {
    int limit = 50;
    cursor_model.CursorModel? cursor;
    final List<e.Fairminter> fairminters = [];
    do {
      final response = await _counterpartyClientFactory
          .getClient(httpConfig)
          .getFairmintersByAsset(asset, status, cursor, limit);
      for (FairminterModel a in response.result ?? []) {
        fairminters.add(a.toDomain());
      }
      cursor = response.nextCursor;
    } while (cursor != null);
    return fairminters;
  }
}
