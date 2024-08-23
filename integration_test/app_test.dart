import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/main.dart';
import 'package:horizon/setup.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const network = String.fromEnvironment('NETWORK', defaultValue: 'mainnet');

  // Define test cases
  final testCases_ = [
    {
      'passphrase':
          'voice flame certainly anyone former raw limit king rhythm tumble crystal earth',
      'format': ImportFormat.counterwallet.description,
      'addresses': [
        'muYJYjRZDPmTEMfyEGe34BGN8tZ6rmRZCu',
        'tb1qn8f324j40n5x4d6led6xs0hm5x779q2780rdxz'
      ],
      'network': 'testnet'
    },
    {
      "passphrase":
          "voice flame certainly anyone former raw limit king rhythm tumble crystal earth",
      'format': ImportFormat.counterwallet.description,
      'addresses': [
        "1F2MFgLaQNLCTFCMWhffEG43GtxPxu6KWM",
        "bc1qn8f324j40n5x4d6led6xs0hm5x779q27dfc7a3"
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
      'network': 'tesntet'
    }
  ];

  final testCases =
      testCases_.where((testCase) => testCase['network'] == network).toList();

  group('Onboarding Integration Tests', () {
    setUpAll(() async {
      // Perform any common setup here
      await setup();
    });

    print('TEST CASES: $testCases');
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
