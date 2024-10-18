import "package:fpdart/fpdart.dart";
import 'package:horizon/data/models/fairminter.dart';
import "package:horizon/domain/entities/fairminter.dart" as e;
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/fairminter_repository.dart';

import 'package:horizon/data/models/cursor.dart' as cursor_model;

class FairmintRepositoryImpl implements FairminterRepository {
  final V2Api api;
  final Logger? logger;
  FairmintRepositoryImpl({required this.api, this.logger});
  @override
  TaskEither<String, List<e.Fairminter>> getAllFairminters() {
    return TaskEither.tryCatch(() => _getAllFairminters(), (error, stacktrace) {
      logger?.error(
          "FairmintRepositoryImpl.getAllFairminters", null, stacktrace);

      return "GetAllFairminters failure";
    });
  }

  Future<List<e.Fairminter>> _getAllFairminters() async {
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
      final response = await api.getAllFairminters(true, cursor, limit);
      for (FairminterModel a in response.result ?? []) {
        fairminters.add(a.toDomain());
      }
      cursor = response.nextCursor;
    } while (cursor != null);

    return fairminters;
  }
}
