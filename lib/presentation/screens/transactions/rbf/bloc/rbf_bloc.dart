import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/common/fn.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/failure.dart';
import 'package:horizon/domain/entities/fee_option.dart' as fee_option;
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/unified_address.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/get_fee_option.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/transactions/rbf/bloc/rbf_event.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';

class RBFData {
  final BitcoinTx tx;
  final String hex;
  final int adjustedSize;

  RBFData({required this.tx, required this.hex, required this.adjustedSize});
}

class RBFComposeData {
  final MakeRBFResponse makeRBFResponse;
  final num oldFee;
  final String txid;
  final String sourceAddress;
  RBFComposeData(
      {required this.makeRBFResponse,
      required this.oldFee,
      required this.txid,
      required this.sourceAddress});
}

class RBFBloc
    extends Bloc<TransactionEvent, TransactionState<RBFData, RBFComposeData>> {
  final HttpConfig httpConfig;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final BitcoinRepository bitcoinRepository;
  final AnalyticsService analyticsService;
  final TransactionService transactionService;
  final Logger logger;
  final SettingsRepository settingsRepository;
  final WalletRepository walletRepository;
  final UnifiedAddressRepository addressRepository;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final ImportedAddressService importedAddressService;
  final BitcoindService bitcoindService;
  final TransactionLocalRepository transactionLocalRepository;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;

  RBFBloc({
    required this.httpConfig,
    required this.getFeeEstimatesUseCase,
    required this.bitcoinRepository,
    required this.analyticsService,
    required this.logger,
    required this.settingsRepository,
    required this.transactionService,
    required this.walletRepository,
    required this.addressRepository,
    required this.inMemoryKeyRepository,
    required this.encryptionService,
    required this.addressService,
    required this.importedAddressService,
    required this.bitcoindService,
    required this.transactionLocalRepository,
    required this.writelocalTransactionUseCase,
  }) : super(TransactionState<RBFData, RBFComposeData>(
          formState: TransactionFormState<RBFData>(
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            dataState: const TransactionDataState.initial(),
            feeOption: fee_option.Medium(),
          ),
          composeState: const ComposeState.initial(),
          broadcastState: const BroadcastState.initial(),
        )) {
    on<RBFDependenciesRequested>(_onDependenciesRequested);
    on<RBFTransactionComposed>(_onTransactionComposed);
    on<RBFTransactionBroadcasted>(_onTransactionBroadcasted);
    on<FeeOptionSelected>(_onFeeOptionSelected);
  }

  void _onDependenciesRequested(
    RBFDependenciesRequested event,
    Emitter<TransactionState<RBFData, RBFComposeData>> emit,
  ) async {
    emit(state.copyWith(
      formState: state.formState.copyWith(
        balancesState: const BalancesState.loading(),
        feeState: const FeeState.loading(),
        dataState: const TransactionDataState.loading(),
      ),
    ));

    try {
      final feeEstimates =
          await getFeeEstimatesUseCase.call(httpConfig: httpConfig);

      BitcoinTx bitcoinTransaction = unwrapOrThrow(await bitcoinRepository
          .getTransaction(txid: event.txHash, httpConfig: httpConfig));

      String bitcoinTransactionHex = unwrapOrThrow(await bitcoinRepository
          .getTransactionHex(txid: event.txHash, httpConfig: httpConfig));

      final virtualSize =
          transactionService.getVirtualSize(bitcoinTransactionHex);

      final sigOps = transactionService.countSigOps(
        rawtransaction: bitcoinTransactionHex,
      );

      final adjustedVirtualSize = max(virtualSize, sigOps * 5);

      emit(state.copyWith(
          formState: state.formState.copyWith(
              balancesState: BalancesState.success(MultiAddressBalance.empty),
              feeState: FeeState.success(feeEstimates),
              dataState: TransactionDataState.success(RBFData(
                  tx: bitcoinTransaction,
                  hex: bitcoinTransactionHex,
                  adjustedSize: adjustedVirtualSize)))));
    } catch (e) {
      emit(state.copyWith(
        formState: state.formState.copyWith(
          dataState: TransactionDataState.error(e.toString()),
        ),
      ));
    }
  }

  void _onTransactionComposed(
    RBFTransactionComposed event,
    Emitter<TransactionState<RBFData, RBFComposeData>> emit,
  ) async {
    final source = event.sourceAddress;
    try {
      final newFeeRate = getFeeRate(state);
      num newFee = newFeeRate * event.params.adjustedVirtualSize;

      MakeRBFResponse rbfResponse = await transactionService.makeRBF(
        httpConfig: httpConfig,
        source: source,
        txHex: event.params.hex,
        oldFee: event.params.tx.fee,
        newFee: newFee,
      );

      final rbfComposeData = RBFComposeData(
        makeRBFResponse: rbfResponse,
        oldFee: event.params.tx.fee,
        txid: event.params.tx.txid,
        sourceAddress: source,
      );

      emit(state.copyWith(composeState: ComposeStateSuccess(rbfComposeData)));
    } on TransactionServiceException catch (e) {
      emit(state.copyWith(
        composeState: ComposeStateError(e.message),
      ));
    } catch (e) {
      emit(state.copyWith(
        composeState: ComposeStateError(e.toString()),
      ));
    }
  }

  void _onTransactionBroadcasted(
    RBFTransactionBroadcasted event,
    Emitter<TransactionState<RBFData, RBFComposeData>> emit,
  ) async {
    final composeData = state.getComposeDataOrThrow();
    final address = composeData.sourceAddress;

    emit(state.copyWith(broadcastState: const BroadcastState.loading()));

    try {
      Wallet? wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        throw Exception("invariant: wallet not found");
      }

      final passwordRequired =
          settingsRepository.requirePasswordForCryptoOperations;

      String rootPrivateKey = passwordRequired
          ? await encryptionService.decrypt(wallet.encryptedPrivKey,
              (event.decryptionStrategy as Password).password)
          : await encryptionService.decryptWithKey(
              wallet.encryptedPrivKey, (await inMemoryKeyRepository.get())!);

      String addressPrivateKey =
          unwrapOrThrow<String, String>(await addressRepository
              .get(address)
              .flatMap((UnifiedAddress unifiedAddress) => getUAddressPrivateKey(
                    event.decryptionStrategy,
                    rootPrivateKey,
                    wallet.chainCodeHex,
                    unifiedAddress,
                  ))
              .run());

      Map<String, Utxo> utxoMap = {};

      for (final entry in composeData.makeRBFResponse.inputsByTxHash.entries) {
        final txHash = entry.key;
        final inputIndices = entry.value;

        final transaction = unwrapOrThrow<Failure, BitcoinTx>(
            await bitcoinRepository.getTransaction(
                txid: txHash, httpConfig: httpConfig));
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
          composeData.makeRBFResponse.txHex,
          addressPrivateKey,
          address,
          utxoMap,
          httpConfig);

      final txHash =
          await bitcoindService.sendrawtransaction(txHex, httpConfig);

      // not technically necessary since event shows up very quickly in practice
      await writelocalTransactionUseCase.call(
          hex: txHex, hash: txHash, httpConfig: httpConfig);
      transactionLocalRepository.delete(composeData.txid);

      analyticsService.trackAnonymousEvent('broadcast_rbf',
          properties: {'distinct_id': uuid.v4()});

      emit(state.copyWith(
          broadcastState: BroadcastState.success(
              BroadcastStateSuccess(txHex: txHex, txHash: txHash))));
    } catch (e) {
      emit(state.copyWith(
        broadcastState: BroadcastState.error(e.toString()),
      ));
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

  void _onFeeOptionSelected(
    FeeOptionSelected event,
    Emitter<TransactionState<RBFData, RBFComposeData>> emit,
  ) {
    emit(state.copyWith(
      formState: state.formState.copyWith(
        feeOption: event.feeOption,
      ),
    ));
  }
}
