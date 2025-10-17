import 'package:test/test.dart';
import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/domain/entities/action.dart';
import 'package:horizon/data/sources/repositories/action_repository_impl.dart';

// TODO: add the following
// attach
// parsing action string: signPsbt,1423381683,8a466271-8e70-47de-83bc-c0056cede179,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff0100a50200000001b9c712c5cb58b0cd56430616ba576ad4c4802e1c1cf5636d9048d49e3f55f5580200000000ffffffff032202000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c00000000000000002b6a299c2bfe0203de3f5c2bb2a93ca92cc4351310e1e5b5213684cc08c7af84bcb69c543470e15f4065a5fdd247010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c000000000001011fb54a010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c0103040100000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoiYXR0YWNoIiwiaW5mbyI6eyJhc3NldCI6IkE3ODYzNjM2NjM4NTEyNzU4OTQ4IiwicXVhbnRpdHkiOjg5OTk5OTAwMDAsImFzc2V0X2RpdmlzaWJpbGl0eSI6dHJ1ZX19

void main() {
  late ActionRepository actionRepository;

  setUp(() {
    actionRepository = ActionRepositoryImpl();
  });

  group(RPCGetAddressesAction, () {
    test(
        'should decode a valid RPCGetAddressesAction action with origin, title, and favicon',
        () {
      // Arrange
      const encodedString =
          'getAddresses,1,def,https%3A%2F%2Fexample.com,Example%20Site,https%3A%2F%2Fexample.com%2Ffavicon.ico';

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
      const encodedString = 'getAddresses,1,def,https%3A%2F%2Fexample.com,,';

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
          //                               signInputs                                    sighashTypes=null      txInfo=null
          'signPsbt,1,def,https%3A%2F%2Fexample.com,Example%20Site,https%3A%2F%2Fexample.com%2Ffavicon.ico,psbt-hex,eyIxQTJiM0M0RDVFNkY3RzhIOUkwSiI6WzAsMSwzXX0=,bnVsbA==,bnVsbA==';

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
          expect(action.sighashTypes, isNull);
        },
      );
    });

    test(
        'should decode RPCSignPsbtAction with origin, title, favicon, signInputs and sighashTypes',
        () {
      // Arrange
      const encodedString =
          //                               signInputs                                    sighashTypes=[1,2]  txInfo=null
          'signPsbt,1,def,https%3A%2F%2Fexample.com,Example%20Site,https%3A%2F%2Fexample.com%2Ffavicon.ico,psbt-hex,eyIxQTJiM0M0RDVFNkY3RzhIOUkwSiI6WzAsMSwzXX0=,WzEsMl0=,bnVsbA==';

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
          //                               signInputs                                    sighashTypes=null txInfo=null
          'signPsbt,1,def,https%3A%2F%2Fexample.com,,,psbt-hex,eyIxQTJiM0M0RDVFNkY3RzhIOUkwSiI6WzAsMSwzXX0=,bnVsbA==,bnVsbA==';

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
          expect(action.sighashTypes, isNull);
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
          'signMessage,1,def,https%3A%2F%2Fexample.com,Example%20Site,https%3A%2F%2Fexample.com%2Ffavicon.ico,Hello%20World,1A2b3C4D5E6F7G8H9I0J';

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
          'signMessage,1,def,https%3A%2F%2Fexample.com,,,Hello%20World,1A2b3C4D5E6F7G8H9I0J';

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

  test('should decode RPCSignPsbtAction (Horizon Market example)', () {
    // Arrange
    const encodedString =
        // action,tabId,requestId,origin,title,favicon,psbtHex,signInputsB64,sighashTypesB64
        "signPsbt,1423381683,86bfffbf-438b-4ff3-83f3-edb3804637aa,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff010090020000000198e32e5ff3ba33f6d4a260ecaad6ceaedabd9ae41561ff9f183297eda621a5e20100000000ffffffff020000000000000000356a3349489c22d3a1b0ca3ca72684eb0d5ddcb497bcb49e7ab5f8c350876faa2b44ce978ef7ea07d7992eef96549bbca34a0d5ad90c013a000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c000000000001011f593b000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c01030401000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlswXX0=,WzEzMSwxLDJd";

    // Act
    final result = actionRepository.fromString(encodedString);

    // Assert
    expect(result.isRight(), true);
    result.match(
      (l) => fail('Expected Right but got Left: $l'),
      (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        // header fields
        expect(action.tabId, 1423381683);
        expect(action.requestId, '86bfffbf-438b-4ff3-83f3-edb3804637aa');
        expect(action.origin, 'https://horizon.market');
        expect(action.title,
            'Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens');
        expect(action.favicon,
            'https://horizon.market/icon0.ico?ca04633c4c0c2f74');

        // payload
        expect(action.psbt.startsWith('70736274ff01'), true,
            reason: 'Should be raw PSBT hex');
        expect(action.signInputs, {
          // eyJiYzFx... decodes to {"bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2":[0]}
          "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2": [0],
        });

        // WzEzMSwxLDJd => [131, 1, 2]
        expect(action.sighashTypes, [131, 1, 2]);

        // Optional: if your model has txInfo and treats omission as null, assert it.
        // expect(action.txInfo, isNull);
      },
    );
  });
}
