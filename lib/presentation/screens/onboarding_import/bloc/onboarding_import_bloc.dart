import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';

class OnboardingImportBloc extends Bloc<OnboardingImportEvent, OnboardingImportState> {
  final addressService = GetIt.I<AddressService>();
  final accountRepository = GetIt.I<AccountRepository>();
  final addressRepository = GetIt.I<AddressRepository>();
  final walletRepository = GetIt.I<WalletRepository>();
  final accountService = GetIt.I<AccountService>();

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
      bool validMnemonic = true;
      if (validMnemonic) {
        try {
          List<Address> addresses = await _deriveAddress(event.mnemonic, state.importFormat.name, addressService);

          emit(state.copyWith(mnemonic: event.mnemonic, getAddressesState: GetAddressesStateSuccess(addresses: addresses)));
        } catch (e) {
          emit(state.copyWith(mnemonic: event.mnemonic, getAddressesState: GetAddressesStateError(message: e.toString())));
        }
      } else {
        emit(state.copyWith(mnemonic: event.mnemonic));
      }
    });
    on<ImportFormatChanged>((event, emit) async {
      bool validMnemonic = true;

      ImportFormat importFormat = event.importFormat == "Segwit" ? ImportFormat.segwit : ImportFormat.freewalletBech32;

      if (validMnemonic) {
        try {
          List<Address> addresses = await _deriveAddress(state.mnemonic, importFormat.name, addressService);

          emit(
              state.copyWith(importFormat: importFormat, getAddressesState: GetAddressesStateSuccess(addresses: addresses)));
        } catch (e) {
          emit(state.copyWith(importFormat: importFormat, getAddressesState: GetAddressesStateError(message: e.toString())));
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

    on<ImportAddresses>((event, emit) async {
      // check if there are any address checked
      bool hasChecked = state.isCheckedMap.values.any((a) => a);

      if (!hasChecked) {
        emit(state.copyWith(importState: ImportStateError(message: "Must select at least one address")));
        return;
      } else {
        emit(state.copyWith(importState: ImportStateLoading()));
        // TODO: show loading inditactor

        Account account;
        switch (state.importFormat) {
          case ImportFormat.segwit:
            account = await accountService.deriveRoot(state.mnemonic, state.password!);
          case ImportFormat.freewalletBech32:
            account = await accountService.deriveRootFreewallet(state.mnemonic, state.password!);
          default:
            throw UnimplementedError();
        }

        List<Address> addresses =
            state.isCheckedMap.entries.where((entry) => entry.value).map((entry) => entry.key).toList();

        Wallet wallet = Wallet(uuid: uuid.v4());
        account.uuid = uuid.v4();
        account.walletUuid = wallet.uuid;
        account.name = state.importFormat.description;

        for (Address address in addresses) {
          address.accountUuid = account.uuid;
        }

        try {
          await walletRepository.insert(wallet);
          await accountRepository.insert(account);
          await addressRepository.insertMany(addresses);
        } catch (e) {
          emit(state.copyWith(importState: ImportStateError(message: e.toString())));
        }
        emit(state.copyWith(importState: ImportStateSuccess()));
      }
    });
  }
}

_deriveAddress(String mnemonic, String importFormat, AddressService addressService) async {
  // TODO: swith on actual ENUM
  switch (importFormat) {
    // TODP
    case "Segwit":
      // TODO: obviously we should not be hardcoded to testnet
      List<Address> addresses = await addressService.deriveAddressSegwitRange(mnemonic, 0, 7);
      return addresses;
    case "Freewallet-bech32":
      List<Address> addresses = await addressService.deriveAddressFreewalletBech32Range(mnemonic, 0, 7);
      return addresses;
  }
}
