import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/data/models/event.dart';

void main() {
  group('EventStatusMapper', () {
    test('should return EventStatusValid for "valid" string', () {
      // Arrange
      String input = 'valid';

      // Act
      var result = EventStatusMapper.fromString(input);

      // Assert
      expect(result, isA<EventStatusValid>());
    });

    test(
        'should return EventStatusInvalid with reason for "invalid: <reason>" string',
        () {
      // Arrange
      String input = 'invalid: expired token';

      // Act
      var result = EventStatusMapper.fromString(input);

      // Assert
      expect(result, isA<EventStatusInvalid>());
      expect((result as EventStatusInvalid).reason, 'expired token');
    });

    test('should throw FormatException for unknown status format', () {
      // Arrange
      String input = 'unknown status';

      // Act & Assert
      expect(() => EventStatusMapper.fromString(input), throwsFormatException);
    });
  });
}
