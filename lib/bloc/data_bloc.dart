// Define the data bloc
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/bloc_events.dart';
import 'package:uniparty/bloc/data_state.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';
import 'package:uniparty/utils/secure_storage.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final _secureStorage = SecureStorage();
  DataBloc() : super(DataState(isLoading: true)) {
    on<FetchDataEvent>((event, emit) async {
      try {
        //TODO: pull out to a separate service
        WalletRetrieveInfo? walletRetrieveInfo = await _secureStorage.readWalletRetrieveInfo();

        if (walletRetrieveInfo != null) {
          emit(DataState(isLoading: false, data: walletRetrieveInfo));
        }
        emit(DataState(isLoading: false));
      } catch (e) {
        emit(DataState(isLoading: false, error: "Failed to fetch data: $e"));
      }
    });
    on<SetDataEvent>((event, emit) async {
      print('setting state???');
      await _secureStorage.writeWalletRetrieveInfo(event.walletRetrieveInfo);
      print('setting state: ${event.walletRetrieveInfo}');
      emit(DataState(data: event.walletRetrieveInfo));
    });
  }
}
