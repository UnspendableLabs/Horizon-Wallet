import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import "package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_event.dart";
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_state.dart';

class ImportAddressPkBloc
    extends Bloc<ImportAddressPkEvent, ImportAddressPkState> {
  final WalletRepository walletRepository;
  final WalletService walletService;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final AddressRepository addressRepository;
  final ImportedAddressRepository importedAddressRepository;
  final ImportedAddressService importedAddressService;
  ImportAddressPkBloc({
    required this.walletRepository,
    required this.walletService,
    required this.encryptionService,
    required this.addressService,
    required this.addressRepository,
    required this.importedAddressRepository,
    required this.importedAddressService,
  }) : super(ImportAddressPkStep1()) {
    on<Finalize>((event, emit) async {
      emit(ImportAddressPkStep2(state: Step2Initial()));
    });

    on<Submit>((event, emit) async {
      emit(ImportAddressPkStep2(state: Step2Loading()));
      try {
        Wallet? wallet = await walletRepository.getCurrentWallet();

        if (wallet == null) {
          throw Exception("invariant: wallet is null");
        }
        try {
          // TODO: this is a hack to ensure the user has the correct password
          // TODO: we should be able to check this without decrypting the wallet pk
          await encryptionService.decrypt(
              wallet.encryptedPrivKey, event.password);
        } catch (e) {
          emit(ImportAddressPkStep2(state: Step2Error("Incorrect password")));
          return;
        }

        late String address;
        try {
          address = await importedAddressService.getAddressFromWIF(
              wif: event.wif, format: event.format);
        } catch (e) {
          emit(ImportAddressPkStep2(
              state: Step2Error('Invalid address private key')));
          return;
        }

        final existingAddress = await addressRepository.getAddress(address);
        if (existingAddress != null) {
          emit(ImportAddressPkStep2(
              state: Step2Error(
                  'Address ${event.format.name} $address already exists in your wallet')));
          return;
        }

        final String encryptedWIF =
            await encryptionService.encrypt(event.wif, event.password);

        final ImportedAddress importedAddress = ImportedAddress(
          address: address,
          encryptedWif: encryptedWIF,
          name: event.name,
          walletUuid: wallet.uuid,
        );

        try {
          await importedAddressRepository.insert(importedAddress);
        } catch (e) {
          if (e.toString().contains("UNIQUE")) {
            emit(ImportAddressPkStep2(
                state: Step2Error(
                    'Address ${event.format.name} $address already exists in your wallet')));
          } else {
            emit(ImportAddressPkStep2(state: Step2Error(e.toString())));
          }
          return;
        }

        emit(ImportAddressPkStep2(state: Step2Success(importedAddress)));
      } catch (e) {
        emit(ImportAddressPkStep2(state: Step2Error(e.toString())));
      }
    });

    on<ResetForm>((event, emit) {
      emit(ImportAddressPkStep1());
    });
  }
}
