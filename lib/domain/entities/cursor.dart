import 'package:horizon/data/models/cursor.dart' as data;

class Cursor {
  final int? intValue;
  final String? stringValue;

  Cursor._({this.intValue, this.stringValue});

  factory Cursor.fromInt(int value) => Cursor._(intValue: value);
  factory Cursor.fromString(String value) => Cursor._(stringValue: value);
}

class CursorMapper {
  static Cursor? toDomain(data.Cursor? cursor) {
    if (cursor == null) {
      return null;
    }
    if (cursor.intValue != null) {
      return Cursor.fromInt(cursor.intValue!);
    } else if (cursor.stringValue != null) {
      return Cursor.fromString(cursor.stringValue!);
    }
    throw ArgumentError('Invalid cursor value');
  }

  static data.Cursor? toData(Cursor? cursor) {
    if (cursor == null) {
      return null;
    }
    if (cursor.intValue != null) {
      return data.Cursor.fromInt(cursor.intValue!);
    } else if (cursor.stringValue != null) {
      return data.Cursor.fromString(cursor.stringValue!);
    }
    throw ArgumentError('Invalid cursor value');
  }
}
