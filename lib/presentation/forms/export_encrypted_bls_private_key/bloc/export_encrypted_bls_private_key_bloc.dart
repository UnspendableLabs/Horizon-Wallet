import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/usecases/export_encrypted_bls_private_key.dart';

import 'package:horizon/presentation/common/password_input.dart';
import './export_encrypted_bls_private_key_state.dart';
import './export_encrypted_bls_private_key_event.dart';

class ExportEncryptedBlsPrivateKeyBloc extends Bloc<
    ExportEncryptedBlsPrivateKeyEvent, ExportEncryptedBlsPrivateKeyState> {
  final bool passwordRequired;
  final Network network;
  final int accountIndex;
  final WalletConfigRepository _walletConfigRepository;
  final ExportEncryptedBlsPrivateKeyUseCase _useCase;

  ExportEncryptedBlsPrivateKeyBloc({
    required this.passwordRequired,
    required this.network,
    required this.accountIndex,
    WalletConfigRepository? walletConfigRepository,
    ExportEncryptedBlsPrivateKeyUseCase? useCase,
  })  : _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _useCase = useCase ?? GetIt.I<ExportEncryptedBlsPrivateKeyUseCase>(),
        super(ExportEncryptedBlsPrivateKeyState()) {
    on<WalletPasswordChanged>(_handleWalletPasswordChanged);
    on<ExportPasswordChanged>(_handleExportPasswordChanged);
    on<ConfirmExportPasswordChanged>(_handleConfirmExportPasswordChanged);
    on<ExportEncryptedBlsPrivateKeySubmitted>(_handleSubmitted);
  }

  void _handleWalletPasswordChanged(WalletPasswordChanged event,
      Emitter<ExportEncryptedBlsPrivateKeyState> emit) {
    emit(state.copyWith(
      walletPassword: PasswordInput.dirty(event.password),
      error: null,
      submissionStatus: FormzSubmissionStatus.initial,
    ));
  }

  void _handleExportPasswordChanged(ExportPasswordChanged event,
      Emitter<ExportEncryptedBlsPrivateKeyState> emit) {
    emit(state.copyWith(
      exportPassword: PasswordInput.dirty(event.password),
      error: null,
      submissionStatus: FormzSubmissionStatus.initial,
    ));
  }

  void _handleConfirmExportPasswordChanged(
      ConfirmExportPasswordChanged event,
      Emitter<ExportEncryptedBlsPrivateKeyState> emit) {
    emit(state.copyWith(
      confirmExportPassword: PasswordInput.dirty(event.password),
      error: null,
      submissionStatus: FormzSubmissionStatus.initial,
    ));
  }

  Future<void> _handleSubmitted(ExportEncryptedBlsPrivateKeySubmitted event,
      Emitter<ExportEncryptedBlsPrivateKeyState> emit) async {
    if (state.exportPassword.value.trim().isEmpty) {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        error: 'Export password cannot be empty',
      ));
      return;
    }

    if (state.exportPassword.value != state.confirmExportPassword.value) {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        error: 'Export passwords do not match',
      ));
      return;
    }

    if (passwordRequired && state.walletPassword.value.isEmpty) {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        error: 'Wallet password cannot be empty',
      ));
      return;
    }

    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    try {
      final walletConfig = await _walletConfigRepository.getCurrent();

      final decryptionStrategy = passwordRequired
          ? Password(state.walletPassword.value)
          : InMemoryKey();

      final hex = await _useCase(ExportEncryptedBlsPrivateKeyParams(
        walletConfig: walletConfig,
        decryptionStrategy: decryptionStrategy,
        exportPassword: state.exportPassword.value.trim(),
        network: network,
        accountIndex: accountIndex,
      ));

      emit(state.copyWith(
        encryptedBlsPrivateKey: hex,
        submissionStatus: FormzSubmissionStatus.success,
      ));
    } catch (e) {
      final message = e.toString().contains('Invalid password')
          ? 'Invalid wallet password'
          : 'Could not export the encrypted BLS key. Please try again.';
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        error: message,
      ));
    }
  }
}
