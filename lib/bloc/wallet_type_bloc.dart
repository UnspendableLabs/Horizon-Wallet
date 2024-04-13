import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/models/constants.dart';

class WalletTypeEvent {
  final String walletType;
  WalletTypeEvent({required this.walletType});
}

class WalletTypeState {
  final String walletType;
  WalletTypeState({required this.walletType});
}

class WalletTypeBloc extends Bloc<WalletTypeEvent, WalletTypeState> {
  WalletTypeBloc() : super(WalletTypeState(walletType: COUNTERWALLET)) {
    on<WalletTypeEvent>((event, emit) {
      emit(WalletTypeState(walletType: event.walletType));
    });
  }
}
