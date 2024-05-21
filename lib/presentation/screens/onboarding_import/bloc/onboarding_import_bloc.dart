import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:uniparty/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:uniparty/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';
import 'package:uniparty/domain/services/address_service.dart';
import 'package:uniparty/domain/entities/address.dart';

import 'package:uniparty/common/constants.dart' as c;

class OnboardingImportBloc
    extends Bloc<OnboardingImportEvent, OnboardingImportState> {
  final addressService = GetIt.I<AddressService>();
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
          emit(state.copyWith(
              importFormat: importFormat
              ));

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
