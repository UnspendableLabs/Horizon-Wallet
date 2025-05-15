import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import './get_addresses_event.dart';
import './get_addresses_state.dart';
import 'package:horizon/domain/entities/account_v2.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/public_key_service.dart';
import 'package:horizon/domain/entities/address_rpc.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/address_v2_repository.dart';
import 'package:horizon/domain/entities/http_config.dart';

class GetAddressesBloc extends Bloc<GetAddressesEvent, GetAddressesState> {
  final bool passwordRequired;
  final List<AccountV2> accounts;
  final ImportedAddressRepository importedAddressRepository;
  final EncryptionService encryptionService;
  // final AccountRepository accountRepository;
  final AddressService addressService;
  final ImportedAddressService importedAddressService;
  final PublicKeyService publicKeyService;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final HttpConfig httpConfig;
  final AddressV2Repository _addressV2Repository;

  GetAddressesBloc({
    required this.httpConfig,
    required this.inMemoryKeyRepository,
    required this.passwordRequired,
    required this.addressService,
    required this.importedAddressService,
    required this.accounts,
    required this.importedAddressRepository,
    required this.encryptionService,

    // required this.accountRepository,
    required this.publicKeyService,
    AddressV2Repository? addressV2Repository,
  })  : _addressV2Repository =
            addressV2Repository ?? GetIt.I<AddressV2Repository>(),
        super(GetAddressesState()) {
    on<AccountChanged>(_handleAccountChanged);
    on<GetAddressesSubmitted>(_handleGetAddressesSubmitted);
    on<AddressSelectionModeChanged>(_handleAddressSelectionModeChanged);
    on<ImportedAddressSelected>(_handleImportedAddressSelected);
    on<PasswordChanged>(_handlePasswordChanged);
    on<WarningAcceptedChanged>(_handleWarningAcceptedChanged);
  }

  _handlePasswordChanged(
      PasswordChanged event, Emitter<GetAddressesState> emit) {
    final password = PasswordInput.dirty(event.password);

    emit(state.copyWith(
      password: password,
    ));
  }

  void _handleAccountChanged(
      AccountChanged event, Emitter<GetAddressesState> emit) {
    final account = AccountInput.dirty(event.account.hash.toString());

    emit(state.copyWith(
      account: account,
      submissionStatus: Formz.validate([account])
          ? FormzSubmissionStatus.initial
          : FormzSubmissionStatus.failure,
    ));
  }

  Future<void> _handleGetAddressesSubmitted(
      GetAddressesSubmitted event, Emitter<GetAddressesState> emit) async {
    // TODO: must handle this
    if (state.addressSelectionMode != AddressSelectionMode.byAccount) {
      throw GetAddressesException('Address selection mode not supported.');
    }

    if (!state.warningAccepted) {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        error: 'Please accept the warning before continuing.',
      ));
      return;
    }
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    AccountV2 account = accounts.firstWhere(
      (account) => account.hash == state.account.value,
    );

    final task =
        TaskEither<GetAddressesException, List<AddressRpc>>.Do(($) async {
      List<AddressV2> addresses = await $(_addressV2Repository
          .getByAccountT(
              account: account,
              onError: (_, __) =>
                  "Failed to find addresses for account at index ${account.index}")
          .mapLeft((msg) => GetAddressesException(msg)));

      return addresses.map((a) => a.toRpc()).toList();
    });

    final result = await task.run();

    result.fold((error) {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        error: error.toString(),
      ));
    }, (addresses) async {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.success,
        addresses: addresses,
        error: null, // Clear any previous errors
      ));
    });
  }

  void _handleAddressSelectionModeChanged(AddressSelectionModeChanged event,
      Emitter<GetAddressesState> emit) async {
    if (event.mode == AddressSelectionMode.importedAddresses) {
      final importedAddresses = await importedAddressRepository.getAll();
      emit(state.copyWith(
          addressSelectionMode: event.mode,
          importedAddresses: importedAddresses));
    } else {
      emit(state.copyWith(addressSelectionMode: event.mode));
    }
  }

  void _handleImportedAddressSelected(
      ImportedAddressSelected event, Emitter<GetAddressesState> emit) {
    final importedAddress = ImportedAddressInput.dirty(event.address);
    emit(state.copyWith(
      importedAddress: importedAddress,
      submissionStatus: Formz.validate([importedAddress])
          ? FormzSubmissionStatus.initial
          : FormzSubmissionStatus.failure,
    ));
  }

  // Future<String> _getAddressPrivKeyForAddress(
  //     Address address, DecryptionStrategy decryptionStrategy) async {
  //   throw UnimplementedError(
  //       'This function is not implemented yet. Please implement it.');
  // final account =
  //     await accountRepository.getAccountByUuid(address.accountUuid);
  // if (account == null) {
  //   throw GetAddressesException('Account not found.');
  // }
  //
  // final wallet = await walletRepository.getWallet(account.walletUuid);
  //
  // // Decrypt Root Private Key
  // String decryptedRootPrivKey;
  // try {
  //   decryptedRootPrivKey = switch (decryptionStrategy) {
  //     Password(password: var password) =>
  //       await encryptionService.decrypt(wallet!.encryptedPrivKey, password),
  //     InMemoryKey() => await encryptionService.decryptWithKey(
  //         wallet!.encryptedPrivKey, (await inMemoryKeyRepository.get())!)
  //   };
  // } catch (e) {
  //   throw GetAddressesException('Incorrect password.');
  // }
  //
  // // Derive Address Private Key
  // final addressPrivKey = await addressService.deriveAddressPrivateKey(
  //   rootPrivKey: decryptedRootPrivKey,
  //   chainCodeHex: wallet.chainCodeHex,
  //   purpose: account.purpose,
  //   coin: account.coinType,
  //   account: account.accountIndex,
  //   change: '0',
  //   index: address.index,
  //   importFormat: account.importFormat,
  // );
  //
  // return addressPrivKey;
  // }
  //
  // Future<String> _getAddressPrivKeyForImportedAddress(
  //     ImportedAddress importedAddress,
  //     DecryptionStrategy decryptionStrategy) async {
  //   late String decryptedAddressWif;
  //   try {
  //     final maybeKey =
  //         (await inMemoryKeyRepository.getMap())[importedAddress.address];
  //
  //     decryptedAddressWif = switch (decryptionStrategy) {
  //       Password(password: var password) => await encryptionService.decrypt(
  //           importedAddress.encryptedWif, password),
  //       InMemoryKey() => await encryptionService.decryptWithKey(
  //           importedAddress.encryptedWif, maybeKey!)
  //     };
  //   } catch (e) {
  //     throw GetAddressesException('Incorrect password.');
  //   }
  //
  //   final addressPrivKey =
  //       await importedAddressService.getAddressPrivateKeyFromWIF(
  //           wif: decryptedAddressWif, network: httpConfig.network);
  //
  //   return addressPrivKey;
  // }

  // _getAddressRpcType(String address) {
  //   if (address.startsWith("bc") || address.startsWith("tb")) {
  //     return AddressRpcType.p2wpkh;
  //   } else {
  //     return AddressRpcType.p2pkh;
  //   }
  // }

  void _handleWarningAcceptedChanged(
      WarningAcceptedChanged event, Emitter<GetAddressesState> emit) {
    emit(state.copyWith(warningAccepted: event.accepted));
  }
}

class GetAddressesException implements Exception {
  final String message;
  GetAddressesException(
      [this.message =
          'An error occurred during the sign and broadcast process.']);
}
