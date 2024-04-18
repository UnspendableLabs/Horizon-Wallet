import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/stored_wallet_data.dart';
import 'package:uniparty/models/transaction.dart';
import 'package:uniparty/services/key_value_store_service.dart';

sealed class TransactionState {
  const TransactionState();
}

class TransactionInitial extends TransactionState {
  final List<String> sourceAddressOptions;
  TransactionInitial({required this.sourceAddressOptions});
}

class TransactionLoading extends TransactionState {
  TransactionLoading();
}

class TransactionSuccess extends TransactionState {
  final Transaction transaction;
  TransactionSuccess({required this.transaction});
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
  TransactionBloc() : super(TransactionLoading()) {
    on<InitializeTransactionEvent>((event, emit) async {
      emit(TransactionLoading());
      KeyValueService keyValueService = GetIt.I.get<KeyValueService>();
      String? walletJson = await keyValueService.get(STORED_WALLET_DATA_KEY);
      if (walletJson == null) {
        emit(TransactionError(message: 'No wallet data found'));
        return;
      }
      StoredWalletData walletData = StoredWalletData.deserialize(walletJson);

      if (event.network == NetworkEnum.mainnet) {
        emit(TransactionInitial(sourceAddressOptions: walletData.mainnetNodes.map((e) => e.address).toList()));
      } else {
        emit(TransactionInitial(sourceAddressOptions: walletData.testnetNodes.map((e) => e.address).toList()));
      }
    });
    on<TransactionEvent>((event, emit) {
      emit(TransactionLoading());
      // emit(_buildTransactionState(event));
    });
  }
}
