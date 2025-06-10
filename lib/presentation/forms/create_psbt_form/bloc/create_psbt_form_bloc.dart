import 'package:equatable/equatable.dart';
import 'package:horizon/data/sources/local/db.dart';
import "package:horizon/domain/entities/bitcoin_tx.dart";
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';

import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/js/bitcoin.dart';

import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';

enum BtcPriceInputError { required, isNaN, isNegative }

class BtcPriceInput extends FormzInput<String, BtcPriceInputError> {
  const BtcPriceInput.pure() : super.pure('');
  const BtcPriceInput.dirty({required String value}) : super.dirty(value);
  @override
  BtcPriceInputError? validator(String value) {
    if (value.isEmpty) {
      return BtcPriceInputError.required;
    }

    return asDecimal.fold(
      () => BtcPriceInputError.isNaN,
      (decimal) =>
          decimal <= Decimal.zero ? BtcPriceInputError.isNegative : null,
    );
  }

  Option<Decimal> get asDecimal {
    return Option.tryCatch(() => Decimal.parse(value));
  }

  Option<BigInt> get asSats {
    // chat, wihtha  value decimal value of 0.02, this returns 0
    return asDecimal.map((d) => d * Decimal.fromInt(100000000)).map(
          (d) => d.toBigInt(),
        );
  }
}

class CreatePsbtFormModel with FormzMixin {
  final BtcPriceInput btcPriceInput;
  final FormzSubmissionStatus submissionStatus;
  final DateTime? expiryDate;
  final String? error;
  final String? signedPsbt;

  CreatePsbtFormModel(
      {required this.btcPriceInput,
      required this.submissionStatus,
      this.expiryDate,
      this.error,
      this.signedPsbt});

  @override
  List<FormzInput> get inputs => [btcPriceInput];

  CreatePsbtFormModel copyWith({
    BtcPriceInput? btcPriceInput,
    DateTime? expiryDate,
    FormzSubmissionStatus? submissionStatus,
    String? error,
    String? signedPsbt,
  }) =>
      CreatePsbtFormModel(
        btcPriceInput: btcPriceInput ?? this.btcPriceInput,
        expiryDate: expiryDate ?? this.expiryDate,
        submissionStatus: submissionStatus ?? this.submissionStatus,
        error: error ?? this.error,
        signedPsbt: signedPsbt ?? this.signedPsbt,
      );

  get submitDisabled => isNotValid || submissionStatus.isInProgress;
}

sealed class CreatePsbtFormEvent extends Equatable {
  const CreatePsbtFormEvent();

  @override
  List<Object?> get props => [];
}

class BtcPriceInputChanged extends CreatePsbtFormEvent {
  final String value;

  const BtcPriceInputChanged({required this.value});
}

class SubmitClicked extends CreatePsbtFormEvent {}

class ExpiryDateSelected extends CreatePsbtFormEvent {
  final DateTime? date;

  const ExpiryDateSelected({this.date});
}

class CreatePsbtFormBloc
    extends Bloc<CreatePsbtFormEvent, CreatePsbtFormModel> {
  final AddressV2 address;

  final String utxoID;
  final HttpConfig httpConfig;

  final BitcoinRepository _bitcoinRepository;
  final TransactionService _transactionService;

  final WalletConfigRepository _walletConfigRepository;
  final SeedService _seedService;
  final InMemoryKeyRepository _inMemoryKeyRepository;

  final EncryptionService _encryptionService;
  final AddressService _addressService;

  CreatePsbtFormBloc({
    required this.address,
    required this.httpConfig,
    required this.utxoID,
    BitcoinRepository? bitcoinRepository,
    TransactionService? transactionService,
    WalletConfigRepository? walletConfigRepository,
    SeedService? seedService,
    InMemoryKeyRepository? inMemoryKeyRepository,
    EncryptionService? encryptionService,
    AddressService? addressService,
  })  : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _transactionService =
            transactionService ?? GetIt.I<TransactionService>(),
        _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _seedService = seedService ?? GetIt.I<SeedService>(),
        _inMemoryKeyRepository =
            inMemoryKeyRepository ?? GetIt.I<InMemoryKeyRepository>(),
        _encryptionService = encryptionService ?? GetIt.I<EncryptionService>(),
        _addressService = addressService ?? GetIt.I<AddressService>(),
        super(
          CreatePsbtFormModel(
            btcPriceInput:
                const BtcPriceInput.dirty(value: "0.00"), // const value
            submissionStatus: FormzSubmissionStatus.initial,
          ),
        ) {
    on<BtcPriceInputChanged>(_onBtcPriceInputChanged); // handler wired up once
    on<SubmitClicked>(_onSubmitClicked);
    on<ExpiryDateSelected>(_onExpiryDateSelected);
  }

  void _onExpiryDateSelected(ExpiryDateSelected event, Emitter<CreatePsbtFormModel> emit) {
    emit(state.copyWith(expiryDate: event.date));
  }

  // give the handler an explicit return type
  void _onBtcPriceInputChanged(
    BtcPriceInputChanged event,
    Emitter<CreatePsbtFormModel> emit,
  ) {
    emit(
      state.copyWith(
        btcPriceInput: BtcPriceInput.dirty(value: event.value), // mark it dirty
        submissionStatus: FormzSubmissionStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitClicked(
    SubmitClicked event,
    Emitter<CreatePsbtFormModel> emit,
  ) async {
    final attachTxID = utxoID.split(":")[0];
    final voutIndex = int.parse(utxoID.split(":")[1]);

    final task = TaskEither<String, String>.Do(($) async {
      final tx = await $(_bitcoinRepository.getTransactionT(
          txid: attachTxID,
          httpConfig: httpConfig,
          onError: (_) => "Error fetching tx with id: $utxoID"));

      final priceInSats = await $(TaskEither.fromOption(
          state.btcPriceInput.asSats,
          () => "Error parsing BTC price input as sats"));


      final newSalePsbtHex = await $(TaskEither.fromEither(
          _transactionService.makeSalePsbtT(
              // expiryDate: state.expiryDate,  // TODO: add expiry date
              price: priceInSats,
              source: address.address,
              utxoTxid: attachTxID,
              utxoVoutIndex: voutIndex,
              utxoVout: tx.vout[voutIndex],
              httpConfig: httpConfig,
              onError: (err) => err.toString())));

      final pk = await $(_getPK());

      final signedHex =
          await $(TaskEither.fromEither(_transactionService.signPsbtT(
              psbtHex: newSalePsbtHex,
              inputPrivateKeyMap: {0: pk},
              sighashTypes: [
                0x03 | 0x80, // single | anyone_can_pay
              ],
              httpConfig: httpConfig,
              onError: (_err) => "Error signing PSBT: ${_err.toString()}")));

      return signedHex;
    });

    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    final result = await task.run();

    result.fold((err) {
      emit(state.copyWith(
          error: err.toString(),
          submissionStatus: FormzSubmissionStatus.failure));
    }, (psbtHex) {
      emit(state.copyWith(
          signedPsbt: psbtHex,
          submissionStatus: FormzSubmissionStatus.success));
    });
  }

  // TODO: this is still reasonably dependency heavy
  // and should be abstracted out into it's own service basically
  TaskEither<String, String> _getPK() {
    // TODO: for now all signing is uses "InMemoryKey" decryption
    final DecryptionStrategy decryptionStrategy = InMemoryKey();
    return switch (address.derivation) {
      Bip32Path(value: var value) => _walletConfigRepository
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
                  ))),
      WIF(value: var value) => switch (decryptionStrategy) {
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
        }
    };
  }
}
