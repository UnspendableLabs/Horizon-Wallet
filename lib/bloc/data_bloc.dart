// Define the data bloc
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/data_events.dart';
import 'package:uniparty/bloc/data_state.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';
import 'package:uniparty/utils/secure_storage.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final _secureStorage = SecureStorage();
  DataBloc() : super(DataState(initial: null, loading: Loading(), success: null, failure: null)) {
    on<FetchDataEvent>((event, emit) async {
      try {
        print('fetching??');
        //TODO: pull out to a separate service
        WalletRetrieveInfo? walletRetrieveInfo = await _secureStorage.readWalletRetrieveInfo();

        if (walletRetrieveInfo != null) {
          emit(DataState(initial: null, loading: null, success: Success(data: walletRetrieveInfo), failure: null));
        }
        emit(DataState(initial: Initial(), loading: null, success: null, failure: null));
      } catch (e) {
        emit(DataState(initial: Initial(), loading: null, success: null, failure: Failure(message: e.toString())));
      }
    });
    on<SetDataEvent>((event, emit) async {
      print('setting state???');
      await _secureStorage.writeWalletRetrieveInfo(event.walletRetrieveInfo);
      print('setting state: ${event.walletRetrieveInfo}');
      emit(DataState(initial: null, loading: null, success: Success(data: event.walletRetrieveInfo), failure: null));
    });
  }
}
