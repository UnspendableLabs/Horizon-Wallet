import 'package:horizon/domain/entities/cursor.dart';

class CursorModel {
  final int? intValue;
  final String? stringValue;

  CursorModel._({this.intValue, this.stringValue});

  factory CursorModel.fromInt(int value) => CursorModel._(intValue: value);
  factory CursorModel.fromString(String value) =>
      CursorModel._(stringValue: value);

  factory CursorModel.fromJson(dynamic json) {
    if (json is int) {
      return CursorModel.fromInt(json);
    } else if (json is String) {
      return CursorModel.fromString(json);
    }
    throw ArgumentError('Invalid cursor value');
  }

  dynamic toJson() {
    if (intValue != null) {
      return intValue;
    } else if (stringValue != null) {
      return stringValue;
    }
    return null;
  }
}

class CursorMapper {
  static Cursor? toDomain(CursorModel? cursor) {
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

  static CursorModel? toData(Cursor? cursor) {
    if (cursor == null) {
      return null;
    }
    if (cursor.intValue != null) {
      return CursorModel.fromInt(cursor.intValue!);
    } else if (cursor.stringValue != null) {
      return CursorModel.fromString(cursor.stringValue!);
    }
    throw ArgumentError('Invalid cursor value');
  }
}
