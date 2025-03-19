import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/main.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/setup.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const mnemonic =
      "stomach worry artefact bicycle finger doctor outdoor learn lecture powder agent body";

  group('Onboarding Integration Tests', () {
    setUp(() async {
      // Perform any common setup here
      setup();
      await initSettings();
    });

    tearDown(() async {
      // Reset the repositories
      await GetIt.I.get<WalletRepository>().deleteAllWallets();
      await GetIt.I.get<AccountRepository>().deleteAllAccounts();
      await GetIt.I.get<AddressRepository>().deleteAllAddresses();
      await Future.delayed(const Duration(milliseconds: 100));

      // Clean up settings
      Settings.clearCache();

      // Reset GetIt
      await GetIt.I.reset();
    });

    testWidgets('recover mnemonic', (WidgetTester tester) async {
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
        Settings.clearCache();
        FlutterError.onError = originalOnError;
      });

      await tester.pumpWidget(MyApp(
        currentVersion: Version(0, 0, 0),
        latestVersion: Version(0, 0, 0),
      ));

      // Wait for the Load seed phrase button to appear
      bool buttonFound = false;
      int attempts = 0;
      while (!buttonFound && attempts < 100) {
        await tester.pump(const Duration(milliseconds: 100));
        buttonFound = find.text('Load seed phrase').evaluate().isNotEmpty;
        attempts++;
      }

      // Find and tap the "LOAD SEED" button
      final importSeedButton = find.text('Load seed phrase');
      expect(importSeedButton, findsOneWidget);
      await tester.tap(importSeedButton);
      await tester.pumpAndSettle();

      // Open the dropdown for import format
      final dropdownFinder = find.byType(HorizonRedesignDropdown<String>);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Select the specified import format
      final formatOption = find.text("Horizon Native").last;
      await tester.tap(formatOption);
      await tester.pumpAndSettle();

      // Tap the "CONTINUE" button
      final continueButton = find.text('Continue');
      expect(continueButton, findsOneWidget);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Now we should be on the seed phrase input screen
      const seedPhrase = mnemonic;
      final firstWordField = find.byType(TextField).first;
      await tester.enterText(firstWordField, seedPhrase);
      await tester.pumpAndSettle();

      // Tap the "CONTINUE" button
      final continueButtonAfterSeed = find.text('Continue');
      expect(continueButtonAfterSeed, findsOneWidget);
      await tester.tap(continueButtonAfterSeed);
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
      final loginButton = find.text('Load Wallet');
      expect(loginButton, findsOneWidget);

      await tester.ensureVisible(loginButton);
      await tester.pumpAndSettle();

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      final encryptionService = GetIt.instance<EncryptionService>();

      final walletRepository = GetIt.instance<WalletRepository>();
      final wallet = await walletRepository.getCurrentWallet();

      final encryptedMnemonic = wallet!.encryptedMnemonic!;

      final decryptedMnemonic = await encryptionService.decrypt(
          encryptedMnemonic, 'securepassword123');

      expect(decryptedMnemonic, mnemonic);

      await tester.pumpAndSettle();
    });
  });
}
