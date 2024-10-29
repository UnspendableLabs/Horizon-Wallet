import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/dashboard/view_address_pk_form/bloc/view_address_pk_event.dart';
import 'package:horizon/presentation/screens/dashboard/view_address_pk_form/bloc/view_address_pk_state.dart';

class ViewAddressPkError extends Error {
  final String message;
  ViewAddressPkError(this.message);
}

class ViewAddressPkFormBloc
    extends Bloc<ViewAddressPkFormEvent, ViewAddressPkState> {
  final AddressRepository addressRepository;
  final ImportedAddressRepository importedAddressRepository;
  final AddressService addressService;
  final WalletRepository walletRepository;
  final AccountRepository accountRepository;
  final EncryptionService encryptionService;
  final WalletService walletService;
  ViewAddressPkFormBloc({
    required this.addressRepository,
    required this.importedAddressRepository,
    required this.addressService,
    required this.walletRepository,
    required this.accountRepository,
    required this.encryptionService,
    required this.walletService,
  }) : super(const ViewAddressPkState.initial(
            ViewAddressPkStateInitial(error: null))) {
    on<ViewAddressPk>((event, emit) async {
      try {
        emit(const ViewAddressPkState.loading());

        final address = await addressRepository.getAddress(event.address);
        final importedAddress =
            await importedAddressRepository.getImportedAddress(event.address);

        if (address == null && importedAddress == null) {
          emit(const ViewAddressPkState.error('Address not found'));
          return;
        }
        String privateKeyWif;
        String name;
        if (address != null) {
          final account =
              await accountRepository.getAccountByUuid(address.accountUuid);
          if (account == null) {
            throw ViewAddressPkError('Account not found for address');
          }
          privateKeyWif = await _getPrivateKeyWifForAddress(
              account, address, event.password);
          name = account.name;
        } else {
          privateKeyWif = await _getPrivateKeyWifForImportedAddress(
              importedAddress!, event.password);
          name = importedAddress.name;
        }
        emit(ViewAddressPkState.success(ViewAddressPkStateSuccess(
            privateKeyWif: privateKeyWif, address: event.address, name: name)));
      } on ViewAddressPkError catch (e) {
        emit(ViewAddressPkState.initial(
            ViewAddressPkStateInitial(error: e.message)));
      } catch (e) {
        emit(const ViewAddressPkState.error('An unknown error occurred'));
      }
    });
  }

  _getPrivateKeyWifForAddress(
      Account account, Address address, String password) async {
    final wallet = await walletRepository.getWallet(account.walletUuid);
    if (wallet == null) {
      throw ViewAddressPkError('Wallet not found');
    }

    String decryptedPrivateKey;

    try {
      final encryptedPrivateKey = wallet.encryptedPrivKey;
      decryptedPrivateKey =
          await encryptionService.decrypt(encryptedPrivateKey, password);
    } catch (e) {
      throw ViewAddressPkError('Invalid password');
    }

    String privateKeyWif;

    try {
      privateKeyWif = await addressService.getAddressWIFFromPrivateKey(
          rootPrivKey: decryptedPrivateKey,
          chainCodeHex: wallet.chainCodeHex,
          purpose: account.purpose,
          coin: account.coinType,
          account: account.accountIndex,
          change: '0',
          index: address.index,
          importFormat: account.importFormat);
    } catch (e) {
      throw ViewAddressPkError('Unable to get private key');
    }

    return privateKeyWif;
  }

  _getPrivateKeyWifForImportedAddress(
      ImportedAddress importedAddress, String password) async {
    String decryptedPrivateKeyWif;

    try {
      decryptedPrivateKeyWif = await encryptionService.decrypt(
          importedAddress.encryptedPrivateKey, password);
    } catch (e) {
      throw ViewAddressPkError('Invalid password');
    }

    return decryptedPrivateKeyWif;
  }
}
