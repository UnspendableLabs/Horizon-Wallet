import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import './get_addresses_event.dart';
import './get_addresses_state.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/public_key_service.dart';
import 'package:horizon/domain/entities/address_rpc.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

class GetAddressesBloc extends Bloc<GetAddressesEvent, GetAddressesState> {
  final bool passwordRequired;
  final List<Account> accounts;
  final AddressRepository addressRepository;
  final ImportedAddressRepository importedAddressRepository;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AccountRepository accountRepository;
  final AddressService addressService;
  final ImportedAddressService importedAddressService;
  final PublicKeyService publicKeyService;
  final InMemoryKeyRepository inMemoryKeyRepository;

  GetAddressesBloc({
    required this.inMemoryKeyRepository,
    required this.passwordRequired,
    required this.addressService,
    required this.importedAddressService,
    required this.accounts,
    required this.addressRepository,
    required this.importedAddressRepository,
    required this.walletRepository,
    required this.encryptionService,
    required this.accountRepository,
    required this.publicKeyService,
  }) : super(GetAddressesState()) {
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
    final account = AccountInput.dirty(event.accountUuid);

    emit(state.copyWith(
      account: account,
      submissionStatus: Formz.validate([account])
          ? FormzSubmissionStatus.initial
          : FormzSubmissionStatus.failure,
    ));
  }

  Future<void> _handleGetAddressesSubmitted(
      GetAddressesSubmitted event, Emitter<GetAddressesState> emit) async {
    if (!state.warningAccepted) {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        error: 'Please accept the warning before continuing.',
      ));
      return;
    }
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));
    try {
      Wallet? wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        throw GetAddressesException("invariant:No wallet found");
      }

      final selectedAccountUuid = state.account.value;

      List<AddressRpc> addresses = [];

      if (state.addressSelectionMode == AddressSelectionMode.byAccount) {
        List<Address> addresses_ =
            await addressRepository.getAllByAccountUuid(selectedAccountUuid);

        for (var address in addresses_) {
          final pk = passwordRequired
              ? await _getAddressPrivKeyForAddress(
                  address, Password(state.password.value))
              : await _getAddressPrivKeyForAddress(address, InMemoryKey());

          final publicKey = await publicKeyService.fromPrivateKeyAsHex(pk);

          addresses.add(AddressRpc(
              address: address.address,
              type: _getAddressRpcType(address.address),
              publicKey: publicKey));
        }
      } else {
        // address is imported
        final importedAddress = await importedAddressRepository
            .getImportedAddress(state.importedAddress.value);

        if (importedAddress == null) {
          throw GetAddressesException('Imported address not found.');
        }

        final pk = passwordRequired
            ? await _getAddressPrivKeyForImportedAddress(
                importedAddress, Password(state.password.value))
            : await _getAddressPrivKeyForImportedAddress(
                importedAddress, InMemoryKey());

        final publicKey = await publicKeyService.fromPrivateKeyAsHex(pk);

        addresses.add(AddressRpc(
            address: importedAddress.address,
            type: _getAddressRpcType(importedAddress.address),
            publicKey: publicKey));
      }

      if (addresses.isEmpty &&
          state.addressSelectionMode == AddressSelectionMode.byAccount) {
        throw GetAddressesException("No account selected");
      }

      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.success,
        addresses: addresses,
        error: null, // Clear any previous errors
      ));
    } catch (e) {
      // Handle different types of errors
      final errorMessage = e is GetAddressesException
          ? e.message
          : 'An unexpected error occurred. Please try again.';

      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        error: errorMessage,
      ));
    }
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

  Future<String> _getAddressPrivKeyForAddress(
      Address address, DecryptionStrategy decryptionStrategy) async {
    final account =
        await accountRepository.getAccountByUuid(address.accountUuid);
    if (account == null) {
      throw GetAddressesException('Account not found.');
    }

    final wallet = await walletRepository.getWallet(account.walletUuid);

    // Decrypt Root Private Key
    String decryptedRootPrivKey;
    try {
      decryptedRootPrivKey = switch (decryptionStrategy) {
        Password(password: var password) =>
          await encryptionService.decrypt(wallet!.encryptedPrivKey, password),
        InMemoryKey() => await encryptionService.decryptWithKey(
            wallet!.encryptedPrivKey, (await inMemoryKeyRepository.get())!)
      };
    } catch (e) {
      throw GetAddressesException('Incorrect password.');
    }

    // Derive Address Private Key
    final addressPrivKey = await addressService.deriveAddressPrivateKey(
      rootPrivKey: decryptedRootPrivKey,
      chainCodeHex: wallet.chainCodeHex,
      purpose: account.purpose,
      coin: account.coinType,
      account: account.accountIndex,
      change: '0',
      index: address.index,
      importFormat: account.importFormat,
    );

    return addressPrivKey;
  }

  Future<String> _getAddressPrivKeyForImportedAddress(
      ImportedAddress importedAddress,
      DecryptionStrategy decryptionStrategy) async {
    late String decryptedAddressWif;
    try {
      final maybeKey =
          (await inMemoryKeyRepository.getMap())[importedAddress.address];

      decryptedAddressWif = switch (decryptionStrategy) {
        Password(password: var password) => await encryptionService.decrypt(
            importedAddress.encryptedWif, password),
        InMemoryKey() => await encryptionService.decryptWithKey(
            importedAddress.encryptedWif, maybeKey!)
      };
    } catch (e) {
      throw GetAddressesException('Incorrect password.');
    }

    final addressPrivKey = await importedAddressService
        .getAddressPrivateKeyFromWIF(wif: decryptedAddressWif);

    return addressPrivKey;
  }

  _getAddressRpcType(String address) {
    if (address.startsWith("bc") || address.startsWith("tb")) {
      return AddressRpcType.p2wpkh;
    } else {
      return AddressRpcType.p2pkh;
    }
  }

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
