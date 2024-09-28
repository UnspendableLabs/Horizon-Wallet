import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/wallet.dart';
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
    if (event.params is! ComposeIssuanceEventParams) return;

    final params = event.params as ComposeIssuanceEventParams;
    FeeEstimates? feeEstimates =
        state.feeState.maybeWhen(success: (value) => value, orElse: () => null);

    if (feeEstimates == null) {
      return;
    }
    emit(state.copyWith(submitState: const SubmitInitial(loading: true)));

    final source = event.sourceAddress;
    final quantity = params.quantity;
    final name = params.name;
    final divisible = params.divisible;
    final lock = params.lock;
    final reset = params.reset;
    final description = params.description;
    final feeRate = switch (state.feeOption) {
      FeeOption.Fast() => feeEstimates.fast,
      FeeOption.Medium() => feeEstimates.medium,
      FeeOption.Slow() => feeEstimates.slow,
      FeeOption.Custom(fee: var fee) => fee,
    };

    try {
      final utxos = await utxoRepository.getUnspentForAddress(source);
      final inputsSet = utxos.isEmpty ? null : utxos;

      ComposeIssuanceVerbose issuance =
          await composeRepository.composeIssuanceVerbose(source, name, quantity,
              divisible, lock, reset, description, null, true, 1, inputsSet);

      final virtualSize =
          transactionService.getVirtualSize(issuance.rawtransaction);

      final totalFee = virtualSize * feeRate;

      ComposeIssuanceVerbose issuanceActual =
          await composeRepository.composeIssuanceVerbose(
              source,
              name,
              quantity,
              divisible,
              lock,
              reset,
              description,
              null,
              true,
              totalFee,
              inputsSet);

      logger.d('rawTx: ${issuanceActual.rawtransaction}');

      emit(state.copyWith(
          submitState: SubmitComposingTransaction<ComposeIssuanceVerbose>(
              composeTransaction: issuanceActual,
              virtualSize: virtualSize,
              fee: totalFee,
              feeRate: feeRate)));
    } catch (error) {
      emit(state.copyWith(
          submitState: SubmitInitial(loading: false, error: error.toString())));
    }
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
    if (state.submitState is! SubmitFinalizing<ComposeIssuanceVerbose>) {
      return;
    }

    final issuanceParams =
        (state.submitState as SubmitFinalizing<ComposeIssuanceVerbose>)
            .composeTransaction;
    final fee =
        (state.submitState as SubmitFinalizing<ComposeIssuanceVerbose>).fee;

    emit(state.copyWith(
        submitState: SubmitFinalizing<ComposeIssuanceVerbose>(
            loading: true,
            error: null,
            composeTransaction: issuanceParams,
            fee: fee)));

    final source = issuanceParams.params.source;
    final password = event.password;

    try {
      final utxos = await utxoRepository.getUnspentForAddress(source);

      final rawTx = issuanceParams.rawtransaction;

      Map<String, Utxo> utxoMap = {for (var e in utxos) e.txid: e};

      Address? address = await addressRepository.getAddress(source);
      Account? account =
          await accountRepository.getAccountByUuid(address!.accountUuid);
      Wallet? wallet = await walletRepository.getWallet(account!.walletUuid);
      String? decryptedRootPrivKey;
      try {
        decryptedRootPrivKey =
            await encryptionService.decrypt(wallet!.encryptedPrivKey, password);
      } catch (e) {
        throw Exception("Incorrect password");
      }
      String addressPrivKey = await addressService.deriveAddressPrivateKey(
          rootPrivKey: decryptedRootPrivKey,
          chainCodeHex: wallet.chainCodeHex,
          purpose: account.purpose,
          coin: account.coinType,
          account: account.accountIndex,
          change: '0',
          index: address.index,
          importFormat: account.importFormat);

      String txHex = await transactionService.signTransaction(
          rawTx, addressPrivKey, source, utxoMap);

      String txHash = await bitcoindService.sendrawtransaction(txHex);

      TransactionInfoVerbose txInfo =
          await transactionRepository.getInfoVerbose(txHex);

      await transactionLocalRepository.insertVerbose(txInfo.copyWith(
        hash: txHash,
      ));

      logger.d('issue broadcasted txHash: $txHash');

      emit(state.copyWith(
          submitState:
              SubmitSuccess(transactionHex: txHash, sourceAddress: source)));

      analyticsService.trackEvent('broadcast_tx_issue');
    } catch (error) {
      final issuanceParams =
          (state.submitState as SubmitFinalizing<ComposeIssuanceVerbose>)
              .composeTransaction;
      final fee =
          (state.submitState as SubmitFinalizing<ComposeIssuanceVerbose>).fee;

      emit(state.copyWith(
          submitState: SubmitFinalizing<ComposeIssuanceVerbose>(
              loading: false,
              error: error.toString(),
              composeTransaction: issuanceParams,
              fee: fee)));
    }
  }
}
