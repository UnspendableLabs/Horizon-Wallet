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

    test('should decode a valid dispense action (uri encoded)', () {
      // Arrange
      const encodedString = 'dispense%2C0x123abc';

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
    test(
        'should decode a valid RPCGetAddressesAction action with origin, title, and favicon',
        () {
      // Arrange
      const encodedString =
          'getAddresses:ext,1,def,https%3A%2F%2Fexample.com,Example%20Site,https%3A%2F%2Fexample.com%2Ffavicon.ico';

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
          expect(action.origin, 'https://example.com');
          expect(action.title, 'Example Site');
          expect(action.favicon, 'https://example.com/favicon.ico');
        },
      );
    });

    test('should decode RPCGetAddressesAction with empty title and favicon',
        () {
      // Arrange
      const encodedString =
          'getAddresses:ext,1,def,https%3A%2F%2Fexample.com,,';

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
          expect(action.origin, 'https://example.com');
          expect(action.title, '');
          expect(action.favicon, '');
        },
      );
    });
  });

  group(RPCSignPsbtAction, () {
    test(
        'should decode a valid RPCSignPsbtAction action with origin, title, favicon, and signInputs',
        () {
      // Arrange
      const encodedString =
          'signPsbt:ext,1,def,https%3A%2F%2Fexample.com,Example%20Site,https%3A%2F%2Fexample.com%2Ffavicon.ico,psbt-hex,eyIxQTJiM0M0RDVFNkY3RzhIOUkwSiI6WzAsMSwzXX0=';

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
          expect(action.origin, 'https://example.com');
          expect(action.title, 'Example Site');
          expect(action.favicon, 'https://example.com/favicon.ico');
          expect(action.psbt, 'psbt-hex');
          expect(action.signInputs, {
            "1A2b3C4D5E6F7G8H9I0J": [0, 1, 3]
          });
        },
      );
    });

    test(
        'should decode RPCSignPsbtAction with origin, title, favicon, signInputs and sighashTypes',
        () {
      // Arrange
      const encodedString =
          'signPsbt:ext,1,def,https%3A%2F%2Fexample.com,Example%20Site,https%3A%2F%2Fexample.com%2Ffavicon.ico,psbt-hex,eyIxQTJiM0M0RDVFNkY3RzhIOUkwSiI6WzAsMSwzXX0=,WzEsMl0=';

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
          expect(action.origin, 'https://example.com');
          expect(action.title, 'Example Site');
          expect(action.favicon, 'https://example.com/favicon.ico');
          expect(action.psbt, 'psbt-hex');
          expect(action.signInputs, {
            "1A2b3C4D5E6F7G8H9I0J": [0, 1, 3]
          });
          expect(action.sighashTypes, [1, 2]);
        },
      );
    });

    test('should decode RPCSignPsbtAction with empty title and favicon', () {
      // Arrange
      const encodedString =
          'signPsbt:ext,1,def,https%3A%2F%2Fexample.com,,,psbt-hex,eyIxQTJiM0M0RDVFNkY3RzhIOUkwSiI6WzAsMSwzXX0=';

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
          expect(action.origin, 'https://example.com');
          expect(action.title, '');
          expect(action.favicon, '');
          expect(action.psbt, 'psbt-hex');
        },
      );
    });
  });

  group(RPCSignMessageAction, () {
    test(
        'should decode a valid RPCSignMessageAction with origin, title, and favicon',
        () {
      // Arrange
      const encodedString =
          'signMessage:ext,1,def,https%3A%2F%2Fexample.com,Example%20Site,https%3A%2F%2Fexample.com%2Ffavicon.ico,Hello%20World,1A2b3C4D5E6F7G8H9I0J';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<RPCSignMessageAction>());
          final action = r as RPCSignMessageAction;
          expect(action.tabId, 1);
          expect(action.requestId, 'def');
          expect(action.origin, 'https://example.com');
          expect(action.title, 'Example Site');
          expect(action.favicon, 'https://example.com/favicon.ico');
          expect(action.message, 'Hello World');
          expect(action.address, '1A2b3C4D5E6F7G8H9I0J');
        },
      );
    });

    test('should decode RPCSignMessageAction with empty title and favicon', () {
      // Arrange
      const encodedString =
          'signMessage:ext,1,def,https%3A%2F%2Fexample.com,,,Hello%20World,1A2b3C4D5E6F7G8H9I0J';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<RPCSignMessageAction>());
          final action = r as RPCSignMessageAction;
          expect(action.tabId, 1);
          expect(action.requestId, 'def');
          expect(action.origin, 'https://example.com');
          expect(action.title, '');
          expect(action.favicon, '');
          expect(action.message, 'Hello World');
          expect(action.address, '1A2b3C4D5E6F7G8H9I0J');
        },
      );
    });
  });
}
