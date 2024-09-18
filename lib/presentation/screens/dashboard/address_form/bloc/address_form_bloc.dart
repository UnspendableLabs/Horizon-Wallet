import 'package:flutter_bloc/flutter_bloc.dart';
import "package:horizon/common/constants.dart";
import "package:horizon/domain/entities/account.dart";
import "package:horizon/domain/entities/address.dart";
import "package:horizon/domain/entities/wallet.dart";
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import "package:horizon/presentation/screens/dashboard/address_form/bloc/address_form_event.dart";
import "package:horizon/remote_data_bloc/remote_data_state.dart";

class AddressFormBloc
    extends Bloc<AddressFormEvent, RemoteDataState<Map<String, dynamic>>> {
  final WalletRepository walletRepository;
  final WalletService walletService;
  final EncryptionService encryptionService;
  final AddressRepository addressRepository;
  final AccountRepository accountRepository;
  final AddressService addressService;

  AddressFormBloc({
    required this.walletRepository,
    required this.walletService,
    required this.encryptionService,
    required this.addressRepository,
    required this.accountRepository,
    required this.addressService,
  }) : super(const RemoteDataState.initial()) {
    on<Submit>((event, emit) async {
      final currentState = state;

      emit(const RemoteDataState.loading());

      try {
        Wallet? wallet = await walletRepository.getCurrentWallet();

        if (wallet == null) {
          throw Exception("invariant: wallet is null");
        }

        String decryptedPrivKey;
        try {
          decryptedPrivKey = await encryptionService.decrypt(
              wallet.encryptedPrivKey, event.password);
        } catch (e) {
          throw Exception("Incorrect password");
        }

        Wallet compareWallet = await walletService.fromPrivateKey(
            decryptedPrivKey, wallet.chainCodeHex);

        if (wallet.publicKey != compareWallet.publicKey) {
          throw Exception("Incorrect password");
        }

        Account? account =
            await accountRepository.getAccountByUuid(event.accountUuid);

        if (account == null) {
          throw Exception("invariant: account is null: $event.accountUuid");
        }

        List<Address> addresses =
            await addressRepository.getAllByAccountUuid(event.accountUuid);

        int maxIndex = addresses
            .reduce((acc, curr) => acc.index > curr.index ? acc : curr)
            .index;

        switch (account.importFormat) {
          case ImportFormat.horizon:
            // this is a no-op
            emit(currentState);
            break;
          case ImportFormat.freewallet:
            List<Address> legacyAddresses =
                await addressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: decryptedPrivKey,
              chainCodeHex: wallet.chainCodeHex,
              accountUuid: account.uuid,
              account: account.accountIndex,
              change: "0",
              start: maxIndex + 1,
              end: maxIndex + 1,
            );

            List<Address> bech32Addresses =
                await addressService.deriveAddressFreewalletRange(
              type: AddressType.bech32,
              privKey: decryptedPrivKey,
              chainCodeHex: wallet.chainCodeHex,
              accountUuid: account.uuid,
              account: account.accountIndex,
              change: "0",
              start: maxIndex + 1,
              end: maxIndex + 1,
            );

            final newAddresses = [bech32Addresses[0], legacyAddresses[0]];

            await addressRepository.insertMany(newAddresses);

            emit(RemoteDataState.success({
              'newAddresses': newAddresses,
              'accountUuid': event.accountUuid
            }));
            break;

          case ImportFormat.counterwallet:
            List<Address> legacyAddresses =
                await addressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: decryptedPrivKey,
              chainCodeHex: wallet.chainCodeHex,
              accountUuid: account.uuid,
              account: account.accountIndex,
              change: "0",
              start: maxIndex + 1,
              end: maxIndex + 1,
            );

            List<Address> bech32Addresses =
                await addressService.deriveAddressFreewalletRange(
              type: AddressType.bech32,
              privKey: decryptedPrivKey,
              chainCodeHex: wallet.chainCodeHex,
              accountUuid: account.uuid,
              account: account.accountIndex,
              change: "0",
              start: maxIndex + 1,
              end: maxIndex + 1,
            );
            final newAddresses = [bech32Addresses[0], legacyAddresses[0]];
            await addressRepository.insertMany(newAddresses);

            emit(RemoteDataState.success({
              'newAddresses': newAddresses,
              'accountUuid': event.accountUuid
            }));
            break;
        }
      } catch (e) {
        emit(RemoteDataState.error(e.toString()));
      }
    });

    on<Reset>((event, emit) {
      emit(const RemoteDataState.initial());
    });
  }
}
