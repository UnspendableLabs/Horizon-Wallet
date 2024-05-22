import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/common/uuid.dart';
import 'package:uniparty/data/sources/local/dao/account_dao.dart';
import 'package:uniparty/data/sources/local/db.dart';

import 'package:uniparty/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:uniparty/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';
import 'package:uniparty/domain/services/address_service.dart';
import 'package:uniparty/domain/entities/address.dart';

import 'package:uniparty/common/constants.dart' as c;

class OnboardingImportBloc
    extends Bloc<OnboardingImportEvent, OnboardingImportState> {
  final addressService = GetIt.I<AddressService>();
    final accountDao = GetIt.I<AccountDao>();

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

    on<ImportAddresses>((event, emit) async{
      // check if there are any address checked
      bool hasChecked = state.isCheckedMap.values.any((a) => a);

      if (!hasChecked) {
        emit(state.copyWith(
            importState:
                ImportStateError(message: "Must select at least one address")));
        return;
      } else {

        List<Address> addresses = state.isCheckedMap.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

        // create user account
        String accountUuid = uuid.v4();
        var newAccount = Account(
          uuid: accountUuid, // Generate a new UUID
        );

        await accountDao.insertAccount(newAccount);
        Account? account = await accountDao.getAccountByUuid(accountUuid);
        print('ACCOUNT: $account');

        // derive wallet from seed and save wif and public key, etc with user account

        // dervice keys for each address at path with wallet_id

        print(addresses);

        emit(state.copyWith(importState: ImportStateLoading()));
      }
   });
  }
}

// _handleDeriveAddress(event, emit, AddressService addressService) async {
//   final importFormat = event.importFormat;
//
//   // TODO: swith on actual ENUM
//   switch (importFormat) {
//     // TODP
//     case "Segwit":
//       try {
//         // TODO: obviously we should not be hardcoded to testnet
//         List<Address> addresses =
//             await addressService.deriveAddressSegwitRange(event.mnemonic, 0, 7);
//
//         print(addresses);
//
//         emit(Success(addresses: addresses));
//       } catch (e) {
//         print(e.toString());
//
//         emit(Error(message: e.toString()));
//       }
//
//     case "Freewallet-bech32":
//       try {
//         List<Address> addresses = await addressService
//             .deriveAddressFreewalletBech32Range(event.mnemonic, 0, 7);
//
//         emit(Success(addresses: addresses));
//       } catch (e) {
//         print(e.toString());
//
//         emit(Error(message: e.toString()));
//       }
//   }
// }

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
