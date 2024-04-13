import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/models/constants.dart';

class NetworkEvent {
  final String network;
  NetworkEvent({required this.network});
}

class NetworkState {
  final String network;
  NetworkState({required this.network});
}

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  NetworkBloc() : super(NetworkState(network: MAINNET)) {
    on<NetworkEvent>((event, emit) {
      emit(NetworkState(network: event.network));
    });
  }
}
