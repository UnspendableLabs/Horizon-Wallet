import "package:fpdart/fpdart.dart";
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:get_it/get_it.dart";
import 'package:horizon/common/format.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';

import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/failure.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart' as dbtc;
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/seed_service.dart';

import "./sign_psbt_state.dart";
import "./sign_psbt_event.dart";

class AssetCredit {
  final String asset;
  final int quantity;
  final String quantityNormalized;

  const AssetCredit(
      {required this.asset,
      required this.quantity,
      required this.quantityNormalized});
}

class AssetDebit {
  final String asset;
  final int quantity;
  final String quantityNormalized;

  const AssetDebit(
      {required this.asset,
      required this.quantity,
      required this.quantityNormalized});
}

class AugmentedInput {
  final dbtc.Vin vin;
  final String? address;
  final Vout prevOut;
  final List<Balance> balances;
  final bool signatureRequired;

  const AugmentedInput({
    required this.vin,
    required this.prevOut,
    required this.balances,
    required this.signatureRequired,
    this.address,
  });

  bool isUserOwned(Set<String> userAddresses) {
    if (address == null) return false;
    return userAddresses.contains(address);
  }

  List<AssetDebit> getDebits(Set<String> userAddresses) {
    List<AssetDebit> debits = [];

    // if asset is attached, only track debits for atached asset, ignoring
    // envelope
    if (isUserOwned(userAddresses)) {
      if (balances.isNotEmpty) {
        for (final balance in balances) {
          debits.add(AssetDebit(
            asset: displayAssetName(
                balance.asset, balance.assetInfo.assetLongname),
            quantity: balance.quantity,
            quantityNormalized: balance.quantityNormalized,
          ));
        }
      } else {
        debits.add(AssetDebit(
          asset: "BTC",
          quantity: prevOut.value,
          quantityNormalized: satoshisToBtc(prevOut.value).toString(),
        ));
      }
    }

    return debits;
  }
}

class AugmentedOutput {
  final dbtc.Vout vout;
  final List<Balance> balances;

  AugmentedOutput({
    required this.balances,
    required this.vout,
  });

  get address => vout.scriptPubKey.address;

  int get value => (vout.value * 10e7).toInt();

  bool isUserOwned(Set<String> userAddresses) {
    if (address == null) return false;
    return userAddresses.contains(address);
  }

  List<AssetCredit> getCredits(Set<String> userAddresses) {
    List<AssetCredit> credits = [];
    // for now, we only show btc credits
    if (isUserOwned(userAddresses)) {
      if (balances.isNotEmpty) {
        for (final balance in balances) {
          credits.add(AssetCredit(
            asset: displayAssetName(
                balance.asset, balance.assetInfo.assetLongname),
            quantity: balance.quantity,
            quantityNormalized: balance.quantityNormalized,
          ));
        }
      } else {
        credits.add(AssetCredit(
            asset: "BTC",
            quantity: value,
            quantityNormalized: satoshisToBtc(value).toString()));
      }
    }
    return credits;
  }
}

class SignPsbtBloc extends Bloc<SignPsbtEvent, SignPsbtState> {
  final List<AddressV2> addresses;
  final bool passwordRequired;
  final String unsignedPsbt;
  final Map<String, List<int>> signInputs;
  final List<int>? sighashTypes;
  final HttpConfig httpConfig;
  final WalletConfigRepository _walletConfigRepository;
  final InMemoryKeyRepository _inMemoryKeyRepository;
  final SeedService _seedService;
  final TransactionService _transactionService;
  final EncryptionService _encryptionService;
  final AddressService _addressService;
  final BitcoindService _bitcoindService;
  final BitcoinRepository _bitcoinRepository;
  final BalanceRepository _balanceRepository;

  SignPsbtBloc({
    required this.addresses,
    required this.httpConfig,
    required this.passwordRequired,
    required this.unsignedPsbt,
    required this.signInputs,
    required this.sighashTypes,
    EncryptionService? encryptionService,
    AddressService? addressService,
    BitcoindService? bitcoindService,
    BalanceRepository? balanceRepository,
    BitcoinRepository? bitcoinRepository,
    InMemoryKeyRepository? inMemoryKeyRepository,
    TransactionService? transactionService,
    WalletConfigRepository? walletConfigRepository,
    SeedService? seedService,
  })  : _balanceRepository = balanceRepository ?? GetIt.I<BalanceRepository>(),
        _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _bitcoindService = bitcoindService ?? GetIt.I<BitcoindService>(),
        _transactionService =
            transactionService ?? GetIt.I<TransactionService>(),
        _inMemoryKeyRepository =
            inMemoryKeyRepository ?? GetIt.I<InMemoryKeyRepository>(),
        _encryptionService = encryptionService ?? GetIt.I<EncryptionService>(),
        _addressService = addressService ?? GetIt.I<AddressService>(),
        _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _seedService = seedService ?? GetIt.I<SeedService>(),
        super(SignPsbtState()) {
    on<FetchFormEvent>(_handleFetchForm);
    on<PasswordChanged>(_handlePasswordChanged);
    on<SignPsbtSubmitted>(_handleSignPsbtSubmitted);
  }

  Future<void> _handleFetchForm(
    FetchFormEvent event,
    Emitter<SignPsbtState> emit,
  ) async {
    try {
      // decode the psbt transaction

      final transactionHex =
          _transactionService.psbtToUnsignedTransactionHex(unsignedPsbt);

      final decoded = await _bitcoindService.decoderawtransaction(
          transactionHex, httpConfig);

      Either<Failure, List<AugmentedInput>> inputs =
          await TaskEither.traverseListWithIndex(decoded.vin, (vin, index) {
        print("vin: ${vin.txid}");

        return TaskEither<Failure, AugmentedInput>.Do(($) async {
          final getTransactionTask = _bitcoinRepository
              .getTransactionT(
                  txid: vin.txid,
                  httpConfig: httpConfig,
                  onError: (_) =>
                      "Failed to get transaction with txid: ${vin.txid}")
              .mapLeft(
                (_) => UnexpectedFailure(
                  message: "Failed to get transaction with txid: ${vin.txid}",
                ),
              );

          final getBalancesTask = TaskEither<Failure, List<Balance>>.tryCatch(
              () => _balanceRepository.getBalancesForUTXO(
                  httpConfig: httpConfig, utxo: "${vin.txid}:${vin.vout}"),
              (_, stacktrace) => const UnexpectedFailure(
                    message: "Failed to get balances for UTXO",
                  ));

          final transaction = await $(getTransactionTask);
          final balances = await $(getBalancesTask);

          final prevout = transaction.vout[vin.vout];
          final address = prevout.scriptpubkeyAddress;

          final signatureRequired =
              signInputs[address]?.contains(index) ?? false;

          return $(TaskEither.right(AugmentedInput(
              address: address,
              vin: vin,
              prevOut: prevout,
              balances: balances,
              signatureRequired: signatureRequired)));
        });
      }).run();

      final augmentedInputs = inputs.getOrElse((error) {
        throw error;
      });

      // append asset balances to output that has same value as input
      final augmentedOutputs = decoded.vout
          .map((o) => AugmentedOutput(
              vout: o,
              balances: augmentedInputs.firstWhereOrNull((input) {
                    return satoshisToBtc(input.prevOut.value).toDouble() ==
                        o.value;
                  })?.balances ??
                  []))
          .toList();

      final addressSet = addresses.map((address) => address.address).toSet();

      final debits =
          augmentedInputs.map((i) => i.getDebits(addressSet)).flatten.toList();

      final credits = augmentedOutputs
          .map((o) => o.getCredits(addressSet))
          .flatten
          .toList();

      Map<String, Decimal> map = {};

      print("debigts: $debits");
      print("credits: $credits");

      for (final debit in debits) {
        map.putIfAbsent(debit.asset, () => Decimal.zero);
        map[debit.asset] =
            map[debit.asset]! - Decimal.fromJson(debit.quantityNormalized);
      }

      for (final credit in credits) {
        map.putIfAbsent(credit.asset, () => Decimal.zero);
        map[credit.asset] =
            map[credit.asset]! + Decimal.fromJson(credit.quantityNormalized);
      }

      final netDebits = map.entries
          .filter((entry) => entry.value < Decimal.zero)
          .map((e) => AssetDebit(
              asset: e.key,
              quantity: 0, // temp hack
              quantityNormalized: e.value.abs().toString()));

      final netCredits = map.entries
          .filter((entry) => entry.value > Decimal.zero)
          .map((e) => AssetCredit(
              asset: e.key,
              quantity: 0, // temp hack
              quantityNormalized: e.value.toString()));

      emit(state.copyWith(
        debits: netDebits.toList(),
        credits: netCredits.toList(),
        augmentedInputs: augmentedInputs,
        augmentedOutputs: augmentedOutputs,
        isFormDataLoaded: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isFormDataLoaded: true,
      ));
    }
  }

  _handlePasswordChanged(PasswordChanged event, Emitter<SignPsbtState> emit) {
    final password = PasswordInput.dirty(event.password);

    emit(state.copyWith(
      password: password,
      error: null,
      submissionStatus: FormzSubmissionStatus.initial,
    ));
  }

  _handleSignPsbtSubmitted(
      SignPsbtSubmitted event, Emitter<SignPsbtState> emit) async {
    final task = TaskEither<String, String>.Do(($) async {
      final inputPrivateKeyMap = await $(buildInputPrivateKeyMap(
        addresses,
        signInputs,
        passwordRequired ? Password(state.password.value) : InMemoryKey(),
        httpConfig,
      ));

      String signedHex = await $(TaskEither.fromEither(
          _transactionService.signPsbtT(
              psbtHex: unsignedPsbt,
              inputPrivateKeyMap: inputPrivateKeyMap,
              httpConfig: httpConfig,
              sighashTypes: sighashTypes,
              onError: (e) => e.toString())));

      return signedHex;
    });

    final result = await task.run();

    result.fold((msg) {
      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.failure,
          error: msg.toString()));
    }, (success) {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.success,
        signedPsbt: success,
      ));
    });
  }

  TaskEither<String, Map<int, String>> buildInputPrivateKeyMap(
    List<AddressV2> addresses,
    Map<String, List<int>> signInputs,
    DecryptionStrategy decryptionStrategy,
    HttpConfig httpConfig,
  ) {
    final tasks = signInputs.entries.map((entry) {
      return TaskEither<String, Map<int, String>>.Do(($) async {
        final address = await $(TaskEither.fromOption(
            Option.fromNullable(
                addresses.firstWhereOrNull((a) => a.address == entry.key)),
            () => "Address not found"));

        String pk = switch (address.derivation) {
          Bip32Path(value: var value) => await $(_walletConfigRepository
              .getCurrentT((_) => "invariant: could not read wallet config")
              .flatMap((walletConfig) => _seedService
                  .getForWalletConfigT(
                      walletConfig: walletConfig,
                      decryptionStrategy: decryptionStrategy,
                      onError: (_) => "invairant: could not derive seed")
                  .flatMap(
                      (seed) => _addressService.deriveAddressPrivateKeyWIPT(
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
        return {
          for (final index in entry.value) index: pk,
        };
      });
    }).toList();

    return TaskEither.sequenceList(tasks).map((listOfMaps) {
      return {
        for (final map in listOfMaps) ...map,
      };
    });
  }
}
