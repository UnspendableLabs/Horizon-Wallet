import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/wallet.dart';

class MockWalletService extends Mock implements WalletService {}

class MockMnemonicService extends Mock implements MnemonicService {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockAddressService extends Mock implements AddressService {}

class MockWalletRepository extends Mock implements WalletRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockConfig extends Mock implements Config {}

// Fake classes for fallback values
class FakeWallet extends Fake implements Wallet {}

class FakeAccount extends Fake implements Account {}

class FakeAddress extends Fake implements Address {}

void main() {
  late ImportWalletUseCase importWalletUseCase;
  late MockAddressRepository mockAddressRepository;
  late MockAccountRepository mockAccountRepository;
  late MockWalletRepository mockWalletRepository;
  late MockEncryptionService mockEncryptionService;
  late MockAddressService mockAddressService;

  late MockConfig mockConfig;
  late MockWalletService mockWalletService;
  setUpAll(() {
    registerFallbackValue(FakeAccount());
    registerFallbackValue(FakeAddress());
    registerFallbackValue(FakeWallet());
    registerFallbackValue(AddressType.bech32);
    registerFallbackValue(AddressType.legacy);
  });

  setUp(() {
    mockAddressRepository = MockAddressRepository();
    mockAccountRepository = MockAccountRepository();
    mockWalletRepository = MockWalletRepository();
    mockEncryptionService = MockEncryptionService();
    mockAddressService = MockAddressService();
    mockConfig = MockConfig();
    mockWalletService = MockWalletService();

    importWalletUseCase = ImportWalletUseCase(
      addressRepository: mockAddressRepository,
      accountRepository: mockAccountRepository,
      walletRepository: mockWalletRepository,
      encryptionService: mockEncryptionService,
      addressService: mockAddressService,
      config: mockConfig,
    );
  });

  group('ImportWalletUseCase call', () {
    void runImportTest(String description, Network network,
        String expectedCoinType, ImportFormat importFormat) {
      test(description, () async {
        // Setup
        const mnemonic = 'test mnemonic phrase for import';
        const password = 'testPassword';
        const wallet = Wallet(
            name: "Imported Wallet",
            uuid: 'import-wallet-uuid',
            publicKey: "imported-public-key",
            encryptedPrivKey: 'encrypted',
            chainCodeHex: 'chainCode');
        const decryptedPrivKey = 'decrypted-private-key';

        when(() => mockConfig.network).thenReturn(network);
        when(() => mockWalletService.deriveRoot(any(), any()))
            .thenAnswer((_) async => wallet);
        when(() => mockWalletService.deriveRootFreewallet(any(), any()))
            .thenAnswer((_) async => wallet);
        when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
            .thenAnswer((_) async => wallet);
        when(() => mockEncryptionService.decrypt(any(), any()))
            .thenAnswer((_) async => decryptedPrivKey);
        when(() => mockAddressService.deriveAddressSegwit(
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                purpose: any(named: 'purpose'),
                coin: any(named: 'coin'),
                account: any(named: 'account'),
                change: any(named: 'change'),
                index: any(named: 'index'),
                password: any(named: 'password')))
            .thenAnswer((_) async => const Address(
                index: 0, address: "0xdeadbeef", accountUuid: 'account-uuid'));

        when(() => mockAddressService.deriveAddressFreewalletRange(
                type: AddressType.bech32,
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                account: any(named: 'account'),
                change: any(named: 'change'),
                start: any(named: 'start'),
                end: any(named: 'end'),
                password: any(named: 'password')))
            .thenAnswer((_) async => [
                  const Address(
                      index: 0, address: "bc1q...", accountUuid: 'account-uuid')
                ]);
        when(() => mockAddressService.deriveAddressFreewalletRange(
                type: AddressType.legacy,
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                account: any(named: 'account'),
                change: any(named: 'change'),
                start: any(named: 'start'),
                end: any(named: 'end'),
                password: any(named: 'password')))
            .thenAnswer((_) async => [
                  const Address(
                      index: 1, address: "1M...", accountUuid: 'account-uuid')
                ]);
        when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
        when(() => mockAccountRepository.insert(any()))
            .thenAnswer((_) async {});
        when(() => mockAddressRepository.insert(any()))
            .thenAnswer((_) async {});
        when(() => mockAddressRepository.insertMany(any()))
            .thenAnswer((_) async {});

        bool successCallbackInvoked = false;
        bool errorCallbackInvoked = false;
        // Act
        await importWalletUseCase.call(
          password: password,
          importFormat: importFormat,
          secret: mnemonic,
          onError: (error) {
            errorCallbackInvoked = true;
          },
          deriveWallet: (secret, password) => switch (importFormat) {
            ImportFormat.horizon =>
              mockWalletService.deriveRoot(secret, password),
            ImportFormat.freewallet =>
              mockWalletService.deriveRootFreewallet(secret, password),
            ImportFormat.counterwallet =>
              mockWalletService.deriveRootCounterwallet(secret, password),
          },
          onSuccess: () {
            successCallbackInvoked = true;
          },
        );

        verify(() => mockEncryptionService.decrypt(
            wallet.encryptedPrivKey, password)).called(1);
        switch (importFormat) {
          case ImportFormat.horizon:
            verify(() => mockWalletService.deriveRoot(any(), any())).called(1);

            verify(() => mockAddressService.deriveAddressSegwit(
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                purpose: '84\'',
                coin: expectedCoinType,
                account: '0\'',
                change: '0',
                index: any(named: 'index'),
                password: any(named: 'password'))).called(1);
            verify(() => mockWalletRepository.insert(any())).called(1);
            verify(() => mockAccountRepository.insert(any())).called(1);
            verify(() => mockAddressRepository.insert(any())).called(1);
            expect(successCallbackInvoked, true);
            expect(errorCallbackInvoked, false);
            break;
          case ImportFormat.freewallet:
            verify(() => mockWalletService.deriveRootFreewallet(any(), any()))
                .called(1);
            verify(() => mockAddressService.deriveAddressFreewalletRange(
                type: AddressType.bech32,
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                account: any(named: 'account'),
                change: any(named: 'change'),
                start: any(named: 'start'),
                end: any(named: 'end'),
                password: any(named: 'password'))).called(1);
            verify(() => mockAddressService.deriveAddressFreewalletRange(
                type: AddressType.legacy,
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                account: any(named: 'account'),
                change: any(named: 'change'),
                start: any(named: 'start'),
                end: any(named: 'end'),
                password: any(named: 'password'))).called(1);
            verify(() => mockWalletRepository.insert(any())).called(1);
            verify(() => mockAccountRepository.insert(any())).called(1);
            verify(() => mockAddressRepository.insertMany(any())).called(2);
            expect(successCallbackInvoked, true);
            expect(errorCallbackInvoked, false);
            break;
          case ImportFormat.counterwallet:
            verify(() =>
                    mockWalletService.deriveRootCounterwallet(any(), any()))
                .called(1);
            verify(() => mockAddressService.deriveAddressFreewalletRange(
                type: AddressType.bech32,
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                account: any(named: 'account'),
                change: any(named: 'change'),
                start: any(named: 'start'),
                end: any(named: 'end'),
                password: any(named: 'password'))).called(1);
            verify(() => mockAddressService.deriveAddressFreewalletRange(
                type: AddressType.legacy,
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                account: any(named: 'account'),
                change: any(named: 'change'),
                start: any(named: 'start'),
                end: any(named: 'end'),
                password: any(named: 'password'))).called(1);
            verify(() => mockWalletRepository.insert(any())).called(1);
            verify(() => mockAccountRepository.insert(any())).called(1);
            verify(() => mockAddressRepository.insertMany(any())).called(2);
            expect(successCallbackInvoked, true);
            expect(errorCallbackInvoked, false);
            break;
        }
      });

      test('error callback is invoked when an error occurs: $importFormat',
          () async {
        // Setup
        const mnemonic = 'test mnemonic phrase for import';
        const password = 'testPassword';
        when(() => mockWalletService.deriveRoot(any(), any()))
            .thenThrow(Exception('error'));
        when(() => mockWalletService.deriveRootFreewallet(any(), any()))
            .thenThrow(Exception('error'));
        when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
            .thenThrow(Exception('error'));

        bool errorCallbackInvoked = false;
        bool successCallbackInvoked = false;

        // Act
        await importWalletUseCase.call(
          password: password,
          importFormat: importFormat,
          secret: mnemonic,
          onError: (error) {
            errorCallbackInvoked = true;
          },
          deriveWallet: (secret, password) => switch (importFormat) {
            ImportFormat.horizon =>
              mockWalletService.deriveRoot(secret, password),
            ImportFormat.freewallet =>
              mockWalletService.deriveRootFreewallet(secret, password),
            ImportFormat.counterwallet =>
              mockWalletService.deriveRootCounterwallet(secret, password),
          },
          onSuccess: () {
            successCallbackInvoked = true;
          },
        );

        switch (importFormat) {
          case ImportFormat.horizon:
            verify(() => mockWalletService.deriveRoot(any(), any())).called(1);
            break;
          case ImportFormat.freewallet:
            verify(() => mockWalletService.deriveRootFreewallet(any(), any()))
                .called(1);
            break;
          case ImportFormat.counterwallet:
            verify(() =>
                    mockWalletService.deriveRootCounterwallet(any(), any()))
                .called(1);
            break;
        }

        // Assert
        expect(errorCallbackInvoked, true);
        expect(successCallbackInvoked, false);
      });
    }

    // Tests for Horizon format
    runImportTest(
        'emits correct states when importing wallet for mainnet using Horizon format',
        Network.mainnet,
        "0'",
        ImportFormat.horizon);
    runImportTest(
        'emits correct states when importing wallet for testnet using Horizon format',
        Network.testnet,
        "1'",
        ImportFormat.horizon);
    runImportTest(
        'emits correct states when importing wallet for regtest using Horizon format',
        Network.regtest,
        "1'",
        ImportFormat.horizon);
    //
    // // Tests for Freewallet format
    runImportTest(
        'emits correct states when importing wallet for mainnet using Freewallet format',
        Network.mainnet,
        "0",
        ImportFormat.freewallet);

    runImportTest(
        'emits correct states when importing wallet for testnet using Freewallet format',
        Network.testnet,
        '1',
        ImportFormat.freewallet);

    runImportTest(
        'emits correct states when importing wallet for regtest using Freewallet format',
        Network.regtest,
        '1',
        ImportFormat.freewallet);

    runImportTest(
        'emits correct states when importing wallet for mainnet using Counterwallet format',
        Network.mainnet,
        '0',
        ImportFormat.counterwallet);

    runImportTest(
        'emits correct states when importing wallet for testnet using Counterwallet format',
        Network.testnet,
        '1',
        ImportFormat.counterwallet);
    runImportTest(
        'emits correct states when importing wallet for regtest using Counterwallet format',
        Network.regtest,
        '1',
        ImportFormat.counterwallet);
  });

  group('ImportWalletUseCase callHorizon', () {
    test(
        'emits correct states when importing wallet for mainnet using Horizon format',
        () async {
      // Setup
      const mnemonic = 'test mnemonic phrase for import';
      const password = 'testPassword';
      const wallet = Wallet(
          name: "Imported Wallet",
          uuid: 'import-wallet-uuid',
          publicKey: "imported-public-key",
          encryptedPrivKey: 'encrypted',
          chainCodeHex: 'chainCode');
      const decryptedPrivKey = 'decrypted-private-key';

      when(() => mockConfig.network).thenReturn(Network.mainnet);
      when(() => mockWalletService.deriveRoot(any(), any()))
          .thenAnswer((_) async => wallet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);
      when(() => mockAddressService.deriveAddressSegwit(
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              purpose: any(named: 'purpose'),
              coin: any(named: 'coin'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              index: any(named: 'index'),
              password: any(named: 'password')))
          .thenAnswer((_) async => const Address(
              index: 0, address: "0xdeadbeef", accountUuid: 'account-uuid'));
      when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAddressRepository.insert(any())).thenAnswer((_) async {});

      // Act
      await importWalletUseCase.callHorizon(
        password: password,
        secret: mnemonic,
        deriveWallet: (secret, password) =>
            mockWalletService.deriveRoot(secret, password),
      );

      verify(() => mockWalletService.deriveRoot(any(), any())).called(1);

      verify(() => mockAddressService.deriveAddressSegwit(
          privKey: any(named: 'privKey'),
          chainCodeHex: any(named: 'chainCodeHex'),
          accountUuid: any(named: 'accountUuid'),
          purpose: '84\'',
          coin: '0\'',
          account: '0\'',
          change: '0',
          index: any(named: 'index'),
          password: any(named: 'password'))).called(1);
      verify(() => mockWalletRepository.insert(any())).called(1);
      verify(() => mockAccountRepository.insert(any())).called(1);
      verify(() => mockAddressRepository.insert(any())).called(1);
    });
  });
}
