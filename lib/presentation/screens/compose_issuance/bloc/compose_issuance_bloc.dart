import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/compose_base/shared/compose_tx.dart';
import 'package:horizon/presentation/common/compose_base/shared/sign_and_broadcast_tx.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:logger/logger.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';

class ComposeIssuanceEventParams {
  final String name;
  final int quantity;
  final String description;
  final bool divisible;
  final bool lock;
  final bool reset;

  ComposeIssuanceEventParams({
    required this.name,
    required this.quantity,
    required this.description,
    required this.divisible,
    required this.lock,
    required this.reset,
  });
}

class ComposeIssuanceBloc extends ComposeBaseBloc<ComposeIssuanceState> {
  final Logger logger = Logger();
  final AddressRepository addressRepository;
  final BalanceRepository balanceRepository;
  final ComposeRepository composeRepository;
  final UtxoRepository utxoRepository;
  final AccountRepository accountRepository;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final TransactionService transactionService;
  final BitcoindService bitcoindService;
  final TransactionRepository transactionRepository;
  final TransactionLocalRepository transactionLocalRepository;
  final AnalyticsService analyticsService;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;

  ComposeIssuanceBloc(
      {required this.addressRepository,
      required this.balanceRepository,
      required this.composeRepository,
      required this.utxoRepository,
      required this.accountRepository,
      required this.walletRepository,
      required this.encryptionService,
      required this.addressService,
      required this.transactionService,
      required this.bitcoindService,
      required this.transactionRepository,
      required this.transactionLocalRepository,
      required this.analyticsService,
      required this.getFeeEstimatesUseCase,
      required this.composeTransactionUseCase})
      : super(ComposeIssuanceState(
            submitState: const SubmitInitial(),
            feeOption: FeeOption.Medium(),
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            quantity: '')) {
    // Event handlers specific to issuance
    on<FetchBalances>(_onFetchBalances);
  }

  _onFetchBalances(FetchBalances event, emit) async {
    emit(state.copyWith(balancesState: const BalancesState.loading()));
    try {
      List<Balance> balances =
          await balanceRepository.getBalancesForAddress(event.address);
      emit(state.copyWith(balancesState: BalancesState.success(balances)));
    } catch (e) {
      emit(state.copyWith(balancesState: BalancesState.error(e.toString())));
    }
  }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    emit(state.copyWith(
        balancesState: const BalancesState.loading(),
        submitState: const SubmitInitial()));

    late List<Balance> balances;
    late FeeEstimates feeEstimates;

    try {
      List<Address> addresses = [event.currentAddress!];

      balances =
          await balanceRepository.getBalancesForAddress(addresses[0].address);
    } catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(e.toString()),
      ));
      return;
    }

    try {
      feeEstimates = await getFeeEstimatesUseCase.call(
        targets: (1, 3, 6),
      );
    } catch (e) {
      emit(state.copyWith(feeState: FeeState.error(e.toString())));
      return;
    }

    emit(state.copyWith(
      balancesState: BalancesState.success(balances),
      feeState: FeeState.success(feeEstimates),
    ));
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    emit((state).copyWith(submitState: const SubmitInitial(loading: true)));

    try {
      final feeRate = _getFeeRate();
      final source = event.sourceAddress;

      final composeResponse = await composeTransactionUseCase
          .call<ComposeIssuanceParams, ComposeIssuanceResponseVerbose>(
        source: source,
        feeRate: feeRate,
        params: ComposeIssuanceParams(
          source: event.sourceAddress,
          name: event.params.name,
          quantity: event.params.quantity,
          description: event.params.description,
          divisible: event.params.divisible,
          lock: event.params.lock,
          reset: event.params.reset,
        ),
        composeFn: composeRepository.composeIssuanceVerbose,
      );

      final composed = composeResponse.$1;
      final virtualSize = composeResponse.$2;

      emit(state.copyWith(
          submitState: SubmitComposingTransaction<
              ComposeIssuanceResponseVerbose, ComposeIssuanceEventParams>(
        composeTransaction: composed,
        fee: composed.btcFee,
        feeRate: feeRate,
        virtualSize: virtualSize.virtualSize,
        adjustedVirtualSize: virtualSize.adjustedVirtualSize,
      )));
    } catch (e) {
      emit(state.copyWith(
          submitState: SubmitInitial(
              loading: false,
              error: 'An unexpected error occurred: ${e.toString()}')));
    }
  }

  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, emit) async {
    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeIssuanceResponseVerbose>(
      loading: false,
      error: null,
      composeTransaction: event.composeTransaction,
      fee: event.fee,
    )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    await signAndBroadcastTransaction<ComposeIssuanceResponseVerbose,
            ComposeIssuanceState>(
        state: state,
        emit: emit,
        password: event.password,
        addressRepository: addressRepository,
        accountRepository: accountRepository,
        walletRepository: walletRepository,
        utxoRepository: utxoRepository,
        encryptionService: encryptionService,
        addressService: addressService,
        transactionService: transactionService,
        bitcoindService: bitcoindService,
        composeRepository: composeRepository,
        transactionRepository: transactionRepository,
        transactionLocalRepository: transactionLocalRepository,
        analyticsService: analyticsService,
        logger: logger,
        extractParams: () {
          final issuanceParams = (state.submitState
                  as SubmitFinalizing<ComposeIssuanceResponseVerbose>)
              .composeTransaction;
          final source = issuanceParams.params.source;
          final rawTx = issuanceParams.rawtransaction;
          final destination =
              source; // For issuance, destination is the same as source
          final quantity = issuanceParams.params.quantity;
          final asset = issuanceParams.params.asset;

          return (source, rawTx, destination, quantity, asset);
        },
        successAction:
            (txHex, txHash, source, destination, quantity, asset) async {
          TransactionInfo txInfo = await transactionRepository.getInfo(txHex);

          await transactionLocalRepository.insert(txInfo.copyWith(
            hash: txHash,
          ));

          logger.d('issue broadcasted txHash: $txHash');

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex, sourceAddress: source!)));

          analyticsService.trackEvent('broadcast_tx_issue');
        });
  }

  int _getFeeRate() {
    FeeEstimates feeEstimates = state.feeState.feeEstimatesOrThrow();
    return switch (state.feeOption) {
      FeeOption.Fast() => feeEstimates.fast,
      FeeOption.Medium() => feeEstimates.medium,
      FeeOption.Slow() => feeEstimates.slow,
      FeeOption.Custom(fee: var fee) => fee,
    };
  }
}
