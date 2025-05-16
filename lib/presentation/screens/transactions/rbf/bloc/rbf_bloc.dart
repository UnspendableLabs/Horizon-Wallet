import 'dart:math';
import "package:get_it/get_it.dart";
import 'package:horizon/domain/entities/address_v2.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as fee_option;
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transactions/get_fee_option.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/transactions/rbf/bloc/rbf_event.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';

import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/seed_service.dart';

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
  final AddressV2 address;
  final HttpConfig httpConfig;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final BitcoinRepository bitcoinRepository;
  final AnalyticsService analyticsService;
  final TransactionService transactionService;
  final Logger logger;
  final SettingsRepository settingsRepository;
  final InMemoryKeyRepository _inMemoryKeyRepository;
  final EncryptionService _encryptionService;
  final AddressService _addressService;
  final BitcoindService bitcoindService;
  final TransactionLocalRepository transactionLocalRepository;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final SeedService _seedService;
  final WalletConfigRepository _walletConfigRepository;

  RBFBloc({
    required this.address,
    required this.httpConfig,
    required this.getFeeEstimatesUseCase,
    required this.bitcoinRepository,
    required this.analyticsService,
    required this.logger,
    required this.settingsRepository,
    required this.transactionService,
    required InMemoryKeyRepository inMemoryKeyRepository,
    required EncryptionService encryptionService,
    required AddressService addressService,
    required this.bitcoindService,
    required this.transactionLocalRepository,
    required this.writelocalTransactionUseCase,
    SeedService? seedService,
    WalletConfigRepository? walletConfigRepository,
  })  : _inMemoryKeyRepository = inMemoryKeyRepository,
        _encryptionService = encryptionService,
        _addressService = addressService,
        _seedService = seedService ?? GetIt.I<SeedService>(),
        _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        super(TransactionState<RBFData, RBFComposeData>(
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

    final task = TaskEither<String, FormDependenciesResult>.Do(($) async {
      final feeEstimates = await $(getFeeEstimatesUseCase.callT(
          httpConfig: httpConfig,
          onError: (e) => "error: could not get fee estimates"));

      final originalTransaction = await $(bitcoinRepository.getTransactionT(
          txid: event.txHash,
          httpConfig: httpConfig,
          onError: (e) => "error: could not get transaction"));

      final originalTransactionHex = await $(
          bitcoinRepository.getTransactionHexT(
              txid: event.txHash,
              httpConfig: httpConfig,
              onError: (e) => "error: could not get transaction"));

      final virtualSize = await $(TaskEither.fromEither(
          transactionService.getVirtualSizeT(
              rawTransaction: originalTransactionHex,
              onError: (err_) => "error: error computing virtual size")));

      final sigOps = await $(TaskEither.fromEither(
          transactionService.countSigOpsT(
              rawTransaction: originalTransactionHex,
              onError: (err_) => "error: counting sig ops")));

      final adjustedVirtualSize = max(virtualSize, sigOps * 5);

      return FormDependenciesResult(
        feeEstimates: feeEstimates,
        originalTransaction: originalTransaction,
        originalTransactionHex: originalTransactionHex,
        virtualSize: virtualSize,
        sigOps: sigOps,
        adjustedVirtualSize: adjustedVirtualSize,
      );
    });

    final result = await task.run();

    result.fold(
        (msg) => emit(state.copyWith(
              formState: state.formState.copyWith(
                dataState: TransactionDataState.error(e.toString()),
              ),
            )),
        (deps) => emit(state.copyWith(
            formState: state.formState.copyWith(
                balancesState: BalancesState.success(MultiAddressBalance.empty),
                feeState: FeeState.success(deps.feeEstimates),
                dataState: TransactionDataState.success(RBFData(
                    tx: deps.originalTransaction,
                    hex: deps.originalTransactionHex,
                    adjustedSize: deps.adjustedVirtualSize))))));
  }

  // TODO: clean this up
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

    emit(state.copyWith(broadcastState: const BroadcastState.loading()));

    final task = TaskEither<String, (String hex, String hash)>.Do(($) async {
      String pk = switch (address.derivation) {
        Bip32Path(value: var value) => await $(_walletConfigRepository
            .getCurrentT((_) => "invariant: could not read wallet config")
            .flatMap((walletConfig) => _seedService
                .getForWalletConfigT(
                    walletConfig: walletConfig,
                    decryptionStrategy: event.decryptionStrategy,
                    onError: (_) => "invairant: could not derive seed")
                .flatMap((seed) => _addressService.deriveAddressPrivateKeyWIPT(
                      path: Bip32Path(value: value),
                      seed: seed,
                      network: httpConfig.network,
                    )))),
        WIF(value: var value) => await $(switch (event.decryptionStrategy) {
            Password(password: var password) => _encryptionService.decryptT(
                data: value,
                password: password,
                onError: (_, __) => "Invalid password"),
            InMemoryKey() => _inMemoryKeyRepository
                .getMapT(
                    onError: (_, __) =>
                        "invariant: failed to read in memory key map")
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

      // fetched all UTXOs in parallel
      final utxoMap = await $(buildUtxoMapT(
          inputsByTxHash: composeData.makeRBFResponse.inputsByTxHash,
          httpConfig: httpConfig,
          address: address.address,
          bitcoinRepository: bitcoinRepository));

      final signedHex = await $(transactionService.signTransactionT(
          unsignedTransaction: composeData.makeRBFResponse.txHex,
          privateKey: pk,
          sourceAddress: address.address,
          utxoMap: utxoMap,
          httpConfig: httpConfig,
          onError: (_) => "Error while signing transaction "));

      final hash = await $(bitcoindService.sendrawtransactionT(
          signedHex: signedHex,
          httpConfig: httpConfig,
          onError: (msg, _) => msg.toString()));

      return (signedHex, hash);
    });

    final result = await task.run();

    result.fold(
        (msg) => emit(state.copyWith(
              broadcastState: BroadcastState.error(msg),
            )), (success) async {
      final txHex = success.$1;
      final txHash = success.$2;

      await writelocalTransactionUseCase.call(
          hex: txHex, hash: txHash, httpConfig: httpConfig);
      transactionLocalRepository.delete(composeData.txid);

      analyticsService.trackAnonymousEvent('broadcast_rbf',
          properties: {'distinct_id': uuid.v4()});

      emit(state.copyWith(
          broadcastState: BroadcastState.success(
              BroadcastStateSuccess(txHex: txHex, txHash: txHash))));
    });
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

class FormDependenciesResult {
  final FeeEstimates feeEstimates;
  final BitcoinTx originalTransaction;
  final String originalTransactionHex;
  final int virtualSize;
  final int sigOps;
  final int adjustedVirtualSize;

  const FormDependenciesResult({
    required this.feeEstimates,
    required this.originalTransaction,
    required this.originalTransactionHex,
    required this.virtualSize,
    required this.sigOps,
    required this.adjustedVirtualSize,
  });
}

TaskEither<String, Map<String, Utxo>> buildUtxoMapT({
  required Map<String, List<int>> inputsByTxHash,
  required HttpConfig httpConfig,
  required String address,
  required BitcoinRepository bitcoinRepository,
}) {
  final tasks = inputsByTxHash.entries.map((entry) {
    final txHash = entry.key;
    final indices = entry.value;

    return bitcoinRepository
        .getTransactionT(
            txid: txHash,
            httpConfig: httpConfig,
            onError: (_) => 'Failed to fetch transaction $txHash: $_')
        .map(
          (tx) => {
            for (final index in indices)
              '$txHash:$index': Utxo(
                txid: txHash,
                vout: index,
                value: tx.vout[index].value,
                address: address,
              )
          },
        );
  }).toList();

  // these will be executed in parallel
  return TaskEither.sequenceList(tasks).map((listOfMaps) {
    return {
      for (final map in listOfMaps) ...map,
    };
  });
}
