// Define the data bloc
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/data_events.dart';
import 'package:uniparty/bloc/data_state.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';
import 'package:uniparty/utils/secure_storage.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final secureStorage = SecureStorage();

  DataBloc() : super(DataState(data: null)) {
    on<WriteDataEvent>((event, emit) async {
      String walletInfoJson = WalletRetrieveInfo.serialize(event.data);
      await secureStorage.writeSecureData(key: 'wallet_info', value: walletInfoJson);

      emit(DataState(data: event.data));
    });

    on<SetDataEvent>((event, emit) => emit(DataState(data: event.data)));
  }
}
