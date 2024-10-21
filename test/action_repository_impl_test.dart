import 'package:test/test.dart';
import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/domain/entities/action.dart';
import 'package:horizon/data/sources/repositories/action_repository_impl.dart';

void main() {
  late ActionRepository actionRepository;

  setUp(() {
    actionRepository = ActionRepositoryImpl();
  });

  group(DispenseAction, () {
    test('should decode a valid dispense action', () {
      // Arrange
      const encodedString = 'dispense,0x123abc';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<DispenseAction>());
          final action = r as DispenseAction;
          expect(action.address, '0x123abc');
        },
      );
    });

    test('should return an error for an invalid action type', () {
      // Arrange
      const encodedString = 'invalidaction,0x123abc';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isLeft(), true);
      result.match(
        (l) => expect(l, 'Failed to parse action'),
        (r) => fail('Expected Left but got Right: $r'),
      );
    });

    test('should return an error for a missing parameter', () {
      // Arrange
      const encodedString = 'dispense'; // Missing the address

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isLeft(), true);
      result.match(
        (l) => expect(l, 'Failed to parse action'),
        (r) => fail('Expected Left but got Right: $r'),
      );
    });

    test('should correctly decode with URI-encoded characters', () {
      // Arrange
      const encodedString = 'dispense,0x123%20abc'; // URI-encoded space

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<DispenseAction>());
          final action = r as DispenseAction;
          expect(action.address, '0x123 abc'); // Decoded space
        },
      );
    });
  });
  group(FairmintAction, () {
    test('should decode a valid fairmint action', () {
      // Arrange
      const encodedString = 'fairmint,0x123abc';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<FairmintAction>());
          final action = r as FairmintAction;
          expect(action.fairminterTxHash, '0x123abc');
        },
      );
    });
  });
}
