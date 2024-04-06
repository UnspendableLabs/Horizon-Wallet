// Define the data bloc
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/bloc_events.dart';
import 'package:uniparty/bloc/data_state.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';
import 'package:uniparty/utils/secure_storage.dart';

class DataBloc extends Bloc<FetchDataEvent, DataState> {
  DataBloc() : super(DataState(isLoading: true)) {
    on<FetchDataEvent>((event, emit) async {
      try {
        WalletRetrieveInfo? walletRetrieveInfo = await SecureStorage().readWalletRetrieveInfo();

        if (walletRetrieveInfo != null) {
          emit(DataState(isLoading: false, data: walletRetrieveInfo));
        }
        emit(DataState(isLoading: false));
      } catch (e) {
        emit(DataState(isLoading: false, error: "Failed to fetch data: $e"));
      }
    });
  }
}
//   Stream<DataState> _mapFetchDataToState(Emitter<DataState> emit) async* {
//     print('in the map');
//     try {
//       print('are we fetching?');
//       // Simulate async data fetching
//       WalletRetrieveInfo? walletRetrieveInfo = await SecureStorage().readWalletRetrieveInfo();

//       if (walletRetrieveInfo != null) {
//         emit(DataState(data: walletRetrieveInfo));
//       }
//     } catch (e) {
//       print('ERRPOR? $e');
//       emit(DataState(error: "Failed to fetch data: $e"));
//     }
//   }
// }

// class DataBloc extends Bloc<FetchDataEvent, DataState> {
//   DataBloc() : super(DataState(isLoading: true)) {
//     @override
//     Stream<DataState> mapEventToState(DataEvent event) async* {
//       if (event is FetchDataEvent) {
//         _mapFetchDataToState(event);
//       }
//     }
//   }

//   Stream<DataState> _mapFetchDataToState(FetchDataEvent event) async* {
//     print('in the map');
//     try {
//       print('are we fetching?');
//       // Simulate async data fetching
//       WalletRetrieveInfo? walletRetrieveInfo = await SecureStorage().readWalletRetrieveInfo();

//       if (walletRetrieveInfo != null) {
//         yield DataState(data: walletRetrieveInfo);
//       }
//     } catch (e) {
//       yield DataState(error: "Failed to fetch data: $e");
//     }
//   }
// }

// Define the data bloc
// class DataBloc extends Bloc<FetchDataEvent, DataState> {
//   DataBloc() : super(DataState(isLoading: true));

//   @override
//   Stream<DataState> mapEventToState(FetchDataEvent event) async* {
//     try {
//       // Simulate async data fetching
//       WalletRetrieveInfo? walletRetrieveInfo = await SecureStorage().readWalletRetrieveInfo();
//       // Replace this with your actual data fetching logic
//       if (walletRetrieveInfo != null) {
//         yield DataState(data: walletRetrieveInfo);
//       }
//     } catch (e) {
//       yield DataState(error: "Failed to fetch data: $e");
//     }
//   }
// }
