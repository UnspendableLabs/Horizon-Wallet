import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/hd_wallet_entity.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/hd_wallet_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';

class OnboardingImportBloc extends Bloc<OnboardingImportEvent, OnboardingImportState> {
  final accountRepository = GetIt.I<AccountRepository>();
  final addressRepository = GetIt.I<AddressRepository>();
  final walletRepository = GetIt.I<WalletRepository>();
  final accountService = GetIt.I<HDWalletService>();
  final mnemonicService = GetIt.I<MnemonicService>();

  OnboardingImportBloc() : super(OnboardingImportState()) {
    on<PasswordSubmit>((event, emit) {
      if (event.password != event.passwordConfirmation) {
        emit(state.copyWith(passwordError: "Passwords do not match"));
      } else if (event.password.length != 32) {
        emit(state.copyWith(passwordError: "Password must be 32 characters.  Don't worry, we'll change this :)"));
      } else {
        emit(state.copyWith(password: event.password, passwordError: null));
      }
    });

    on<MnemonicChanged>((event, emit) async {
      emit(state.copyWith(mnemonic: event.mnemonic));
    });

    on<ImportFormatChanged>((event, emit) async {
      // bool validMnemonic = mnemonicService.validateMnemonic(state.mnemonic);
      bool validMnemonic = true;

      ImportFormat importFormat = event.importFormat == "Segwit" ? ImportFormat.segwit : ImportFormat.freewalletBech32;

      if (validMnemonic) {
        try {
          emit(state.copyWith(importFormat: importFormat));
        } catch (e) {
          emit(state.copyWith(importFormat: importFormat));
        }
      } else {
        emit(state.copyWith(importFormat: importFormat));
      }
    });

    on<ImportWallet>((event, emit) async {
      // bool validMnemonic = mnemonicService.validateMnemonic(state.mnemonic);
      bool validMnemonic = true;
      if (!validMnemonic) {
        emit(state.copyWith(importState: ImportStateError(message: "Invalid mnemonic")));
        return;
      }

      emit(state.copyWith(importState: ImportStateLoading()));
      try {
        HDWalletEntity hdWalletEntity;

        switch (state.importFormat) {
          case ImportFormat.segwit:
            hdWalletEntity = await accountService.deriveHDWallet(
                mnemonic: state.mnemonic, password: state.password!, purpose: '84', coinType: 0, accountIndex: 0);

            break;
          case ImportFormat.freewalletBech32:
            hdWalletEntity = await accountService.deriveFreewalletBech32HDWallet(
                mnemonic: state.mnemonic, password: state.password!, purpose: '32', coinType: 0, accountIndex: 0);

            break;
          default:
            throw UnimplementedError();
        }
        await walletRepository.insert(hdWalletEntity.wallet);
        await accountRepository.insert(hdWalletEntity.account);
        await addressRepository.insert(hdWalletEntity.address);

        emit(state.copyWith(importState: ImportStateSuccess()));
        return;
      } catch (e) {
        emit(state.copyWith(importState: ImportStateError(message: e.toString())));
        return;
      }
    });
  }
}
