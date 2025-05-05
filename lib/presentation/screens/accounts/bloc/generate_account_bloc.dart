import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:formz/formz.dart';
import "package:equatable/equatable.dart";

abstract class GenerateAccountEvent {}

class GenerateAccountClicked extends GenerateAccountEvent {}

class GenerateAccountState extends Equatable {
  final FormzSubmissionStatus status;

  const GenerateAccountState({
    this.status = FormzSubmissionStatus.initial,
  });

  @override
  List<Object?> get props => [status];
}

class GenerateAccountBloc
    extends Bloc<GenerateAccountEvent, GenerateAccountState> {
  final WalletConfigRepository _walletConfigRepository;
  GenerateAccountBloc({
    WalletConfigRepository? walletConfigRepository,
  })  : _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        super(const GenerateAccountState()) {
    on<GenerateAccountClicked>((event, emit) async {
      emit(GenerateAccountState(
        status: FormzSubmissionStatus.inProgress,
      ));

      // TODO: current config needs to be dynamic.
      final walletConfigs = await _walletConfigRepository.getAll();
      final mainnetConfig = walletConfigs.first;

      try {
        final create = await _walletConfigRepository.update(mainnetConfig
            .copyWith(accountIndexEnd: mainnetConfig.accountIndexEnd + 1));
        emit(GenerateAccountState(
          status: FormzSubmissionStatus.success,
        ));
        emit(GenerateAccountState(
          status: FormzSubmissionStatus.initial,
        ));
      } catch (e, callstack) {
        emit(GenerateAccountState(
          status: FormzSubmissionStatus.failure,
        ));
      }
    });
  }
}
