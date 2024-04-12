// Define the data bloc
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/bloc/data_events.dart';
import 'package:uniparty/bloc/data_state.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';
import 'package:uniparty/services/key_value_store.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  DataBloc() : super(DataState(data: null)) {
    on<WriteDataEvent>((event, emit) async {
      String walletInfoJson = WalletRetrieveInfo.serialize(event.data);
      await GetIt.I.get<KeyValueService>().set('wallet_info', walletInfoJson);

      emit(DataState(data: event.data));
    });

    on<SetDataEvent>((event, emit) => emit(DataState(data: event.data)));
  }
}
