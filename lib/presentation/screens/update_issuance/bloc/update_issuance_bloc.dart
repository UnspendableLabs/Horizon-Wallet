import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/compose_base/shared/compose_tx.dart';
import 'package:horizon/presentation/common/compose_base/shared/sign_and_broadcast_tx.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_bloc.dart';
import 'package:horizon/presentation/screens/update_issuance/bloc/update_issuance_state.dart';
import 'package:logger/logger.dart';

class UpdateIssuanceEventParams extends ComposeIssuanceEventParams {
  final IssuanceActionType issuanceActionType;
  final String? destination;

  UpdateIssuanceEventParams({
    required super.name,
    required super.quantity,
    required super.description,
    required super.divisible,
    required super.lock,
    required super.reset,
    required this.issuanceActionType,
    this.destination,
  });
}

class UpdateIssuanceBloc extends ComposeBaseBloc<UpdateIssuanceState> {
  final Logger logger = Logger();
  final AssetRepository assetRepository;
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

  UpdateIssuanceBloc({
    required this.assetRepository,
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
  }) : super(UpdateIssuanceState(
          submitState: const SubmitInitial(),
          feeOption: FeeOption.Medium(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
          assetState: const AssetState.initial(),
        ));

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    if (event.assetName == null || event.currentAddress == null) {
      return;
    }

    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      submitState: const SubmitInitial(),
      assetState: const AssetState.loading(),
    ));

    final Asset asset;
    late FeeEstimates feeEstimates;
    late Balance? balance;

    try {
      asset = await assetRepository.getAssetVerbose(event.assetName!);
    } catch (e) {
      emit(state.copyWith(assetState: AssetState.error(e.toString())));
      return;
    }

    try {
      balance = await balanceRepository.getBalanceForAddressAndAssetVerbose(
          event.assetName!, event.currentAddress!.address);
    } catch (e) {
      emit(state.copyWith(balancesState: BalancesState.error(e.toString())));
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
      assetState: AssetState.success(asset),
      balancesState: BalancesState.success([balance]),
      feeState: FeeState.success(feeEstimates),
    ));
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {
    await composeTransaction<ComposeIssuanceVerbose, UpdateIssuanceState>(
        state: state,
        emit: emit,
        event: event,
        utxoRepository: utxoRepository,
        composeRepository: composeRepository,
        transactionService: transactionService,
        logger: logger,
        transactionHandler: (inputsSet, feeRate) async {
          final issuanceParams = event.params;
          // Dummy transaction to compute virtual size
          final issuance = await composeRepository.composeIssuanceVerbose(
            event.sourceAddress,
            issuanceParams.name,
            issuanceParams.quantity,
            issuanceParams.divisible,
            issuanceParams.lock,
            issuanceParams.reset,
            issuanceParams.description,
            issuanceParams.destination,
            true,
            1,
            inputsSet,
          );

          final virtualSize =
              transactionService.getVirtualSize(issuance.rawtransaction);
          final int totalFee = virtualSize * feeRate;

          final composeTransaction =
              await composeRepository.composeIssuanceVerbose(
            event.sourceAddress,
            issuanceParams.name,
            issuanceParams.quantity,
            issuanceParams.divisible,
            issuanceParams.lock,
            issuanceParams.reset,
            issuanceParams.description,
            issuanceParams.destination,
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
            UpdateIssuanceState>(
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
          final issuanceParams =
              (state.submitState as SubmitFinalizing<ComposeIssuanceVerbose>)
                  .composeTransaction;
          final source = issuanceParams.params.source;
          final rawTx = issuanceParams.rawtransaction;
          final destination =
              issuanceParams.params.transferDestination ?? source;
          final quantity = issuanceParams.params.quantity;
          final asset = issuanceParams.params.asset;

          return (source, rawTx, destination, quantity, asset);
        },
        successAction:
            (txHex, txHash, source, destination, quantity, asset) async {
          TransactionInfoVerbose txInfo =
              await transactionRepository.getInfoVerbose(txHex);

          await transactionLocalRepository.insertVerbose(txInfo.copyWith(
            hash: txHash,
          ));

          logger.d('issue broadcasted txHash: $txHash');

          emit(state.copyWith(
              submitState: SubmitSuccess(
                  transactionHex: txHex, sourceAddress: source!)));

          analyticsService.trackEvent('broadcast_tx_issue');
        });
  }
}
