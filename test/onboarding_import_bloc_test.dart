import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';
import 'package:mocktail/mocktail.dart';

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
  late MockWalletService mockWalletService;
  late MockMnemonicService mockMnemonicService;
  late MockEncryptionService mockEncryptionService;
  late MockAddressService mockAddressService;
  late MockWalletRepository mockWalletRepository;
  late MockAccountRepository mockAccountRepository;
  late MockAddressRepository mockAddressRepository;
  late MockConfig mockConfig;

  setUpAll(() {
    registerFallbackValue(FakeWallet());
    registerFallbackValue(FakeAccount());
    registerFallbackValue(FakeAddress());
    registerFallbackValue(AddressType.bech32);
  });

  setUp(() {
    mockMnemonicService = MockMnemonicService();
    mockWalletService = MockWalletService();
    mockEncryptionService = MockEncryptionService();
    mockAddressService = MockAddressService();
    mockWalletRepository = MockWalletRepository();
    mockAccountRepository = MockAccountRepository();
    mockAddressRepository = MockAddressRepository();
    mockConfig = MockConfig();

    GetIt.I.registerSingleton<MnemonicService>(mockMnemonicService);
    GetIt.I.registerSingleton<WalletService>(mockWalletService);
    GetIt.I.registerSingleton<EncryptionService>(mockEncryptionService);
    GetIt.I.registerSingleton<AddressService>(mockAddressService);
    GetIt.I.registerSingleton<WalletRepository>(mockWalletRepository);
    GetIt.I.registerSingleton<AccountRepository>(mockAccountRepository);
    GetIt.I.registerSingleton<AddressRepository>(mockAddressRepository);
    GetIt.I.registerSingleton<Config>(mockConfig);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('OnboardingImportBloc - ImportWallet', () {
    const mnemonic = 'test mnemonic phrase for import';
    const password = 'testPassword';
    const wallet = Wallet(
        name: "Imported Wallet",
        uuid: 'import-wallet-uuid',
        publicKey: "imported-public-key",
        encryptedPrivKey: 'encrypted',
        chainCodeHex: 'chainCode');
    const decryptedPrivKey = 'decrypted-private-key';

    void setupMocksHorizon(Network network, String expectedCoinType) {
      when(() => mockConfig.network).thenReturn(network);
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
              index: any(named: 'index')))
          .thenAnswer((_) async => const Address(
              index: 0, address: "0xdeadbeef", accountUuid: 'account-uuid'));
      when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAddressRepository.insert(any())).thenAnswer((_) async {});
    }

    void setupMocksFreewallet(Network network, String expectedCoinType) {
      when(() => mockConfig.network).thenReturn(network);
      when(() => mockWalletService.deriveRootFreewallet(any(), any()))
          .thenAnswer((_) async => wallet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);
      when(() => mockAddressService.deriveAddressFreewalletRange(
              type: any(named: 'type'),
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              // purpose: any(named: 'purpose'),
              // coin: any(named: 'coin'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end')))
          .thenAnswer((_) async => List.generate(
              10,
              (i) => Address(
                  index: i,
                  address: "0xdeadbeef$i",
                  accountUuid: 'account-uuid')));
      when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAddressRepository.insertMany(any()))
          .thenAnswer((_) async {});
    }

    void setupMocksCounterwallet(Network network, String expectedCoinType) {
      when(() => mockConfig.network).thenReturn(network);
      when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
          .thenAnswer((_) async => wallet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);
      when(() => mockAddressService.deriveAddressFreewalletRange(
              type: any(named: 'type'),
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              // purpose: any(named: 'purpose'),
              // coin: any(named: 'coin'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end')))
          .thenAnswer((_) async => [
                const Address(
                    index: 0,
                    address: "0xdeadbeef",
                    accountUuid: 'account-uuid')
              ]);
      when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAddressRepository.insertMany(any()))
          .thenAnswer((_) async {});
    }

    void runImportTest(String description, Network network,
        String expectedCoinType, ImportFormat importFormat) {
      blocTest<OnboardingImportBloc, OnboardingImportState>(
        description,
        build: () {
          switch (importFormat) {
            case ImportFormat.horizon:
              setupMocksHorizon(network, expectedCoinType);
              break;
            case ImportFormat.freewallet:
              setupMocksFreewallet(network, expectedCoinType);
              break;
            case ImportFormat.counterwallet:
              setupMocksCounterwallet(network, expectedCoinType);
              break;
          }
          return OnboardingImportBloc(
            config: mockConfig,
            accountRepository: mockAccountRepository,
            addressRepository: mockAddressRepository,
            walletRepository: mockWalletRepository,
            walletService: mockWalletService,
            addressService: mockAddressService,
            mnemonicService: mockMnemonicService,
            encryptionService: mockEncryptionService,
          );
        },
        seed: () => OnboardingImportState(
            importFormat: importFormat, mnemonic: mnemonic),
        act: (bloc) => bloc.add(ImportWallet(password: password)),
        expect: () => [
          predicate<OnboardingImportState>(
              (state) => state.importState is ImportStateLoading),
          predicate<OnboardingImportState>(
              (state) => state.importState is ImportStateSuccess),
        ],
        verify: (_) async {
          switch (importFormat) {
            case ImportFormat.horizon:
              verify(() => mockWalletService.deriveRoot(mnemonic, password))
                  .called(1);
              verify(() => mockEncryptionService.decrypt(any(), password))
                  .called(1);
              verify(() => mockAddressService.deriveAddressSegwit(
                  privKey: any(named: 'privKey'),
                  chainCodeHex: any(named: 'chainCodeHex'),
                  accountUuid: any(named: 'accountUuid'),
                  purpose: '84\'',
                  coin: expectedCoinType,
                  account: '0\'',
                  change: '0',
                  index: any(named: 'index'))).called(1);
              verify(() => mockWalletRepository.insert(any())).called(1);
              verify(() => mockAccountRepository.insert(any())).called(1);
              verify(() => mockAddressRepository.insert(any())).called(1);
              break;
            case ImportFormat.freewallet:
              verify(() => mockWalletService.deriveRootFreewallet(
                  mnemonic, password)).called(1);
              verify(() => mockEncryptionService.decrypt(any(), password))
                  .called(1);
              verify(() => mockAddressService.deriveAddressFreewalletRange(
                  type: AddressType.bech32,
                  privKey: any(named: 'privKey'),
                  chainCodeHex: any(named: 'chainCodeHex'),
                  accountUuid: any(named: 'accountUuid'),
                  // purpose: '32',
                  // coin: expectedCoinType,
                  account: '0\'',
                  change: '0',
                  start: 0,
                  end: 9)).called(1);
              verify(() => mockAddressService.deriveAddressFreewalletRange(
                  type: AddressType.legacy,
                  privKey: decryptedPrivKey,
                  chainCodeHex: wallet.chainCodeHex,
                  accountUuid: any(named: 'accountUuid'),
                  // purpose: '32',
                  // coin: expectedCoinType,
                  account: '0\'',
                  change: '0',
                  start: 0,
                  end: 9)).called(1);
              verify(() => mockWalletRepository.insert(any())).called(1);
              verify(() => mockAccountRepository.insert(any())).called(1);
              verify(() => mockAddressRepository.insertMany(any())).called(2);
              break;
            case ImportFormat.counterwallet:
              verify(() => mockWalletService.deriveRootCounterwallet(
                  mnemonic, password)).called(1);
              verify(() => mockEncryptionService.decrypt(any(), password))
                  .called(1);
              verify(() => mockAddressService.deriveAddressFreewalletRange(
                  type: AddressType.bech32,
                  privKey: any(named: 'privKey'),
                  chainCodeHex: any(named: 'chainCodeHex'),
                  accountUuid: any(named: 'accountUuid'),
                  // purpose: '32',
                  // coin: expectedCoinType,
                  account: '0\'',
                  change: '0',
                  start: 0,
                  end: 9)).called(1);
              verify(() => mockAddressService.deriveAddressFreewalletRange(
                  type: AddressType.legacy,
                  privKey: any(named: 'privKey'),
                  chainCodeHex: wallet.chainCodeHex,
                  accountUuid: any(named: 'accountUuid'),
                  // purpose: '0\'',
                  // coin: expectedCoinType,
                  account: '0\'',
                  change: '0',
                  start: 0,
                  end: 9)).called(1);
              verify(() => mockWalletRepository.insert(any())).called(1);
              verify(() => mockAccountRepository.insert(any())).called(1);
              verify(() => mockAddressRepository.insertMany(any())).called(2);
              break;
          }
        },
      );
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
}
