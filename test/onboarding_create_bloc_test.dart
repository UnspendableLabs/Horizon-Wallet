import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletService extends Mock implements WalletService {}

class MockMnemonicService extends Mock implements MnemonicService {}

class MockImportWalletUseCase extends Mock implements ImportWalletUseCase {}

// Fake classes for fallback values
class FakeWallet extends Fake implements Wallet {}

class FakeAccount extends Fake implements Account {}

class FakeAddress extends Fake implements Address {}

void main() {
  late MockWalletService mockWalletService;
  late MockMnemonicService mockMnemonicService;
  late MockImportWalletUseCase mockImportWalletUseCase;

  setUpAll(() {
    registerFallbackValue(FakeWallet());
    registerFallbackValue(FakeAccount());
    registerFallbackValue(FakeAddress());
  });

  setUp(() {
    mockMnemonicService = MockMnemonicService();
    mockWalletService = MockWalletService();
    mockImportWalletUseCase = MockImportWalletUseCase();

    // Register mocks with GetIt
    // Register mocks with GetIt

    GetIt.I.registerSingleton<MnemonicService>(mockMnemonicService);
    GetIt.I.registerSingleton<WalletService>(mockWalletService);
    GetIt.I.registerSingleton<ImportWalletUseCase>(mockImportWalletUseCase);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('OnboardingCreateBloc - WalletCreated', () {
    const mnemonic = 'test mnemonic';
    const password = 'testPassword';

    void setupMocks(Network network, String expectedCoinType) {
      when(() => mockImportWalletUseCase.callHorizon(
            mnemonic: any(named: 'mnemonic'),
            password: any(named: 'password'),
            deriveWallet: any(named: 'deriveWallet'),
          )).thenAnswer((_) async {});
    }

    blocTest<OnboardingCreateBloc, OnboardingCreateState>(
      'emits correct states when creating wallet for mainnet',
      build: () {
        setupMocks(Network.mainnet, '0');
        return OnboardingCreateBloc(
          mnmonicService: mockMnemonicService,
          walletService: mockWalletService,
          importWalletUseCase: mockImportWalletUseCase,
        );
      },
      seed: () => const OnboardingCreateState(
        createMnemonicState: CreateMnemonicState.success(mnemonic: mnemonic),
      ),
      act: (bloc) => bloc.add(WalletCreated(password: password)),
      expect: () => [
        predicate<OnboardingCreateState>(
          (state) => state.createState is CreateStateLoading,
        ),
        predicate<OnboardingCreateState>(
          (state) => state.createState is CreateStateSuccess,
        ),
      ],
      verify: (_) {
        verify(() => mockImportWalletUseCase.callHorizon(
              mnemonic: any(named: 'mnemonic'),
              password: any(named: 'password'),
              deriveWallet: any(named: 'deriveWallet'),
            )).called(1);
      },
    );

    blocTest<OnboardingCreateBloc, OnboardingCreateState>(
      'emits correct states when creating wallet for testnet',
      build: () {
        setupMocks(Network.testnet, '1');
        return OnboardingCreateBloc(
          mnmonicService: mockMnemonicService,
          walletService: mockWalletService,
          importWalletUseCase: mockImportWalletUseCase,
        );
      },
      seed: () => const OnboardingCreateState(
        createMnemonicState: CreateMnemonicState.success(mnemonic: mnemonic),
      ),
      act: (bloc) => bloc.add(WalletCreated(password: password)),
      expect: () => [
        predicate<OnboardingCreateState>(
          (state) => state.createState is CreateStateLoading,
        ),
        predicate<OnboardingCreateState>(
          (state) => state.createState is CreateStateSuccess,
        ),
      ],
      verify: (_) {
        verify(() => mockImportWalletUseCase.callHorizon(
              mnemonic: any(named: 'mnemonic'),
              password: any(named: 'password'),
              deriveWallet: any(named: 'deriveWallet'),
            )).called(1);
      },
    );

    blocTest<OnboardingCreateBloc, OnboardingCreateState>(
      'emits correct states when creating wallet for regtest',
      build: () {
        setupMocks(Network.regtest, '1');
        return OnboardingCreateBloc(
          mnmonicService: mockMnemonicService,
          walletService: mockWalletService,
          importWalletUseCase: mockImportWalletUseCase,
        );
      },
      seed: () => const OnboardingCreateState(
        createMnemonicState: CreateMnemonicState.success(mnemonic: mnemonic),
      ),
      act: (bloc) => bloc.add(WalletCreated(password: password)),
      expect: () => [
        predicate<OnboardingCreateState>(
          (state) => state.createState is CreateStateLoading,
        ),
        predicate<OnboardingCreateState>(
          (state) => state.createState is CreateStateSuccess,
        ),
      ],
      verify: (_) {
        verify(() => mockImportWalletUseCase.callHorizon(
              mnemonic: any(named: 'mnemonic'),
              password: any(named: 'password'),
              deriveWallet: any(named: 'deriveWallet'),
            )).called(1);
      },
    );
    blocTest<OnboardingCreateBloc, OnboardingCreateState>(
      'emits error states when creating wallet fails',
      build: () {
        when(() => mockImportWalletUseCase.callHorizon(
              mnemonic: any(named: 'mnemonic'),
              password: any(named: 'password'),
              deriveWallet: any(named: 'deriveWallet'),
            )).thenThrow(Exception('Failed to create wallet'));
        return OnboardingCreateBloc(
          mnmonicService: mockMnemonicService,
          walletService: mockWalletService,
          importWalletUseCase: mockImportWalletUseCase,
        );
      },
      seed: () => const OnboardingCreateState(
        createMnemonicState: CreateMnemonicState.success(mnemonic: mnemonic),
      ),
      act: (bloc) => bloc.add(WalletCreated(password: password)),
      expect: () => [
        predicate<OnboardingCreateState>(
          (state) => state.createState is CreateStateLoading,
        ),
        predicate<OnboardingCreateState>(
          (state) => state.createState is CreateStateError,
        ),
      ],
      verify: (_) {
        verify(() => mockImportWalletUseCase.callHorizon(
              mnemonic: any(named: 'mnemonic'),
              password: any(named: 'password'),
              deriveWallet: any(named: 'deriveWallet'),
            )).called(1);
      },
    );
  });
}
