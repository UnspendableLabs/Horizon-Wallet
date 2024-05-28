import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';

class NetworkEvent {
  final NetworkEnum network;
  NetworkEvent({required this.network});
}

class NetworkState {
  final NetworkEnum network;
  NetworkState({required this.network});
}

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  NetworkBloc() : super(NetworkState(network: NetworkEnum.mainnet)) {
    on<NetworkEvent>((event, emit) {
      emit(NetworkState(network: event.network));
    });
  }
}
