import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/settings/reset_wallet/bloc/reset_event.dart';
import 'package:horizon/presentation/screens/settings/reset_wallet/bloc/reset_state.dart';
import 'package:logger/logger.dart';
import 'package:horizon/domain/usecases/reset_wallet.dart';

class ResetBloc extends Bloc<ResetEvent, ResetState> {
  final logger = Logger();

  final ResetWalletUseCase resetWalletUseCase;

  ResetBloc({
    required this.resetWalletUseCase,
  }) : super(const ResetState()) {
    on<ResetEvent>(_onReset);
  }

  void _onReset(ResetEvent event, Emitter emit) async {
    logger.d('Reset event received');

    await resetWalletUseCase.call(const NoParams());

    emit(const ResetState(status: ResetStatus.completed));
  }
}
