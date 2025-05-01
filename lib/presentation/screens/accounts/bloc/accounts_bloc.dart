import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import "package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_event.dart";
import 'package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_state.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:formz/formz.dart';
import "package:equatable/equatable.dart";

abstract class GenerateAccountEvent {}

class GenerateAccountClicked extends GenerateAccountEvent {}

class GenerateAccountState extends Equatable {
  final FormzSubmissionStatus status;

  const GenerateAccountState({
    this.status = FormzSubmissionStatus.initial,
  });

  @override
  List<Object?> get props => [status];
}

class GenerateAccountBloc
    extends Bloc<GenerateAccountEvent, GenerateAccountState> {
  final InMemoryKeyRepository inMemoryKeyRepository;
  final AccountRepository accountRepository;
  final WalletRepository walletRepository;
  final WalletService walletService;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final AddressRepository addressRepository;
  final ErrorService errorService;

  GenerateAccountBloc({
    required this.inMemoryKeyRepository,
    required this.accountRepository,
    required this.walletRepository,
    required this.walletService,
    required this.encryptionService,
    required this.addressService,
    required this.addressRepository,
    required this.errorService,
  }) : super(const GenerateAccountState()) {
    on<GenerateAccountClicked>((event, emit) async {
      try {
        Wallet? wallet = await walletRepository.getCurrentWallet();

        if (wallet == null) {
          throw Exception("invariant: wallet is null");
        }

        String decryptedPrivKey = await encryptionService.decryptWithKey(
            wallet.encryptedPrivKey, (await inMemoryKeyRepository.get())!);

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
            List<Address> addresses =
                await addressService.deriveAddressFreewalletRange(
                    type: AddressType.bech32,
                    privKey: decryptedPrivKey,
                    chainCodeHex: wallet.chainCodeHex,
                    accountUuid: account.uuid,
                    account: account.accountIndex,
                    change: '0',
                    start: 0,
                    end: 9);

            List<Address> addressesLegacy =
                await addressService.deriveAddressFreewalletRange(
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
            List<Address> addresses =
                await addressService.deriveAddressFreewalletRange(
                    type: AddressType.bech32,
                    privKey: decryptedPrivKey,
                    chainCodeHex: wallet.chainCodeHex,
                    accountUuid: account.uuid,
                    account: account.accountIndex,
                    change: '0',
                    start: 0,
                    end: 0);

            List<Address> addressesLegacy =
                await addressService.deriveAddressFreewalletRange(
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

      } catch (e) {

      }
    });

  }
}
