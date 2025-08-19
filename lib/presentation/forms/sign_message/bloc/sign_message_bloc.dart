import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import "package:fpdart/fpdart.dart";

import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';

import "./sign_message_state.dart";
import "./sign_message_event.dart";

class SignMessageBloc extends Bloc<SignMessageEvent, SignMessageState> {
  final bool passwordRequired;
  final String message;
  final AddressV2 address;
  final TransactionService _transactionService;
  final EncryptionService _encryptionService;
  final AddressService _addressService;
  final InMemoryKeyRepository _inMemoryKeyRepository;
  final WalletConfigRepository _walletConfigRepository;
  final SeedService _seedService;
  final HttpConfig httpConfig;

  SignMessageBloc({
    required this.httpConfig,
    required this.passwordRequired,
    required this.message,
    required this.address,
    TransactionService? transactionService,
    EncryptionService? encryptionService,
    AddressService? addressService,
    WalletConfigRepository? walletConfigRepository,
    InMemoryKeyRepository? inMemoryKeyRepository,
    SeedService? seedService,
  })  : _seedService = seedService ?? GetIt.I<SeedService>(),
        _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _inMemoryKeyRepository =
            inMemoryKeyRepository ?? GetIt.I<InMemoryKeyRepository>(),
        _addressService = addressService ?? GetIt.I<AddressService>(),
        _encryptionService = encryptionService ?? GetIt.I<EncryptionService>(),
        _transactionService =
            transactionService ?? GetIt.I<TransactionService>(),
        super(SignMessageState(
          message: message,
        )) {
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
    final decryptionStrategy =
        passwordRequired ? Password(state.password.value) : InMemoryKey();

    final task = TaskEither<String, String>.Do(($) async {
      String pk = switch (address.derivation) {
        Bip32Path(value: var value) => await $(_walletConfigRepository
            .getCurrentT((_) => "invariant: could not read wallet config")
            .flatMap((walletConfig) => _seedService
                .getForWalletConfigT(
                    walletConfig: walletConfig,
                    decryptionStrategy: decryptionStrategy,
                    onError: (_) => "invairant: could not derive seed")
                .flatMap((seed) => _addressService.deriveAddressPrivateKeyWIPT(
                      path: Bip32Path(value: value),
                      seed: seed,
                      network: httpConfig.network,
                    )))),
        WIF(value: var value) => await $(switch (decryptionStrategy) {
            Password(password: var password) => _encryptionService.decryptT(
                data: value,
                password: password,
                onError: (_, __) => "Invalid password"),
            InMemoryKey() => _inMemoryKeyRepository
                .getMapT(
                    onError: (_, __) =>
                        "invariant: failed to read in memory key map")
                // TODO: this lookup needs to be consistent, either by encyptedWIF or address
                .flatMap((map) => TaskEither.fromOption(
                    Option.fromNullable(map[address.address]),
                    () =>
                        "invariant: decryption key not found for address: ${address.address}"))
                .flatMap((decryptionKey) => _encryptionService.decryptWithKeyT(
                    data: value,
                    key: decryptionKey,
                    onError: (_, __) =>
                        "failed to decrypt wif for address: ${address.address}")),
          })
      };

      final signedMessage =
          await $(TaskEither.fromEither(_transactionService.signMessageT(
        httpConfig: httpConfig,
        message: state.message,
        privateKey: pk,
        onError: (err) =>
            "Error signing message for address ${address.address}",
      )));

      return signedMessage;
    });

    final result = await task.run();

    final nextState = result.fold(
      (error) => state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        error: error,
      ),
      (signature) => state.copyWith(
        signature: signature,
        submissionStatus: FormzSubmissionStatus.success,
      ),
    );

    emit(nextState);
  }
}
