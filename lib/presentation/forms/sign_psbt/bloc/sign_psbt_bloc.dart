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
import 'package:horizon/domain/entities/unified_address.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart' as dbtc;
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/seed.dart';
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
  final TransactionService transactionService;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final ImportedAddressService importedAddressService;
  final BitcoindService bitcoindService;
  final BitcoinRepository bitcoinRepository;
  final BalanceRepository balanceRepository;
  final UnifiedAddressRepository addressRepository;
  final Map<String, List<int>> signInputs;
  final List<int>? sighashTypes;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final SessionStateSuccess session;
  final HttpConfig httpConfig;
  final WalletConfigRepository _walletConfigRepository;
  final SeedService _seedService;

  SignPsbtBloc({
    required this.addresses,
    required this.httpConfig,
    required this.session,
    required this.passwordRequired,
    required this.unsignedPsbt,
    required this.transactionService,
    required this.encryptionService,
    required this.addressService,
    required this.importedAddressService,
    required this.bitcoindService,
    required this.balanceRepository,
    required this.bitcoinRepository,
    required this.addressRepository,
    required this.signInputs,
    required this.sighashTypes,
    required this.inMemoryKeyRepository,
    WalletConfigRepository? walletConfigRepository,
    SeedService? seedService,
  })  : _walletConfigRepository =
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
          transactionService.psbtToUnsignedTransactionHex(unsignedPsbt);

      final decoded = await bitcoindService.decoderawtransaction(
          transactionHex, httpConfig);

      Either<Failure, List<AugmentedInput>> inputs =
          await TaskEither.traverseListWithIndex(decoded.vin, (vin, index) {
        return TaskEither<Failure, AugmentedInput>.Do(($) async {
          final getTransactionTask = bitcoinRepository
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
              () => balanceRepository.getBalancesForUTXO(
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

      final addressSet =
          session.addresses.map((address) => address.address).toSet();

      final debits =
          augmentedInputs.map((i) => i.getDebits(addressSet)).flatten.toList();

      final credits = augmentedOutputs
          .map((o) => o.getCredits(addressSet))
          .flatten
          .toList();

      Map<String, Decimal> map = {};

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
      // if any failures were thrown, then psbt does not fit the criteria of a swap, and we just load the form without transaction data
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
      final walletConfig = await $(_walletConfigRepository
          .getCurrentT((err_) => "invariant: no wallet config"));

      final seed = await $(_seedService.getForWalletConfigT(
          walletConfig: walletConfig,
          decryptionStrategy:
              passwordRequired ? Password(state.password.value) : InMemoryKey(),
          onError: (err_) => passwordRequired
              ? "Invalid password"
              : "invariant: could not derive seed"));

      final inputPrivateKeyMap = await $(buildInputPrivateKeyMap(
          addresses, signInputs, addressService, seed, httpConfig));

      String signedHex = await $(TaskEither.fromEither(
          transactionService.signPsbtT(
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
    throw UnimplementedError(
        'getAddressPrivateKeyForAddress is not implemented yet.');
    // final account =
    //     await accountRepository.getAccountByUuid(address.accountUuid);
    //
    // if (account == null) {
    //   throw Exception('Account not found.');
    // }
    //
    // // Derive Address Private Key
    // final addressPrivKey = await addressService.deriveAddressPrivateKey(
    //   rootPrivKey: rootPrivKey,
    //   chainCodeHex: chainCodeHex,
    //   purpose: account.purpose,
    //   coin: account.coinType,
    //   account: account.accountIndex,
    //   change: '0',
    //   index: address.index,
    //   importFormat: account.importFormat,
    // );
    //
    // return addressPrivKey;
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

    final addressPrivKey =
        await importedAddressService.getAddressPrivateKeyFromWIF(
            wif: decryptedAddressWif, network: httpConfig.network);

    return addressPrivKey;
  }
}

class FailedToDeriveAddressPrivateKey extends Error {
  final String address;
  FailedToDeriveAddressPrivateKey(this.address);
}

TaskEither<String, Map<int, String>> buildInputPrivateKeyMap(
  List<AddressV2> addresses,
  Map<String, List<int>> signInputs,
  AddressService addressService,
  Seed seed,
  HttpConfig httpConfig,
) {
  final tasks = signInputs.entries.map((entry) {
    return TaskEither<String, Map<int, String>>.tryCatch(() async {
      final address = addresses.firstWhereOrNull((a) => a.address == entry.key);
      if (address == null) {
        throw Exception("Address ${entry.key} not found.");
      }

      final pk = await addressService.deriveAddressPrivateKeyWIP(
        address: address,
        seed: seed,
        network: httpConfig.network,
      );

      return {
        for (final index in entry.value) index: pk,
      };
    }, (e, _) => 'Error deriving private key for address ${entry.key}');
  }).toList();

  return TaskEither.sequenceList(tasks).map((listOfMaps) {
    return {
      for (final map in listOfMaps) ...map,
    };
  });
}
