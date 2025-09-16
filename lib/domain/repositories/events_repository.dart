import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/cursor.dart';
import 'package:horizon/domain/entities/http_config.dart';

import 'package:fpdart/fpdart.dart';

abstract class EventsRepository {
  // Future<(List<Event>, Cursor? nextCursor, int? resultCount)> getByAddress({
  //   required String address,
  //   int? limit,
  //   Cursor? cursor,
  //   bool? unconfirmed = false,
  //   List<String>? whitelist,
  // });
  Future<(List<VerboseEvent>, Cursor? nextCursor, int? resultCount)>
      getByAddressesVerbose({
    required List<String> addresses,
    int? limit,
    Cursor? cursor,
    bool? unconfirmed = false,
    List<String>? whitelist,
    required HttpConfig httpConfig,
  });

  // Future<List<Event>> getAllByAddress({
  //   required String address,
  //   bool? unconfirmed = false,
  //   List<String>? whitelist,
  // });

  Future<List<VerboseEvent>> getAllMempoolVerboseEventsForAddresses(
    HttpConfig httpConfig,
    List<String> addresses,
    List<String>? whitelist,
  );

  Future<List<VerboseEvent>> getAllByAddressesVerbose({
    required HttpConfig httpConfig,
    required List<String> addresses,
    bool? unconfirmed = false,
    List<String>? whitelist,
  });

  Future<(List<VerboseEvent>, Cursor? nextCursor, int? resultCount)>
      getMempoolEventsByAddressesVerbose({
    required HttpConfig httpConfig,
    required List<String> addresses,
    int? limit,
    Cursor? cursor,
    List<String>? whitelist,
  });

  Future<int> numEventsForAddresses({
    required HttpConfig httpConfig,
    required List<String> addresses,
  });
}

extension EventsRepositoryX on EventsRepository {
  TaskEither<String, (List<VerboseEvent>, Cursor? nextCursor, int? resultCount)>
      getByAddressesVerboseT({
    required List<String> addresses,
    int? limit,
    Cursor? cursor,
    bool? unconfirmed = false,
    List<String>? whitelist,
    required HttpConfig httpConfig,
    required String Function(Object error, StackTrace stacktrace) onError,
  }) =>
          TaskEither.tryCatch(
            () => getByAddressesVerbose(
              addresses: addresses,
              limit: limit,
              cursor: cursor,
              unconfirmed: unconfirmed,
              whitelist: whitelist,
              httpConfig: httpConfig,
            ),
            onError,
          );

  TaskEither<String, List<VerboseEvent>>
      getAllMempoolVerboseEventsForAddressesT(
    HttpConfig httpConfig,
    List<String> addresses,
    List<String>? whitelist,
    String Function(Object error, StackTrace stacktrace) onError,
  ) =>
          TaskEither.tryCatch(
            () => getAllMempoolVerboseEventsForAddresses(
              httpConfig,
              addresses,
              whitelist,
            ),
            onError,
          );

  TaskEither<String, List<VerboseEvent>> getAllByAddressesVerboseT({
    required HttpConfig httpConfig,
    required List<String> addresses,
    bool? unconfirmed = false,
    List<String>? whitelist,
    required String Function(Object error, StackTrace stacktrace) onError,
  }) =>
      TaskEither.tryCatch(
        () => getAllByAddressesVerbose(
          httpConfig: httpConfig,
          addresses: addresses,
          unconfirmed: unconfirmed,
          whitelist: whitelist,
        ),
        onError,
      );

  TaskEither<String, (List<VerboseEvent>, Cursor? nextCursor, int? resultCount)>
      getMempoolEventsByAddressesVerboseT({
    required HttpConfig httpConfig,
    required List<String> addresses,
    int? limit,
    Cursor? cursor,
    List<String>? whitelist,
    required String Function(Object error, StackTrace stacktrace) onError,
  }) =>
          TaskEither.tryCatch(
            () => getMempoolEventsByAddressesVerbose(
              httpConfig: httpConfig,
              addresses: addresses,
              limit: limit,
              cursor: cursor,
              whitelist: whitelist,
            ),
            onError,
          );

  TaskEither<String, int> numEventsForAddressesT({
    required HttpConfig httpConfig,
    required List<String> addresses,
    required String Function(Object error, StackTrace stacktrace) onError,
  }) =>
      TaskEither.tryCatch(
        () => numEventsForAddresses(
          httpConfig: httpConfig,
          addresses: addresses,
        ),
        onError,
      );
}
