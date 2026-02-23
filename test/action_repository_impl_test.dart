import 'dart:math';

import 'package:horizon/domain/entities/asset_quantity.dart';
import "package:horizon/common/constants.dart";
import 'package:test/test.dart';
import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/domain/entities/action.dart';
import 'package:horizon/domain/entities/psbt_type.dart';
import 'package:horizon/data/sources/repositories/action_repository_impl.dart';

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

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<RPCSignPsbtAction>());
          final action = r as RPCSignPsbtAction;
          expect(action.psbtType, isA<AtomicSwapListingFee>());
        },
      );
    });

    test("xcp send", () {
      const encodedString =
          "signPsbt,1423382259,cca7c921-84ef-49af-b2f4-dfdc5f3607b1,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff01008d0200000001b9c712c5cb58b0cd56430616ba576ad4c4802e1c1cf5636d9048d49e3f55f5580200000000ffffffff020000000000000000326a309c2bfe0203de3f5c4c778569be202e0769e676c78cb77453af33fe3793d8a16d6bd506cc87990a74f8ea5988279b8815ba48010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c000000000001011fb54a010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c01030401000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoic2VuZCIsImluZm8iOnsiZGVzdGluYXRpb24iOiJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiLCJhc3NldCI6IkE3ODYzNjM2NjM4NTEyNzU4OTQ4IiwicXVhbnRpdHkiOjIxMjMwMDAwMCwiYXNzZXRfZGl2aXNpYmlsaXR5Ijp0cnVlfX0=";
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<RPCSignPsbtAction>());
          final action = r as RPCSignPsbtAction;
          expect(action.psbtType, isA<XCPSendPsbt>());
          expect(
              (action.psbtType as XCPSendPsbt).asset, 'A7863636638512758948');

          expect((action.psbtType as XCPSendPsbt).quantity.quantity,
              BigInt.from(212300000));
          expect((action.psbtType as XCPSendPsbt).quantity.divisible, true);
          expect((action.psbtType as XCPSendPsbt).toAddress,
              "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2");
        },
      );
    });

    test("detach asset", () {
      const encodedString =
          "signPsbt,1423382259,07c6e7c2-35cf-4842-b7c3-7f5b6770e4f7,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff010048020000000139ed7baf6a7eb6b604640a3a5b4698f40f0226d19757a3371a95437d6a2497660000000000ffffffff0100000000000000000c6a0a4f8ad6f9c5b03ba202d9000000000001011f2202000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c010304010000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoiZGV0YWNoIiwiaW5mbyI6eyJ0eF9oYXNoIjoiNjY5NzI0NmE3ZDQzOTUxYTM3YTM1Nzk3ZDEyNjAyMGZmNDk4NDY1YjNhMGE2NDA0YjZiNjdlNmFhZjdiZWQzOSJ9fQ==";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;
        expect(action.psbtType, isA<DetachPsbt>());
      });
    });

//     test("create order", () {
//       const encodedString =
//           "signPsbt,1423382259,b28098d2-b2b8-47be-8645-3ce188567afe,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff0100900200000001b9c712c5cb58b0cd56430616ba576ad4c4802e1c1cf5636d9048d49e3f55f5580200000000ffffffff020000000000000000356a339c2bfe0203de3f5c449ebf3b431ebec68126d2dd8015f152f930fe9bbcc087ac650440d16f4bcf5f81e96464959b8455add2d35947010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c000000000001011fb54a010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c01030401000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoib3JkZXItY3JlYXRlIiwiaW5mbyI6eyJnZXRfYXNzZXQiOiJYQ1AiLCJnaXZlX2Fzc2V0IjoiQTc4NjM2MzY2Mzg1MTI3NTg5NDgiLCJnZXRfcXVhbnRpdHkiOiIxMCIsImdpdmVfcXVhbnRpdHkiOiIxIiwiZXhwaXJhdGlvbiI6NDMyMCwiZ2V0X2Fzc2V0X2RpdmlzaWJpbGl0eSI6dHJ1ZSwiZ2l2ZV9hc3NldF9kaXZpc2liaWxpdHkiOnRydWV9fQ==";
// //
// // txInfo: {type: order-create, info: {get_asset: XCP, give_asset: A7863636638512758948, get_quantity: 10, give_quantity: 1, expiration: 4320, get_asset_divisibility: true, give_asset_divisibility: true}}
// //
//
//     });

    test("attach", () {
      const encodedString =
          "signPsbt,1423382259,71e85795-032e-45f8-915f-b844ff203f5f,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff0100a50200000001b9c712c5cb58b0cd56430616ba576ad4c4802e1c1cf5636d9048d49e3f55f5580200000000ffffffff032202000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c00000000000000002b6a299c2bfe0203de3f5c2bb2a93ca92cc4351310e1e5b5213684cc08c7af84bcb69e573070e15f4065a5fdce44010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c000000000001011fb54a010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c0103040100000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoiYXR0YWNoIiwiaW5mbyI6eyJhc3NldCI6IkE3ODYzNjM2NjM4NTEyNzU4OTQ4IiwicXVhbnRpdHkiOjM5OTk5OTAwMDAsImFzc2V0X2RpdmlzaWJpbGl0eSI6dHJ1ZX19";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;
        expect(action.psbtType, isA<AttachPsbt>());
      });
    });

    test("issuance", () {
      const encodedString =
          "signPsbt,1423382259,3d8d324a-641f-4d4c-882a-aa172220952e,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff01007d0200000001b9c712c5cb58b0cd56430616ba576ad4c4802e1c1cf5636d9048d49e3f55f5580200000000ffffffff028002000000000000225120a38d861b993e69bdd50975f7ad467844ff401b61d415713a1ee0b8efb30af4af3845010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c000000000001011fb54a010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c01030401000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoiaXNzdWFuY2UiLCJpbmZvIjp7ImFzc2V0IjoiQTQ5OTI5MDg4NzczMTI4MTM5ODYiLCJxdWFudGl0eSI6NTAxMjM0MDAwMCwiZGl2aXNpYmxlIjp0cnVlfX0=";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<Issuance>());

        expect((action.psbtType as Issuance).asset, 'A4992908877312813986');

        expect((action.psbtType as Issuance).quantity!.divisible, true);

        expect((action.psbtType as Issuance).quantity!.quantity,
            BigInt.from(5012340000));
      });
    });

    test("fairminter", () {
      const encodedString =
          "signPsbt,1423382259,c04cfb4f-9bc0-48a6-9e1f-00539d927df1,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff01007d0200000001b9c712c5cb58b0cd56430616ba576ad4c4802e1c1cf5636d9048d49e3f55f5580200000000ffffffff0283010000000000002251206ecccfe596aedd5fa6102906cc37c59e3668a7fc6fd97624d3170fc3825bcb106747010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c000000000001011fb54a010000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c01030401000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoiZmFpcm1pbnRlciIsImluZm8iOnsiaXNzdWFuY2VfdHlwZSI6Im1pbnQiLCJhc3NldCI6IkExMzkzMTEzNDc4NDI5MjI4NzA1MCIsImRpdmlzaWJsZSI6ZmFsc2UsIm1heF9taW50X3Blcl90eCI6MSwiZW5jb2RpbmciOiJhdXRvIiwiaW5zY3JpcHRpb24iOm51bGwsImRlc2NyaXB0aW9uIjoiaXBmczpiYWZrcmVpZ2tpdmh4eXNscWx5Y2huNWx2Mzd4eXlnY3RwN2EzZWdrZnhjem9xanhmN2kzdnZzZzZlNCIsIm1pbWVfdHlwZSI6bnVsbCwiYXVkaW8iOm51bGwsIm1lZGlhIjoiYmFma3JlaWZpN2YzcG9rc242YTZqdG50bmVyNGNvcTc1bTRpcDRreDY2dmptd296cG1sNnJ5YW9sNXUifX0=";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<Fairminter>());
      });
    });

    test("create-order", () {
      const encodedString =
          "signPsbt,1423382443,61a251e3-5a54-40ae-bccf-2a4cffff69c5,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff0100900200000001501af54362af72cb13a0c970244fce2e443f92197015a7c0bfb30c44ba2e529b0100000000ffffffff020000000000000000356a3345266484fc6612f8d041158c2a5a551501c9de298fe27fb1a56bdbda88b7d68a3e8788a032463fafb6deec08537cce4ba3ef5837c7030000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011fefcd030000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030401000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoib3JkZXItY3JlYXRlIiwiaW5mbyI6eyJnZXRfYXNzZXQiOiJYQ1AiLCJnaXZlX2Fzc2V0IjoiQTExMDE2MTU3NzUyMjQwOTAyODIiLCJnZXRfcXVhbnRpdHkiOjEwMDAwMDAwMDAwLCJnaXZlX3F1YW50aXR5IjoxMCwiZXhwaXJhdGlvbiI6NDMyMCwiZ2V0X2Fzc2V0X2RpdmlzaWJpbGl0eSI6dHJ1ZSwiZ2l2ZV9hc3NldF9kaXZpc2liaWxpdHkiOmZhbHNlfX0=";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<OrderPsbt>());

        expect(
            (action.psbtType as OrderPsbt).giveAsset, 'A1101615775224090282');
        expect((action.psbtType as OrderPsbt).giveQuantity.quantity,
            BigInt.from(10));
        expect((action.psbtType as OrderPsbt).giveQuantity.divisible, false);
        expect((action.psbtType as OrderPsbt).getAsset, 'XCP');
        expect((action.psbtType as OrderPsbt).getQuantity.quantity,
            BigInt.from(10000000000));
        expect((action.psbtType as OrderPsbt).getQuantity.divisible, true);
      });
    });

    test("cancel-order", () {
      const encodedString =
          "signPsbt,1423382460,af9c3604-2360-4c72-84a6-7756dd7cbbe1,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff0100860200000001e46b0cbf2084102c917d0b8a05270882dff9a396a1b72c2a3fd1c756d0da7a1c0100000000ffffffff0200000000000000002b6a291940b778f024db7d1c011405ca518aafad127609f547fa336eb0cce8d9c5c6f0a285c5035da7f5cce64f9e030000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011fa3a4030000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030401000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoiY2FuY2VsLW9yZGVyIiwiaW5mbyI6eyJ0eF9oYXNoIjoiZmEyMjUzYmExZTBjNzQ5NDQwYzc3NWFmOGEyNjQxYzI1OGI4NjFiMjlmNThiNjljNTBjOTljZDE1NWE4YjUwNCIsImFzc2V0IjoiQTE0MDc3MDg5MTk3OTkzODk0OTciLCJxdWFudGl0eSI6IjIiLCJwcmljZSI6IjQuMDAwMDAwMDAiLCJ4Y3BfcHJpY2UiOiI4LjAwMDAwMDAwIiwiY3JlYXRlZF9hdCI6MTc1ODkyMDY0MCwiYXNzZXRfZGl2aXNpYmlsaXR5IjpmYWxzZX19";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<CancelOrder>());
        expect((action.psbtType as CancelOrder).asset, 'A1407708919799389497');
        expect(
            (action.psbtType as CancelOrder).quantity.quantity, BigInt.from(2));
        expect(
            (action.psbtType as CancelOrder).xcpPrice,
            Price(
              pair: MarketPair(
                quoteDivisible: true,
                baseDivisible: false,
              ),
              numer: BigInt.from(8) * TenToTheEigth.bigIntValue,
              denom: BigInt.from(2),
            ));
      });
    });

    test("sweep", () {
      const encodedString =
          "signPsbt,1423382460,c090c961-c45d-45f0-ab93-1784afa52677,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff0100850200000001501af54362af72cb13a0c970244fce2e443f92197015a7c0bfb30c44ba2e529b0100000000ffffffff0200000000000000002a6a2845266484fc6612f8decd0a369c9e3ff90782126e0bfdfcf4378c77c9dd0d8c4e2c84cdf36538e035a5c7030000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011fefcd030000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030401000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoic3dlZXAiLCJpbmZvIjp7ImRlc3RpbmF0aW9uIjoidGIxcWM0dno5dHp0ZTNyY2c4dXJna3Z3MHRxbjJrYTk0M3FubHFodXE3IiwiZmxhZ3MiOjMsIm1lbW8iOiJTV0VFUCJ9fQ==";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<Sweep>());
        expect((action.psbtType as Sweep).destination,
            'tb1qc4vz9tzte3rcg8urgkvw0tqn2ka943qnlqhuq7');
      });
    });
    test("move", () {
      const encodedString =
          "signPsbt,1423382460,c549bee9-cc39-4fe7-8311-ff14220b075b,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff01009a0200000002d4ee1650344cd02c9ea581ae16bf92e5a06d00a277252a0c326b005156531ac40000000000ffffffff501af54362af72cb13a0c970244fce2e443f92197015a7c0bfb30c44ba2e529b0100000000ffffffff022202000000000000160014c55822ac4bcc47841f834598e7ac1355ba5ac413c5c5030000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011f2202000000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716010304010000000001011fefcd030000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030401000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswLDFdfQ==,WzEzMSwxLDJd,eyJ0eXBlIjoibW92ZSIsImluZm8iOnsidXR4byI6ImM0MWE1MzU2NTEwMDZiMzIwYzJhMjU3N2EyMDA2ZGEwZTU5MmJmMTZhZTgxYTU5ZTJjZDA0YzM0NTAxNmVlZDQ6MCIsImRlc3RpbmF0aW9uIjoidGIxcWM0dno5dHp0ZTNyY2c4dXJna3Z3MHRxbjJrYTk0M3FubHFodXE3In19";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<UtxoMove>());
        expect((action.psbtType as UtxoMove).destination,
            'tb1qc4vz9tzte3rcg8urgkvw0tqn2ka943qnlqhuq7');
      });
    });

    test("destroy", () {
      const encodedString =
          "signPsbt,1423382460,2476df97-f000-46a4-bbe1-059bbf445575,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff01007d0200000001501af54362af72cb13a0c970244fce2e443f92197015a7c0bfb30c44ba2e529b0100000000ffffffff020000000000000000226a2045266484fc6612f8b41499e1cf35c2a15ec9de2998aa0959af08b4b5e4c4b2ecf5c7030000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011fefcd030000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030401000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoiZGVzdHJveSIsImluZm8iOnsiYXNzZXQiOiJBNjU0MDg2NzQ4ODYyOTIyNjIyOSIsInF1YW50aXR5IjoxMDAwMDAwMDAwMDAsInRhZyI6ImNvb2xzZGYiLCJhc3NldF9kaXZpc2liaWxpdHkiOnRydWV9fQ==";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<Destroy>());
        expect((action.psbtType as Destroy).asset, 'A6540867488629226229');
        expect((action.psbtType as Destroy).quantity.quantity,
            BigInt.from(100000000000));
        expect((action.psbtType as Destroy).quantity.divisible, true);
      });
    });

    test("lock quantity", () {
      const encodedString =
          "signPsbt,1423382443,c3fc3e8a-d883-4656-8071-5839f4eedc9d,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff0100760200000001501af54362af72cb13a0c970244fce2e443f92197015a7c0bfb30c44ba2e529b0100000000ffffffff0200000000000000001b6a1945266484fc6612f8ccc947227a46a90e5d0d49297b178bd1593bc8030000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011fefcd030000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030401000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoibG9jay1xdWFudGl0eSIsImluZm8iOnsiYXNzZXQiOiJBMTcyMjA5NjY4MTcwNTk4MTA3OSIsInF1YW50aXR5IjowLCJsb2NrIjp0cnVlLCJkaXZpc2libGUiOmZhbHNlLCJhc3NldF9kaXZpc2liaWxpdHkiOmZhbHNlfX0=";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<LockQuantity>());
        expect((action.psbtType as LockQuantity).asset, 'A1722096681705981079');
      });
    });

    test("lock description", () {
      const encodedString =
          "signPsbt,1423382443,63dd99ad-b6cd-468e-9509-3d3d111c9345,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff01007a0200000001501af54362af72cb13a0c970244fce2e443f92197015a7c0bfb30c44ba2e529b0100000000ffffffff0200000000000000001f6a1d45266484fc6612f8ccc947d55931086cb79278297b168bd1eb279499c313c8030000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011fefcd030000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030401000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoibG9jay1kZXNjcmlwdGlvbiIsImluZm8iOnsiYXNzZXQiOiJBMTYxOTY0Njg2NjI5NTM4NjAwMDYiLCJxdWFudGl0eSI6MCwiZGVzY3JpcHRpb24iOiJMT0NLIiwiZGl2aXNpYmxlIjpmYWxzZSwiYXNzZXRfZGl2aXNpYmlsaXR5IjpmYWxzZX19";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<LockDescription>());
        expect((action.psbtType as LockDescription).asset,
            'A16196468662953860006');
      });
    });
    test("change description", () {
      const encodedString =
          "signPsbt,1423382443,19b3792a-0f4e-433d-8984-13ca572e7aa6,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff010081020000000167a7510010e96c367c68c5a872b086d53dd612ed76491bb8d6fb519894b53f220100000000ffffffff020000000000000000266a24014f4dce892bda56af4b31b932f2df93cbfdbc3531cf9e772b49b9b10107d61ece47826e5451000000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011f7657000000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030401000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoiY2hhbmdlLWRlc2NyaXB0aW9uIiwiaW5mbyI6eyJhc3NldCI6IkExNDA3NzA4OTE5Nzk5Mzg5NDk3IiwiZGVzY3JpcHRpb24iOiJyZWFsbHkgY29vbCIsInF1YW50aXR5IjowLCJkaXZpc2libGUiOmZhbHNlLCJhc3NldF9kaXZpc2liaWxpdHkiOmZhbHNlfX0=";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<ChangeDescription>());
        expect((action.psbtType as ChangeDescription).asset,
            'A1407708919799389497');
        expect(
            (action.psbtType as ChangeDescription).description, 'really cool');
      });
    });

    test("reset asset", () {
      const encodedString =
          "signPsbt,1423382443,3fcd4e96-b158-4364-91c3-9e8479254ca8,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff0100780200000001e46b0cbf2084102c917d0b8a05270882dff9a396a1b72c2a3fd1c756d0da7a1c0100000000ffffffff0200000000000000001d6a1b1940b778f024db7d4c7c2d15b7af66214557266559252986598882db9e030000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011fa3a4030000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030401000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoicmVzZXQiLCJpbmZvIjp7ImFzc2V0IjoiQTQ4ODQxMTk1Nzc3ODYzMjAyNzkiLCJxdWFudGl0eSI6MTAwMCwiZGl2aXNpYmxlIjp0cnVlLCJyZXNldCI6dHJ1ZSwiYXNzZXRfZGl2aXNpYmlsaXR5IjpmYWxzZX19";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<Reset>());
        expect((action.psbtType as Reset).asset, 'A4884119577786320279');
      });
    });

    test("issue more", () {
      const encodedString =
          "signPsbt,1423382443,bc9f6987-6d12-460d-b544-c45ebd039dad,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff01007a0200000001501af54362af72cb13a0c970244fce2e443f92197015a7c0bfb30c44ba2e529b0100000000ffffffff0200000000000000001f6a1d45266484fc6612f8ccc947254245cfa895279633b478b5b15a9f2fba7e13c8030000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011fefcd030000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030401000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoiaXNzdWUtbW9yZSIsImluZm8iOnsiYXNzZXQiOiJBMTIxNTQ0MjY1ODI3MzQ1NTY4OCIsInF1YW50aXR5IjoxMDAwMDAwMDAwLCJkaXZpc2libGUiOnRydWUsImFzc2V0X2RpdmlzaWJpbGl0eSI6dHJ1ZX19";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<IssueMore>());
        expect((action.psbtType as IssueMore).asset, 'A1215442658273455688');
        expect((action.psbtType as IssueMore).quantity.quantity,
            BigInt.from(1000000000));
        expect((action.psbtType as IssueMore).quantity.divisible, true);
      });
    });
    test("change-ownership", () {
      const encodedString =
          "signPsbt,1423382939,bf653a77-7e9e-4c51-8295-371afa9e10d8,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff0100950200000001501af54362af72cb13a0c970244fce2e443f92197015a7c0bfb30c44ba2e529b0100000000ffffffff032202000000000000160014c55822ac4bcc47841f834598e7ac1355ba5ac41300000000000000001b6a1945266484fc6612f8ccc94704c5988f9481dd65297b168bd159e3c4030000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011fefcd030000000000160014a8b21366aa1dae07bffe52c56f4619e01c5237160103040100000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoiY2hhbmdlLW93bmVyc2hpcCIsImluZm8iOnsiYXNzZXQiOiJBMzU1NjA4ODc4MzMxMzcwNDEyMyIsInRyYW5zZmVyX2Rlc3RpbmF0aW9uIjoidGIxcWM0dno5dHp0ZTNyY2c4dXJna3Z3MHRxbjJrYTk0M3FubHFodXE3IiwicXVhbnRpdHkiOjAsImRpdmlzaWJsZSI6ZmFsc2UsImFzc2V0X2RpdmlzaWJpbGl0eSI6ZmFsc2V9fQ==";

      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<ChangeOwnership>());

        expect(
            (action.psbtType as ChangeOwnership).asset, 'A3556088783313704123');
        expect((action.psbtType as ChangeOwnership).transferDestination,
            'tb1qc4vz9tzte3rcg8urgkvw0tqn2ka943qnlqhuq7');
      });
    });
    test("dividend", () {
      const encodedString =
          "signPsbt,1423382939,e964f582-b732-4437-a5fe-045c1f8fa4aa,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff01007e0200000001e46b0cbf2084102c917d0b8a05270882dff9a396a1b72c2a3fd1c756d0da7a1c0100000000ffffffff020000000000000000236a211940b778f024db7d68fb3656704f86db385df8c5eccceebc06abb3698ba0e243a99f9e030000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011fa3a4030000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030401000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoiZGl2aWRlbmQiLCJpbmZvIjp7ImFzc2V0IjoiQTExMDE2MTU3NzUyMjQwOTAyODIiLCJkaXZpZGVuZF9hc3NldCI6IkE0ODg0MTE5NTc3Nzg2MzIwMjc5IiwicXVhbnRpdHlfcGVyX3VuaXQiOjEsImFzc2V0X2RpdmlzaWJpbGl0eSI6ZmFsc2UsImRpdmlkZW5kX2Fzc2V0X2RpdmlzaWJpbGl0eSI6ZmFsc2V9fQ==";
      final result = actionRepository.fromString(encodedString);

      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<Dividend>());
        expect((action.psbtType as Dividend).asset, 'A1101615775224090282');
        expect((action.psbtType as Dividend).dividendAsset,
            'A4884119577786320279');
        expect((action.psbtType as Dividend).quantityPerUnit.quantity,
            BigInt.from(1));
        expect((action.psbtType as Dividend).quantityPerUnit.divisible, false);
      });
    });
    test("defaults to opaque", () {
      // psbt info encoding is invalid
      const encodedString =
          "signPsbt,1423382443,d70a5a68-ab77-48a2-a5b7-5c7148becd1b,https://horizon-market-testnet.vercel.app,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon-market-testnet.vercel.app/icon0.ico?ca04633c4c0c2f74,70736274ff01009e0200000001501af54362af72cb13a0c970244fce2e443f92197015a7c0bfb30c44ba2e529b0100000000ffffffff020000000000000000436a4145266484fc6612f8d94e5db559034577e00599ad90613a2948c7c88f32ed129967195a7ab1f7a864b6ce0c08537cce4bf3ef583f65a70bcf9ea36da4a261c4472fabc6030000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716000000000001011fefcd030000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030401000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoibXBtYSIsImluZm8iOnsic2VuZHMiOlt7ImRlc3RpbmF0aW9uIjoidGIxcWM0dno5dH4dXJna3Z3MHRxbjJrYTk0M3FubHFodXE3IiwiYXNzZXQiOiJYQ1AiLCJxdWFudGl0aWUiOjEwMDAwMDAsImFzc2V0X2RpdmlzaWJpbGl0eSI6dHJ1ZX0seyJkZXN0aW5hdGlvbiI6InRiMXFjNHZ6OXR6dGUzcmNnOHVyZ2t2dzB0cW4ya2E5NDNxbmxxaHVxNyIsImFzc2V0IjoiQTcwOTYzNDg1NTY3Mjg0ODA3NzIiLCJxdWFudGl0aWUiOjEsImFzc2V0X2RpdmlzaWJpbGl0eSI6ZmFsc2V9XX19";

      final result = actionRepository.fromString(encodedString);
      expect(result.isRight(), true);
      result.match((l) => fail('Expected Right but got Left: $l'), (r) {
        expect(r, isA<RPCSignPsbtAction>());
        final action = r as RPCSignPsbtAction;

        expect(action.psbtType, isA<OpaquePsbt>());
      });
    });
  });

  group(RPCSignMessageBLSAction, () {
    test(
        'should decode a valid RPCSignMessageBLSAction with DST (8 fields)',
        () {
      // Arrange — default/min_sig DST (G1, 48-byte sig) used by Kontor & Portal
      const encodedString =
          'signMessageBLS,1,def,https%3A%2F%2Fexample.com,Example%20Site,https%3A%2F%2Fexample.com%2Ffavicon.ico,Hello%20World,BLS_SIG_BLS12381G1_XMD%3ASHA-256_SSWU_RO_NUL_';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<RPCSignMessageBLSAction>());
          final action = r as RPCSignMessageBLSAction;
          expect(action.tabId, 1);
          expect(action.requestId, 'def');
          expect(action.origin, 'https://example.com');
          expect(action.title, 'Example Site');
          expect(action.favicon, 'https://example.com/favicon.ico');
          expect(action.message, 'Hello World');
          expect(action.dst, 'BLS_SIG_BLS12381G1_XMD:SHA-256_SSWU_RO_NUL_');
          expect(action.messageHex, isNull);
        },
      );
    });

    test(
        'should decode RPCSignMessageBLSAction without DST (7 fields)',
        () {
      // Arrange
      const encodedString =
          'signMessageBLS,1,def,https%3A%2F%2Fexample.com,Example%20Site,https%3A%2F%2Fexample.com%2Ffavicon.ico,Hello%20World';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<RPCSignMessageBLSAction>());
          final action = r as RPCSignMessageBLSAction;
          expect(action.tabId, 1);
          expect(action.requestId, 'def');
          expect(action.origin, 'https://example.com');
          expect(action.title, 'Example Site');
          expect(action.favicon, 'https://example.com/favicon.ico');
          expect(action.message, 'Hello World');
          expect(action.dst, isNull);
          expect(action.messageHex, isNull);
        },
      );
    });

    test('should decode RPCSignMessageBLSAction with empty title and favicon',
        () {
      // Arrange
      const encodedString =
          'signMessageBLS,1,def,https%3A%2F%2Fexample.com,,,Hello%20World';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<RPCSignMessageBLSAction>());
          final action = r as RPCSignMessageBLSAction;
          expect(action.tabId, 1);
          expect(action.requestId, 'def');
          expect(action.origin, 'https://example.com');
          expect(action.title, '');
          expect(action.favicon, '');
          expect(action.message, 'Hello World');
          expect(action.dst, isNull);
          expect(action.messageHex, isNull);
        },
      );
    });

    test(
        'should decode RPCSignMessageBLSAction with messageHex (9 fields)',
        () {
      // Arrange
      const encodedString =
          'signMessageBLS,1,def,https%3A%2F%2Fexample.com,Example%20Site,https%3A%2F%2Fexample.com%2Ffavicon.ico,,BLS_SIG_BLS12381G1_XMD%3ASHA-256_SSWU_RO_NUL_,deadbeef0123';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<RPCSignMessageBLSAction>());
          final action = r as RPCSignMessageBLSAction;
          expect(action.tabId, 1);
          expect(action.requestId, 'def');
          expect(action.origin, 'https://example.com');
          expect(action.title, 'Example Site');
          expect(action.favicon, 'https://example.com/favicon.ico');
          expect(action.message, '');
          expect(action.dst, 'BLS_SIG_BLS12381G1_XMD:SHA-256_SSWU_RO_NUL_');
          expect(action.messageHex, 'deadbeef0123');
        },
      );
    });

    test(
        'should decode RPCSignMessageBLSAction with messageHex and empty dst (9 fields)',
        () {
      // Arrange
      const encodedString =
          'signMessageBLS,1,def,https%3A%2F%2Fexample.com,Example%20Site,https%3A%2F%2Fexample.com%2Ffavicon.ico,,,deadbeef0123';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isRight(), true);
      result.match(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r, isA<RPCSignMessageBLSAction>());
          final action = r as RPCSignMessageBLSAction;
          expect(action.message, '');
          expect(action.dst, isNull);
          expect(action.messageHex, 'deadbeef0123');
        },
      );
    });

    test('should fail with too few fields (5)', () {
      // Arrange
      const encodedString =
          'signMessageBLS,1,def,https%3A%2F%2Fexample.com,Example%20Site';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should fail with too many fields (10)', () {
      // Arrange
      const encodedString =
          'signMessageBLS,1,def,https%3A%2F%2Fexample.com,Example%20Site,favicon,msg,dst,hex,extra';

      // Act
      final result = actionRepository.fromString(encodedString);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
