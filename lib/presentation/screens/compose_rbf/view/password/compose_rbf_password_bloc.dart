import 'package:equatable/equatable.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/entities/failure.dart';
import "package:fpdart/fpdart.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';

import 'package:formz/formz.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/unified_address.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/common/fn.dart';

import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

import 'package:horizon/domain/entities/decryption_strategy.dart';

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
}

class PasswordChanged extends FormEvent {
  final String password;
  const PasswordChanged({required this.password});
}

class FormSubmitted extends FormEvent {
  const FormSubmitted();
}

enum PasswordValidationError { required }

class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure() : super.pure('');

  const PasswordInput.dirty(super.value) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    return value.isNotEmpty ? null : PasswordValidationError.required;
  }
}

class FormStateModel extends Equatable {
  final PasswordInput password;

  final String psbtHex;
  final FormzSubmissionStatus submissionStatus;
  final String? errorMessage;

  const FormStateModel({
    required this.psbtHex,
    this.password = const PasswordInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  FormStateModel copyWith({
    PasswordInput? password,
    String? psbtHex,
    FormzSubmissionStatus? submissionStatus,
    String? errorMessage,
  }) {
    return FormStateModel(
      password: password ?? this.password,
      psbtHex: psbtHex ?? this.psbtHex,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [password, psbtHex, submissionStatus, errorMessage];
}

class ComposeRbfPasswordBloc extends Bloc<FormEvent, FormStateModel> {
  final bool passwordRequired;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final String address;
  final String txHashToReplace;
  final MakeRBFResponse makeRBFResponse;

  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final TransactionLocalRepository transactionLocalRepository;

  final AnalyticsService analyticsService;
  final BitcoindService bitcoindService;
  final AddressService addressService;
  final AccountRepository accountRepository;
  final TransactionService transactionService;
  final EncryptionService encryptionService;
  final WalletRepository walletRepository;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final UnifiedAddressRepository addressRepository;
  final ImportedAddressService importedAddressService;
  final BitcoinRepository bitcoinRepository;

  ComposeRbfPasswordBloc({
    required this.inMemoryKeyRepository,
    required this.passwordRequired,
    required this.txHashToReplace,
    required this.analyticsService,
    required this.bitcoindService,
    required this.makeRBFResponse,
    required this.address,
    required this.walletRepository,
    required this.signAndBroadcastTransactionUseCase,
    required this.transactionService,
    required this.encryptionService,
    required this.addressRepository,
    required this.accountRepository,
    required this.addressService,
    required this.importedAddressService,
    required this.bitcoinRepository,
    required this.writelocalTransactionUseCase,
    required this.transactionLocalRepository,
  }) : super(FormStateModel(psbtHex: makeRBFResponse.txHex)) {
    on<PasswordChanged>((event, emit) {
      final password = PasswordInput.dirty(event.password);
      emit(state.copyWith(password: password));
    });

    on<FormSubmitted>((event, emit) async {
      emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

      try {
        Wallet? wallet = await walletRepository.getCurrentWallet();

        if (wallet == null) {
          throw Exception("invariant: wallet not found");
        }

        String rootPrivateKey = passwordRequired
            ? await encryptionService.decrypt(
                wallet.encryptedPrivKey, state.password.value)
            : await encryptionService.decryptWithKey(
                wallet.encryptedPrivKey, (await inMemoryKeyRepository.get())!);

        String addressPrivateKey = unwrapOrThrow<String, String>(
            await addressRepository
                .get(address)
                .flatMap(
                    (UnifiedAddress unifiedAddress) => getUAddressPrivateKey(
                          passwordRequired
                              ? Password(state.password.value)
                              : InMemoryKey(),
                          rootPrivateKey,
                          wallet.chainCodeHex,
                          unifiedAddress,
                        ))
                .run());

        Map<String, Utxo> utxoMap = {};

        for (final entry in makeRBFResponse.inputsByTxHash.entries) {
          final txHash = entry.key;
          final inputIndices = entry.value;

          final transaction = unwrapOrThrow<Failure, BitcoinTx>(
              await bitcoinRepository.getTransaction(txHash));
          for (final index in inputIndices) {
            final input = transaction.vout[index];
            final utxo = Utxo(
                txid: txHash,
                vout: index,
                value: input.value,
                address: address // TODO: temp hack
                );
            utxoMap["$txHash:$index"] = utxo;
          }
        }

        final txHex = await transactionService.signTransaction(
            makeRBFResponse.txHex, addressPrivateKey, address, utxoMap);

        final txHash = await bitcoindService.sendrawtransaction(txHex);

        // not technically necessary since event shows up very quickly in practive
        await writelocalTransactionUseCase.call(txHex, txHash);

        transactionLocalRepository.delete(txHashToReplace);

        analyticsService.trackAnonymousEvent('broadcast_rbf',
            properties: {'distinct_id': uuid.v4()});

        emit(state.copyWith(submissionStatus: FormzSubmissionStatus.success));
      } catch (e) {
        emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
          // error: "Incorrect password.",
        ));
      }
    });
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
