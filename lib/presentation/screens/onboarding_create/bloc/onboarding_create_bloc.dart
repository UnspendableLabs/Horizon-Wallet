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
    on<CreateWallet>((event, emit) async {
      logger.d('Processing CreateWallet event');
      emit(state.copyWith(createState: CreateStateLoading()));
      final password = event.password;
      try {
        await importWalletUseCase.callHorizon(
          secret: state.mnemonicState.mnemonic,
          password: password,
          deriveWallet: (secret, password) =>
              walletService.deriveRoot(secret, password),
        );

        emit(state.copyWith(createState: CreateStateSuccess()));
      } catch (e) {
        logger.e({'message': 'Failed to create wallet'});
        emit(state.copyWith(
            createState: CreateStateError(message: e.toString())));
      }
    });

    on<GenerateMnemonic>((event, emit) {
      if (state.mnemonicState is GenerateMnemonicStateUnconfirmed) {
        // If a mnemonic is already generated, do not generate a new one
        return;
      }
      emit(state.copyWith(mnemonicState: GenerateMnemonicStateLoading()));

      try {
        String mnemonic = mnmonicService.generateMnemonic();

        emit(state.copyWith(
            mnemonicState: GenerateMnemonicStateGenerated(mnemonic: mnemonic)));
      } catch (e) {
        emit(state.copyWith(
            mnemonicState: GenerateMnemonicStateError(message: e.toString())));
      }
    });

    on<UnconfirmMnemonic>((event, emit) {
      emit(state.copyWith(
          mnemonicState: GenerateMnemonicStateUnconfirmed(
              mnemonic: state.mnemonicState.mnemonic),
          createState: CreateStateMnemonicUnconfirmed));
    });

    on<ConfirmMnemonicChanged>((event, emit) {
      if (state.mnemonicState.mnemonic != event.mnemonic) {
        List<int> incorrectIndexes = [];
        for (int i = 0; i < 12; i++) {
          if (state.mnemonicState.mnemonic.split(' ')[i] !=
              event.mnemonic.split(' ')[i]) {
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

    on<ConfirmMnemonic>((event, emit) {
      if (event.mnemonic.isEmpty) {
        emit(state.copyWith(
            mnemonicError: MnemonicErrorState(
                message: 'Seed phrase is required', incorrectIndexes: [])));
        return;
      }
      if (state.mnemonicState.mnemonic != event.mnemonic.join(' ')) {
        List<int> incorrectIndexes = [];
        for (int i = 0; i < 12; i++) {
          if (state.mnemonicState.mnemonic.split(' ')[i] != event.mnemonic[i]) {
            incorrectIndexes.add(i);
          }
        }
        emit(state.copyWith(
            mnemonicError: MnemonicErrorState(
                message: 'Seed phrase does not match',
                incorrectIndexes: incorrectIndexes)));
      } else {
        emit(state.copyWith(
            createState: CreateStateMnemonicConfirmed, mnemonicError: null));
      }
    });

    on<GoBackToMnemonic>((event, emit) {
      emit(state.copyWith(
          createState: CreateStateNotAsked, mnemonicError: null));
    });
  }
}
