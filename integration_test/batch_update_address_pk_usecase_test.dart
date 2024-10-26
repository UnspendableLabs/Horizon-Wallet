import 'package:horizon/common/constants.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/presentation/common/usecase/batch_update_address_pks.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/data/services/encryption_service_impl.dart';
import 'package:horizon/main.dart';
import 'package:horizon/setup.dart';
import 'fixtures/addresses_fixtures.dart' as fixtures;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BatchUpdateAddressPksUseCase Integration Tests -- web worker', () {
    late EncryptionService encryptionService;
    late EncryptionServiceImpl fallbackEncryptionService;
    late BatchUpdateAddressPksUseCase batchUpdateAddressPksUseCase;

    setUpAll(() async {
      await setup();
      encryptionService = GetIt.instance<EncryptionService>();
      fallbackEncryptionService = EncryptionServiceImpl();
      batchUpdateAddressPksUseCase = BatchUpdateAddressPksUseCase(
        addressRepository: GetIt.instance<AddressRepository>(),
        encryptionService: encryptionService,
        addressService: GetIt.instance<AddressService>(),
        walletRepository: GetIt.instance<WalletRepository>(),
        accountRepository: GetIt.instance<AccountRepository>(),
        logger: GetIt.instance<Logger>(),
      );
    });

    // Future<void> generateAddresses(int numAddresses, String accountUuid,
    //     String decryptedPrivKey, String chainCodeHex, String password) async {
    //   final List<Address> addresses = [];
    //   for (var i = 0; i < numAddresses; i++) {
    //     final Address address =
    //         await GetIt.instance<AddressService>().deriveAddressSegwit(
    //       privKey: decryptedPrivKey,
    //       chainCodeHex: chainCodeHex,
    //       accountUuid: accountUuid,
    //       purpose: '84\'',
    //       coin: '0\'',
    //       account: '$i\'',
    //       change: '0',
    //       index: 0,
    //       password: password,
    //     );
    //     addresses.add(address);
    //   }
    //   await GetIt.instance<AddressRepository>().insertMany(addresses);
    // }

    // Future<void> generateAccountsWithAddresses(
    //     int numAccounts,
    //     String walletUuid,
    //     String decryptedPrivKey,
    //     String chainCodeHex,
    //     String password) async {
    //   for (var i = 0; i < numAccounts; i++) {
    //     final Account account = Account(
    //       name: 'ACCOUNT $i',
    //       walletUuid: walletUuid,
    //       uuid: uuid.v4(),
    //       purpose: '84\'',
    //       coinType: '0\'',
    //       accountIndex: '$i\'',
    //       importFormat: ImportFormat.horizon,
    //     );
    //     await GetIt.instance<AccountRepository>().insert(account);
    //     generateAddresses(
    //         50, account.uuid, decryptedPrivKey, chainCodeHex, password);
    //   }
    // }

    Future<Wallet> setUpWallet(String password) async {
      // create a wallet with a known test private key
      // test mnemonic: stomach worry artefact bicycle finger doctor outdoor learn lecture powder agent body
      const String decryptedPrivKey =
          'd09471b1dba194b80747eb43481704b309550833a4b1ac43378c1aeb7808600c';
      const String chainCodeHex =
          '6a6d7e3767dac190fce11a17bfe4595ff8d27d5749e42c536e4bbe0aa212df97';
      const String walletUuid = '2ac54d11-543f-403b-a417-b1f8aaaf3816';
      const String publicKey =
          'xpub661MyMwAqRbcFbtd8jirfM2pRXsmsY3RbbE8beEQ9nPy8KZHdfqotizDJqnLJbS6QVQZqMu2pdShAYF8g73YtgFBgNZpEAKBjL4auhMW6T7';
      final String encryptedPrivKey =
          await encryptionService.encrypt(decryptedPrivKey, password);

      final Wallet wallet = Wallet(
        name: 'TEST WALLET',
        encryptedPrivKey: encryptedPrivKey,
        chainCodeHex: chainCodeHex,
        uuid: walletUuid,
        publicKey: publicKey,
      );

      await GetIt.instance<WalletRepository>().insert(wallet);
      return wallet;
    }

    setUpAccount(String walletUuid, int accountIndex) async {
      final Account account = Account(
        name: 'ACCOUNT $accountIndex',
        walletUuid: walletUuid,
        uuid: 'account_$accountIndex',
        purpose: '84\'',
        coinType: '0\'',
        accountIndex: '$accountIndex\'',
        importFormat: ImportFormat.horizon,
      );
      await GetIt.instance<AccountRepository>().insert(account);
    }

    Future<(List<Address>, Map<String, String>)> getAddressesFixtures(
        String key, String accountUuid, String password,
        {bool includePrivKeys = false}) async {
      final List<Map<String, dynamic>> jsonList =
          fixtures.addressesFixtures[key]!;
      final List<Address> initialAddresses = [];
      final Map<String, String> addressToWIF = {};

      for (var i = 0; i < jsonList.length; i++) {
        final Map<String, dynamic> json = jsonList[i];
        final int index = int.parse(json['path'].split('/').last);

        final String privateKey = json['private_key'];

        // if we want to include the private keys, only encrypt some of them
        final String? encryptedPrivateKey = includePrivKeys
            ? index % 2 == 0
                ? await encryptionService.encrypt(privateKey, password)
                : null
            : null;
        initialAddresses.add(Address(
          accountUuid: accountUuid,
          address: json['address'],
          index: index,
          encryptedPrivateKey: encryptedPrivateKey,
        ));

        addressToWIF[json['address']] = json['private_key'];
      }
      return (initialAddresses, addressToWIF);
    }

    tearDownAll(() async {
      await GetIt.instance<AddressRepository>().deleteAllAddresses();
      await GetIt.instance<AccountRepository>().deleteAllAccounts();
      await GetIt.instance<WalletRepository>().deleteAllWallets();
    });

    tearDown(() async {
      await GetIt.instance<AddressRepository>().deleteAllAddresses();
      await GetIt.instance<AccountRepository>().deleteAllAccounts();
      await GetIt.instance<WalletRepository>().deleteAllWallets();
    });

    testWidgets(
        'Updates addresses in an account with null encrypted private keys',
        (WidgetTester tester) async {
      print('starting test 1');
      await tester.pumpWidget(MyApp());
      const password = 'strongPassword123';
      final wallet = await setUpWallet(password);
      await setUpAccount(wallet.uuid, 0);
      final (initialAddresses, addressToWIF) = await getAddressesFixtures(
          'addresses_account_zero', 'account_0', password);
      await GetIt.instance<AddressRepository>().insertMany(initialAddresses);

      final addressesWithNullPrivateKeyBeforeUpdate =
          await GetIt.instance<AddressRepository>()
              .getAddressesWithNullPrivateKey();
      expect(addressesWithNullPrivateKeyBeforeUpdate.length, 70);

      print('starting batch update********************');
      final stopwatch = Stopwatch()..start();
      await batchUpdateAddressPksUseCase.populateEncryptedPrivateKeys(password);
      stopwatch.stop();
      print('Operation took: ${stopwatch.elapsed}');
      GetIt.instance<Logger>().info('Operation took: ${stopwatch.elapsed}');

      final addressesWithNullPrivateKeyAfterUpdate =
          await GetIt.instance<AddressRepository>()
              .getAddressesWithNullPrivateKey();
      expect(addressesWithNullPrivateKeyAfterUpdate.isEmpty, true);

      for (var i = 0; i < initialAddresses.length; i++) {
        final address = initialAddresses[i];
        final addressAfterUpdate = await GetIt.instance<AddressRepository>()
            .getAddress(address.address);
        expect(addressAfterUpdate!.encryptedPrivateKey!.isNotEmpty, true,
            reason:
                'Address ${address.address} has null encrypted private key');

        final decryptedPrivateKey = await encryptionService.decrypt(
            addressAfterUpdate.encryptedPrivateKey!, password);
        expect(decryptedPrivateKey, addressToWIF[address.address],
            reason:
                'Address ${address.address} has incorrect decrypted private key');
      }

      await tester.pumpAndSettle();
    });

    testWidgets(
        'Updates addresses in an account with partial encrypted private keys',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      const password = 'strongPassword123';
      final wallet = await setUpWallet(password);
      await setUpAccount(wallet.uuid, 0);
      await setUpAccount(wallet.uuid, 1);

      final (initialAddressesAccountZero, addressToWIFAccountZero) =
          await getAddressesFixtures(
              'addresses_account_zero', 'account_0', password,
              includePrivKeys: true);
      await GetIt.instance<AddressRepository>()
          .insertMany(initialAddressesAccountZero);

      final (initialAddressesAccountOne, addressToWIFAccountOne) =
          await getAddressesFixtures(
              'addresses_account_one', 'account_1', password,
              includePrivKeys: true);
      await GetIt.instance<AddressRepository>()
          .insertMany(initialAddressesAccountOne);

      final addressesWithNullPrivateKeyBeforeUpdate =
          await GetIt.instance<AddressRepository>()
              .getAddressesWithNullPrivateKey();
      expect(addressesWithNullPrivateKeyBeforeUpdate.length,
          60); // 35 from account zero + 25 from account one

      print('starting batch update********************');
      final stopwatch = Stopwatch()..start();
      await batchUpdateAddressPksUseCase.populateEncryptedPrivateKeys(password);
      stopwatch.stop();
      print('Operation took: ${stopwatch.elapsed}');
      GetIt.instance<Logger>().info('Operation took: ${stopwatch.elapsed}');

      final addressesAccountZeroWithNullPrivateKeyAfterUpdate =
          await GetIt.instance<AddressRepository>()
              .getAddressesWithNullPrivateKey();
      expect(addressesAccountZeroWithNullPrivateKeyAfterUpdate.isEmpty, true);

      for (var i = 0; i < addressesWithNullPrivateKeyBeforeUpdate.length; i++) {
        final address = addressesWithNullPrivateKeyBeforeUpdate[i];
        final addressAfterUpdate = await GetIt.instance<AddressRepository>()
            .getAddress(address.address);
        expect(addressAfterUpdate!.encryptedPrivateKey!.isNotEmpty, true,
            reason:
                'Address ${address.address} has null encrypted private key');

        final decryptedPrivateKey = await encryptionService.decrypt(
            addressAfterUpdate.encryptedPrivateKey!, password);
        if (address.accountUuid == 'account_0') {
          expect(decryptedPrivateKey, addressToWIFAccountZero[address.address],
              reason:
                  'Address ${address.address} has incorrect decrypted private key');
        } else {
          expect(decryptedPrivateKey, addressToWIFAccountOne[address.address],
              reason:
                  'Address ${address.address} has incorrect decrypted private key');
        }
      }

      await tester.pumpAndSettle();
    });
  });
}
