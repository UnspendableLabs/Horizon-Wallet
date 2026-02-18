import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';

import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/services/bls_service.dart';
import 'package:horizon/domain/entities/http_config.dart';

import 'package:horizon/presentation/common/password_input.dart';
import './sign_message_bls_state.dart';
import './sign_message_bls_event.dart';

class SignMessageBLSBloc
    extends Bloc<SignMessageBLSEvent, SignMessageBLSState> {
  final bool passwordRequired;
  final String message;
  final String? dst;
  final WalletConfigRepository _walletConfigRepository;
  final SeedService _seedService;
  final BlsService _blsService;
  final HttpConfig httpConfig;

  SignMessageBLSBloc({
    required this.httpConfig,
    required this.passwordRequired,
    required this.message,
    this.dst,
    WalletConfigRepository? walletConfigRepository,
    SeedService? seedService,
    BlsService? blsService,
  })  : _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _seedService = seedService ?? GetIt.I<SeedService>(),
        _blsService = blsService ?? GetIt.I<BlsService>(),
        super(SignMessageBLSState(
          message: message,
          dst: dst,
        )) {
    on<PasswordChanged>(_handlePasswordChanged);
    on<SignMessageBLSSubmitted>(_handleSubmitted);
  }

  void _handlePasswordChanged(
      PasswordChanged event, Emitter<SignMessageBLSState> emit) {
    final password = PasswordInput.dirty(event.password);
    emit(state.copyWith(
      password: password,
      error: null,
      submissionStatus: FormzSubmissionStatus.initial,
    ));
  }

  Future<void> _handleSubmitted(
      SignMessageBLSSubmitted event, Emitter<SignMessageBLSState> emit) async {
    final decryptionStrategy =
        passwordRequired ? Password(state.password.value) : InMemoryKey();

    final task =
        TaskEither<String, ({String signature, String publicKey})>.Do(
            ($) async {
      final walletConfig = await $(_walletConfigRepository
          .getCurrentT((_) => "invariant: could not read wallet config"));

      final seed = await $(_seedService.getForWalletConfigT(
        walletConfig: walletConfig,
        decryptionStrategy: decryptionStrategy,
        onError: (_) => switch (decryptionStrategy) {
          Password() => "Invalid password",
          InMemoryKey() => "invariant: could not derive seed"
        },
      ));

      return await $(TaskEither.tryCatch(
        () async => _blsService.signMessage(
          seed: seed.bytes,
          message: state.message,
          dst: state.dst,
        ),
        (e, _) => "Error signing message with BLS",
      ));
    });

    final result = await task.run();

    final nextState = result.fold(
      (error) => state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        error: error,
      ),
      (r) => state.copyWith(
        signature: r.signature,
        publicKey: r.publicKey,
        submissionStatus: FormzSubmissionStatus.success,
      ),
    );

    emit(nextState);
  }
}
