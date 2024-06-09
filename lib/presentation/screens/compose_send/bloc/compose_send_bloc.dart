import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import "package:horizon/api/v2_api.dart" as v2_api;
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/bitcoind.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';

class ComposeSendBloc extends Bloc<ComposeSendEvent, ComposeSendState> {
  ComposeSendBloc() : super(ComposeSendInitial()) {
    on<SendTransactionEvent>((event, emit) async => _onSendTransactionEvent(event, emit));

    on<SignTransactionEvent>((event, emit) async => _onSignTransactionEvent(event, emit));
  }
}

_onSignTransactionEvent(SignTransactionEvent event, emit) async {
  final bitcoindService = GetIt.I.get<BitcoindService>();
  final transactionService = GetIt.I.get<TransactionService>();
  final walletRepository = GetIt.I<WalletRepository>();
  final client = GetIt.I.get<v2_api.V2Api>();

  try {
    final utxoResponse = await client.getUnspentUTXOs(event.sourceAddress.address, false);

    if (utxoResponse.error != null) {
      return emit(ComposeSendError(message: utxoResponse.error!));
    }

    Map<String, v2_api.UTXO> utxoMap = {for (var e in utxoResponse.result!) e.txid: e};

    final wallet = await walletRepository.getWalletByUuid(event.sourceAddress.walletUuid!);

    String txHex = await transactionService.signTransaction(
        event.unsignedTransactionHex, wallet!.wif, event.sourceAddress.address, utxoMap);

    bitcoindService.sendrawtransaction(txHex);

    emit(ComposeSendSignSuccess(signedTransaction: txHex));
  } catch (error) {
    rethrow;
    // emit(TransactionError(message: error.toString()));
  }
}

_onSendTransactionEvent(SendTransactionEvent event, emit) async {
  emit(ComposeSendLoading());

  try {
    final source = event.sourceAddress;
    final destination = event.destinationAddress;
    final quantity = event.quantity;
    final asset = event.asset;
    // final memo = event.memo;
    // final memoIsHex = event.memoIsHex;

    final client = GetIt.I.get<v2_api.V2Api>();

    final response = await client.composeSend(source.address, destination, asset, quantity, true, 100);
    debugger(when: true);
    if (response.error != null) {
      return emit(ComposeSendError(message: response.error!));
    }

    final txInfoResponse = await client.getTransactionInfo(response.result!.rawtransaction);
    debugger(when: true);
    if (txInfoResponse.error != null) {
      return emit(ComposeSendError(message: txInfoResponse.error!));
    }

    final transactionService = GetIt.I.get<TransactionService>();
    final walletRepository = GetIt.I<WalletRepository>();

    final utxoResponse = await client.getUnspentUTXOs(event.sourceAddress.address, false);

    if (utxoResponse.error != null) {
      return emit(ComposeSendError(message: utxoResponse.error!));
    }

    Map<String, v2_api.UTXO> utxoMap = {for (var e in utxoResponse.result!) e.txid: e};

    final wallet = await walletRepository.getWalletByUuid(event.sourceAddress.walletUuid!);
    debugger(when: true);

    String txHex = await transactionService.signTransaction(
        response.result!.rawtransaction, wallet!.wif, event.sourceAddress.address, utxoMap);

    debugger(when: true);
    final bitcoindService = GetIt.I.get<BitcoindService>();
    bitcoindService.sendrawtransaction(txHex);

    emit(ComposeSendSuccess(
        transactionHex: response.result!.rawtransaction, info: txInfoResponse.result!, sourceAddress: source.address));
  } catch (error) {
    if (error is DioException) {
      emit(ComposeSendError(message: "${error.response!.data.keys.first} ${error.response!.data.values.first}"));
    } else {
      emit(ComposeSendError(message: error.toString()));
    }
  }
}
