import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:logger/logger.dart';

class OnboardingCreateBloc
    extends Bloc<OnboardingCreateEvent, OnboardingCreateState> {
  final Logger logger = Logger();

  final MnemonicService mnmonicService;
  final WalletService walletService;
  final ImportWalletUseCase importWalletUseCase;

  OnboardingCreateBloc({
    required this.mnmonicService,
    required this.walletService,
    required this.importWalletUseCase,
  }) : super(const OnboardingCreateState()) {
    on<WalletCreated>((event, emit) async {
      logger.d('Processing WalletCreated event');
      emit(state.copyWith(createState: const CreateState.loading()));
      final password = event.password;
      try {
        final mnemonic = state.createMnemonicState.maybeWhen(
          success: (mnemonic) => mnemonic,
          orElse: () => '',
        );
        await importWalletUseCase.callHorizon(
          mnemonic: mnemonic,
          password: password,
          deriveWallet: (secret, password) =>
              walletService.deriveRoot(secret, password),
        );

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
      if (mnemonic != event.mnemonic) {
        List<int> incorrectIndexes = [];
        for (int i = 0; i < 12; i++) {
          if (mnemonic.split(' ')[i] != event.mnemonic.split(' ')[i]) {
            incorrectIndexes.add(i);
          }
        }
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

    on<GoBackToMnemonic>((event, emit) {
      emit(state.copyWith(
          mnemonicError: null, currentStep: OnboardingCreateStep.showMnemonic));
    });
  }
}
