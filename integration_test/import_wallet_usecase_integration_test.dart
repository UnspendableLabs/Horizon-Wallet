import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/data/services/address_service_impl.dart';
import 'package:horizon/data/services/bip39_service_impl.dart';
import 'package:horizon/data/services/encryption_service_web_worker_impl.dart';
import 'package:horizon/data/services/mnemonic_service_impl.dart';
import 'package:horizon/data/services/secure_kv_service_impl.dart';
import 'package:horizon/data/services/wallet_service_impl.dart';
import 'package:horizon/data/sources/local/db_manager.dart';
import 'package:horizon/data/sources/repositories/account_repository_impl.dart';
import "package:horizon/data/sources/repositories/address_repository_impl.dart";
import 'package:horizon/data/sources/repositories/config_repository_impl.dart';
import 'package:horizon/data/sources/repositories/in_memory_key_repository_impl.dart';
import 'package:horizon/data/sources/repositories/wallet_repository_impl.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bip39.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBitcoinRepository extends Mock implements BitcoinRepository {}

class MockEventsRepository extends Mock implements EventsRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Register the mock
  late MockBitcoinRepository mockBitcoinRepository;
  late MockEventsRepository mockEventsRepository;
  var transactionCallCount = 0;

  // Define test cases
  final testCases_ = [
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
    },
    {
      "passphrase":
          "stomach worry artefact bicycle finger doctor outdoor learn lecture powder agent body",
      'format': ImportFormat.horizon.description,
      'addresses': [
        "bc1q2d0uhg8wupev6d22umufydd98jvznxngnvt5mm",
        "bc1q3jpqgq03vl6xaed36mjw0uh94xfapd4wxzmwzh",
        "bc1q5y82yfpwzm9yqhgy27lwn6tcehw6hvh3q080km",
        "bc1qgngvej4zrv0z7qen44rp6n6nxqeu9ye5g8v952",
        "bc1qv2dwl4wp4p22cwv9tnyhu9jfmhyt8l8q4r573a",
        "bc1qcf3de2thj63utrp5ltq0fvd257m99c87la2dvc",
        "bc1q97ayjx5mdddvsrpe3ugf844vqr8sfpdgvw7vf6",
        "bc1q4mg9f4hvjdexuj287nws79zwm3agpqlsv3vfht",
        "bc1qnpy6zj0utmnfwyt8acrcm8dz7zta4kx84muxme",
        "bc1qlse5jhw0ny8qx23d0v2lkp6j9w7hdz0kemup5v"
      ],
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
    },
  ];

  final testCases = testCases_.toList();

  group('Onboarding Integration Tests', () {
    setUp(() async {
      transactionCallCount = 0;

      // Initialize Settings
      await Settings.init(
        cacheProvider: SharePreferenceCache(),
      );
      GetIt injector = GetIt.I;

      // Create the mock instance
      mockBitcoinRepository = MockBitcoinRepository();
      mockEventsRepository = MockEventsRepository();
      // Register our mock BEFORE running setup
      injector.registerSingleton<BitcoinRepository>(mockBitcoinRepository);
      injector.registerSingleton<EventsRepository>(mockEventsRepository);

      // Now run the regular setup

      Config config = ConfigImpl();

      injector.registerLazySingleton<Config>(() => config);
      injector.registerSingleton<DatabaseManager>(DatabaseManager());

      injector.registerSingleton<EncryptionService>(
          EncryptionServiceWebWorkerImpl());
      injector.registerSingleton<WalletService>(
          WalletServiceImpl(injector(), config));
      injector.registerSingleton<AddressService>(
          AddressServiceImpl(config: config));

      injector.registerSingleton<Bip39Service>(Bip39ServiceImpl());

      injector.registerSingleton<MnemonicService>(
          MnemonicServiceImpl(GetIt.I.get<Bip39Service>()));

      injector.registerSingleton<SecureKVService>(SecureKVServiceImpl());

      injector
          .registerSingleton<InMemoryKeyRepository>(InMemoryKeyRepositoryImpl(
        secureKVService: GetIt.I.get<SecureKVService>(),
      ));

      injector.registerSingleton<AccountRepository>(
          AccountRepositoryImpl(injector.get<DatabaseManager>().database));
      injector.registerSingleton<WalletRepository>(
          WalletRepositoryImpl(injector.get<DatabaseManager>().database));
      injector.registerSingleton<AddressRepository>(
          AddressRepositoryImpl(injector.get<DatabaseManager>().database));

      injector.registerSingleton<ImportWalletUseCase>(ImportWalletUseCase(
        inMemoryKeyRepository: GetIt.I.get<InMemoryKeyRepository>(),
        addressService: GetIt.I.get<AddressService>(),
        config: GetIt.I.get<Config>(),
        addressRepository: GetIt.I.get<AddressRepository>(),
        accountRepository: GetIt.I.get<AccountRepository>(),
        walletRepository: GetIt.I.get<WalletRepository>(),
        encryptionService: GetIt.I.get<EncryptionService>(),
        walletService: GetIt.I.get<WalletService>(),
        bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
        mnemonicService: GetIt.I.get<MnemonicService>(),
        eventsRepository: GetIt.I.get<EventsRepository>(),
      ));
    });

    tearDown(() async {
      // Clean up settings
      Settings.clearCache();
      await GetIt.I.get<AccountRepository>().deleteAllAccounts();
      await GetIt.I.get<WalletRepository>().deleteAllWallets();
      await GetIt.I.get<AddressRepository>().deleteAllAddresses();

      // Clean up GetIt
      await GetIt.I.reset();
    });

    for (final testCase in testCases) {
      testWidgets(
          'Import Wallet with bitcoin transactions - ${testCase['format']}',
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

        int transactionCount;
        if (testCase['format'] == ImportFormat.horizon.description) {
          transactionCount =
              10; // import 10 horizon accounts, 1 address per account
        } else {
          transactionCount =
              1; // import 1 counterwallet or freewallet account with 20 address
        }

        // Setup default mock behavior before any test runs
        when(() => mockBitcoinRepository.getTransactions(any()))
            .thenAnswer((_) async {
          if (transactionCallCount < transactionCount) {
            transactionCallCount++;

            // only import 1 account
            return Right([
              BitcoinTx(
                txid: 'mock_txid_$transactionCallCount',
                version: 1,
                locktime: 0,
                vin: [],
                vout: [],
                size: 100,
                weight: 400,
                fee: 1000,
                status: Status(
                  confirmed: true,
                  blockHeight: 1000,
                  blockHash: 'mock_block_hash',
                  blockTime: 1600000000,
                ),
              ),
            ]);
          } else {
            return const Right([]);
          }
        });
        when(() => mockEventsRepository.numEventsForAddresses(
            addresses: any(named: 'addresses'))).thenAnswer((_) async {
          return 0;
        });

        final walletType =
            testCase['format'] == ImportFormat.horizon.description
                ? WalletType.horizon
                : WalletType.bip32;
        final importWalletUseCase = GetIt.I.get<ImportWalletUseCase>();
        await importWalletUseCase.call(
          mnemonic: testCase['passphrase'] as String,
          password: 'password',
          walletType: walletType,
          onError: (error) {
            print('Error: $error');
          },
          onSuccess: () {
            print('Success');
          },
        );

        final wallet = await GetIt.I.get<WalletRepository>().getCurrentWallet();

        // ensure the inserted wallet is the same as the one derived from the mnemonic
        final comparisonWallet = switch (testCase['format']) {
          'Horizon Native' => await GetIt.I
              .get<WalletService>()
              .deriveRoot(testCase['passphrase'] as String, 'password'),
          'Freewallet (BIP39)' => await GetIt.I
              .get<WalletService>()
              .deriveRootFreewallet(
                  testCase['passphrase'] as String, 'password'),
          'Freewallet / Counterwallet' => await GetIt.I
              .get<WalletService>()
              .deriveRootCounterwallet(
                  testCase['passphrase'] as String, 'password'),
          _ => throw Exception('Unknown format'),
        };

        expect(wallet!.publicKey, comparisonWallet.publicKey);
        expect(wallet.chainCodeHex, comparisonWallet.chainCodeHex);
        expect(wallet.name, comparisonWallet.name);

        final accounts = await GetIt.I
            .get<AccountRepository>()
            .getAccountsByWalletUuid(wallet.uuid);

        final expectedAccountCount =
            testCase['format'] == ImportFormat.horizon.description ? 10 : 1;

        expect(accounts.length, expectedAccountCount);

        for (final account in accounts) {
          final addresses = await GetIt.I
              .get<AddressRepository>()
              .getAllByAccountUuid(account.uuid);

          final expectedAddressCount =
              testCase['format'] == ImportFormat.horizon.description ? 1 : 20;

          expect(addresses.length, expectedAddressCount);

          for (final address in addresses) {
            expect(
                (testCase['addresses'] as List<String>)
                    .contains(address.address),
                isTrue);
            expect(
                address.address,
                (testCase['addresses'] as List<String>)
                    .firstWhere((e) => e == address.address));
          }
        }
      });

      testWidgets(
          'Import Wallet with bitcoin transactions - ${testCase['format']}',
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

        int transactionCount;
        if (testCase['format'] == ImportFormat.horizon.description) {
          transactionCount =
              10; // import 10 horizon accounts, 1 address per account
        } else {
          transactionCount =
              1; // import 1 counterwallet account with 20 address
        }

        // Setup default mock behavior before any test runs
        when(() => mockBitcoinRepository.getTransactions(any()))
            .thenAnswer((_) async {
          return const Right([]);
        });
        when(() => mockEventsRepository.numEventsForAddresses(
            addresses: any(named: 'addresses'))).thenAnswer((_) async {
          if (transactionCallCount < transactionCount) {
            transactionCallCount++;
            return 1;
          } else {
            return 0;
          }
        });

        final walletType =
            testCase['format'] == ImportFormat.horizon.description
                ? WalletType.horizon
                : WalletType.bip32;
        final importWalletUseCase = GetIt.I.get<ImportWalletUseCase>();
        await importWalletUseCase.call(
          mnemonic: testCase['passphrase'] as String,
          password: 'password',
          walletType: walletType,
          onError: (error) {
            print('Error: $error');
          },
          onSuccess: () {
            print('Success');
          },
        );

        final wallet = await GetIt.I.get<WalletRepository>().getCurrentWallet();

        // ensure the inserted wallet is the same as the one derived from the mnemonic
        final comparisonWallet = switch (testCase['format']) {
          'Horizon Native' => await GetIt.I
              .get<WalletService>()
              .deriveRoot(testCase['passphrase'] as String, 'password'),
          'Freewallet (BIP39)' => await GetIt.I
              .get<WalletService>()
              .deriveRootFreewallet(
                  testCase['passphrase'] as String, 'password'),
          'Freewallet / Counterwallet' => await GetIt.I
              .get<WalletService>()
              .deriveRootCounterwallet(
                  testCase['passphrase'] as String, 'password'),
          _ => throw Exception('Unknown format'),
        };

        expect(wallet!.publicKey, comparisonWallet.publicKey);
        expect(wallet.chainCodeHex, comparisonWallet.chainCodeHex);
        expect(wallet.name, comparisonWallet.name);

        final accounts = await GetIt.I
            .get<AccountRepository>()
            .getAccountsByWalletUuid(wallet.uuid);

        final expectedAccountCount =
            testCase['format'] == ImportFormat.horizon.description ? 10 : 1;

        expect(accounts.length, expectedAccountCount);

        for (final account in accounts) {
          final addresses = await GetIt.I
              .get<AddressRepository>()
              .getAllByAccountUuid(account.uuid);

          final expectedAddressCount =
              testCase['format'] == ImportFormat.horizon.description ? 1 : 20;

          expect(addresses.length, expectedAddressCount);

          for (final address in addresses) {
            expect(
                (testCase['addresses'] as List<String>)
                    .contains(address.address),
                isTrue);
            expect(
                address.address,
                (testCase['addresses'] as List<String>)
                    .firstWhere((e) => e == address.address));
          }
        }
      });
    }
  });
}
