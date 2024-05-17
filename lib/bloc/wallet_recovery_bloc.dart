import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/common/constants.dart';

class WalletRecoveryEvent {
  final WalletType recoveryWallet;
  WalletRecoveryEvent({required this.recoveryWallet});
}

class WalletRecoveryState {
  final WalletType recoveryWallet;
  WalletRecoveryState({required this.recoveryWallet});
}

class WalletRecoveryBloc extends Bloc<WalletRecoveryEvent, WalletRecoveryState> {
  WalletRecoveryBloc() : super(WalletRecoveryState(recoveryWallet: WalletType.counterwallet)) {
    on<WalletRecoveryEvent>((event, emit) {
      emit(WalletRecoveryState(recoveryWallet: event.recoveryWallet));
    });
  }
}
