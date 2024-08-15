import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
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
  // TODO: pass these in constructor to the bloc
  final addressRepository = GetIt.I.get<AddressRepository>();
  final balanceRepository = GetIt.I.get<BalanceRepository>();
  final composeRepository = GetIt.I.get<ComposeRepository>();
  final utxoRepository = GetIt.I.get<UtxoRepository>();
  final transactionService = GetIt.I.get<TransactionService>();
  final bitcoindService = GetIt.I.get<BitcoindService>();
  final accountRepository = GetIt.I.get<AccountRepository>();
  final walletRepository = GetIt.I.get<WalletRepository>();
  final encryptionService = GetIt.I.get<EncryptionService>();
  final addressService = GetIt.I.get<AddressService>();
  final transactionRepository = GetIt.I.get<TransactionRepository>();
  final transactionLocalRepository = GetIt.I.get<TransactionLocalRepository>();
  final bitcoinRepository = GetIt.I.get<BitcoinRepository>();

  ComposeSendBloc() : super(const ComposeSendState()) {
    on<FetchFormData>((event, emit) async {
      emit(const ComposeSendState(
          addressesState: AddressesState.loading(),
          balancesState: BalancesState.loading(),
          submitState: SubmitState.initial()));

      try {
        List<Address> addresses = [event.currentAddress];

        List<Balance> balances =
            await balanceRepository.getBalancesForAddress(addresses[0].address);
        emit(ComposeSendState(
            addressesState: AddressesState.success(addresses),
            balancesState: BalancesState.success(balances),
            submitState: const SubmitState.initial()));
      } catch (e) {
        emit(ComposeSendState(
            addressesState: AddressesState.error(e.toString()),
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

    on<ConfirmTransactionEvent>((event, emit) async {
      final source = event.sourceAddress;
      final destination = event.destinationAddress;
      final quantity = event.quantity;
      final asset = event.asset;
      // final memo = event.memo;
      // final memoIsHex = event.memoIsHex;

      final send = await composeRepository.composeSendVerbose(source,
          destination, asset, quantity, true, 2000); // TODO: don't hardcode fee
      emit(state.copyWith(
          submitState: SubmitState.composing(
              SubmitStateComposingSend(composeSend: send))));
    });

    on<SendTransactionEvent>((event, emit) async {
      emit(state.copyWith(submitState: const SubmitState.loading()));

      try {
        final sendParams = event.composeSend.params;
        final source = sendParams.source;
        final destination = sendParams.destination;
        final quantity = sendParams.quantity;
        final asset = sendParams.asset;
        final rawTx = event.composeSend.rawtransaction;
        final password = event.password;
        // final memo = event.memo;
        // final memoIsHex = event.memoIsHex;

        final utxoResponse =
            await utxoRepository.getUnspentForAddress(source, true);

        Map<String, Utxo> utxoMap = {for (var e in utxoResponse) e.txid: e};

        // print("utxoMap $utxoMap");

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
            change: '0', // TODO make sure change is stored
            index: address.index);

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

          // final txEither = await bitcoinRepository.getTransaction(txHash);

          // txEither.match((l) {
          //   print("error: ${l.message}");
          // }, (r) {
          //   final tx = r as BitcoinTx;
          //
          //   print("bitcontx cool: ${tx}");
          //
          //   // transactionLocalRepository.insert(tx.copyWith(
          //   //     source: source,
          //   //     destination: destination,
          //   //     asset: asset,
          //   //     quantity: quantity,
          //   //     fee: rawTx.fee,
          //   //     txHash: txHash));
          // });
        }

        emit(state.copyWith(submitState: SubmitState.success(txHash, source)));
      } catch (error) {
        rethrow;
        if (error is DioException) {
          emit(state.copyWith(
              submitState: SubmitState.error(
                  "${error.response!.data.keys.first} ${error.response!.data.values.first}")));
        } else {
          emit(
              state.copyWith(submitState: SubmitState.error(error.toString())));
        }
      }
    });
  }
}
