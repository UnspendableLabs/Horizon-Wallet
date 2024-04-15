// Define the data bloc
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/stored_wallet_data.dart';
import 'package:uniparty/services/key_value_store_service.dart';

abstract class StoredWalletDataEvent {}

class WriteStoredWalletDataEvent extends StoredWalletDataEvent {
  final StoredWalletData data;
  WriteStoredWalletDataEvent({required this.data});
}

class StoredWalletDataState {
  final StoredWalletData? data;

  StoredWalletDataState({this.data});
}

class StoredWalletDataBloc extends Bloc<StoredWalletDataEvent, StoredWalletDataState> {
  StoredWalletDataBloc() : super(StoredWalletDataState(data: null)) {
    on<WriteStoredWalletDataEvent>((event, emit) async {
      String walletDataJson = StoredWalletData.serialize(event.data);

      await GetIt.I.get<KeyValueService>().set(STORED_WALLET_DATA_KEY, walletDataJson);

      emit(StoredWalletDataState(data: event.data));
    });
  }
}
