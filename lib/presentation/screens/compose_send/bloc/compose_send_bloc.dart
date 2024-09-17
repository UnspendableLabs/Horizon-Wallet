import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';

class ComposeSendBloc extends Bloc<ComposeSendEvent, ComposeSendState> {
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
  final BitcoinRepository bitcoinRepository;

  ComposeSendBloc({
    required this.addressRepository,
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
    required this.bitcoinRepository,
  }) : super(const ComposeSendState()) {
    on<FetchFormData>((event, emit) async {
      emit(const ComposeSendState(
          balancesState: BalancesState.loading(),
          submitState: SubmitState.initial()));

      try {
        List<Address> addresses = [event.currentAddress];

        List<Balance> balances =
            await balanceRepository.getBalancesForAddress(addresses[0].address);
        emit(ComposeSendState(
            balancesState: BalancesState.success(balances),
            submitState: const SubmitState.initial()));
      } catch (e) {
        emit(ComposeSendState(
            balancesState: BalancesState.error(e.toString()),
            submitState: const SubmitState.initial()));
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
      try {
        final source = event.sourceAddress;
        final destination = event.destinationAddress;
        final quantity = event.quantity;
        final asset = event.asset;

        // We use lowest fee possible here ( 1 sat )
        // so we can calculate the virtual size of the transaction
        final send = await composeRepository.composeSendVerbose(
            source, destination, asset, quantity, true, 1);

        final virtualSize =
            transactionService.getVirtualSize(send.rawtransaction);

        final feeEstimatesE = await bitcoinRepository.getFeeEstimates();

        final feeEstimates = feeEstimatesE.fold(
            (l) => throw Exception("Error getting fee estimates"), (r) => r);

        emit(state.copyWith(
            submitState: SubmitState.composing(SubmitStateComposingSend(
                composeSend: send,
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
        composeSend: event.composeSend,
        fee: event.fee,
      ))));
    });

    on<SignAndBroadcastTransactionEvent>((event, emit) async {
      final finalizingState = state.submitState.maybeWhen(
          finalizing: (finalizing) => finalizing,
          orElse: () => throw Exception("Invariant: state not found"));

      emit(state.copyWith(submitState: const SubmitState.loading()));

      try {
        final sendParams = finalizingState.composeSend.params;
        final source = sendParams.source;
        final destination = sendParams.destination;
        final quantity = sendParams.quantity;
        final asset = sendParams.asset;
        final fee = finalizingState.fee;
        final password = event.password;

        // Compose a new tx with user specified fee
        final send = await composeRepository.composeSendVerbose(
            source, destination, asset, quantity, true, fee);

        final rawTx = send.rawtransaction;

        // final memo = event.memo;
        // final memoIsHex = event.memoIsHex;

        final utxoResponse =
            await utxoRepository.getUnspentForAddress(source, true);

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

        // for now we don't track btc sends
        if (asset.toLowerCase() != 'btc') {
          TransactionInfoVerbose txInfo =
              await transactionRepository.getInfoVerbose(txHex);

          await transactionLocalRepository.insertVerbose(txInfo.copyWith(
              hash: txHash,
              source:
                  source // TODO: set this manually as a tmp hack because it can be undefined with btc sends
              ));
        } else {
          // TODO: this is a bit of a hack
          transactionLocalRepository.insertVerbose(TransactionInfoVerbose(
            hash: txHash,
            source: source,
            destination: destination,
            btcAmount: quantity,
            domain: TransactionInfoDomainLocal(
                raw: txHex, submittedAt: DateTime.now()),
            btcAmountNormalized: quantity.toString(), //TODO: this is temporary
            fee: 0, // dummy values
            data: "",
          ));
        }

        emit(state.copyWith(submitState: SubmitState.success(txHash, source)));
      } catch (error) {
        emit(state.copyWith(submitState: SubmitState.error(error.toString())));
      }
    });
  }
}
