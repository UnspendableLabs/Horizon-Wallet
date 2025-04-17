import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
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
      await GetIt.I.get<AccountRepository>().deleteAllAccounts();
      GetIt.I.reset();
    });

    testWidgets('buttons should be disabled when wallet exists',
        (WidgetTester tester) async {
      // Insert a test wallet before running the app
      final accountRepository = GetIt.I.get<AccountRepository>();
      await accountRepository.insert(
        Account(
          name: 'Test Wallet',
          uuid: 'test-wallet-uuid',
          walletUuid: 'test-wallet-uuid',
          purpose: '84',
          coinType: '0',
          accountIndex: '0',
          importFormat: ImportFormat.horizon,
        ),
      );

      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await tester.pumpWidget(MyApp(
          currentVersion: Version(0, 0, 0),
          latestVersion: Version(0, 0, 0),
        ));

        await tester.pumpAndSettle();

        // Verify error message is shown
        expect(
          find.text(onboardingErrorMessage),
          findsOneWidget,
        );

        // Find and verify both buttons are disabled
        final createButton = find.text('Create a new wallet');
        final importButton = find.text('Load seed phrase');

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
