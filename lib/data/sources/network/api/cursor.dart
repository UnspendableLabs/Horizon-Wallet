class Cursor {
  final int? intValue;
  final String? stringValue;

  Cursor._({this.intValue, this.stringValue});

  factory Cursor.fromInt(int value) => Cursor._(intValue: value);
  factory Cursor.fromString(String value) => Cursor._(stringValue: value);

  factory Cursor.fromJson(dynamic json) {
    if (json is int) {
      return Cursor.fromInt(json);
    } else if (json is String) {
      return Cursor.fromString(json);
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
