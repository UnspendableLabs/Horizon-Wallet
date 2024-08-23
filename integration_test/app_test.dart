import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/main.dart';
import 'package:horizon/setup.dart';
import 'package:integration_test/integration_test.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:get_it/get_it.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const network = String.fromEnvironment('NETWORK', defaultValue: 'mainnet');

  // Define test cases
  final testCases_ = [
    {
      'passphrase':
          'voice flame certainly anyone former raw limit king rhythm tumble crystal earth',
      'format': ImportFormat.counterwallet.description,
      'addresses': ['muYJYjRZDPmTEMfyEGe34BGN8tZ6rmRZCu'],
      'network': 'testnet'
    },
    {
      "passphrase":
          "voice flame certainly anyone former raw limit king rhythm tumble crystal earth",
      'format': ImportFormat.counterwallet.description,
      'addresses': ["1F2MFgLaQNLCTFCMWhffEG43GtxPxu6KWM"],
      'network': 'mainnet'
    },

    {
      "passphrase":
          "stomach worry artefact bicycle finger doctor outdoor learn lecture powder agent body",
      'format': ImportFormat.horizon.description,
      'addresses': ["bc1q2d0uhg8wupev6d22umufydd98jvznxngnvt5mm"],
      'network': 'mainnet'
    }

    // Add more test cases here in the future
  ];

  final testCases =
      testCases_.where((testCase) => testCase['network'] == network).toList();

  group('Onboarding Integration Tests', () {
    setUpAll(() async {
      // Perform any common setup here
      await setup();
    });

    for (final testCase in testCases) {
      testWidgets('Import seed flow - ${testCase['format']}',
          (WidgetTester tester) async {
        await tester.pumpWidget(MyApp());

        // Wait for the app to settle
        await tester.pumpAndSettle();

        // Find and tap the "IMPORT SEED" button
        final importSeedButton = find.text('IMPORT SEED');
        expect(importSeedButton, findsOneWidget);
        await tester.tap(importSeedButton);
        await tester.pumpAndSettle();

        // Enter the seed phrase into the first field
        final seedPhrase = testCase['passphrase'] as String;
        final firstWordField = find.byType(TextField).first;
        await tester.enterText(firstWordField, seedPhrase);
        await tester.pumpAndSettle();

        // Open the dropdown for import format
        final dropdownFinder = find.byType(DropdownButton<String>);
        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();

        // Select the specified import format
        final formatOption = find.text(testCase['format'] as String).last;
        await tester.tap(formatOption);
        await tester.pumpAndSettle();
        // Tap the "CONTINUE" button
        final continueButton = find.text('CONTINUE');
        expect(continueButton, findsOneWidget);
        await tester.tap(continueButton);
        await tester.pumpAndSettle();

        // Now we should be on the password entry screen
        expect(find.text('Please create a password'), findsOneWidget);

        // Enter the password
        final passwordField = find.byType(TextField).first;
        await tester.enterText(passwordField, 'securepassword123');
        await tester.pumpAndSettle();

        // Enter the password confirmation
        final confirmPasswordField = find.byType(TextField).last;
        await tester.enterText(confirmPasswordField, 'securepassword123');
        await tester.pumpAndSettle();

        // Tap the "LOGIN" button
        final loginButton = find.text('LOGIN');
        expect(loginButton, findsOneWidget);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        final addressRepository = GetIt.instance<AddressRepository>();
        final addresses = await addressRepository.getAll();

        final expectedAddresses = testCase['addresses'] as List<String>;

        expect(addresses.length, expectedAddresses.length,
            reason: 'Number of imported addresses does not match expected');

        for (var address in addresses) {
          expect(expectedAddresses.contains(address.address), isTrue,
              reason:
                  'Imported address ${address.address} was not in the list of expected addresses');
          print('Verified address: ${address.address}');
        }

        final logoutButton = find.text('Logout');
        expect(logoutButton, findsOneWidget);
        await tester.tap(logoutButton);
        await tester.pumpAndSettle();

        final confirmLogoutButton = find.text('Logout').last;
        expect(confirmLogoutButton, findsOneWidget);
        await tester.tap(confirmLogoutButton);
        await tester.pumpAndSettle();
      });
    }
  });
}
