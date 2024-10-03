import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
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
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/shared/compose_tx.dart';
import 'package:horizon/presentation/common/compose_base/shared/sign_and_broadcast_tx.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_state.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/usecase/get_fee_estimates.dart';
import 'package:logger/logger.dart';

class ComposeDispenserEventParams {
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int status;
  final String? openAddress;
  final String? oracleAddress;

  ComposeDispenserEventParams({
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
    this.openAddress,
    this.oracleAddress,
  });
}

class ComposeDispenserBloc extends ComposeBaseBloc<ComposeDispenserState> {
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
  final BitcoinRepository bitcoinRepository;
  final AnalyticsService analyticsService;

  ComposeDispenserBloc({
    required this.addressRepository,
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
    required this.bitcoinRepository,
    required this.analyticsService,
  }) : super(ComposeDispenserState(
            submitState: const SubmitInitial(),
            feeOption: FeeOption.Medium(),
            balancesState: const BalancesState.initial(),
            feeState: const FeeState.initial(),
            giveQuantity: '',
            escrowQuantity: '',
            mainchainrate: '',
            status: 0)) {
    // Event handlers specific to the dispenser
    on<ChangeAsset>(_onChangeAsset);
    on<ChangeGiveQuantity>(_onChangeGiveQuantity);
    on<ChangeEscrowQuantity>(_onChangeEscrowQuantity);
  }

  _onChangeEscrowQuantity(ChangeEscrowQuantity event, emit) {
    final quantity = event.value;
    emit(state.copyWith(escrowQuantity: quantity));
  }

  _onChangeGiveQuantity(ChangeGiveQuantity event, emit) {
    final quantity = event.value;
    emit(state.copyWith(giveQuantity: quantity));
  }

  _onChangeAsset(ChangeAsset event, emit) {
    emit(state.copyWith(
      assetName: event.asset,
      balancesState: BalancesState.success([event.balance]),
    ));
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
      List<Address> addresses = [event.currentAddress];

      final balances_ =
          await balanceRepository.getBalancesForAddress(addresses[0].address);

      balances = balances_.where((balance) => balance.asset != 'BTC').toList();
    } catch (e) {
      emit(state.copyWith(
        balancesState: BalancesState.error(e.toString()),
      ));
      return;
    }

    try {
      feeEstimates = await GetFeeEstimates(
        targets: (1, 3, 6),
        bitcoindService: bitcoindService,
      ).call();
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
    await composeTransaction<ComposeDispenserVerbose, ComposeDispenserState>(
        state: state,
        emit: emit,
        event: event,
        utxoRepository: utxoRepository,
        composeRepository: composeRepository,
        transactionService: transactionService,
        logger: logger,
        transactionHandler: (inputsSet, feeRate) async {
          final dispenserParams = event.params;
          // Dummy transaction to compute virtual size
          final dispenser = await composeRepository.composeDispenserVerbose(
            event.sourceAddress,
            dispenserParams.asset,
            dispenserParams.giveQuantity,
            dispenserParams.escrowQuantity,
            dispenserParams.mainchainrate,
            dispenserParams.status,
            dispenserParams.openAddress,
            dispenserParams.oracleAddress,
            true,
            1,
            inputsSet,
          );

          final virtualSize =
              transactionService.getVirtualSize(dispenser.rawtransaction);
          final int totalFee = virtualSize * feeRate;

          final composeTransaction =
              await composeRepository.composeDispenserVerbose(
            event.sourceAddress,
            dispenserParams.asset,
            dispenserParams.giveQuantity,
            dispenserParams.escrowQuantity,
            dispenserParams.mainchainrate,
            dispenserParams.status,
            dispenserParams.openAddress,
            dispenserParams.oracleAddress,
            true,
            totalFee,
            inputsSet,
          );

          return (composeTransaction, virtualSize);
        });
  }

  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, emit) async {
    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeDispenserVerbose>(
      loading: false,
      error: null,
      composeTransaction: event.composeTransaction,
      fee: event.fee,
    )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    await signAndBroadcastTransaction<ComposeDispenserVerbose,
            ComposeDispenserState>(
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
          final dispenserParams =
              (state.submitState as SubmitFinalizing<ComposeDispenserVerbose>)
                  .composeTransaction;
          final source = dispenserParams.params.source;
          final rawTx = dispenserParams.rawtransaction;
          final destination = source;
          final giveQuantity = dispenserParams.params.giveQuantity;
          final asset = dispenserParams.params.asset;

          return (source, rawTx, destination, giveQuantity, asset);
        },
        successAction:
            (txHex, txHash, source, destination, giveQuantity, asset) async {
          TransactionInfoVerbose txInfo =
              await transactionRepository.getInfoVerbose(txHex);

          await transactionLocalRepository.insertVerbose(txInfo.copyWith(
            hash: txHash,
          ));

          logger.d('dispenser broadcasted txHash: $txHash');

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex, sourceAddress: source!)));

          analyticsService.trackEvent('broadcast_tx_dispenser');
        });
  }
}
