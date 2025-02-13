import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/main.dart';
import 'package:horizon/setup.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Validation Tests', () {
    setUpAll(() async {
      setup();
    });

    tearDown(() async {
      // Clean up after each test
      await GetIt.I.get<WalletRepository>().deleteAllWallets();
      GetIt.I.reset();
    });

    testWidgets('buttons should be disabled when wallet exists',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(MyApp(
          currentVersion: Version(0, 0, 0),
          latestVersion: Version(0, 0, 0),
        ));

        await tester.pumpAndSettle();

        // Insert a test wallet before running the app
        final walletRepository = GetIt.I.get<WalletRepository>();
        await walletRepository.insert(
          const Wallet(
            name: 'Test Wallet',
            uuid: 'test-wallet-uuid',
            publicKey: 'test-public-key',
            encryptedPrivKey: 'test-encrypted-priv-key',
            chainCodeHex: 'test-chain-code',
          ),
        );

        await tester.pumpAndSettle();

        // Verify error message is shown
        expect(
          find.text('Invalid state detected. Please contact support.'),
          findsOneWidget,
        );

        // Find and verify both buttons are disabled
        final createButton = find.text('CREATE A NEW WALLET');
        final importButton = find.text('LOAD SEED PHRASE');

        expect(
            tester
                .widget<ElevatedButton>(
                  find.ancestor(
                    of: createButton,
                    matching: find.byType(ElevatedButton),
                  ),
                )
                .onPressed,
            isNull);

        expect(
            tester
                .widget<ElevatedButton>(
                  find.ancestor(
                    of: importButton,
                    matching: find.byType(ElevatedButton),
                  ),
                )
                .onPressed,
            isNull);

        await tester.pumpAndSettle();
      });
    });
  });
}
