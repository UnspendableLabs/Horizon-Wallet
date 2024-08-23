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
import 'package:horizon/domain/services/wallet_service.dart';
import "package:horizon/presentation/shell/account_form/bloc/account_form_event.dart";
import "package:horizon/remote_data_bloc/remote_data_state.dart";

class AccountFormBloc extends Bloc<AccountFormEvent, RemoteDataState<Account>> {
  final accountRepository = GetIt.I<AccountRepository>();
  final walletRepository = GetIt.I<WalletRepository>();
  final walletService = GetIt.I<WalletService>();
  final encryptionService = GetIt.I<EncryptionService>();
  final addressService = GetIt.I<AddressService>();
  final addressRepository = GetIt.I<AddressRepository>();

  AccountFormBloc() : super(const RemoteDataState.initial()) {
    on<Submit>((event, emit) async {
      emit(const RemoteDataState.loading());

      try {
        Wallet? wallet = await walletRepository.getCurrentWallet();

        if (wallet == null) {
          throw Exception("invariant: wallet is null");
        }

        String decryptedPrivKey = await encryptionService.decrypt(wallet.encryptedPrivKey, event.password);

        Wallet compareWallet = await walletService.fromPrivateKey(decryptedPrivKey, wallet.chainCodeHex);

        if (wallet.publicKey != compareWallet.publicKey) {
          throw Exception("invalid password");
        }

        final account = Account(
          name: event.name,
          uuid: uuid.v4(),
          walletUuid: event.walletUuid,
          purpose: event.purpose,
          coinType: event.coinType,
          accountIndex: event.accountIndex,
          importFormat: event.importFormat,
        );

        switch (event.importFormat) {
          // if it's just segwit, only imprt single addy
          case ImportFormat.horizon:
            Address address = await addressService.deriveAddressSegwit(
              privKey: decryptedPrivKey,
              chainCodeHex: wallet.chainCodeHex,
              accountUuid: account.uuid,
              purpose: account.purpose,
              coin: account.coinType,
              account: account.accountIndex,
              change: '0',
              index: 0,
            );

            await accountRepository.insert(account);
            await addressRepository.insert(address);

          case ImportFormat.freewallet:
            List<Address> addresses = await addressService.deriveAddressFreewalletRange(
                type: AddressType.bech32,
                privKey: decryptedPrivKey,
                chainCodeHex: wallet.chainCodeHex,
                accountUuid: account.uuid,
                account: account.accountIndex,
                change: '0',
                start: 0,
                end: 9);

            List<Address> addressesLegacy = await addressService.deriveAddressFreewalletRange(
                type: AddressType.legacy,
                privKey: decryptedPrivKey,
                chainCodeHex: wallet.chainCodeHex,
                accountUuid: account.uuid,
                account: account.accountIndex,
                change: '0',
                start: 0,
                end: 9);

            await accountRepository.insert(account);
            await addressRepository.insertMany(addresses);
            await addressRepository.insertMany(addressesLegacy);

          case ImportFormat.counterwallet:
            List<Address> addresses = await addressService.deriveAddressFreewalletRange(
                type: AddressType.bech32,
                privKey: decryptedPrivKey,
                chainCodeHex: wallet.chainCodeHex,
                accountUuid: account.uuid,
                account: account.accountIndex,
                change: '0',
                start: 0,
                end: 9);

            // TODO: fix misnomer method
            List<Address> addressesLegacy = await addressService.deriveAddressFreewalletRange(
                type: AddressType.legacy,
                privKey: decryptedPrivKey,
                chainCodeHex: wallet.chainCodeHex,
                accountUuid: account.uuid,
                account: account.accountIndex,
                change: '0',
                start: 0,
                end: 0);

            await accountRepository.insert(account);
            await addressRepository.insertMany(addresses);
            await addressRepository.insertMany(addressesLegacy);

          default:
            throw Exception("invalid import format");
        }

        emit(RemoteDataState.success(account));
      } catch (e) {
        emit(RemoteDataState.error(e.toString()));
      }
    });
  }
}
