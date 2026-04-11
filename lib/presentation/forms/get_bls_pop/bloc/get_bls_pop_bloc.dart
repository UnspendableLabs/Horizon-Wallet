import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';

import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/services/pop_service.dart';
import 'package:horizon/domain/entities/http_config.dart';

import 'package:horizon/presentation/common/password_input.dart';
import './get_bls_pop_state.dart';
import './get_bls_pop_event.dart';

class GetBLSPoPBloc extends Bloc<GetBLSPoPEvent, GetBLSPoPState> {
  final bool passwordRequired;
  final String address;
  final String taprootDerivationPath;
  final Network network;
  final int accountIndex;
  final WalletConfigRepository _walletConfigRepository;
  final SeedService _seedService;
  final PopService _popService;
  final HttpConfig httpConfig;

  GetBLSPoPBloc({
    required this.httpConfig,
    required this.passwordRequired,
    required this.address,
    required this.taprootDerivationPath,
    required this.network,
    required this.accountIndex,
    WalletConfigRepository? walletConfigRepository,
    SeedService? seedService,
    PopService? popService,
  })  : _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _seedService = seedService ?? GetIt.I<SeedService>(),
        _popService = popService ?? GetIt.I<PopService>(),
        super(GetBLSPoPState(address: address)) {
    on<PasswordChanged>(_handlePasswordChanged);
    on<GetBLSPoPSubmitted>(_handleSubmitted);
  }

  void _handlePasswordChanged(
      PasswordChanged event, Emitter<GetBLSPoPState> emit) {
    final password = PasswordInput.dirty(event.password);
    emit(state.copyWith(
      password: password,
      error: null,
      submissionStatus: FormzSubmissionStatus.initial,
    ));
  }

  Future<void> _handleSubmitted(
      GetBLSPoPSubmitted event, Emitter<GetBLSPoPState> emit) async {
    final decryptionStrategy =
        passwordRequired ? Password(state.password.value) : InMemoryKey();

    final task = TaskEither<String,
        ({String xpubkey, String blsPubkey, String schnorrSig, String blsSig})>.Do(
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
        () async => _popService.generatePoP(
          seed: seed.bytes,
          taprootDerivationPath: taprootDerivationPath,
          network: network,
          accountIndex: accountIndex,
        ),
        (e, _) => "Error generating BLS Proof of Possession",
      ));
    });

    final result = await task.run();

    final nextState = result.fold(
      (error) => state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        error: error,
      ),
      (r) => state.copyWith(
        xpubkey: r.xpubkey,
        blsPubkey: r.blsPubkey,
        schnorrSig: r.schnorrSig,
        blsSig: r.blsSig,
        submissionStatus: FormzSubmissionStatus.success,
      ),
    );

    emit(nextState);
  }
}
