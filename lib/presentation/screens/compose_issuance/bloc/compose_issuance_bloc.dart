import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
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
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/screens/compose_base/shared/compose_tx.dart';
import 'package:horizon/presentation/screens/compose_base/shared/sign_and_broadcast_tx.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/usecase/get_fee_estimates.dart';
import 'package:logger/logger.dart';

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
  final BitcoinRepository bitcoinRepository;
  final AnalyticsService analyticsService;

  ComposeIssuanceBloc({
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
  }) : super(ComposeIssuanceState(
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
      List<Address> addresses = [event.currentAddress];

      balances =
          await balanceRepository.getBalancesForAddress(addresses[0].address);
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
    await composeTransaction<ComposeIssuanceVerbose, ComposeIssuanceState,
        ComposeIssuanceEventParams>(
      state: state,
      emit: emit,
      event: event,
      utxoRepository: utxoRepository,
      composeRepository: composeRepository,
      transactionService: transactionService,
      logger: logger,
    );
  }

  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, emit) async {
    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeIssuanceVerbose>(
      loading: false,
      error: null,
      composeTransaction: event.composeTransaction,
      fee: event.fee,
    )));
  }

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {
    await signAndBroadcastTransaction<ComposeIssuanceVerbose,
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
    );
  }
}
