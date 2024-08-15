import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';

class OnboardingImportBloc
    extends Bloc<OnboardingImportEvent, OnboardingImportState> {
  final accountRepository = GetIt.I<AccountRepository>();
  final addressRepository = GetIt.I<AddressRepository>();
  final walletRepository = GetIt.I<WalletRepository>();
  final walletService = GetIt.I<WalletService>();
  final addressService = GetIt.I<AddressService>();
  final mnemonicService = GetIt.I<MnemonicService>();
  final encryptionService = GetIt.I<EncryptionService>();

  OnboardingImportBloc() : super(const OnboardingImportState()) {
    on<PasswordChanged>((event, emit) {
      if (event.password.length < 8) {
        emit(state.copyWith(
            passwordError: "Password must be at least 8 characters."));
      } else {
        emit(state.copyWith(password: event.password, passwordError: null));
      }
    });

    on<PasswordConfirmationChanged>((event, emit) {
      if (state.password != event.passwordConfirmation) {
        emit(state.copyWith(passwordError: "Passwords do not match"));
      } else {
        emit(state.copyWith(passwordError: null));
      }
    });

    on<PasswordError>((event, emit) {
      emit(state.copyWith(passwordError: event.error));
    });

    on<MnemonicChanged>((event, emit) async {
      if (event.mnemonic.isEmpty) {
        emit(state.copyWith(
            mnemonicError: "Mnemonic is required", mnemonic: event.mnemonic));
        return;
      } else if (event.mnemonic.split(' ').length != 12) {
        emit(state.copyWith(
            mnemonicError: "Invalid mnemonic length",
            mnemonic: event.mnemonic));
        return;
      } else {
        bool validMnemonic = mnemonicService.validateMnemonic(event.mnemonic);
        if (!validMnemonic) {
          emit(state.copyWith(
              mnemonicError: "Invalid mnemonic", mnemonic: event.mnemonic));
          return;
        }
        emit(state.copyWith(mnemonic: event.mnemonic, mnemonicError: null));
      }
    });

    on<ImportFormatChanged>((event, emit) async {
      ImportFormat importFormat = event.importFormat == "Segwit"
          ? ImportFormat.segwit
          : ImportFormat.freewalletBech32;
      emit(state.copyWith(importFormat: importFormat));
    });

    on<MnemonicSubmit>((event, emit) async {
      if (state.mnemonic.isEmpty) {
        emit(state.copyWith(mnemonicError: "Mnemonic is required"));
        return;
      } else if (state.mnemonic.split(' ').length != 12) {
        emit(state.copyWith(mnemonicError: "Invalid mnemonic length"));
        return;
      } else {
        bool validMnemonic = mnemonicService.validateMnemonic(state.mnemonic);
        if (!validMnemonic) {
          emit(state.copyWith(mnemonicError: "Invalid mnemonic"));
          return;
        }
      }
      ImportFormat importFormat = event.importFormat == "Segwit"
          ? ImportFormat.segwit
          : ImportFormat.freewalletBech32;
      emit(state.copyWith(
          importState: ImportStateMnemonicCollected(),
          importFormat: importFormat,
          mnemonic: event.mnemonic));
    });

    on<ImportWallet>((event, emit) async {
      emit(state.copyWith(importState: ImportStateLoading()));
      try {
        switch (state.importFormat) {
          case ImportFormat.segwit:
            Wallet wallet =
                await walletService.deriveRoot(state.mnemonic, state.password!);
            String decryptedPrivKey = await encryptionService.decrypt(
                wallet.encryptedPrivKey, state.password!);

            //m/84'/1'/0'/0
            Account account0 = Account(
              name: 'Account #0',
              walletUuid: wallet.uuid,
              purpose: '84\'',
              coinType: '${_getCoinType()}\'',
              accountIndex: '0\'',
              uuid: uuid.v4(),
              importFormat: ImportFormat.segwit,
            );

            Address address = await addressService.deriveAddressSegwit(
              privKey: decryptedPrivKey,
              chainCodeHex: wallet.chainCodeHex,
              accountUuid: account0.uuid,
              purpose: account0.purpose,
              coin: account0.coinType,
              account: account0.accountIndex,
              change: '0',
              index: 0,
            );

            await walletRepository.insert(wallet);
            await accountRepository.insert(account0);
            await addressRepository.insert(address);
            break;

          case ImportFormat.freewalletBech32:
            Wallet wallet = await walletService.deriveRootFreewallet(
                state.mnemonic, state.password!);

            String decryptedPrivKey = await encryptionService.decrypt(
                wallet.encryptedPrivKey, state.password!);

            Account account = Account(
                name: 'Account 0',
                walletUuid: wallet.uuid,
                purpose: '32', // unused in Freewallet path
                coinType: _getCoinType(),
                accountIndex: '0\'',
                uuid: uuid.v4(),
                importFormat: ImportFormat.freewalletBech32);

            List<Address> addresses =
                await addressService.deriveAddressFreewalletBech32Range(
                    privKey: decryptedPrivKey,
                    chainCodeHex: wallet.chainCodeHex,
                    accountUuid: account.uuid,
                    purpose: account.purpose,
                    coin: account.coinType,
                    account: account.accountIndex,
                    change: '0',
                    start: 0,
                    end: 9);

            await walletRepository.insert(wallet);
            await accountRepository.insert(account);
            await addressRepository.insertMany(addresses);

            break;
          default:
            throw UnimplementedError();
        }

        emit(state.copyWith(importState: ImportStateSuccess()));
        return;
      } catch (e) {
        emit(state.copyWith(
            importState: ImportStateError(message: e.toString())));
        return;
      }
    });
  }

  String _getCoinType() {
    // bool isTestnet = dotenv.get('TEST') == 'true';
    bool isTestnet =
        const String.fromEnvironment('TEST', defaultValue: 'true') == 'true';
    return isTestnet ? '1' : '0';
  }
}
