import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/counterparty_api/counterparty_api.dart';
import 'package:uniparty/models/stored_wallet_data.dart';
import 'package:uniparty/models/transaction.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/services/key_value_store_service.dart';

sealed class TransactionState {
  const TransactionState();
}

class TransactionInitial extends TransactionState {
  final List<String> sourceAddressOptions;
  TransactionInitial({required this.sourceAddressOptions});
}

class InitializeTransactionLoading extends TransactionState {
  InitializeTransactionLoading();
}

class SendTransactionLoading extends TransactionState {
  SendTransactionLoading();
}

class TransactionSuccess extends TransactionState {
  final String transactionHex;
  TransactionSuccess({required this.transactionHex});
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError({required this.message});
}

sealed class TransactionEvent {
  const TransactionEvent();
}

class InitializeTransactionEvent extends TransactionEvent {
  final NetworkEnum network;
  const InitializeTransactionEvent({required this.network});
}

class SendTransactionEvent extends TransactionEvent {
  final Transaction transaction;
  final NetworkEnum network;
  SendTransactionEvent({required this.transaction, required this.network});
}

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(InitializeTransactionLoading()) {
    on<InitializeTransactionEvent>((event, emit) async => await _onInitializeTransaction(event, emit));

    on<SendTransactionEvent>((event, emit) async => _onSendTransactionEvent(event, emit));
  }
}

_onInitializeTransaction(event, emit) async {
  emit(InitializeTransactionLoading());
  KeyValueService keyValueService = GetIt.I.get<KeyValueService>();

  List<String> addressOptions = await _getAddressOptionsForNetwork(emit, event.network, keyValueService);

  emit(TransactionInitial(sourceAddressOptions: addressOptions));
}

_onSendTransactionEvent(event, emit) async {
  emit(SendTransactionLoading());
  final CounterpartyApi counterpartyApi = GetIt.I.get<CounterpartyApi>();
  try {
    final response = await counterpartyApi.createSendTransaction(event.transaction, event.network);
    emit(TransactionSuccess(transactionHex: response));
  } catch (error) {
    emit(TransactionError(message: error.toString()));
  }
}

Future<List<String>> _getAddressOptionsForNetwork(emit, NetworkEnum network, KeyValueService keyValueService) async {
  switch (network) {
    case NetworkEnum.mainnet:
      String? mainnetNodesJson = await keyValueService.get(MAINNET_WALLET_NODES_KEY);

      if (mainnetNodesJson == null) {
        return emit(TransactionError(message: 'No mainnet wallet nodes found'));
      }

      List<WalletNode> mainnetNodes = WalletNode.deserializeList(mainnetNodesJson);

      return mainnetNodes.map((e) => e.address).toList();

    case NetworkEnum.testnet:
      String? testnetNodesJson = await keyValueService.get(TESTNET_WALLET_NODES_KEY);

      if (testnetNodesJson == null) {
        return emit(TransactionError(message: 'No testnet wallet nodes found'));
      }

      List<WalletNode> testnetNodes = WalletNode.deserializeList(testnetNodesJson);

      return testnetNodes.map((e) => e.address).toList();
  }
}
