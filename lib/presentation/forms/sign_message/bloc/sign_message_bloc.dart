import "package:fpdart/fpdart.dart";
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/format.dart';

import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/unified_address.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';

import "./sign_message_state.dart";
import "./sign_message_event.dart";

class SignMessageBloc extends Bloc<SignMessageEvent, SignMessageState> {
  final bool passwordRequired;
  final String message;
  final String address;
  final TransactionService transactionService;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final ImportedAddressService importedAddressService;
  final BitcoindService bitcoindService;
  final BitcoinRepository bitcoinRepository;
  final BalanceRepository balanceRepository;
  final UnifiedAddressRepository addressRepository;
  final AccountRepository accountRepository;
  final Map<String, List<int>> signInputs;
  final List<int>? sighashTypes;
  final InMemoryKeyRepository inMemoryKeyRepository;

  SignMessageBloc({
    required this.passwordRequired,
    required this.message,
    required this.address,
    required this.transactionService,
    required this.walletRepository,
    required this.encryptionService,
    required this.addressService,
    required this.importedAddressService,
    required this.bitcoindService,
    required this.balanceRepository,
    required this.bitcoinRepository,
    required this.addressRepository,
    required this.accountRepository,
    required this.signInputs,
    required this.sighashTypes,
    required this.inMemoryKeyRepository,
  }) : super(SignMessageState()) {
    on<PasswordChanged>(_handlePasswordChanged);
    on<SignMessageSubmitted>(_handleSignMessageSubmitted);
  }

  _handlePasswordChanged(
      PasswordChanged event, Emitter<SignMessageState> emit) {
    final password = PasswordInput.dirty(event.password);

    emit(state.copyWith(
      password: password,
      error: null,
      submissionStatus: FormzSubmissionStatus.initial,
    ));
  }

  _handleSignMessageSubmitted(
      SignMessageSubmitted event, Emitter<SignMessageState> emit) async {
    try {
      Wallet? wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        throw Exception("invariant: wallet not found");
      }

      String privateKey = '';

      if (passwordRequired) {
        try {
          privateKey = await encryptionService.decrypt(
              wallet.encryptedPrivKey, state.password.value);
        } catch (e) {
          emit(state.copyWith(
            submissionStatus: FormzSubmissionStatus.failure,
            error: "Incorrect password.",
          ));
          return;
        }
      } else {
        try {
          privateKey = await encryptionService.decryptWithKey(
              wallet.encryptedPrivKey, (await inMemoryKeyRepository.get())!);
        } catch (e) {
          emit(state.copyWith(
            submissionStatus: FormzSubmissionStatus.failure,
            error: "Invariant: could not decrypt wallet",
          ));
          return;
        }
      }

      final addressPrivKey = await addressRepository
          .get(address)
          .flatMap((UnifiedAddress unifiedAddress) => getUAddressPrivateKey(
                passwordRequired
                    ? Password(state.password.value)
                    : InMemoryKey(),
                privateKey,
                wallet.chainCodeHex,
                unifiedAddress,
              ))
          .match((error) => throw Exception("Could not find address: $address"),
              (addressPrivateKey) => addressPrivateKey)
          .run();


      // sign the message

      // Map<int, String> inputPrivateKeyMap = {};
      //
      // for (final entry in signInputs.entries) {
      //   final address = entry.key;
      //   final inputIndices = entry.value;
      //
      //   final result = await addressRepository
      //       .get(address)
      //       .flatMap((UnifiedAddress unifiedAddress) => getUAddressPrivateKey(
      //             passwordRequired
      //                 ? Password(state.password.value)
      //                 : InMemoryKey(),
      //             privateKey,
      //             wallet.chainCodeHex,
      //             unifiedAddress,
      //           ))
      //       .run();
      //
      //   result.fold(
      //       (error) => throw Exception("Could not find address: $address"),
      //       (addressPrivateKey) {
      //     for (final index in inputIndices) {
      //       inputPrivateKeyMap[index] = addressPrivateKey;
      //     }
      //   });
      // }
      //
      // String signedHex = transactionService.signMessage(
      //     unsignedMessage, inputPrivateKeyMap, sighashTypes);
      //
      // emit(state.copyWith(
      //   signedMessage: signedHex,
      //   submissionStatus: FormzSubmissionStatus.success,
      // ));
    } catch (e) {
      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.failure,
          error: e.toString()));
    }
  }

  TaskEither<String, String> getUAddressPrivateKey(
          DecryptionStrategy decryptionStrategy,
          String rootPrivKey,
          String chainCodeHex,
          UnifiedAddress address) =>
      switch (address) {
        UAddress(address: var address) =>
          getAddressPrivateKey(rootPrivKey, chainCodeHex, address),
        UImportedAddress(importedAddress: var importedAddress) =>
          getImportedAddressPrivateKey(importedAddress, decryptionStrategy)
      };

  TaskEither<String, String> getAddressPrivateKey(
          String rootPrivKey, String chainCodeHex, Address address) =>
      TaskEither.tryCatch(
          () =>
              _getAddressPrivKeyForAddress(rootPrivKey, chainCodeHex, address),
          (e, s) => "Failed to derive address private key.");

  TaskEither<String, String> getImportedAddressPrivateKey(
          ImportedAddress importedAddress,
          DecryptionStrategy decryptionStrategy) =>
      TaskEither.tryCatch(
          () => _getAddressPrivKeyForImportedAddress(
              importedAddress, decryptionStrategy),
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
