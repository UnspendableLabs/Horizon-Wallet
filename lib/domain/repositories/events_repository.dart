import 'package:horizon/domain/entities/event.dart';

abstract class EventsRepository {
  Future<(List<Event>, int? nextCursor, int? resultCount)> getByAddresses({
    required List<String> addresses,
    int? limit,
    int? cursor,
    bool? unconfirmed = false,
    List<String>? whitelist,
  });
  Future<(List<VerboseEvent>, int? nextCursor, int? resultCount)>
      getByAddressesVerbose({
    required List<String> addresses,
    int? limit,
    int? cursor,
    bool? unconfirmed = false,
    List<String>? whitelist,
  });
}
