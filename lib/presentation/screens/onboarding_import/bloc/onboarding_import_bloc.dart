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

  OnboardingImportBloc() : super(NotAsked()) {
    on<DeriveAddress>((event, emit) async =>
        _handleDeriveAddress(event, emit, addressService));
  }
}

_handleDeriveAddress(event, emit, AddressService addressService) async {


  final importFormat = event.importFormat;
  
  // TODO: swith on actual ENUM
  switch (importFormat) {
    // TODP
    case "Segwit":
      try {
        // TODO: obviously we should not be hardcoded to testnet
        Address address = await addressService.deriveAddressSegwit(
            event.mnemonic, 'm/84\'/1\'/0\'/0/0');

        emit(Success(address: address));
      } catch (e) {
        print(e.toString());

        emit(Error(message: e.toString()));
      }

    case "Freewallet-bech32":
      try {
        // TODO: obviously we should not be hardcoded to testnet
        Address address = await addressService.deriveAddressFreewalletBech32(
            event.mnemonic, 0);

        emit(Success(address: address));
      } catch (e) {
        print(e.toString());

        emit(Error(message: e.toString()));
      }
  }
}
