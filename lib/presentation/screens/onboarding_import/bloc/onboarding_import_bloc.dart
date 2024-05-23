import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/common/uuid.dart';
import 'package:uniparty/domain/entities/account.dart';
import 'package:uniparty/domain/entities/wallet.dart';
import 'package:uniparty/domain/repositories/account_repository.dart';
import 'package:uniparty/domain/repositories/address_repository.dart';
import 'package:uniparty/domain/repositories/wallet_repository.dart';

import 'package:uniparty/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:uniparty/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';
import 'package:uniparty/domain/services/address_service.dart';
import 'package:uniparty/domain/services/wallet_service.dart';
import 'package:uniparty/domain/entities/address.dart';

import 'package:uniparty/common/constants.dart' as c;

class OnboardingImportBloc
    extends Bloc<OnboardingImportEvent, OnboardingImportState> {

  final addressService = GetIt.I<AddressService>();
  final accountRepository = GetIt.I<AccountRepository>();
  final addressRepository = GetIt.I<AddressRepository>();
  final walletRepository = GetIt.I<WalletRepository>();
  final walletService = GetIt.I<WalletService>();

  OnboardingImportBloc() : super(OnboardingImportState()) {
    on<MnemonicChanged>((event, emit) async {
      bool validMnemonic = true;
      if (validMnemonic) {
        try {
          List<Address> addresses = await _deriveAddress(
              event.mnemonic, state.importFormat.name, addressService);

          emit(state.copyWith(
              mnemonic: event.mnemonic,
              getAddressesState:
                  GetAddressesStateSuccess(addresses: addresses)));
        } catch (e) {
          emit(state.copyWith(
              mnemonic: event.mnemonic,
              getAddressesState:
                  GetAddressesStateError(message: e.toString())));
        }
      } else {
        emit(state.copyWith(mnemonic: event.mnemonic));
      }
    });
    on<ImportFormatChanged>((event, emit) async {
      bool validMnemonic = true;

      ImportFormat importFormat = event.importFormat == "Segwit"
          ? ImportFormat.segwit
          : ImportFormat.freewalletBech32;

      if (validMnemonic) {
        try {
          List<Address> addresses = await _deriveAddress(
              state.mnemonic, importFormat.name, addressService);

          emit(state.copyWith(
              importFormat: importFormat,
              getAddressesState:
                  GetAddressesStateSuccess(addresses: addresses)));
        } catch (e) {
          emit(state.copyWith(
              importFormat: importFormat,
              getAddressesState:
                  GetAddressesStateError(message: e.toString())));
        }
      } else {
        emit(state.copyWith(importFormat: importFormat));
      }
    });
    on<AddressMapChanged>((event, emit) {
      final isCheckedMap = state.isCheckedMap;
      final nextMap = Map<Address, bool>.from(isCheckedMap);
      nextMap[event.address] = event.isChecked;
      emit(state.copyWith(
          isCheckedMap: nextMap, importState: ImportStateNotAsked()));
    });

    on<ImportAddresses>((event, emit) async {
      // check if there are any address checked
      bool hasChecked = state.isCheckedMap.values.any((a) => a);

      if (!hasChecked) {
        emit(state.copyWith(
            importState:
                ImportStateError(message: "Must select at least one address")));
        return;
      } else {


        emit(state.copyWith(importState: ImportStateLoading()));
        // TODO: show loading inditactor

        Wallet wallet;
        switch (state.importFormat) {
          case ImportFormat.segwit:
            wallet = await walletService.deriveRoot(state.mnemonic);
          case ImportFormat.freewalletBech32:
            wallet = await walletService.deriveRootFreewallet(state.mnemonic);
          default:
            throw UnimplementedError();
        }

        List<Address> addresses = state.isCheckedMap.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

        Account account = Account(uuid: uuid.v4());
        wallet.uuid = uuid.v4();
        wallet.accountUuid = account.uuid;
        for (Address address in addresses) {
          address.walletUuid = wallet.uuid;
        }


        try {
            await accountRepository.insert(account);
            await walletRepository.insert(wallet);
            await addressRepository.insertMany(addresses);
        } catch (e) {
          emit(state.copyWith(importState: ImportStateError(message: e.toString())));
        }
        emit(state.copyWith(importState: ImportStateSuccess()));
      }
    });
  }
}

_deriveAddress(
    String mnemonic, String importFormat, AddressService addressService) async {
  // TODO: swith on actual ENUM
  switch (importFormat) {
    // TODP
    case "Segwit":
      // TODO: obviously we should not be hardcoded to testnet
      List<Address> addresses =
          await addressService.deriveAddressSegwitRange(mnemonic, 0, 7);
      return addresses;
    case "Freewallet-bech32":
      List<Address> addresses = await addressService
          .deriveAddressFreewalletBech32Range(mnemonic, 0, 7);
      return addresses;
  }
}
