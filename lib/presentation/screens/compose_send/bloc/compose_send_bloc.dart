import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
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
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/get_max_send_quantity.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/compose_base/shared/compose_tx.dart';
import 'package:horizon/presentation/common/compose_base/shared/sign_and_broadcast_tx.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';
import 'package:logger/logger.dart';

class ComposeSendEventParams {
  final String destinationAddress;
  final int quantity;
  final String asset;

  ComposeSendEventParams({
    required this.destinationAddress,
    required this.quantity,
    required this.asset,
  });
}

class ComposeSendBloc extends ComposeBaseBloc<ComposeSendState> {
  final Logger logger = Logger();
  final AddressRepository addressRepository;
  final BalanceRepository balanceRepository;
  final ComposeRepository composeRepository;
  final UtxoRepository utxoRepository;
  final TransactionService transactionService;
  final BitcoindService bitcoindService;
  final AccountRepository accountRepository;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final TransactionRepository transactionRepository;
  final TransactionLocalRepository transactionLocalRepository;
  final AnalyticsService analyticsService;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;

  ComposeSendBloc(
      {required this.addressRepository,
      required this.balanceRepository,
      required this.composeRepository,
      required this.utxoRepository,
      required this.transactionService,
      required this.bitcoindService,
      required this.accountRepository,
      required this.walletRepository,
      required this.encryptionService,
      required this.addressService,
      required this.transactionRepository,
      required this.transactionLocalRepository,
      required this.analyticsService,
      required this.getFeeEstimatesUseCase})
      : super(ComposeSendState(
          feeOption: FeeOption.Medium(),
          submitState: const SubmitInitial(),
          feeState: const FeeState.initial(),
          balancesState: const BalancesState.initial(),
          maxValue: const MaxValueState.initial(),
          sendMax: false,
          quantity: "",
        )) {
    // Register additional event handlers specific to sending
    on<ToggleSendMaxEvent>(_onToggleSendMaxEvent);
    on<ChangeAsset>(_onChangeAsset);
    on<ChangeDestination>(_onChangeDestination);
    on<ChangeQuantity>(_onChangeQuantity);
  }

  _onChangeAsset(event, emit) async {
    final asset = event.asset;
    emit(state.copyWith(
        submitState: const SubmitInitial(),
        asset: asset,
        sendMax: false,
        quantity: "",
        composeSendError: null,
        feeOption: FeeOption.Medium()));
  }

  _onChangeDestination(event, emit) async {
    final destination = event.value;
    emit(state.copyWith(
        submitState: const SubmitInitial(),
        destination: destination,
        composeSendError: null));
  }

  _onChangeQuantity(event, emit) async {
    final quantity = event.value;

    emit(state.copyWith(
        submitState: const SubmitInitial(),
        quantity: quantity,
        sendMax: false,
        composeSendError: null,
        maxValue: const MaxValueState.initial()));
  }

  _onToggleSendMaxEvent(event, emit) async {
    // return early if fee estimates haven't loaded
    FeeEstimates? feeEstimates =
        state.feeState.maybeWhen(success: (value) => value, orElse: () => null);
    if (feeEstimates == null) {
      return;
    }

    final value = event.value;
    emit(state.copyWith(
        submitState: const SubmitInitial(),
        sendMax: value,
        composeSendError: null));

    if (!value) {
      emit(state.copyWith(maxValue: const MaxValueState.initial()));
    }

    emit(state.copyWith(maxValue: const MaxValueState.loading()));

    try {
      final source = state.source!.address;
      final asset = state.asset ?? "BTC";
      final feeRate = switch (state.feeOption) {
        FeeOption.Fast() => feeEstimates.fast,
        FeeOption.Medium() => feeEstimates.medium,
        FeeOption.Slow() => feeEstimates.slow,
        FeeOption.Custom(fee: var fee) => fee,
      };

      final max = await GetMaxSendQuantity(
        source: source,
        // destination: state.destination!,
        asset: asset,
        feeRate: feeRate,
        balanceRepository: balanceRepository,
        composeRepository: composeRepository,
        transactionService: transactionService,
      ).call();

      emit(state.copyWith(maxValue: MaxValueState.success(max)));
    } catch (e) {
      emit(state.copyWith(
          sendMax: false,
          composeSendError: "Insufficient funds",
          maxValue: MaxValueState.error(e.toString())));
    }
  }

  @override
  onChangeFeeOption(event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value, composeSendError: null));

    if (!state.sendMax) return;

    FeeEstimates? feeEstimates =
        state.feeState.maybeWhen(success: (value) => value, orElse: () => null);
    if (feeEstimates == null) {
      return;
    }

    if (state.destination == null) {
      emit(state.copyWith(
          sendMax: false,
          submitState: const SubmitInitial(),
          composeSendError: "Set destination",
          maxValue: const MaxValueState.initial()));
      return;
    }

    emit(state.copyWith(maxValue: const MaxValueState.loading()));

    try {
      final source = state.source!.address;
      final asset = state.asset ?? "BTC";
      final feeRate = switch (state.feeOption) {
        FeeOption.Fast() => feeEstimates.fast,
        FeeOption.Medium() => feeEstimates.medium,
        FeeOption.Slow() => feeEstimates.slow,
        FeeOption.Custom(fee: var fee) => fee,
      };

      final max = await GetMaxSendQuantity(
        source: source,
        // destination: state.destination!,
        asset: asset,
        feeRate: feeRate,
        balanceRepository: balanceRepository,
        composeRepository: composeRepository,
        transactionService: transactionService,
      ).call();

      emit(state.copyWith(maxValue: MaxValueState.success(max)));
    } catch (e) {
      emit(state.copyWith(
          sendMax: false,
          composeSendError: "Insufficient funds",
          maxValue: MaxValueState.error(e.toString())));
    }
  }

  @override
  onFetchFormData(event, emit) async {
    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      submitState: const SubmitInitial(),
      source: event.currentAddress, // TODO: setting address this way is smell
    ));

    late List<Balance> balances;
    late FeeEstimates feeEstimates;
    try {
      List<Address> addresses = [event.currentAddress!];

      balances =
          await balanceRepository.getBalancesForAddress(addresses[0].address);
    } catch (e) {
      emit(state.copyWith(
          balancesState: BalancesState.error(e.toString()),
          submitState: const SubmitInitial()));
      return;
    }
    try {
      feeEstimates = await getFeeEstimatesUseCase.call(
        targets: (1, 3, 6),
      );
    } catch (e) {
      emit(state.copyWith(
          feeState: FeeState.error(e.toString()),
          submitState: const SubmitInitial()));
      return;
    }

    emit(state.copyWith(
        balancesState: BalancesState.success(balances),
        feeState: FeeState.success(feeEstimates),
        submitState: const SubmitInitial()));
  }

  @override
  onFinalizeTransaction(event, emit) async {
    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeSend>(
            loading: false,
            error: null,
            composeTransaction: event.composeTransaction,
            fee: event.fee)));
  }

  @override
  onComposeTransaction(event, emit) async {
    await composeTransaction<ComposeSend, ComposeSendState, void>(
        state: state,
        emit: emit,
        event: event,
        utxoRepository: utxoRepository,
        composeRepository: composeRepository,
        transactionService: transactionService,
        logger: logger,
        transactionHandler: (inputsSet, feeRate) async {
          final sendParams = event.params;
          // Dummy transaction to compute virtual size
          final send = await composeRepository.composeSendVerbose(
            event.sourceAddress,
            sendParams.destinationAddress,
            sendParams.asset,
            sendParams.quantity,
            true,
            1,
            null,
            inputsSet,
          );

          final virtualSize =
              transactionService.getVirtualSize(send.rawtransaction);
          final int totalFee = virtualSize * feeRate;

          final composeTransaction = await composeRepository.composeSendVerbose(
            event.sourceAddress,
            sendParams.destinationAddress,
            sendParams.asset,
            sendParams.quantity,
            true,
            totalFee,
            null,
            inputsSet,
          );

          return (composeTransaction, virtualSize);
        });
  }

  @override
  onSignAndBroadcastTransaction(event, emit) async {
    await signAndBroadcastTransaction<ComposeSend, ComposeSendState>(
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
          final sendParams =
              (state.submitState as SubmitFinalizing<ComposeSend>)
                  .composeTransaction;

          final source = sendParams.params.source;
          final rawTx = sendParams.rawtransaction;
          final destination = sendParams.params.destination;
          final quantity = sendParams.params.quantity;
          final asset = sendParams.params.asset;

          return (source, rawTx, destination, quantity, asset);
        },
        successAction:
            (txHex, txHash, source, destination, quantity, asset) async {
          // for now we don't track btc sends
          if (asset!.toLowerCase() != 'btc') {
            TransactionInfo txInfo =
                await transactionRepository.getInfo(txHex);

            await transactionLocalRepository.insert(txInfo.copyWith(
                hash: txHash,
                source:
                    source // TODO: set this manually as a tmp hack because it can be undefined with btc sends
                ));
          } else {
            // TODO: this is a bit of a hack
            transactionLocalRepository.insert(TransactionInfo(
              hash: txHash,
              source: source!,
              destination: destination,
              btcAmount: quantity,
              domain: TransactionInfoDomainLocal(
                  raw: txHex, submittedAt: DateTime.now()),
              btcAmountNormalized:
                  quantity.toString(), //TODO: this is temporary
              fee: 0, // dummy values
              data: "",
            ));
          }
          logger.d('send broadcasted txHash: $txHash');

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHash, sourceAddress: source!)));

          analyticsService.trackEvent('broadcast_tx_send');
        });
  }
}
