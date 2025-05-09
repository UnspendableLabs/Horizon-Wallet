import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:formz/formz.dart';
import "package:equatable/equatable.dart";
import 'package:horizon/domain/entities/wallet_config.dart';

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
  // TODO: passing in wallet config here is slight smell
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

      final walletConfig =
          await _walletConfigRepository.getCurrent();

      print("walletConfig.basePath: ${walletConfig.network}");
      print("walletConfig.basePath: ${walletConfig.basePath}");
      // TODO: current config needs to be dynamic.

      try {
        await _walletConfigRepository.update(walletConfig.copyWith(
            accountIndexEnd: walletConfig.accountIndexEnd + 1));
        emit(GenerateAccountState(
          status: FormzSubmissionStatus.success,
        ));
        emit(GenerateAccountState(
          status: FormzSubmissionStatus.initial,
        ));
      } catch (e, _) {
        print(e);
        print(_);
        emit(GenerateAccountState(
          status: FormzSubmissionStatus.failure,
        ));
      }
    });
  }
}
