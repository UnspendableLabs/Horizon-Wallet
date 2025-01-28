import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';

class OnboardingImportBloc
    extends Bloc<OnboardingImportEvent, OnboardingImportState> {
  final MnemonicService mnemonicService;
  final ImportWalletUseCase importWalletUseCase;
  final WalletService walletService;
  OnboardingImportBloc({
    required this.mnemonicService,
    required this.importWalletUseCase,
    required this.walletService,
  }) : super(const OnboardingImportState()) {
    on<MnemonicChanged>((event, emit) async {
      if (event.mnemonic.isEmpty) {
        emit(state.copyWith(
            mnemonicError: "Seed phrase is required",
            mnemonic: event.mnemonic));
        return;
      } else if (event.mnemonic.split(' ').length != 12) {
        emit(state.copyWith(
            mnemonicError: "Seed phrase must be twelve words",
            mnemonic: event.mnemonic));
        return;
      } else {
        bool validMnemonic = switch (state.importFormat) {
          ImportFormat.counterwallet =>
            mnemonicService.validateCounterwalletMnemonic(event.mnemonic),
          ImportFormat.horizon ||
          ImportFormat.freewallet =>
            mnemonicService.validateMnemonic(event.mnemonic),
        };

        if (!validMnemonic) {
          emit(state.copyWith(
              mnemonicError: "Invalid seed phrase", mnemonic: event.mnemonic));
          return;
        }

        emit(state.copyWith(mnemonic: event.mnemonic, mnemonicError: null));
      }
    });

    on<ImportFormatChanged>((event, emit) async {
      final importFormat = switch (event.importFormat) {
        "Horizon" => ImportFormat.horizon,
        "Freewallet" => ImportFormat.freewallet,
        "Counterwallet" => ImportFormat.counterwallet,
        _ => throw Exception('Invariant: Invalid import format')
      };
      emit(state.copyWith(importFormat: importFormat));
    });

    on<ImportFormatSubmitted>((event, emit) async {
      emit(state.copyWith(currentStep: OnboardingImportStep.inputSeed));
    });

    on<MnemonicSubmitted>((event, emit) async {
      // Validate mnemonic before proceeding
      if (state.mnemonic.isEmpty) {
        emit(state.copyWith(mnemonicError: "Seed phrase is required"));
        return;
      } else if (state.mnemonic.split(' ').length != 12) {
        emit(state.copyWith(mnemonicError: "Seed phrase must be twelve words"));
        return;
      } else {
        bool validMnemonic = false;

        if (state.importFormat == ImportFormat.counterwallet) {
          validMnemonic =
              mnemonicService.validateCounterwalletMnemonic(event.mnemonic);
        } else if (state.importFormat == ImportFormat.horizon ||
            state.importFormat == ImportFormat.freewallet) {
          validMnemonic = mnemonicService.validateMnemonic(event.mnemonic);
        }

        if (!validMnemonic) {
          emit(state.copyWith(
              mnemonicError: "Invalid seed phrase", mnemonic: event.mnemonic));
          return;
        }
      }

      emit(state.copyWith(
        mnemonicError: null,
        currentStep: OnboardingImportStep.inputPassword,
        mnemonic: event.mnemonic,
      ));
    });

    on<ImportWallet>((event, emit) async {
      emit(state.copyWith(importState: ImportStateLoading()));
      final password = event.password;

      await importWalletUseCase.callAllWallets(
        password: password,
        mnemonic: state.mnemonic,
        importFormat: state.importFormat,
        onError: (msg) {
          emit(state.copyWith(importState: ImportStateError(message: msg)));
        },
        onSuccess: () {
          emit(state.copyWith(importState: ImportStateSuccess()));
        },
      );
      return;
    });
  }
}
