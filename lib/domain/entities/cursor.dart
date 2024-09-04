class Cursor {
  final int? intValue;
  final String? stringValue;

  Cursor._({this.intValue, this.stringValue});

  factory Cursor.fromInt(int value) => Cursor._(intValue: value);
  factory Cursor.fromString(String value) => Cursor._(stringValue: value);
}
