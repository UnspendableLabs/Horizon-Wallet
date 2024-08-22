import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/common/constants.dart';

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

    // Register mocks with GetIt
    // Register mocks with GetIt

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

  group('OnboardingCreateBloc - CreateWallet', () {
    const mnemonic = 'test mnemonic';
    const password = 'testPassword';
    const wallet = Wallet(
        name: "Wallet #1",
        uuid: 'wallet-uuid',
        publicKey: "public-key",
        encryptedPrivKey: 'encrypted',
        chainCodeHex: 'chainCode');
    const decryptedPrivKey = 'decrypted-private-key';

    void setupMocks(Network network, String expectedCoinType) {
      final account = Account(
          name: 'Account 0',
          walletUuid: wallet.uuid,
          purpose: '84\'',
          coinType: '$expectedCoinType\'',
          accountIndex: '0\'',
          uuid: 'account-uuid',
          importFormat: ImportFormat.horizon);
      final address =
          Address(index: 0, address: "0xdeadbeef", accountUuid: account.uuid);

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
          index: any(named: 'index'))).thenAnswer((_) async => address);
      when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAddressRepository.insert(any())).thenAnswer((_) async {});
    }

    blocTest<OnboardingCreateBloc, OnboardingCreateState>(
      'emits correct states when creating wallet for mainnet',
      build: () {
        setupMocks(Network.mainnet, '0');
        return OnboardingCreateBloc();
      },
      seed: () => OnboardingCreateState(
        mnemonicState: GenerateMnemonicStateGenerated(mnemonic: mnemonic),
        password: password,
      ),
      act: (bloc) => bloc.add(CreateWallet()),
      expect: () => [
        predicate<OnboardingCreateState>(
            (state) => state.createState is CreateStateLoading),
        predicate<OnboardingCreateState>(
            (state) => state.createState is CreateStateSuccess),
      ],
      verify: (_) {
        verify(() => mockWalletService.deriveRoot(mnemonic, password))
            .called(1);
        verify(() => mockEncryptionService.decrypt(
            wallet.encryptedPrivKey, password)).called(1);
        verify(() => mockAddressService.deriveAddressSegwit(
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: any(named: 'accountUuid'),
            purpose: '84\'',
            coin: '0\'',
            account: '0\'',
            change: '0',
            index: 0)).called(1);
        verify(() => mockWalletRepository.insert(any())).called(1);
        verify(() => mockAccountRepository.insert(any())).called(1);
        verify(() => mockAddressRepository.insert(any())).called(1);
      },
    );

    blocTest<OnboardingCreateBloc, OnboardingCreateState>(
      'emits correct states when creating wallet for testnet',
      build: () {
        setupMocks(Network.testnet, '1');
        return OnboardingCreateBloc();
      },
      seed: () => OnboardingCreateState(
        mnemonicState: GenerateMnemonicStateGenerated(mnemonic: mnemonic),
        password: password,
      ),
      act: (bloc) => bloc.add(CreateWallet()),
      expect: () => [
        predicate<OnboardingCreateState>(
            (state) => state.createState is CreateStateLoading),
        predicate<OnboardingCreateState>(
            (state) => state.createState is CreateStateSuccess),
      ],
      verify: (_) {
        verify(() => mockAddressService.deriveAddressSegwit(
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: any(named: 'accountUuid'),
            purpose: '84\'',
            coin: '1\'',
            account: '0\'',
            change: '0',
            index: 0)).called(1);
      },
    );

    blocTest<OnboardingCreateBloc, OnboardingCreateState>(
      'emits correct states when creating wallet for regtest',
      build: () {
        setupMocks(Network.regtest, '1');
        return OnboardingCreateBloc();
      },
      seed: () => OnboardingCreateState(
        mnemonicState: GenerateMnemonicStateGenerated(mnemonic: mnemonic),
        password: password,
      ),
      act: (bloc) => bloc.add(CreateWallet()),
      expect: () => [
        predicate<OnboardingCreateState>(
            (state) => state.createState is CreateStateLoading),
        predicate<OnboardingCreateState>(
            (state) => state.createState is CreateStateSuccess),
      ],
      verify: (_) {
        verify(() => mockAddressService.deriveAddressSegwit(
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: any(named: 'accountUuid'),
            purpose: '84\'',
            coin: '1\'',
            account: '0\'',
            change: '0',
            index: 0)).called(1);
      },
    );
  });
}
