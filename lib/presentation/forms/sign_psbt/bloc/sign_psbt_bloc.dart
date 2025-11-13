import "package:fpdart/fpdart.dart";
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:get_it/get_it.dart";
import 'package:horizon/domain/usecases/decode_raw_transaction.dart';
import 'package:horizon/domain/usecases/esplora/get_transaction.dart';
import 'package:horizon/domain/usecases/get_augmented_psbt_data.dart';
import 'package:horizon/domain/usecases/get_utxo_map_for_address.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:collection/collection.dart';
import 'package:horizon/domain/entities/psbt_type.dart';

import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/balance_v2.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart' as dbtc;
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/usecases/get_utxo_balances.dart';

import "./sign_psbt_state.dart";
import "./sign_psbt_event.dart";

const dummyTxID =
    "0000000000000000000000000000000000000000000000000000000000000000";

class AssetCredit {
  final String asset;
  final AssetQuantity quantity;

  const AssetCredit({
    required this.asset,
    required this.quantity,
  });
}

class AssetDebit {
  final String asset;
  final AssetQuantity quantity;

  const AssetDebit({
    required this.asset,
    required this.quantity,
  });
}

class AugmentedInput {
  final bool confirmed;
  final dbtc.Vin vin;
  final String? address;
  final Vout prevOut;
  final List<UtxoBalance> balances;
  final bool signatureRequired;

  const AugmentedInput({
    required this.confirmed,
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
            asset: displayAssetName(balance.asset, balance.assetLongname),
            quantity: balance.quantity,
          ));
        }
      } else {
        debits.add(AssetDebit(
          asset: "BTC",
          quantity: AssetQuantity(
            quantity: BigInt.from(prevOut.value),
            divisible: true,
          ),
        ));
      }
    }

    return debits;
  }
}

class AugmentedOutput {
  final dbtc.Vout vout;
  final List<UtxoBalance> balances;

  AugmentedOutput({
    required this.balances,
    required this.vout,
  });

  String? get address => vout.scriptPubKey.address;

  int get value => (vout.value * 10e7).toInt();

  bool isUserOwned(Set<String> userAddresses) {
    if (address == null) return false;
    return userAddresses.contains(address);
  }

  bool isOpReturn() {
    return vout.scriptPubKey.asm.contains("OP_RETURN");
  }

  List<AssetCredit> getCredits(Set<String> userAddresses) {
    List<AssetCredit> credits = [];
    // for now, we only show btc credits
    if (isUserOwned(userAddresses)) {
      if (balances.isNotEmpty) {
        for (final balance in balances) {
          credits.add(AssetCredit(
            asset: displayAssetName(balance.asset, balance.assetLongname),
            quantity: balance.quantity,
          ));
        }
      } else {
        credits.add(AssetCredit(
            asset: "BTC",
            quantity:
                AssetQuantity(quantity: BigInt.from(value), divisible: true)));
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

  final GetAugmentedPsbtDataUseCase _getAugmentedPsbtDataUseCase;
  final GetUtxoMapForAddressUseCase _getUtxoMapForAddressUseCase;
  final bool embeddedWitnessData;

  SignPsbtBloc({
    required this.addresses,
    required this.httpConfig,
    required this.passwordRequired,
    required this.unsignedPsbt,
    required this.signInputs,
    required this.sighashTypes,
    required PsbtType psbtType,
    EncryptionService? encryptionService,
    AddressService? addressService,
    BitcoindService? bitcoindService,
    BitcoinRepository? bitcoinRepository,
    InMemoryKeyRepository? inMemoryKeyRepository,
    TransactionService? transactionService,
    WalletConfigRepository? walletConfigRepository,
    SeedService? seedService,
    UtxoRepository? utxoRepository,
    EventsRepository? eventsRepository,
    GetUTXOBalancesUseCase? getUTXOBalancesUseCase,
    DecodeRawTransactionUseCase? decodeRawTransactionUseCase,
    GetTransactionEsploraUseCase? getTransactionEsploraUseCase,
    GetAugmentedPsbtDataUseCase? getAugmentedPsbtDataUseCase,
    GetUtxoMapForAddressUseCase? getUtxoMapForAddressUseCase,
    this.embeddedWitnessData = false,
  })  : _transactionService =
            transactionService ?? GetIt.I<TransactionService>(),
        _inMemoryKeyRepository =
            inMemoryKeyRepository ?? GetIt.I<InMemoryKeyRepository>(),
        _encryptionService = encryptionService ?? GetIt.I<EncryptionService>(),
        _addressService = addressService ?? GetIt.I<AddressService>(),
        _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _seedService = seedService ?? GetIt.I<SeedService>(),
        _getAugmentedPsbtDataUseCase = getAugmentedPsbtDataUseCase ??
            GetIt.I<GetAugmentedPsbtDataUseCase>(),
        _getUtxoMapForAddressUseCase = getUtxoMapForAddressUseCase ??
            GetIt.I<GetUtxoMapForAddressUseCase>(),
        super(SignPsbtState(
            addresses: addresses.map((addy) => addy.address).toList(),
            psbtType: psbtType)) {
    on<FetchFormEvent>(_handleFetchForm);
    on<PasswordChanged>(_handlePasswordChanged);
    on<SignPsbtSubmitted>(_handleSignPsbtSubmitted);
  }

  Future<void> _handleFetchForm(
    FetchFormEvent event,
    Emitter<SignPsbtState> emit,
  ) async {
    final task = _getAugmentedPsbtDataUseCase.call(GetAugmentedPsbtDataParams(
      httpConfig: httpConfig,
      unsignedPsbt: unsignedPsbt,
      addresses: addresses,
      signInputs: signInputs,
    ));
    final result = await task.run();

    result.fold((error) {
      emit(state.copyWith(
        isFormDataLoaded: true,
      ));
    }, (data) {
      emit(state.copyWith(
        debits: data.debits,
        credits: data.credits,
        augmentedInputs: data.augmentedInputs,
        augmentedOutputs: data.augmentedOutputs,
        isFormDataLoaded: true,
      ));
    });
  }

  void _handlePasswordChanged(
      PasswordChanged event, Emitter<SignPsbtState> emit) {
    final password = PasswordInput.dirty(event.password);

    emit(state.copyWith(
      password: password,
      error: null,
      submissionStatus: FormzSubmissionStatus.initial,
    ));
  }

  Future<void> _handleSignPsbtSubmitted(
      SignPsbtSubmitted event, Emitter<SignPsbtState> emit) async {
    final currentAddress =
        addresses.firstWhereOrNull((a) => signInputs.keys.contains(a.address));

    if (currentAddress == null) {
      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.failure,
          error: "Address not found"));
      return;
    }

    final task = TaskEither<String, String>.Do(($) async {
      print("addresses: $addresses");
      print("signInputs: $signInputs");

      final inputPrivateKeyMap = await $(buildInputPrivateKeyMap(
        addresses,
        signInputs,
        passwordRequired ? Password(state.password.value) : InMemoryKey(),
        httpConfig,
      ));

      // here we need to actually take care of adding witness data

      String psbt = unsignedPsbt;

      if (embeddedWitnessData) {
        final utxoMap = await $(
            _getUtxoMapForAddressUseCase.call(GetUtxoMapForAddressParams(
          address: currentAddress,
          httpConfig: httpConfig,
        )));

        psbt = await $(_transactionService.embedWitnessDataT(
            psbtHex: unsignedPsbt,
            inputPrivateKeyMap: inputPrivateKeyMap,
            utxoMap: utxoMap,
            httpConfig: httpConfig,
            onError: (e, c) => c.toString()));
      }

      print("before call signPsbt");

      String signedHex = await $(TaskEither.fromEither(
          _transactionService.signPsbtT(
              psbtHex: psbt,
              inputPrivateKeyMap: inputPrivateKeyMap,
              httpConfig: httpConfig,
              sighashTypes: sighashTypes,
              onError: (e) => e.toString())));
      // onError: (e) => "Error signing PSBT")));

      return signedHex;
    });

    final result = await task.run();

    result.fold((msg) {
      throw (msg);
      // emit(state.copyWith(
      //     submissionStatus: FormzSubmissionStatus.failure,
      //     error: msg.toString()));
    }, (success) {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.success,
        signedPsbt: success,
      ));
    });
  }

  TaskEither<String, Map<int, (String, String)>> buildInputPrivateKeyMap(
    List<AddressV2> addresses,
    Map<String, List<int>> signInputs,
    DecryptionStrategy decryptionStrategy,
    HttpConfig httpConfig,
  ) {
    final tasks = signInputs.entries.map((entry) {
      return TaskEither<String, Map<int, (String, String)>>.Do(($) async {
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
                      onError: (_) => switch (decryptionStrategy) {
                            Password() => "Invalid password",
                            InMemoryKey() => "invariant: could not derive seed"
                          })
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
          for (final index in entry.value) index: (address.address, pk),
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
