import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/main.dart';
import 'package:horizon/setup.dart';
import 'package:integration_test/integration_test.dart';

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
      'addressToWIFMap': {
        'muYJYjRZDPmTEMfyEGe34BGN8tZ6rmRZCu':
            "cQeTd6ap99KQYNr3jaZkANTKfk32CEfYjnZVNZdLKDfHoPxjVn5K",
        'tb1qn8f324j40n5x4d6led6xs0hm5x779q2780rdxz':
            "cQeTd6ap99KQYNr3jaZkANTKfk32CEfYjnZVNZdLKDfHoPxjVn5K",
        'mkvaJJCpMMjvhaHodDCvstZsZwTaWR4w3M':
            "cNG8CeGyXQkhrr5A4MFLG1NTfkmZeMQL3NnpUHJuaLWRq4PbB7ff",
        'tb1q8dgyqdnyr6kf3ctawy5ljl73r86h95aqwg8k7c':
            "cNG8CeGyXQkhrr5A4MFLG1NTfkmZeMQL3NnpUHJuaLWRq4PbB7ff",
        'msj2PuwQRMWEmsi75GDcERXygw63BTRX7W':
            "cMo5vVxxtRNw7PcV1R7eSDnUWqoaC7BknnQbjLZDiGNXeYUqf5WS",
        'tb1qsh57e8axj5v5w378mzjacvsg80xe7agxwkf8sy':
            "cMo5vVxxtRNw7PcV1R7eSDnUWqoaC7BknnQbjLZDiGNXeYUqf5WS",
        'mzxiJXf3ttSyDy989MBnQ8h4y2q3k8cakJ':
            "cPUaLQtHALyPQNFv1HrmgxgtCqrMkeZyLGSMLNkFvxrWZEK3R6Pf",
        'tb1q64ycvmkdsn26uzwdnhnmp9j3wwz57nqetxmpjz':
            "cPUaLQtHALyPQNFv1HrmgxgtCqrMkeZyLGSMLNkFvxrWZEK3R6Pf",
        'mgVJ74YwNGDjoqiGEFy8NWydDXzRwKLoAQ':
            "cTpXZriRCkiyUMA3UyTeDAdnfx9zSqNUGTh7r6v6ngTgLsaXe6tt",
        'tb1qp2nafvy88y38pvkxhzwkqrlm2nj0znmffm6d4q':
            "cTpXZriRCkiyUMA3UyTeDAdnfx9zSqNUGTh7r6v6ngTgLsaXe6tt",
        'mrcPFdq6PKn5vCeDKGuN2bb3knBZktfCTd':
            "cQQiZyqRGsnkL8BNgokNYKtdVvfGM4hfS2yxxYTEUDp6RugBHsc7",
        'tb1q0xcyct02486rxztf6txk7584we2m44l40262mk':
            "cQQiZyqRGsnkL8BNgokNYKtdVvfGM4hfS2yxxYTEUDp6RugBHsc7",
        'mtFWdP1jmCr35E8uLerHinettFrL3C7PTW':
            "cUXGe9v52o7L3jdWFC7cRb9nEqM7HAUuCxiCpNZoMrVAcehqndrS",
        'tb1q3wklshmagq2tzyd35929d7hecfrlwtmjw8ze3u':
            "cUXGe9v52o7L3jdWFC7cRb9nEqM7HAUuCxiCpNZoMrVAcehqndrS",
        'mizHtGJa1AFs7x5dzg75P8XBghffMuiRQn':
            "cSTCxFTQ6YuvmiXS8ETMB4r1r2WyWs2cdYxvPGWSXcUYahvZ2ki8",
        'tb1qycflvz3hvffkdpgu3892es0w748qcgtaslw4fg':
            "cSTCxFTQ6YuvmiXS8ETMB4r1r2WyWs2cdYxvPGWSXcUYahvZ2ki8",
        'mkUtf98ZFvo59ewRvH86yrmFxcXtfG2K1p':
            "cNKSrFXwQJrbCgTJabkDutEoSH3CKGHnbomGUNobrhfRCCjkiyL1",
        'tb1qxe6v9m4ekyuxljh9cl86yarjutxjw02kleka6a':
            "cNKSrFXwQJrbCgTJabkDutEoSH3CKGHnbomGUNobrhfRCCjkiyL1",
        'mnfimZCF7gaR6qhzDHnB9NKFDfdYM9QXDN':
            "cUAgAnRc6D9uVVLGAtiHUosHQjc8Fwbo4CbXLxgBhxbK1krdAHm7",
        'tb1qfec424jsfhawu4cw7353p6qu48yc46924rujet':
            "cUAgAnRc6D9uVVLGAtiHUosHQjc8Fwbo4CbXLxgBhxbK1krdAHm7"
      },
      'network': 'testnet'
    },
    {
      "passphrase":
          "voice flame certainly anyone former raw limit king rhythm tumble crystal earth",
      'format': ImportFormat.counterwallet.description,
      'addressToWIFMap': {
        "1F2MFgLaQNLCTFCMWhffEG43GtxPxu6KWM":
            "KzHUABaxi5d9NwNnMAkco3xG3WjcXnZrfkR2G9App71HYetoX8Jy",
        "bc1qn8f324j40n5x4d6led6xs0hm5x779q27dfc7a3":
            "KzHUABaxi5d9NwNnMAkco3xG3WjcXnZrfkR2G9App71HYetoX8Jy",
        '16Qd1F7qYLJfvTpBueEZ3yMYhwrsanPjSN':
            "Kwu8jjH86M4ShQbtfwSCtgsQ3XU9yuJdyLeMMrrQ5DrRaKMCSHhS",
        'bc1q8dgyqdnyr6kf3ctawy5ljl73r86h95aqywu99t':
            "Kwu8jjH86M4ShQbtfwSCtgsQ3XU9yuJdyLeMMrrQ5DrRaKMCSHhS",
        '1DD56rrRcL4yzmEVMhFEQWKepwVLJScrVA':
            "KwS6Tay7TMgfwx9Dd1JX4uHQtcWAXf64ikG8cv6iD9iXPoM7m7ZU",
        'bc1qsh57e8axj5v5w378mzjacvsg80xe7agxysj5th':
            "KwS6Tay7TMgfwx9Dd1JX4uHQtcWAXf64ikG8cv6iD9iXPoM7m7ZU",
        '1LSm1Ua55s1iSrfWRnDQaDUk73ELrwRCW3':
            "Ky7asVtRjHH8Evnect3eKeBpacYx6CUHGEHtDxHkRrCWJVD7EaoX",
        'bc1q64ycvmkdsn26uzwdnhnmp9j3wwz57nqepqqjf3':
            "Ky7asVtRjHH8Evnect3eKeBpacYx6CUHGEHtDxHkRrCWJVD7EaoX",
        '1yLp1TxZEnV2jEeWgzkYbmJMYPivnLv2G':
            "L3TY6wiZmh2iJugn6ZeWqr8j3iranPGnCRYejgTbHZog68YASx6r",
        'bc1qp2nafvy88y38pvkxhzwkqrlm2nj0znmfrap7wn':
            "L3TY6wiZmh2iJugn6ZeWqr8j3iranPGnCRYejgTbHZog68YASx6r",
        '1C6Rxak7aJLq96AbbhvzCgNitnartkr5Hd':
            "Kz3j74qZqp6VAgi7JPwFB1PZshMrgcbyMzqVr7ziy7A6BAdYTxGJ",
        'bc1q0xcyct02486rxztf6txk7584we2m44l49vpeq9':
            "Kz3j74qZqp6VAgi7JPwFB1PZshMrgcbyMzqVr7ziy7A6BAdYTxGJ",
        '1DjZLKvkxBQnJ7fHd5sutsSa2GFdAZrsPT':
            "L4AHBEvDbjR4tJAErnJV4Geicc3hciPD8vZjhx7HrjqAMub7sm4o",
        'bc1q3wklshmagq2tzyd35929d7hecfrlwtmjype220':
            "L4AHBEvDbjR4tJAErnJV4Geicc3hciPD8vZjhx7HrjqAMub7sm4o",
        '14ULbDDbC8pcLqc2H78hZDJrpi4xRjcBe8':
            "L26DVLTYfVDfcH4AjpeDokLxDoDZrQvvZWpTGr3w2VpYKxrR29KP",
        'bc1qycflvz3hvffkdpgu3892es0w748qcgta6e4xjm':
            "L26DVLTYfVDfcH4AjpeDokLxDoDZrQvvZWpTGr3w2VpYKxrR29KP",
        '15xwN63aSuMpNYTpCi9j9wYw6cwBjqCH7F':
            "KwxTPLY5yFAL3Ez3CBw6YZjjp3jnepC6XmcoMxM6Mb1QwThKS3aG",
        'bc1qxe6v9m4ekyuxljh9cl86yarjutxjw02k4ldwpw':
            "KwxTPLY5yFAL3Ez3CBw6YZjjp3jnepC6XmcoMxM6Mb1QwThKS3aG",
        '189mUW7GJf9AKjENViooKT6vMg2qRdQHT3':
            "L3oghsRkf9TeL3rznUuA7VNDnWJibVW6zAT4EYDgCqwJm1j6Bpgr",
        'bc1qfec424jsfhawu4cw7353p6qu48yc4692l98pzc':
            "L3oghsRkf9TeL3rznUuA7VNDnWJibVW6zAT4EYDgCqwJm1j6Bpgr"
      },
      'network': 'mainnet'
    },
    {
      "passphrase":
          "stomach worry artefact bicycle finger doctor outdoor learn lecture powder agent body",
      'format': ImportFormat.horizon.description,
      'addressToWIFMap': {
        "bc1q2d0uhg8wupev6d22umufydd98jvznxngnvt5mm":
            "KyrpTEubafHDheWBJ9VRM4QVo78Zw5GFXmKv1sUr1gK1Fb4t3JeE"
      },
      'network': 'mainnet'
    },
    {
      "passphrase":
          "stomach worry artefact bicycle finger doctor outdoor learn lecture powder agent body",
      'format': ImportFormat.horizon.description,
      'addressToWIFMap': {
        "tb1qtghcd3sh2lqcc7ylglelu77pj55684rqluukxe":
            "cT3WnVTsJFks9nkTWQ6SPxx3HAiACnysDPJKPZdvqLD5oEgEqNbf"
      },
      'network': 'testnet'
    },
    {
      "passphrase":
          "crash suffer render miss endorse plastic success choice cable check normal gadget",
      'format': ImportFormat.freewallet.description,
      'addressToWIFMap': {
        "1FP7TJfEnPYfg2jPvB89sPcPYH4pkV8xgA":
            "L2tnCtYkSsoAu5DiYteU5wPeVXWgF5HDDvWNCSYoQpfyGrtvqew4",
        "bc1qnhqye8y0tad8newu6hhhyusveh9gm8gu80t9uh":
            "L2tnCtYkSsoAu5DiYteU5wPeVXWgF5HDDvWNCSYoQpfyGrtvqew4",
        "1Bt7nYKBrwwuBJq4nMFNXsWoN4DFqpTq2r":
            "L3nbQxSGr95PgjPTpgRDpNLS3JKVF5GDfHX1WDHhiA3w4dxJL3zm",
        "bc1qwawz93lamp5td6cm54v70qnw73w79m6ckuqdhn":
            "L3nbQxSGr95PgjPTpgRDpNLS3JKVF5GDfHX1WDHhiA3w4dxJL3zm",
        "1FuU9eDVbyzirdcEGzziLpeySA9UQdH5sR":
            "L5GkJdXCG4gbiNAg5qckcr9mg914TfWFC28XKu53ip1Ay85jszR1",
        "bc1q5dlqm3m4qnw0ysuzaj0a4lms32njt2r0u28uj2":
            "L5GkJdXCG4gbiNAg5qckcr9mg914TfWFC28XKu53ip1Ay85jszR1",
        "1HkAtXqoJP2N3z4BBcTrukWC1hPDtuAKRe":
            "L2DEnhxUDr7WcAugUYTmqRFz6aaWr9kDGJcMSQwVoRb7wy3a8RKn",
        "bc1qk7kzw3prdvg7nq25eqmklt3w3yq9w9n04a8res":
            "L2DEnhxUDr7WcAugUYTmqRFz6aaWr9kDGJcMSQwVoRb7wy3a8RKn",
        "1NCvRtUE3SjWCLVPDboowwHrcca7yU3fGQ":
            "L1VCuLkuWugiLccGtbieKqmFMoHX7tZcHAJ8FTwcUvXfYX47aFTB",
        "bc1qazdazsglza6mm32v8ntevfvj24x7admh2vwvsk":
            "L1VCuLkuWugiLccGtbieKqmFMoHX7tZcHAJ8FTwcUvXfYX47aFTB",
        "1A4g9tCTdAzQGrdwuXjG1RHXdn4Uwe51ki":
            "Kxa5B4RFE92AGG9eJvddnYFAjxC9aXKEe1eLk6wcQaPbZwB5JxwC",
        "bc1qvd43qd6ygwmcff5e99kzg3qfqk6g5aefvzqh52":
            "Kxa5B4RFE92AGG9eJvddnYFAjxC9aXKEe1eLk6wcQaPbZwB5JxwC",
        "19qzAw7gWokf692e43kjFLrhKRWpvzYF8d":
            "L3e9teAYubCycLVkqXmfEPcEL5qcHeUStMzsVj2CpymhQ4fymart",
        "bc1qvyzty4zuz5rxaffs9wjpr5qklnzly3sdnry22f":
            "L3e9teAYubCycLVkqXmfEPcEL5qcHeUStMzsVj2CpymhQ4fymart",
        "1CGRJjhJf8RmEmoWuz64ATnsaMPiqRFVda":
            "Ky91t6yDzvWv6hzfHp1YFNYDusQgUwMjySB4xWK8iEiz2mnfFa7v",
        "bc1q0wf7nx0rh4dv47wrdxzvpq85xn3cqrxgm2na5f":
            "Ky91t6yDzvWv6hzfHp1YFNYDusQgUwMjySB4xWK8iEiz2mnfFa7v",
        "1GK52HJapkQsiZt4CR9jT4ZMJdehGkJmtR":
            "Kzc1w6Vw7YEekgNW1HrVxCxWBs3ksn8a441rL3vwBGTFcsnUUHsu",
        "bc1q5l6tk3sak0x9hvntw984hlpansl36apkdxv2lf":
            "Kzc1w6Vw7YEekgNW1HrVxCxWBs3ksn8a441rL3vwBGTFcsnUUHsu",
        "1KfekfR1hWVBCa8y7Wa8TEK94CUp4ftkdz":
            "L16vpNBVKSwpRTPPrZMTG8jRk12cpmFwDZW4VeWc8VSiupA3aSDE",
        "bc1qenqetjtjt2xvp9wdmrg38dw76jard0xlyfqj9p":
            "L16vpNBVKSwpRTPPrZMTG8jRk12cpmFwDZW4VeWc8VSiupA3aSDE"
      },
      'network': 'mainnet'
    },
    {
      "passphrase":
          "crash suffer render miss endorse plastic success choice cable check normal gadget",
      'format': ImportFormat.freewallet.description,
      'addressToWIFMap': {
        "muu4kMkDbQyvT9D1dk6XhJpiQGfXjdRuDZ":
            "cTFmfoYbswVS4WgywJTbTFti7kp5uXNuHxeqJs1JuwKyXbzh3g3h",
        "tb1qnhqye8y0tad8newu6hhhyusveh9gm8gudfsk8y":
            "cTFmfoYbswVS4WgywJTbTFti7kp5uXNuHxeqJs1JuwKyXbzh3g3h",
        "mrQ55bQAfyP9xRJgVvDkMnj8E3oxhUrhZc":
            "cU9assS8HCmerArjD6EMBgqVfXctuXMujKfUcdkDDGhwKP44kR8z",
        "tb1qwawz93lamp5td6cm54v70qnw73w79m6cu6m7vq":
            "cU9assS8HCmerArjD6EMBgqVfXctuXMujKfUcdkDDGhwKP44kR8z",
        "mvRRShJUR1Rydk5qzZy6AjsJJ9kBNWVKvD":
            "cVdjmYX3h8NrsodwUFRszAeqJNJU87bwG4GzSKXZDvfBDsDAKxWF",
        "tb1q5dlqm3m4qnw0ysuzaj0a4lms32njt2r0kvu0fe":
            "cVdjmYX3h8NrsodwUFRszAeqJNJU87bwG4GzSKXZDvfBDsDAKxWF",
        "mxG8Bavn7QTcq6XnuBSEjfiWsgyvjr7bLL":
            "cSaEFcxKeuommcNwrxGuCjm3iosvWbquLLkpYqQ1JYF8CiA1WSTn",
        "tb1qk7kzw3prdvg7nq25eqmklt3w3yq9w9n0lmuszr":
            "cSaEFcxKeuommcNwrxGuCjm3iosvWbquLLkpYqQ1JYF8CiA1WSTn",
        "n2isiwZCrUAkySxzwAnBmrWBUcAptLqnaY":
            "cRrCNFkkwyNyW45YH1XmhAGJz2avnLfJMCSbMtQ7z3BfoG94fR3T",
        "tb1qazdazsglza6mm32v8ntevfvj24x7admhq24lt9":
            "cRrCNFkkwyNyW45YH1XmhAGJz2avnLfJMCSbMtQ7z3BfoG94fR3T",
        "mpadSwHSSCRf3y7Zd6hdqLVrVmfBqQvTth":
            "cNw4dyR6fCiRRhcuhLSm9rkENBVZEyQvi3norXQ7uh3bpgHLdHss",
        "tb1qvd43qd6ygwmcff5e99kzg3qfqk6g5aefxymy0e":
            "cNw4dyR6fCiRRhcuhLSm9rkENBVZEyQvi3norXQ7uh3bpgHLdHss",
        "mpMwTzCfKqBusFWFmcj75G52BR7XqZE36i":
            "cU19MZAQLeuEmmy2Dwanbi7HxK91x6a8xQ9Lc9UiL6RheoisLUoe",
        "tb1qvyzty4zuz5rxaffs9wjpr5qklnzly3sde9le36":
            "cU19MZAQLeuEmmy2Dwanbi7HxK91x6a8xQ9Lc9UiL6RheoisLUoe",
        "mrnNbnnHU9s21tH8dZ4RzP1CSLzRj1TbnC":
            "cPW1M1y5RzDBG9TvgDpfch3HY6i69PTS3UKY4vmeDMNzHWqM76nE",
        "tb1q0wf7nx0rh4dv47wrdxzvpq85xn3cqrxg3vgw06":
            "cPW1M1y5RzDBG9TvgDpfch3HY6i69PTS3UKY4vmeDMNzHWqM76nE",
        "mvq2KLPZdmr8VgMfuz87GymgAdFQE5tmRH":
            "cQy1Q1VnYbvuv7qmPhfdKXTZp6MAYEEG86AKSUPSgP7FscpwwLSL",
        "tb1q5l6tk3sak0x9hvntw984hlpansl36apk8qhey6":
            "cQy1Q1VnYbvuv7qmPhfdKXTZp6MAYEEG86AKSUPSgP7FscpwwLSL",
        "mzBc3iVzWXvRygcaq5YWH9XTvC5WzDMLR6":
            "cRTvHHBLkWe5atrfEyAadTEVNEL2VDMdHbeXc4y7dc6jAZCz38PB",
        "tb1qenqetjtjt2xvp9wdmrg38dw76jard0xlw0mp7j":
            "cRTvHHBLkWe5atrfEyAadTEVNEL2VDMdHbeXc4y7dc6jAZCz38PB"
      },
      'network': 'testnet'
    }
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

        // Find and tap the "LOAD SEED PHRASE" button
        final importSeedButton = find.text('LOAD SEED PHRASE');
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

        final expectedAddresses =
            testCase['addressToWIFMap'] as Map<String, String>;

        // Ensure addresses are returned in the correct order
        final addressRepository = GetIt.instance<AddressRepository>();
        final accountRepository = GetIt.instance<AccountRepository>();
        final walletRepository = GetIt.instance<WalletRepository>();
        final encryptionService = GetIt.instance<EncryptionService>();
        final wallet = await walletRepository.getCurrentWallet();
        final account =
            await accountRepository.getAccountsByWalletUuid(wallet!.uuid);
        final addresses =
            await addressRepository.getAllByAccountUuid(account.first.uuid);
        expect(addresses.length, expectedAddresses.entries.length,
            reason: 'Number of imported addresses does not match expected');

        for (var i = 0; i < addresses.length; i++) {
          final derivedAddress = addresses[i];
          final expectedAddress = expectedAddresses.entries.elementAt(i);
          expect(derivedAddress.address, expectedAddress.key,
              reason:
                  'Address ${derivedAddress.address} does not match expected address ${expectedAddress.key}');
          final derivedAddressPrivateKey = await encryptionService.decrypt(
              derivedAddress.encryptedPrivateKey!, 'securepassword123');
          expect(derivedAddressPrivateKey, expectedAddress.value,
              reason:
                  'Private key $derivedAddressPrivateKey does not match expected private key ${expectedAddress.value}');
        }

        final settingsButton = find.byIcon(Icons.settings);
        expect(settingsButton, findsOneWidget);
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        final resetButton = find.text('Reset wallet');
        expect(resetButton, findsOneWidget);
        await tester.tap(resetButton);
        await tester.pumpAndSettle();

        final confirmResetButton = find.text('RESET WALLET');
        expect(confirmResetButton, findsOneWidget);
        await tester.tap(confirmResetButton);
        await tester.pumpAndSettle();

        // Add this line to ensure all events are processed
        await tester.pumpAndSettle();
      });
    }
  });
}
