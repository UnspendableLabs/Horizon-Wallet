import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/cursor.dart';

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
  });

  // Future<List<Event>> getAllByAddress({
  //   required String address,
  //   bool? unconfirmed = false,
  //   List<String>? whitelist,
  // });

  Future<List<VerboseEvent>> getAllMempoolVerboseEventsForAddresses(
    List<String> addresses,
    List<String>? whitelist,
  );

  Future<List<VerboseEvent>> getAllByAddressesVerbose({
    required List<String> addresses,
    bool? unconfirmed = false,
    List<String>? whitelist,
  });

  Future<(List<VerboseEvent>, Cursor? nextCursor, int? resultCount)>
      getMempoolEventsByAddressesVerbose({
    required List<String> addresses,
    int? limit,
    Cursor? cursor,
    List<String>? whitelist,
  });

  Future<int> numEventsForAddresses({
    required List<String> addresses,
  });
}
