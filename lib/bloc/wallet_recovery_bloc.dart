import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/common/constants.dart';

class WalletRecoveryEvent {
  final RecoveryWalletEnum recoveryWallet;
  WalletRecoveryEvent({required this.recoveryWallet});
}

class WalletRecoveryState {
  final RecoveryWalletEnum recoveryWallet;
  WalletRecoveryState({required this.recoveryWallet});
}

class WalletRecoveryBloc extends Bloc<WalletRecoveryEvent, WalletRecoveryState> {
  WalletRecoveryBloc() : super(WalletRecoveryState(recoveryWallet: RecoveryWalletEnum.counterwallet)) {
    on<WalletRecoveryEvent>((event, emit) {
      emit(WalletRecoveryState(recoveryWallet: event.recoveryWallet));
    });
  }
}
