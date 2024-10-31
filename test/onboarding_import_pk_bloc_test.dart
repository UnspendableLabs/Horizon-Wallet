import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:horizon/presentation/screens/onboarding_import_pk/bloc/onboarding_import_pk_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_import_pk/bloc/onboarding_import_pk_event.dart';
import 'package:horizon/presentation/screens/onboarding_import_pk/bloc/onboarding_import_pk_state.dart';
import 'package:mocktail/mocktail.dart';

class MockMnemonicService extends Mock implements MnemonicService {}

class MockImportWalletUseCase extends Mock implements ImportWalletUseCase {}

class MockWalletService extends Mock implements WalletService {}

void main() {
  late MockMnemonicService mockMnemonicService;
  late MockWalletService mockWalletService;
  late MockImportWalletUseCase mockImportWalletUseCase;

  setUp(() {
    mockMnemonicService = MockMnemonicService();
    mockWalletService = MockWalletService();
    mockImportWalletUseCase = MockImportWalletUseCase();
    GetIt.I.registerSingleton<MnemonicService>(mockMnemonicService);
    GetIt.I.registerSingleton<WalletService>(mockWalletService);
    GetIt.I.registerSingleton<ImportWalletUseCase>(mockImportWalletUseCase);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('OnboardingImportPKBloc - ImportWallet', () {
    const privateKey = 'xprv';
    const password = 'testPassword';

    void setupMocksHorizon(Network network, String expectedCoinType) {
      when(() => mockImportWalletUseCase.call(
          password: any(named: 'password'),
          importFormat: ImportFormat.horizon,
          secret: any(named: 'secret'),
          deriveWallet: any(named: 'deriveWallet'),
          onError: any(named: 'onError'),
          onSuccess: any(named: 'onSuccess'))).thenAnswer((_) async {});
    }

    void setupMocksFreewallet(Network network, String expectedCoinType) {
      when(() => mockImportWalletUseCase.call(
          password: any(named: 'password'),
          importFormat: ImportFormat.freewallet,
          secret: any(named: 'secret'),
          deriveWallet: any(named: 'deriveWallet'),
          onError: any(named: 'onError'),
          onSuccess: any(named: 'onSuccess'))).thenAnswer((_) async {});
    }

    void setupMocksCounterwallet(Network network, String expectedCoinType) {
      when(() => mockImportWalletUseCase.call(
          password: any(named: 'password'),
          importFormat: ImportFormat.counterwallet,
          secret: any(named: 'secret'),
          deriveWallet: any(named: 'deriveWallet'),
          onError: any(named: 'onError'),
          onSuccess: any(named: 'onSuccess'))).thenAnswer((_) async {});
    }

    void runImportTest(String description, Network network,
        String expectedCoinType, ImportFormat importFormat) {
      blocTest<OnboardingImportPKBloc, OnboardingImportPKState>(
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
          return OnboardingImportPKBloc(
            walletService: mockWalletService,
            importWalletUseCase: mockImportWalletUseCase,
          );
        },
        seed: () => OnboardingImportPKState(
          importFormat: importFormat,
          pk: privateKey,
          importState: ImportStatePKCollected(),
        ),
        act: (bloc) => bloc.add(ImportWallet(password: password)),
        expect: () => [
          predicate<OnboardingImportPKState>(
            (state) =>
                state.pkError == null &&
                state.pk == privateKey &&
                state.importState is ImportStateLoading &&
                state.importFormat == importFormat,
          ),
          // Include this if simulating onSuccess or onError callbacks
          // predicate<OnboardingImportPKState>(
          //   (state) => state.importState is ImportStateSuccess,
          // ),
        ],
        verify: (_) async {
          switch (importFormat) {
            case ImportFormat.horizon:
              verify(() => mockImportWalletUseCase.call(
                  password: password,
                  secret: privateKey,
                  importFormat: importFormat,
                  deriveWallet: any(named: 'deriveWallet'),
                  onError: any(named: 'onError'),
                  onSuccess: any(named: 'onSuccess'))).called(1);

              break;
            case ImportFormat.freewallet:
              verify(() => mockImportWalletUseCase.call(
                  password: password,
                  secret: privateKey,
                  importFormat: importFormat,
                  deriveWallet: any(named: 'deriveWallet'),
                  onError: any(named: 'onError'),
                  onSuccess: any(named: 'onSuccess'))).called(1);
              break;
            case ImportFormat.counterwallet:
              verify(() => mockImportWalletUseCase.call(
                  password: password,
                  importFormat: importFormat,
                  secret: privateKey,
                  deriveWallet: any(named: 'deriveWallet'),
                  onError: any(named: 'onError'),
                  onSuccess: any(named: 'onSuccess'))).called(1);
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
