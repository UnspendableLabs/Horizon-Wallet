import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/cursor.dart';

abstract class EventsRepository {
  Future<(List<Event>, Cursor? nextCursor, int? resultCount)> getByAddresses({
    required List<String> addresses,
    int? limit,
    Cursor? cursor,
    bool? unconfirmed = false,
    List<String>? whitelist,
  });
  Future<(List<VerboseEvent>, Cursor? nextCursor, int? resultCount)>
      getByAddressesVerbose({
    required List<String> addresses,
    int? limit,
    Cursor? cursor,
    bool? unconfirmed = false,
    List<String>? whitelist,
  });

  Future<List<Event>> getAllByAddresses({
    required List<String> addresses,
    bool? unconfirmed = false,
    List<String>? whitelist,
  });

  Future<List<VerboseEvent>> getAllByAddressesVerbose({
    required List<String> addresses,
    bool? unconfirmed = false,
    List<String>? whitelist,
  });
}
