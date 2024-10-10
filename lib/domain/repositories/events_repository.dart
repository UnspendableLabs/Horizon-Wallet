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
      getByAddressVerbose({
    required String address,
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

  Future<List<VerboseEvent>> getAllByAddressVerbose({
    required String address,
    bool? unconfirmed = false,
    List<String>? whitelist,
  });

  Future<(List<VerboseEvent>, Cursor? nextCursor, int? resultCount)>
      getMempoolEventsByAddressVerbose({
    required String address,
    int? limit,
    Cursor? cursor,
    bool? unconfirmed = false,
    List<String>? whitelist,
  });
}
