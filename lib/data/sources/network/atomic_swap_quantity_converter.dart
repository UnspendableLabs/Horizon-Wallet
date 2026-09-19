import 'package:json_annotation/json_annotation.dart';

/// Market serializes PostgreSQL bigint quantities as decimal strings. Never
/// route those strings through num/double: browser numbers lose precision.
class AtomicSwapQuantityConverter implements JsonConverter<BigInt, Object?> {
  const AtomicSwapQuantityConverter();

  @override
  BigInt fromJson(Object? value) {
    if (value is String && RegExp(r'^[0-9]+$').hasMatch(value)) {
      return BigInt.parse(value);
    }
    // Accept legacy numeric responses only when they are exact on both Dart VM
    // and JavaScript. Reject malformed data instead of rounding or using zero.
    if (value is num &&
        value.isFinite &&
        value >= 0 &&
        value <= 9007199254740991 &&
        value == value.truncateToDouble()) {
      return BigInt.from(value);
    }
    throw const FormatException('Invalid atomic swap asset quantity');
  }

  @override
  String toJson(BigInt value) => value.toString();
}
