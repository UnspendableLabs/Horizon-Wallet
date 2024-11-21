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
          expect(action.caller, CallerType.app);
        },
      );
    });

    test('should decode a valid dispense action from extension', () {
      // Arrange
      const encodedString = 'dispense:ext,0x123abc';

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
          expect(action.caller, CallerType.extension);
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

          expect(action.caller, CallerType.app);
        },
      );
    });

    test('should decode a valid fairmint action from extension', () {
      // Arrange
      const encodedString = 'fairmint:ext,0x123abc';

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
          expect(action.caller, CallerType.extension);
        },
      );
    });
  });
  group(RPCGetAddressesAction, () {
    test('should decode a valid RPCGetAddressesAction action', () {
      // Arrange
      const encodedString = 'getAddresses:ext,1,def';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<RPCGetAddressesAction>());
          final action = r as RPCGetAddressesAction;
          expect(action.tabId, 1);
          expect(action.requestId, 'def');
        },
      );
    });
    group(RPCSignPsbtAction, () {
      test('should decode a valid RPCSignPsbtAction action with signInputs',
          () {
        // Arrange
        const encodedString =
            'signPsbt:ext,1,def,psbt-hex,%7B%221A2b3C4D5E6F7G8H9I0J%22%3A%5B0%2C1%2C3%5D%7D';

        // Act
        final result = actionRepository.fromString(encodedString);

        // Assert
        expect(result.isRight(), true);
        result.match(
          (l) => fail('Expected Right but got Left: $l'),
          (r) {
            expect(r, isA<RPCSignPsbtAction>());
            final action = r as RPCSignPsbtAction;
            expect(action.tabId, 1);
            expect(action.requestId, 'def');
            expect(action.psbt, 'psbt-hex');
            expect(action.signInputs, {
              "1A2b3C4D5E6F7G8H9I0J": [0, 1, 3]
            });
          },
        );
      });

      test('should return an error for invalid signInputs format', () {
        // Arrange
        const encodedString = 'signPsbt:ext,1,def,psbt-hex,invalid-sign-inputs';

        // Act
        final result = actionRepository.fromString(encodedString);

        // Assert
        expect(result.isLeft(), true);
        result.match(
          (l) => expect(l, 'Failed to parse action'),
          (r) => fail('Expected Left but got Right: $r'),
        );
      });

      test('should return an error for missing signInputs', () {
        // Arrange
        const encodedString = 'signPsbt:ext,1,def,psbt-hex';

        // Act
        final result = actionRepository.fromString(encodedString);

        // Assert
        expect(result.isLeft(), true);
        result.match(
          (l) => expect(l, 'Failed to parse action'),
          (r) => fail('Expected Left but got Right: $r'),
        );
      });
    });
  });
}
