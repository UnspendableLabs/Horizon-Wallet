import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/main.dart';
import 'package:horizon/presentation/shell/view/address_dropdown.dart';
import 'package:horizon/setup.dart';
import 'package:integration_test/integration_test.dart';

import 'test_cases.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const network = String.fromEnvironment('NETWORK', defaultValue: 'mainnet');

  final testCases_ =
      testCases.where((testCase) => testCase['network'] == network).toList();

  group('Onboarding Integration Tests', () {
    setUpAll(() async {
      await setup();
    });

    for (final testCase in testCases) {
      testWidgets('AddressDropdown displays addresses in correct sort order',
          (WidgetTester tester) async {
        // Override FlutterError.onError to ignore RenderFlex overflow errors
        final void Function(FlutterErrorDetails) originalOnError =
            FlutterError.onError!;
        FlutterError.onError = (FlutterErrorDetails details) {
          if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
            // Ignore RenderFlex overflow errors
            return;
          }
          originalOnError(details);
        };

        // Ensure the original error handler is restored after the test
        addTearDown(() {
          FlutterError.onError = originalOnError;
        });

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

        // Verify that the AddressDropdown is displayed
        final addressDropdownFinder = find.byType(AddressDropdown);
        expect(addressDropdownFinder, findsOneWidget);

        // Verify the addresses are in the correct order
        final dropdownButton = find.byType(DropdownButton<Address>);
        await tester.tap(dropdownButton);
        await tester.pumpAndSettle();

        // Scroll through the dropdown menu to ensure all items are rendered
        final dropdownMenu = find.byType(DropdownMenuItem<Address>);
        final gesture =
            await tester.startGesture(tester.getCenter(dropdownMenu.first));
        await gesture
            .moveBy(const Offset(0, -300)); // Adjust the offset as needed
        await tester.pumpAndSettle();

        final expectedAddresses = testCase['addresses'] as List<String>;

        // ensure addresses are returned in the correct order
        final addressRepository = GetIt.instance<AddressRepository>();
        final accountRepository = GetIt.instance<AccountRepository>();
        final walletRepository = GetIt.instance<WalletRepository>();
        final wallet = await walletRepository.getCurrentWallet();
        final account =
            await accountRepository.getAccountsByWalletUuid(wallet!.uuid);
        final addresses =
            await addressRepository.getAllByAccountUuid(account.first.uuid);
        expect(addresses.length, expectedAddresses.length,
            reason: 'Number of imported addresses does not match expected');

        for (var i = 0; i < addresses.length; i++) {
          expect(addresses[i].address, expectedAddresses[i],
              reason:
                  'Address ${addresses[i].address} does not match expected address ${expectedAddresses[i]}');
        }

        final settingsButton = find.byIcon(Icons.settings);
        expect(settingsButton, findsOneWidget);
        await tester.tap(settingsButton, warnIfMissed: false);
        await tester.pumpAndSettle();

        final resetButton = find.text('Reset wallet');
        expect(resetButton, findsOneWidget);
        await tester.tap(resetButton);
        await tester.pumpAndSettle();

        final confirmResetButton = find.text('RESET WALLET');
        expect(confirmResetButton, findsOneWidget);
        await tester.tap(confirmResetButton);
        await tester.pumpAndSettle();
      });
    }
  });
}
