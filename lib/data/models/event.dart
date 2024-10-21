
import 'package:horizon/domain/entities/event.dart';


class EventStatusMapper {
  static EventStatus fromString(String statusString) {
    if (statusString == 'valid') {
      return EventStatusValid();
    } else if (statusString.startsWith('invalid:')) {
      String reason =
          statusString.substring(8).trim(); // Extract reason after 'invalid:'
      return EventStatusInvalid(reason: reason);
    } else {
      throw FormatException("Unknown status format: $statusString");
    }
  }
}

