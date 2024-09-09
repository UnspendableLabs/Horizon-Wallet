import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/main.dart';
import 'package:horizon/setup.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const network = String.fromEnvironment('NETWORK', defaultValue: 'mainnet');

  const mnemonic =
      "stomach worry artefact bicycle finger doctor outdoor learn lecture powder agent body";

  group('Onboarding Integration Tests', () {
    setUpAll(() async {
      // Perform any common setup here
      await setup();
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
      const seedPhrase = mnemonic;
      final firstWordField = find.byType(TextField).first;
      await tester.enterText(firstWordField, seedPhrase);
      await tester.pumpAndSettle();

      // Open the dropdown for import format
      final dropdownFinder = find.byType(DropdownButton<String>);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Select the specified import format
      final formatOption = find.text("Horizon").last;
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

      final encryptionService = GetIt.instance<EncryptionService>();

      final walletRepository = GetIt.instance<WalletRepository>();
      final wallet = await walletRepository.getCurrentWallet();

      final encryptedMnemonic = wallet!.encryptedMnemonic!;

      final decryptedMnemonic = await encryptionService.decrypt(
          encryptedMnemonic, 'securepassword123');

      print("decryptedMnemonic: $decryptedMnemonic");

      expect(decryptedMnemonic, mnemonic);

      await tester.pumpAndSettle();
    });
  });
}