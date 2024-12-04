import "package:fpdart/fpdart.dart";
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/unified_address.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';

import "./sign_psbt_state.dart";
import "./sign_psbt_event.dart";

class SignPsbtBloc extends Bloc<SignPsbtEvent, SignPsbtState> {
  final String unsignedPsbt;
  final TransactionService transactionService;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final ImportedAddressService importedAddressService;
  final UnifiedAddressRepository addressRepository;
  final AccountRepository accountRepository;
  final Map<String, List<int>> signInputs;
  final List<int>? sighashTypes;

  SignPsbtBloc({
    required this.unsignedPsbt,
    required this.transactionService,
    required this.walletRepository,
    required this.encryptionService,
    required this.addressService,
    required this.importedAddressService,
    required this.addressRepository,
    required this.accountRepository,
    required this.signInputs,
    required this.sighashTypes,
  }) : super(SignPsbtState()) {
    on<FetchFormEvent>(_handleFetchForm);
    on<PasswordChanged>(_handlePasswordChanged);
    on<SignPsbtSubmitted>(_handleSignPsbtSubmitted);
  }

  Future<void> _handleFetchForm(
    FetchFormEvent event,
    Emitter<SignPsbtState> emit,
  ) async {
    final decoded =
        transactionService.psbtToUnsignedTransactionHex(unsignedPsbt);

    print("decoded: $decoded");

  }

  _handlePasswordChanged(PasswordChanged event, Emitter<SignPsbtState> emit) {
    final password = PasswordInput.dirty(event.password);

    emit(state.copyWith(
      password: password,
    ));
  }

  _handleSignPsbtSubmitted(
      SignPsbtSubmitted event, Emitter<SignPsbtState> emit) async {
    try {
      Wallet? wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        throw Exception("invariant: wallet not found");
      }

      String privateKey = await encryptionService.decrypt(
          wallet.encryptedPrivKey, state.password.value);

      Map<int, String> inputPrivateKeyMap = {};

      for (final entry in signInputs.entries) {
        final address = entry.key;
        final inputIndices = entry.value;

        final result = await addressRepository
            .get(address)
            .flatMap((UnifiedAddress unifiedAddress) => getUAddressPrivateKey(
                  state.password.value,
                  privateKey,
                  wallet.chainCodeHex,
                  unifiedAddress,
                ))
            .run();

        result.fold(
            (error) => throw Exception("Could not find address: $address"),
            (addressPrivateKey) {
          for (final index in inputIndices) {
            inputPrivateKeyMap[index] = addressPrivateKey;
          }
        });
      }

      String signedHex = transactionService.signPsbt(
          unsignedPsbt, inputPrivateKeyMap, sighashTypes);

      emit(state.copyWith(
        signedPsbt: signedHex,
        submissionStatus: FormzSubmissionStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.failure,
          error: e.toString()));
    }
  }

  TaskEither<String, String> getUAddressPrivateKey(String password,
          String rootPrivKey, String chainCodeHex, UnifiedAddress address) =>
      switch (address) {
        UAddress(address: var address) =>
          getAddressPrivateKey(rootPrivKey, chainCodeHex, address),
        UImportedAddress(importedAddress: var importedAddress) =>
          getImportedAddressPrivateKey(importedAddress, password),
      };

  TaskEither<String, String> getAddressPrivateKey(
          String rootPrivKey, String chainCodeHex, Address address) =>
      TaskEither.tryCatch(
          () =>
              _getAddressPrivKeyForAddress(rootPrivKey, chainCodeHex, address),
          (e, s) => "Failed to derive address private key.");

  TaskEither<String, String> getImportedAddressPrivateKey(
          ImportedAddress importedAddress, String password) =>
      TaskEither.tryCatch(
          () => _getAddressPrivKeyForImportedAddress(importedAddress, password),
          (e, s) => "Failed to derive address private key.");

  Future<String> _getAddressPrivKeyForAddress(
      String rootPrivKey, String chainCodeHex, Address address) async {
    final account =
        await accountRepository.getAccountByUuid(address.accountUuid);

    if (account == null) {
      throw Exception('Account not found.');
    }

    // Derive Address Private Key
    final addressPrivKey = await addressService.deriveAddressPrivateKey(
      rootPrivKey: rootPrivKey,
      chainCodeHex: chainCodeHex,
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
      ImportedAddress importedAddress, String password) async {
    late String decryptedAddressWif;
    try {
      decryptedAddressWif = await encryptionService.decrypt(
          importedAddress.encryptedWif, password);
    } catch (e) {
      throw Exception('Incorrect password.');
    }

    final addressPrivKey = await importedAddressService
        .getAddressPrivateKeyFromWIF(wif: decryptedAddressWif);

    return addressPrivKey;
  }
}

class FailedToDeriveAddressPrivateKey extends Error {
  final String address;
  FailedToDeriveAddressPrivateKey(this.address);
}
