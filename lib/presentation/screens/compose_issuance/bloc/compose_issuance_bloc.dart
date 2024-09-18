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
import 'package:horizon/domain/repositories/bitcoin_repository.dart';

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
  }) : super(const ComposeIssuanceState()) {
    on<FetchFormData>((event, emit) async {
      emit(const ComposeIssuanceState(
          addressesState: AddressesState.loading(),
          balancesState: BalancesState.loading(),
          submitState: SubmitState.initial()));

      try {
        List<Address> addresses = [event.currentAddress];
        List<Balance> balances =
            await balanceRepository.getBalancesForAddress(addresses[0].address);
        emit(ComposeIssuanceState(
          addressesState: AddressesState.success(addresses),
          balancesState: BalancesState.success(balances),
        ));
      } catch (e) {
        emit(ComposeIssuanceState(
          addressesState: AddressesState.error(e.toString()),
          balancesState: BalancesState.error(e.toString()),
        ));
      }
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
      emit(state.copyWith(submitState: const SubmitState.loading()));
      final source = event.sourceAddress;
      final quantity = event.quantity;
      final name = event.name;
      final divisible = event.divisible;
      final lock = event.lock;
      final reset = event.reset;
      final description = event.description;
      // final transferDestination = event.transferDestination;

      emit(state.copyWith(submitState: const SubmitState.loading()));
      try {
        ComposeIssuanceVerbose issuance =
            await composeRepository.composeIssuanceVerbose(source, name,
                quantity, divisible, lock, reset, description, null, true, 1);

        final virtualSize =
            transactionService.getVirtualSize(issuance.rawtransaction);

        final feeEstimatesE = await bitcoinRepository.getFeeEstimates();

        final feeEstimates = feeEstimatesE.fold(
            (l) => throw Exception("Error getting fee estimates"), (r) => r);

        emit(state.copyWith(
            submitState: SubmitState.composing(SubmitStateComposingIssuance(
                composeIssuance: issuance,
                virtualSize: virtualSize,
                feeEstimates: feeEstimates,
                confirmationTarget: feeEstimates.keys.first))));
      } catch (error) {
        emit(state.copyWith(submitState: SubmitState.error(error.toString())));
      }
    });

    on<FinalizeTransactionEvent>((event, emit) async {
      emit(state.copyWith(
          submitState: SubmitState.finalizing(SubmitStateFinalizing(
        composeIssuance: event.composeIssuance,
        fee: event.fee,
      ))));
    });

    on<SignAndBroadcastTransactionEvent>((event, emit) async {
      final finalizingState = state.submitState.maybeWhen(
          finalizing: (finalizing) => finalizing,
          orElse: () => throw Exception("Invariant: state not found"));

      emit(state.copyWith(submitState: const SubmitState.loading()));

      final composeIssuance = finalizingState.composeIssuance;
      final source = composeIssuance.params.source;
      final fee = finalizingState.fee;
      final password = event.password;

      try {
        ComposeIssuanceVerbose issuance =
            await composeRepository.composeIssuanceVerbose(
                composeIssuance.params.source,
                composeIssuance.params.asset,
                composeIssuance.params.quantity,
                composeIssuance.params.divisible,
                composeIssuance.params.lock,
                composeIssuance.params.reset,
                composeIssuance.params.description,
                null,
                true,
                fee);

        final rawTx = issuance.rawtransaction;

        final utxoResponse = await utxoRepository.getUnspentForAddress(source);

        Map<String, Utxo> utxoMap = {for (var e in utxoResponse) e.txid: e};

        Address? address = await addressRepository.getAddress(source);
        Account? account =
            await accountRepository.getAccountByUuid(address!.accountUuid);
        Wallet? wallet = await walletRepository.getWallet(account!.walletUuid);
        String decryptedRootPrivKey =
            await encryptionService.decrypt(wallet!.encryptedPrivKey, password);
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

        emit(state.copyWith(submitState: SubmitState.success(txHex)));
      } catch (error) {
        emit(state.copyWith(submitState: SubmitState.error(error.toString())));
      }
    });
  }
}
