import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/account_service_return.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/account_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';

class OnboardingImportBloc extends Bloc<OnboardingImportEvent, OnboardingImportState> {
  final addressService = GetIt.I<AddressService>();
  final accountRepository = GetIt.I<AccountRepository>();
  final addressRepository = GetIt.I<AddressRepository>();
  final walletRepository = GetIt.I<WalletRepository>();
  final accountService = GetIt.I<AccountService>();
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
      // bool validMnemonic = mnemonicService.validateMnemonic(event.mnemonic);
      print('MNEMONIC IN EVENT: ${event.mnemonic}');
      bool validMnemonic = true;
      if (validMnemonic) {
        try {
          // List<Address> addresses = await _deriveAddress(event.mnemonic, state.importFormat.name, addressService);

          // emit(state.copyWith(mnemonic: event.mnemonic, getAddressesState: GetAddressesStateSuccess(addresses: addresses)));
          emit(state.copyWith(mnemonic: event.mnemonic));
        } catch (e) {
          // emit(state.copyWith(mnemonic: event.mnemonic, getAddressesState: GetAddressesStateError(message: e.toString())));
          emit(state.copyWith(mnemonic: event.mnemonic));
        }
      } else {
        emit(state.copyWith(mnemonic: event.mnemonic));
      }
    });

    on<ImportFormatChanged>((event, emit) async {
      // bool validMnemonic = mnemonicService.validateMnemonic(state.mnemonic);
      bool validMnemonic = true;

      ImportFormat importFormat = event.importFormat == "Segwit" ? ImportFormat.segwit : ImportFormat.freewalletBech32;

      if (validMnemonic) {
        try {
          emit(state.copyWith(importFormat: importFormat));
          // List<Address> addresses = await _deriveAddress(state.mnemonic, importFormat.name, addressService);

          // emit(
          //     state.copyWith(importFormat: importFormat, getAddressesState: GetAddressesStateSuccess(addresses: addresses)));
        } catch (e) {
          emit(state.copyWith(importFormat: importFormat));

          // emit(state.copyWith(importFormat: importFormat, getAddressesState: GetAddressesStateError(message: e.toString())));
        }
      } else {
        emit(state.copyWith(importFormat: importFormat));
      }
    });

    on<AddressMapChanged>((event, emit) {
      final isCheckedMap = state.isCheckedMap;
      final nextMap = Map<Address, bool>.from(isCheckedMap);
      nextMap[event.address] = event.isChecked;
      emit(state.copyWith(isCheckedMap: nextMap, importState: ImportStateNotAsked()));
    });

    on<ImportWallet>((event, emit) async {
      print('MNEMONIC IN STATE: ${state.mnemonic}');
      // bool validMnemonic = mnemonicService.validateMnemonic(state.mnemonic);
      bool validMnemonic = true;
      print("validMnemonic: $validMnemonic");
      if (!validMnemonic) {
        emit(state.copyWith(importState: ImportStateError(message: "Invalid mnemonic")));
        return;
      }

      // check if there are any address checked
      // bool hasChecked = state.isCheckedMap.values.any((a) => a);

      // if (!hasChecked) {
      //   emit(state.copyWith(importState: ImportStateError(message: "Must select at least one address")));
      //   return;
      // } else {
      emit(state.copyWith(importState: ImportStateLoading()));
      try {
        Wallet wallet = Wallet(uuid: uuid.v4(), name: 'Wallet 1', wif: '');

        String purpose;
        int coinType;
        int accountIndex;
        Account account;
        Address address;
        AccountServiceReturn accountServiceReturn;

        switch (state.importFormat) {
          case ImportFormat.segwit:
            purpose = '84';
            coinType = 0;
            accountIndex = 0;

            account = Account(
                uuid: uuid.v4(),
                name: 'm/$purpose\'/$coinType\'/$accountIndex\'',
                walletUuid: wallet.uuid,
                purpose: purpose,
                coinType: coinType,
                accountIndex: accountIndex,
                xPub: '');

            accountServiceReturn = await accountService.deriveAccountAndAddress(state.mnemonic, account);

            account.xPub = accountServiceReturn.xPub;

            address = accountServiceReturn.address;

            await walletRepository.insert(wallet);
            await accountRepository.insert(account);
            await addressRepository.insert(address);

            break;
          case ImportFormat.freewalletBech32:
            purpose = '32';
            coinType = 0;
            accountIndex = 0;
            final change = 0; // 0 for external chain, 1 for internal/change chain

            account = Account(
                uuid: uuid.v4(),
                name: 'm/$accountIndex\'/$change',
                walletUuid: wallet.uuid,
                purpose: purpose,
                coinType: coinType,
                accountIndex: accountIndex,
                xPub: '');

            accountServiceReturn = await accountService.deriveAccountAndAddressFreewalletBech32(state.mnemonic, account);

            account.xPub = accountServiceReturn.xPub;
            address = accountServiceReturn.address;

            await walletRepository.insert(wallet);
            await accountRepository.insert(account);
            await addressRepository.insert(address);

            break;
        }

        emit(state.copyWith(importState: ImportStateSuccess()));
        return;
      } catch (e) {
        emit(state.copyWith(importState: ImportStateError(message: e.toString())));
        return;
      }
      // TODO: show loading inditactor
      // switch (state.importFormat) {
      //   case ImportFormat.segwit:
      //     account = await accountService.deriveRoot(state.mnemonic, state.password!);
      //     break;
      //   case ImportFormat.freewalletBech32:
      //     account = await accountService.deriveRootFreewallet(state.mnemonic, state.password!);
      //     break;
      //   default:
      //     throw UnimplementedError();
      // }
      // List<Address> addresses =
      //     state.isCheckedMap.entries.where((entry) => entry.value).map((entry) => entry.key).toList();

      // Wallet wallet = Wallet(uuid: uuid.v4());
      // account.uuid = uuid.v4();
      // account.walletUuid = wallet.uuid;
      // account.name = state.importFormat.description;

      // for (Address address in addresses) {
      //   address.accountUuid = account.uuid;
      // }

      // try {
      //   await walletRepository.insert(wallet);
      //   await accountRepository.insert(account);
      //   await addressRepository.insertMany(addresses);
      // } catch (e) {
      //   emit(state.copyWith(importState: ImportStateError(message: e.toString())));
      //   return;
      // }
      // }
    });
  }
}

_deriveAddress(String mnemonic, String importFormat, AddressService addressService) async {
  // TODO: swith on actual ENUM
  // switch (importFormat) {
  //   // TODP
  //   case "Segwit":
  //     // TODO: obviously we should not be hardcoded to testnet
  //     List<Address> addresses = await addressService.deriveAddressSegwitRange(mnemonic, 0, 7);
  //     return addresses;
  //   case "Freewallet-bech32":
  //     List<Address> addresses = await addressService.deriveAddressFreewalletBech32Range(mnemonic, 0, 7);
  //     return addresses;
  // }
}
