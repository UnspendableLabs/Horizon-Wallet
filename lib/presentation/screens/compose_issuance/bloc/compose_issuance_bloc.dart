import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/usecase/get_fee_estimates.dart';

class ComposeIssuanceBloc
    extends Bloc<ComposeIssuanceEvent, ComposeIssuanceState> {
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
  }) : super(ComposeIssuanceState(
            submitState: const SubmitInitial(),
            feeOption: FeeOption.Medium())) {
    on<ChangeFeeOption>((event, emit) async {
      final value = event.value;
      emit(state.copyWith(feeOption: value));
    });
    on<FetchFormData>((event, emit) async {
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
    });

    on<FetchBalances>((event, emit) async {
      emit(state.copyWith(balancesState: const BalancesState.loading()));
      try {
        List<Balance> balances =
            await balanceRepository.getBalancesForAddress(event.address);
        emit(state.copyWith(balancesState: BalancesState.success(balances)));
      } catch (e) {
        emit(state.copyWith(balancesState: BalancesState.error(e.toString())));
      }
    });

    on<ComposeTransactionEvent>((event, emit) async {
      FeeEstimates? feeEstimates = state.feeState
          .maybeWhen(success: (value) => value, orElse: () => null);

      if (feeEstimates == null) {
        return;
      }
      emit(state.copyWith(submitState: const SubmitInitial(loading: true)));

      final source = event.sourceAddress;
      final quantity = event.quantity;
      final name = event.name;
      final divisible = event.divisible;
      final lock = event.lock;
      final reset = event.reset;
      final description = event.description;
      final feeRate = switch (state.feeOption) {
        FeeOption.Fast() => feeEstimates.fast,
        FeeOption.Medium() => feeEstimates.medium,
        FeeOption.Slow() => feeEstimates.slow,
        FeeOption.Custom(fee: var fee) => fee,
      };
      // final transferDestination = event.transferDestination;

      try {
        print('SOURCE: $source');
        final utxos = await utxoRepository.getUnspentForAddress(source);

        final utxoQueryStringParam = utxos.map((u) => "${u.txid}:${u.vout}").join(',');
        ComposeIssuanceVerbose issuance =
            await composeRepository.composeIssuanceVerbose(source, name,
                quantity, divisible, lock, reset, description, null, true, 1, utxoQueryStringParam);

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
                utxoQueryStringParam);

        emit(state.copyWith(
            submitState: SubmitComposing(SubmitStateComposingIssuance(
                composeIssuance: issuanceActual,
                virtualSize: virtualSize,
                fee: totalFee,
                feeRate: feeRate))));
      } catch (error) {
        emit(state.copyWith(
            submitState:
                SubmitInitial(loading: false, error: error.toString())));
      }
    });

    on<FinalizeTransactionEvent>((event, emit) async {
      emit(state.copyWith(
          submitState: SubmitFinalizing(
        loading: false,
        error: null,
        composeIssuance: event.composeIssuance,
        fee: event.fee,
      )));
    });

    on<SignAndBroadcastTransactionEvent>((event, emit) async {
      if (state.submitState is! SubmitFinalizing) {
        return;
      }

      final issuanceParams =
          (state.submitState as SubmitFinalizing).composeIssuance;
      final fee = (state.submitState as SubmitFinalizing).fee;

      emit(state.copyWith(
          submitState: SubmitFinalizing(
              loading: true,
              error: null,
              composeIssuance: issuanceParams,
              fee: fee)));

      final source = issuanceParams.params.source;
      final password = event.password;

      try {
        final utxoResponse = await utxoRepository.getUnspentForAddress(source);
        final utxoQueryStringParam = utxoResponse.map((u) => "${u.txid}:${u.vout}").join(',');

        ComposeIssuanceVerbose issuance =
            await composeRepository.composeIssuanceVerbose(
                issuanceParams.params.source,
                issuanceParams.params.asset,
                issuanceParams.params.quantity,
                issuanceParams.params.divisible,
                issuanceParams.params.lock,
                issuanceParams.params.reset,
                issuanceParams.params.description,
                null,
                true,
                fee,
                utxoQueryStringParam);

        final rawTx = issuance.rawtransaction;


        Map<String, Utxo> utxoMap = {for (var e in utxoResponse) e.txid: e};

        Address? address = await addressRepository.getAddress(source);
        Account? account =
            await accountRepository.getAccountByUuid(address!.accountUuid);
        Wallet? wallet = await walletRepository.getWallet(account!.walletUuid);
        String? decryptedRootPrivKey;
        try {
          decryptedRootPrivKey = await encryptionService.decrypt(
              wallet!.encryptedPrivKey, password);
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

        emit(state.copyWith(submitState: SubmitSuccess(transactionHex: txHex)));
      } catch (error) {
        final issuanceParams =
            (state.submitState as SubmitFinalizing).composeIssuance;
        final fee = (state.submitState as SubmitFinalizing).fee;

        emit(state.copyWith(
            submitState: SubmitFinalizing(
                loading: false,
                error: error.toString(),
                composeIssuance: issuanceParams,
                fee: fee)));
      }
    });
  }
}
