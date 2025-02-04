import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/main.dart';
import 'package:horizon/setup.dart';
import 'package:horizon/presentation/screens/onboarding_import/onboarding_config.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pub_semver/pub_semver.dart';

extension WidgetTesterExtension on WidgetTester {
  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    bool found = false;
    final DateTime start = DateTime.now();
    while (!found) {
      if (DateTime.now().difference(start) > timeout) {
        throw Exception('Timed out waiting for ${finder.toString()}');
      }
      await pump(const Duration(milliseconds: 100));
      found = finder.evaluate().isNotEmpty;
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const network =
      String.fromEnvironment('HORIZON_NETWORK', defaultValue: 'mainnet');

  // Define test cases
  final testCases_ = [
    {
      'passphrase':
          'voice flame certainly anyone former raw limit king rhythm tumble crystal earth',
      'format': ImportFormat.counterwallet.description,
      'addresses': [
        'muYJYjRZDPmTEMfyEGe34BGN8tZ6rmRZCu',
        'tb1qn8f324j40n5x4d6led6xs0hm5x779q2780rdxz',
        'mkvaJJCpMMjvhaHodDCvstZsZwTaWR4w3M',
        'tb1q8dgyqdnyr6kf3ctawy5ljl73r86h95aqwg8k7c',
        'msj2PuwQRMWEmsi75GDcERXygw63BTRX7W',
        'tb1qsh57e8axj5v5w378mzjacvsg80xe7agxwkf8sy',
        'mzxiJXf3ttSyDy989MBnQ8h4y2q3k8cakJ',
        'tb1q64ycvmkdsn26uzwdnhnmp9j3wwz57nqetxmpjz',
        'mgVJ74YwNGDjoqiGEFy8NWydDXzRwKLoAQ',
        'tb1qp2nafvy88y38pvkxhzwkqrlm2nj0znmffm6d4q',
        'mrcPFdq6PKn5vCeDKGuN2bb3knBZktfCTd',
        'tb1q0xcyct02486rxztf6txk7584we2m44l40262mk',
        'mtFWdP1jmCr35E8uLerHinettFrL3C7PTW',
        'tb1q3wklshmagq2tzyd35929d7hecfrlwtmjw8ze3u',
        'mizHtGJa1AFs7x5dzg75P8XBghffMuiRQn',
        'tb1qycflvz3hvffkdpgu3892es0w748qcgtaslw4fg',
        'mkUtf98ZFvo59ewRvH86yrmFxcXtfG2K1p',
        'tb1qxe6v9m4ekyuxljh9cl86yarjutxjw02kleka6a',
        'mnfimZCF7gaR6qhzDHnB9NKFDfdYM9QXDN',
        'tb1qfec424jsfhawu4cw7353p6qu48yc46924rujet'
      ],
      'network': 'testnet'
    },
    {
      "passphrase":
          "voice flame certainly anyone former raw limit king rhythm tumble crystal earth",
      'format': ImportFormat.counterwallet.description,
      'addresses': [
        "1F2MFgLaQNLCTFCMWhffEG43GtxPxu6KWM",
        "bc1qn8f324j40n5x4d6led6xs0hm5x779q27dfc7a3",
        '16Qd1F7qYLJfvTpBueEZ3yMYhwrsanPjSN',
        'bc1q8dgyqdnyr6kf3ctawy5ljl73r86h95aqywu99t',
        '1DD56rrRcL4yzmEVMhFEQWKepwVLJScrVA',
        'bc1qsh57e8axj5v5w378mzjacvsg80xe7agxysj5th',
        '1LSm1Ua55s1iSrfWRnDQaDUk73ELrwRCW3',
        'bc1q64ycvmkdsn26uzwdnhnmp9j3wwz57nqepqqjf3',
        '1yLp1TxZEnV2jEeWgzkYbmJMYPivnLv2G',
        'bc1qp2nafvy88y38pvkxhzwkqrlm2nj0znmfrap7wn',
        '1C6Rxak7aJLq96AbbhvzCgNitnartkr5Hd',
        'bc1q0xcyct02486rxztf6txk7584we2m44l49vpeq9',
        '1DjZLKvkxBQnJ7fHd5sutsSa2GFdAZrsPT',
        'bc1q3wklshmagq2tzyd35929d7hecfrlwtmjype220',
        '14ULbDDbC8pcLqc2H78hZDJrpi4xRjcBe8',
        'bc1qycflvz3hvffkdpgu3892es0w748qcgta6e4xjm',
        '15xwN63aSuMpNYTpCi9j9wYw6cwBjqCH7F',
        'bc1qxe6v9m4ekyuxljh9cl86yarjutxjw02k4ldwpw',
        '189mUW7GJf9AKjENViooKT6vMg2qRdQHT3',
        'bc1qfec424jsfhawu4cw7353p6qu48yc4692l98pzc'
      ],
      'network': 'mainnet'
    },
    {
      "passphrase":
          "stomach worry artefact bicycle finger doctor outdoor learn lecture powder agent body",
      'format': ImportFormat.horizon.description,
      'addresses': ["bc1q2d0uhg8wupev6d22umufydd98jvznxngnvt5mm"],
      'network': 'mainnet'
    },
    {
      "passphrase":
          "stomach worry artefact bicycle finger doctor outdoor learn lecture powder agent body",
      'format': ImportFormat.horizon.description,
      'addresses': ["tb1qtghcd3sh2lqcc7ylglelu77pj55684rqluukxe"],
      'network': 'testnet'
    },
    {
      "passphrase":
          "crash suffer render miss endorse plastic success choice cable check normal gadget",
      'format': ImportFormat.freewallet.description,
      'addresses': [
        "1FP7TJfEnPYfg2jPvB89sPcPYH4pkV8xgA",
        "bc1qnhqye8y0tad8newu6hhhyusveh9gm8gu80t9uh",
        "1Bt7nYKBrwwuBJq4nMFNXsWoN4DFqpTq2r",
        "bc1qwawz93lamp5td6cm54v70qnw73w79m6ckuqdhn",
        "1FuU9eDVbyzirdcEGzziLpeySA9UQdH5sR",
        "bc1q5dlqm3m4qnw0ysuzaj0a4lms32njt2r0u28uj2",
        "1HkAtXqoJP2N3z4BBcTrukWC1hPDtuAKRe",
        "bc1qk7kzw3prdvg7nq25eqmklt3w3yq9w9n04a8res",
        "1NCvRtUE3SjWCLVPDboowwHrcca7yU3fGQ",
        "bc1qazdazsglza6mm32v8ntevfvj24x7admh2vwvsk",
        "1A4g9tCTdAzQGrdwuXjG1RHXdn4Uwe51ki",
        "bc1qvd43qd6ygwmcff5e99kzg3qfqk6g5aefvzqh52",
        "19qzAw7gWokf692e43kjFLrhKRWpvzYF8d",
        "bc1qvyzty4zuz5rxaffs9wjpr5qklnzly3sdnry22f",
        "1CGRJjhJf8RmEmoWuz64ATnsaMPiqRFVda",
        "bc1q0wf7nx0rh4dv47wrdxzvpq85xn3cqrxgm2na5f",
        "1GK52HJapkQsiZt4CR9jT4ZMJdehGkJmtR",
        "bc1q5l6tk3sak0x9hvntw984hlpansl36apkdxv2lf",
        "1KfekfR1hWVBCa8y7Wa8TEK94CUp4ftkdz",
        "bc1qenqetjtjt2xvp9wdmrg38dw76jard0xlyfqj9p"
      ],
      'network': 'mainnet'
    },
    {
      "passphrase":
          "crash suffer render miss endorse plastic success choice cable check normal gadget",
      'format': ImportFormat.freewallet.description,
      'addresses': [
        "muu4kMkDbQyvT9D1dk6XhJpiQGfXjdRuDZ",
        "tb1qnhqye8y0tad8newu6hhhyusveh9gm8gudfsk8y",
        "mrQ55bQAfyP9xRJgVvDkMnj8E3oxhUrhZc",
        "tb1qwawz93lamp5td6cm54v70qnw73w79m6cu6m7vq",
        "mvRRShJUR1Rydk5qzZy6AjsJJ9kBNWVKvD",
        "tb1q5dlqm3m4qnw0ysuzaj0a4lms32njt2r0kvu0fe",
        "mxG8Bavn7QTcq6XnuBSEjfiWsgyvjr7bLL",
        "tb1qk7kzw3prdvg7nq25eqmklt3w3yq9w9n0lmuszr",
        "n2isiwZCrUAkySxzwAnBmrWBUcAptLqnaY",
        "tb1qazdazsglza6mm32v8ntevfvj24x7admhq24lt9",
        "mpadSwHSSCRf3y7Zd6hdqLVrVmfBqQvTth",
        "tb1qvd43qd6ygwmcff5e99kzg3qfqk6g5aefxymy0e",
        "mpMwTzCfKqBusFWFmcj75G52BR7XqZE36i",
        "tb1qvyzty4zuz5rxaffs9wjpr5qklnzly3sde9le36",
        "mrnNbnnHU9s21tH8dZ4RzP1CSLzRj1TbnC",
        "tb1q0wf7nx0rh4dv47wrdxzvpq85xn3cqrxg3vgw06",
        "mvq2KLPZdmr8VgMfuz87GymgAdFQE5tmRH",
        "tb1q5l6tk3sak0x9hvntw984hlpansl36apk8qhey6",
        "mzBc3iVzWXvRygcaq5YWH9XTvC5WzDMLR6",
        "tb1qenqetjtjt2xvp9wdmrg38dw76jard0xlw0mp7j"
      ],
      'network': 'testnet'
    }
  ];

  final testCases =
      testCases_.where((testCase) => testCase['network'] == network).toList();

  group('Lockscreen Tests', () {
    setUp(() async {
      // Perform any common setup here
      setup();
      await initSettings();
    });

    tearDown(() async {
      // Clean up settings
      Settings.clearCache();

      // Reset GetIt
      await GetIt.I.reset();

      // Add a small delay to ensure cleanup is complete
      await Future.delayed(const Duration(milliseconds: 100));
    });

    for (final testCase in testCases) {
      testWidgets('Import seed flow - ${testCase['format']}',
          (WidgetTester tester) async {
        final isFreewalletBip39 =
            testCase['format'] == ImportFormat.freewallet.description;
        OnboardingConfig.setIsFreewalletImportBip39(isFreewalletBip39);
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

        await tester.pumpWidget(MyApp(
          currentVersion: Version(0, 0, 0),
          latestVersion: Version(0, 0, 0),
        ));

        // Wait for the app to settle
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Find and tap the "LOAD SEED PHRASE" button
        final importSeedButton = find.text('LOAD SEED PHRASE');
        expect(importSeedButton, findsOneWidget);
        await tester.tap(importSeedButton);
        await tester.pumpAndSettle();

        // Now we should be on the "Choose the format of your seed phrase" screen
        // Open the dropdown for import format
        final dropdownFinder = find.byType(DropdownButton<String>);
        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();

        // Select the specified import format
        String dropdownText;
        if (testCase['format'] == ImportFormat.horizon.description) {
          dropdownText = 'Horizon Native';
        } else {
          dropdownText = 'Freewallet / Counterwallet / Rare Pepe Wallet';
        }
        final formatOption = find.text(dropdownText).last;
        await tester.tap(formatOption);
        await tester.pumpAndSettle();

        // Tap the "CONTINUE" button
        final continueButton = find.text('CONTINUE');
        expect(continueButton, findsOneWidget);
        await tester.tap(continueButton);
        await tester.pumpAndSettle();

        // Now we should be on the seed phrase input screen
        final seedPhrase = testCase['passphrase'] as String;
        final firstWordField = find.byType(TextField).first;
        await tester.enterText(firstWordField, seedPhrase);
        await tester.pumpAndSettle();

        // Tap the "CONTINUE" button
        final continueButtonAfterSeed = find.text('CONTINUE');
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

        // Ensure the "LOGIN" button is visible
        final loginButton = find.text('LOGIN');
        expect(loginButton, findsOneWidget);

        await tester.ensureVisible(loginButton);
        await tester.pumpAndSettle();

        // Now tap the "LOGIN" button
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        final expectedAddresses = testCase['addresses'] as List<String>;

        // Ensure addresses are returned in the correct order
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
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        final lockScreen = find.text('Lock Screen');
        expect(lockScreen, findsOneWidget);
        await tester.tap(lockScreen);
        await tester.pumpAndSettle();

        final password = find.byType(TextField);
        await tester.enterText(password, "securepassword123");
        await tester.pumpAndSettle();

        final unlock = find.text('UNLOCK');
        expect(unlock, findsOneWidget);
        await tester.tap(unlock);
        await tester.pumpAndSettle();

        // Keep pumping frames until the settings button appears or timeout occurs
        await tester.pumpUntilFound(
          find.byIcon(Icons.settings),
          timeout: const Duration(seconds: 10),
        );

        final settingsButton2 = find.byIcon(Icons.settings);
        expect(settingsButton2, findsOneWidget);
        await tester.tap(settingsButton2);
        await tester.pumpAndSettle();

        final resetButton = find.text('Reset wallet');
        expect(resetButton, findsOneWidget);
        await tester.tap(resetButton);
        await tester.pumpAndSettle();

        final resetCheckbox = find.byType(CheckboxListTile);
        expect(resetCheckbox, findsOneWidget);
        await tester.tap(resetCheckbox);
        await tester.pumpAndSettle();

        final continueResetButton = find.text('CONTINUE');
        expect(continueResetButton, findsOneWidget);
        await tester.tap(continueResetButton);
        await tester.pumpAndSettle();

        final resetConfirmationField =
            find.byKey(const Key('resetConfirmationTextField'));
        expect(resetConfirmationField, findsOneWidget);
        await tester.enterText(resetConfirmationField, 'RESET WALLET');
        await tester.pumpAndSettle();

        final confirmResetButton = find.byKey(const Key('continueButton'));
        expect(confirmResetButton, findsOneWidget);
        await tester.tap(confirmResetButton);

        await tester.pumpAndSettle();
      });
    }
  });
}
