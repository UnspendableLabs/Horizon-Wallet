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
          bool validMnemonic = switch (state.walletType) {
            WalletType.bip32 =>
              mnemonicService.validateCounterwalletMnemonic(event.mnemonic) ||
                  mnemonicService.validateMnemonic(event.mnemonic),
            WalletType.horizon =>
              mnemonicService.validateMnemonic(event.mnemonic),
          null => false,
          };

          if (!validMnemonic) {
            emit(state.copyWith(
                mnemonicError: "Invalid seed phrase",
                mnemonic: event.mnemonic));
            return;
          }

          emit(state.copyWith(mnemonic: event.mnemonic, mnemonicError: null));
        }
    });

    on<ImportFormatChanged>((event, emit) async {
      final walletType = switch (event.walletType) {
        "Horizon" => WalletType.horizon,
        "BIP32" => WalletType.bip32,
        _ => null,
      };
      emit(state.copyWith(walletType: walletType));
    });

    on<ImportFormatSubmitted>((event, emit) async {
      emit(state.copyWith(currentStep: OnboardingImportStep.inputSeed));
    });

    on<MnemonicSubmitted>((event, emit) async {
      // Validate mnemonic before proceeding
      print(state);
      print(event);

      if (state.mnemonic.isEmpty) {
        emit(state.copyWith(mnemonicError: "Seed phrase is required"));
        return;
      } else if (state.mnemonic.split(' ').length != 12) {
        emit(state.copyWith(mnemonicError: "Seed phrase must be twelve words"));
        return;
      } else {
        bool validMnemonic = false;

        if (state.walletType == WalletType.bip32) {
          validMnemonic =
              mnemonicService.validateCounterwalletMnemonic(event.mnemonic) ||
                  mnemonicService.validateMnemonic(event.mnemonic);
        } else if (state.walletType == WalletType.horizon) {
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
      emit(state.copyWith(importState: const ImportState.loading()));

      if (state.walletType == null) {
        emit(state.copyWith(
            importState: const ImportState.error(
                message: "invariant: Wallet type is required")));
        return;
      }
      final password = event.password;

      await importWalletUseCase.call(
        password: password,
        mnemonic: state.mnemonic,
        walletType: state.walletType!,
        onError: (msg) {
          emit(state.copyWith(importState: ImportState.error(message: msg)));
        },
        onSuccess: () {
          emit(state.copyWith(importState: const ImportState.success()));
        },
      );
      return;
    });

    on<SeedInputBackPressed>((event, emit) async {
      emit(state.copyWith(
        currentStep: OnboardingImportStep.inputSeed,
        mnemonicError: null,
        mnemonic: '',
      ));
    });

    on<ImportFormatBackPressed>((event, emit) async {
      emit(state.copyWith(
          currentStep: OnboardingImportStep.chooseFormat,
          mnemonicError: null,
          mnemonic: '',
          walletType: null));
    });
  }
}
