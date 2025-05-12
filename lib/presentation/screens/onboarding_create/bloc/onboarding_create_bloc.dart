import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:logger/logger.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/http_config.dart';

// TODO: set_mnemonic_usecase is a dumb name
import 'package:horizon/presentation/common/usecase/set_mnemonic_usecase.dart';
import 'package:horizon/domain/repositories/account_v2_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import "package:horizon/domain/entities/base_path.dart";
import "package:horizon/domain/entities/wallet_config.dart";
import "package:horizon/domain/entities/network.dart";
import "package:horizon/domain/entities/seed_derivation.dart";
import 'package:horizon/domain/repositories/settings_repository.dart';

class OnboardingCreateBloc
    extends Bloc<OnboardingCreateEvent, OnboardingCreateState> {
  final Logger logger = Logger();

  final SetMnemonicUseCase _setMnemonicUseCase;
  final WalletService walletService;
  final MnemonicService mnmonicService;
  final AccountV2Repository _accountV2Repository;
  final WalletConfigRepository _walletConfigRepository;
  final SettingsRepository _settingsRepository;
  final HttpConfig httpConfig;

  OnboardingCreateBloc({
    required this.mnmonicService,
    required this.walletService,
    required this.httpConfig,
    AccountV2Repository? accountV2Repository,
    SettingsRepository? settingsRepository,
    WalletConfigRepository? walletConfigRepository,
    SetMnemonicUseCase? setMnemonicUseCase,
  })  : _setMnemonicUseCase =
            setMnemonicUseCase ?? GetIt.I<SetMnemonicUseCase>(),
        _accountV2Repository =
            accountV2Repository ?? GetIt.I<AccountV2Repository>(),
        _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _settingsRepository = GetIt.I<SettingsRepository>(),
        super(const OnboardingCreateState()) {
    on<WalletCreated>((event, emit) async {
      logger.d('Processing WalletCreated event');
      emit(state.copyWith(createState: const CreateState.loading()));
      final password = event.password;
      try {
        final mnemonic = state.createMnemonicState.maybeWhen(
          success: (mnemonic) => mnemonic,
          orElse: () => '',
        );

        await _setMnemonicUseCase.call(
          mnemonic: mnemonic,
          password: password,
        );

        WalletConfig walletConfig = await _walletConfigRepository.findOrCreate(
          basePath: BasePath.horizon,
          network: Network.mainnet,
          seedDerivation: SeedDerivation.bip39MnemonicToSeed,
        );

        await _settingsRepository.setWalletConfigID(walletConfig.uuid);

        emit(state.copyWith(createState: const CreateState.success()));
      } catch (e) {
        logger.e({'message': 'Failed to create wallet'});
        emit(state.copyWith(
            createState: CreateState.error(message: e.toString())));
      }
    });

    on<MnemonicGenerated>((event, emit) {
      emit(state.copyWith(
          createMnemonicState: const CreateMnemonicState.loading()));

      try {
        String mnemonic = mnmonicService.generateMnemonic();

        emit(state.copyWith(
            createMnemonicState:
                CreateMnemonicState.success(mnemonic: mnemonic)));
      } catch (e) {
        emit(state.copyWith(
            createMnemonicState:
                CreateMnemonicState.error(message: e.toString())));
      }
    });

    on<MnemonicCreated>((event, emit) {
      final mnemonic = state.createMnemonicState.maybeWhen(
        success: (mnemonic) => mnemonic,
        orElse: () => '',
      );
      emit(state.copyWith(
          createMnemonicState: CreateMnemonicState.success(mnemonic: mnemonic),
          currentStep: OnboardingCreateStep.confirmMnemonic));
    });

    on<MnemonicConfirmedChanged>((event, emit) {
      final mnemonic = state.createMnemonicState.maybeWhen(
        success: (mnemonic) => mnemonic,
        orElse: () => '',
      );

      // Split both mnemonics into word arrays
      final correctWords = mnemonic.split(' ');
      final inputWords =
          event.mnemonic.split(' ').where((w) => w.isNotEmpty).toList();

      List<int> incorrectIndexes = [];

      // Check each position 0-11
      for (int i = 0; i < 12; i++) {
        // If this position is beyond input words or word doesn't match, mark as incorrect
        if (i >= inputWords.length ||
            (i < inputWords.length && correctWords[i] != inputWords[i])) {
          incorrectIndexes.add(i);
        }
      }

      // Only emit error state if there are incorrect indices
      if (incorrectIndexes.isNotEmpty) {
        emit(state.copyWith(
            mnemonicError: MnemonicErrorState(
                message: 'Seed phrase does not match',
                incorrectIndexes: incorrectIndexes)));
      } else {
        emit(state.copyWith(mnemonicError: null));
      }
    });

    on<MnemonicConfirmed>((event, emit) {
      final mnemonic = state.createMnemonicState.maybeWhen(
        success: (mnemonic) => mnemonic,
        orElse: () => '',
      );
      if (event.mnemonic.isEmpty) {
        emit(state.copyWith(
            mnemonicError: MnemonicErrorState(
                message: 'Seed phrase is required', incorrectIndexes: [])));
        return;
      }
      if (mnemonic != event.mnemonic.join(' ')) {
        List<int> incorrectIndexes = [];
        for (int i = 0; i < 12; i++) {
          if (mnemonic.split(' ')[i] != event.mnemonic[i]) {
            incorrectIndexes.add(i);
          }
        }
        emit(state.copyWith(
            mnemonicError: MnemonicErrorState(
                message: 'Seed phrase does not match',
                incorrectIndexes: incorrectIndexes)));
      } else {
        emit(state.copyWith(
            mnemonicError: null,
            currentStep: OnboardingCreateStep.createPassword));
      }
    });

    on<MnemonicBackPressed>((event, emit) {
      emit(state.copyWith(
          mnemonicError: null, currentStep: OnboardingCreateStep.showMnemonic));
    });

    on<ConfirmMnemonicBackPressed>((event, emit) {
      emit(state.copyWith(
          mnemonicError: null,
          currentStep: OnboardingCreateStep.confirmMnemonic));
    });
  }
}
