import 'package:test/test.dart';
import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/domain/entities/action.dart';
import 'package:horizon/domain/entities/psbt_type.dart';
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

  group("sign psbt with parsed type", () {
    group("create swap", () {
      test('from whitelisted domain', () {
        // Arrange

        const encodedString =
            "signPsbt,1423382259,5f2306bc-6b41-4c74-9972-688ee27614a9,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff01009a020000000200000000000000000000000000000000000000000000000000000000000000000000000000ffffffff1a0c8c8d1fb07eecb8e024517e0b53830d73580e075c50367b7d187bb13eebfd0000000000ffffffff020000000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c80841e0000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c0000000000010304020000000001011f2202000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c01030483000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlsxXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoic3dhcC1jcmVhdGUiLCJpbmZvIjp7ImFzc2V0IjoiQ1NBVCIsInF1YW50aXR5IjoxMDAwMDAwMDAsInByaWNlIjoyMDAwMDAwLCJleHBpcmVzX2F0IjoiMjAyNS0xMS0xOVQxNDo1Mjo1MS4zODRaIiwidXR4b19pZCI6ImZkZWIzZWIxN2IxODdkN2IzNjUwNWMwNzBlNTg3MzBkODM1MzBiN2U1MTI0ZTBiOGVjN2ViMDFmOGQ4YzBjMWE6MCIsInV0eG9fdmFsdWUiOjU0Niwic2VsbGVyX2FkZHJlc3MiOiJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiLCJhc3NldF9kaXZpc2liaWxpdHkiOmZhbHNlfX0=";
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
            expect(action.tabId, 1423382259);
            expect(action.requestId, '5f2306bc-6b41-4c74-9972-688ee27614a9');
            expect(action.origin, 'https://horizon.market');
            expect(action.title,
                'Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens');
            expect(action.favicon,
                'https://horizon.market/icon0.ico?ca04633c4c0c2f74');

            // payload
            expect(action.psbt.startsWith('70736274'), true,
                reason: 'Should be raw PSBT hex');
            expect(action.signInputs, {
              // eyJiYzFx... decodes to {"bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2":[0]}
              "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2": [1],
            });

            // WzEzMSwxLDJd => [131, 1, 2]
            expect(action.sighashTypes, [131, 1, 2]);

            expect(action.psbtType, isA<AtomicSwapSellPsbt>());

            // Optional: if your model has txInfo and treats omission as null, assert it.
            // expect(action.txInfo, isNull);
          },
        );
      });
      test('from untrusted domain', () {
        // Arrange

        const encodedString =
            "signPsbt,1423382259,5f2306bc-6b41-4c74-9972-688ee27614a9,https://example.com,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff01009a020000000200000000000000000000000000000000000000000000000000000000000000000000000000ffffffff1a0c8c8d1fb07eecb8e024517e0b53830d73580e075c50367b7d187bb13eebfd0000000000ffffffff020000000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c80841e0000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c0000000000010304020000000001011f2202000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c01030483000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlsxXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoic3dhcC1jcmVhdGUiLCJpbmZvIjp7ImFzc2V0IjoiQ1NBVCIsInF1YW50aXR5IjoxMDAwMDAwMDAsInByaWNlIjoyMDAwMDAwLCJleHBpcmVzX2F0IjoiMjAyNS0xMS0xOVQxNDo1Mjo1MS4zODRaIiwidXR4b19pZCI6ImZkZWIzZWIxN2IxODdkN2IzNjUwNWMwNzBlNTg3MzBkODM1MzBiN2U1MTI0ZTBiOGVjN2ViMDFmOGQ4YzBjMWE6MCIsInV0eG9fdmFsdWUiOjU0Niwic2VsbGVyX2FkZHJlc3MiOiJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiLCJhc3NldF9kaXZpc2liaWxpdHkiOmZhbHNlfX0=";
        // Act
        final result = actionRepository.fromString(encodedString);

        // Assert
        expect(result.isRight(), true);
        result.match(
          (l) => fail('Expected Right but got Left: $l'),
          (r) {
            expect(r, isA<RPCSignPsbtAction>());
            final action = r as RPCSignPsbtAction;
            expect(action.psbtType, isA<OpaquePsbt>());
          },
        );
      });
    });

    group("swap buy", () {
      test("from known", () {
        final encodedString =
            "signPsbt,1423382259,a6cd4e67-273e-4f08-bf79-12447be1d027,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff0100fd86010200000007b9c712c5cb58b0cd56430616ba576ad4c4802e1c1cf5636d9048d49e3f55f5580200000000ffffffff3894f23d839ad3783fc0c3a1a53acf53e16cdc142808e860fc12ed994d80cecc0000000000ffffffff98e32e5ff3ba33f6d4a260ecaad6ceaedabd9ae41561ff9f183297eda621a5e20100000000ffffffff1201b45cf2a9e67dee9be85bdf025bb5fcc8a8c318c83767456f0f5591a1ab8d0400000000ffffffff1201b45cf2a9e67dee9be85bdf025bb5fcc8a8c318c83767456f0f5591a1ab8d0000000000ffffffff1201b45cf2a9e67dee9be85bdf025bb5fcc8a8c318c83767456f0f5591a1ab8d0500000000ffffffff1201b45cf2a9e67dee9be85bdf025bb5fcc8a8c318c83767456f0f5591a1ab8d0600000000ffffffff020000000000000000356a339c2bfe0203de3f5c2891fd35ee2b816e1655b4b6f06068d4cc46c6abdba1be9c537e77b6011d3dfef580f515e3feb32c98bce1a0860100000000001600146311c352514cc9e41db6f38df8e66c674d602483000000000001011fb54a010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c010304010000000001011f22020000000000001600146311c352514cc9e41db6f38df8e66c674d602483010304830000000001011f593b000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c010304010000000001011f5802000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c010304010000000001011f5802000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c010304010000000001011f5802000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c010304010000000001011f5802000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c01030401000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlswLDIsMyw0LDUsNl19,WzEzMSwxLDJd,eyJ0eXBlIjoic3dhcC1tdWx0aS1idXkiLCJpbmZvIjp7InN3YXBzIjpbeyJpZCI6IjY5MjhhMzMwLTdmMDEtMTFmMC1iZTRlLTU3ODJiOGQ5ZjY2MSIsImFzc2V0IjoiQTEyMTIyNjI1MTQxOTQxMDg4MDAwIiwicXVhbnRpdHkiOjEwMDAwMDAwMCwicHJpY2UiOjEwMDAwMCwidXR4b19pZCI6ImNjY2U4MDRkOTllZDEyZmM2MGU4MDgyODE0ZGM2Y2UxNTNjZjNhYTVhMWMzYzAzZjc4ZDM5YTgzM2RmMjk0Mzg6MCIsImFzc2V0X2RpdmlzaWJpbGl0eSI6ZmFsc2V9XSwiZmVlIjo0LCJyb3lhbHR5IjowfX0=";

        final result = actionRepository.fromString(encodedString);

        // Assert
        expect(result.isRight(), true);
        result.match(
          (l) => fail('Expected Right but got Left: $l'),
          (r) {
            expect(r, isA<RPCSignPsbtAction>());
            final action = r as RPCSignPsbtAction;
            expect(action.psbtType, isA<AtomicSwapBuyPsbt>());
          },
        );
      });

      test("from unknown", () {
        final encodedString =
            "signPsbt,1423382259,a6cd4e67-273e-4f08-bf79-12447be1d027,https://example.com,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff0100fd86010200000007b9c712c5cb58b0cd56430616ba576ad4c4802e1c1cf5636d9048d49e3f55f5580200000000ffffffff3894f23d839ad3783fc0c3a1a53acf53e16cdc142808e860fc12ed994d80cecc0000000000ffffffff98e32e5ff3ba33f6d4a260ecaad6ceaedabd9ae41561ff9f183297eda621a5e20100000000ffffffff1201b45cf2a9e67dee9be85bdf025bb5fcc8a8c318c83767456f0f5591a1ab8d0400000000ffffffff1201b45cf2a9e67dee9be85bdf025bb5fcc8a8c318c83767456f0f5591a1ab8d0000000000ffffffff1201b45cf2a9e67dee9be85bdf025bb5fcc8a8c318c83767456f0f5591a1ab8d0500000000ffffffff1201b45cf2a9e67dee9be85bdf025bb5fcc8a8c318c83767456f0f5591a1ab8d0600000000ffffffff020000000000000000356a339c2bfe0203de3f5c2891fd35ee2b816e1655b4b6f06068d4cc46c6abdba1be9c537e77b6011d3dfef580f515e3feb32c98bce1a0860100000000001600146311c352514cc9e41db6f38df8e66c674d602483000000000001011fb54a010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c010304010000000001011f22020000000000001600146311c352514cc9e41db6f38df8e66c674d602483010304830000000001011f593b000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c010304010000000001011f5802000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c010304010000000001011f5802000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c010304010000000001011f5802000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c010304010000000001011f5802000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c01030401000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlswLDIsMyw0LDUsNl19,WzEzMSwxLDJd,eyJ0eXBlIjoic3dhcC1tdWx0aS1idXkiLCJpbmZvIjp7InN3YXBzIjpbeyJpZCI6IjY5MjhhMzMwLTdmMDEtMTFmMC1iZTRlLTU3ODJiOGQ5ZjY2MSIsImFzc2V0IjoiQTEyMTIyNjI1MTQxOTQxMDg4MDAwIiwicXVhbnRpdHkiOjEwMDAwMDAwMCwicHJpY2UiOjEwMDAwMCwidXR4b19pZCI6ImNjY2U4MDRkOTllZDEyZmM2MGU4MDgyODE0ZGM2Y2UxNTNjZjNhYTVhMWMzYzAzZjc4ZDM5YTgzM2RmMjk0Mzg6MCIsImFzc2V0X2RpdmlzaWJpbGl0eSI6ZmFsc2V9XSwiZmVlIjo0LCJyb3lhbHR5IjowfX0=";

        final result = actionRepository.fromString(encodedString);

        // Assert
        expect(result.isRight(), true);
        result.match(
          (l) => fail('Expected Right but got Left: $l'),
          (r) {
            expect(r, isA<RPCSignPsbtAction>());
            final action = r as RPCSignPsbtAction;
            expect(action.psbtType, isA<OpaquePsbt>());
          },
        );
      });
    });

    test("listing fee", () {
      const encodedString =
          "signPsbt,1423382259,7d36c89d-eb36-4e87-9ae3-fe2821376bbd,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff0100710200000001b9c712c5cb58b0cd56430616ba576ad4c4802e1c1cf5636d9048d49e3f55f5580200000000ffffffff02090700000000000016001468d4a51db58654d8b0819d9d375c16c8a610bbcf7c41010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c000000000001011fb54a010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c01030401000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoic3dhcC1jcmVhdGUtZmVlIiwiaW5mbyI6eyJzZWxsZXJfYWRkcmVzcyI6ImJjMXE0c2gzc2ZrcHBsZzV2ODBnYTkwN3o3Z25taGt0eXFxdmU3eTVuMiJ9fQ==";

      final result = actionRepository.fromString(encodedString);

      print(result);
      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<RPCSignPsbtAction>());
          final action = r as RPCSignPsbtAction;
          print(action.psbtType);
          expect(action.psbtType, isA<AtomicSwapListingFee>());
        },
      );
    });
  });
}
