import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';

import 'package:horizon/common/uuid.dart';
import './review_event.dart';
import './review_state.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/services/analytics_service.dart';

class ReviewBloc<TComposeResponse extends ComposeResponse>
    extends Bloc<ReviewEvent, ReviewState> {
  final String name;

  final TComposeResponse composeResponse;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final String Function(TComposeResponse) getSource;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final WriteLocalTransactionUseCase writelocalTransactionUseCase;
  final Logger logger;
  final AnalyticsService analyticsService;

  ReviewBloc({
    required this.name,
    required this.getSource,
    required this.composeResponse,
    SettingsRepository? settingsRepository,
    WalletRepository? walletRepository,
    EncryptionService? encryptionService,
    SignAndBroadcastTransactionUseCase? signAndBroadcastTransactionUseCase,
    WriteLocalTransactionUseCase? writelocalTransactionUseCase,
    Logger? logger,
    AnalyticsService? analyticsService,
  })  : walletRepository = walletRepository ?? GetIt.I<WalletRepository>(),
        encryptionService = encryptionService ?? GetIt.I<EncryptionService>(),
        signAndBroadcastTransactionUseCase =
            signAndBroadcastTransactionUseCase ??
                GetIt.I<SignAndBroadcastTransactionUseCase>(),
        writelocalTransactionUseCase = writelocalTransactionUseCase ??
            GetIt.I<WriteLocalTransactionUseCase>(),
        logger = logger ?? GetIt.I<Logger>(),
        analyticsService = analyticsService ?? GetIt.I<AnalyticsService>(),
        super(ReviewState(
            passwordRequired:
                (settingsRepository ?? GetIt.I<SettingsRepository>())
                    .requirePasswordForCryptoOperations,
            formModel: ReviewModel(status: FormzSubmissionStatus.initial),
            passwordFormModel: PasswordFormModel(
                status: FormzSubmissionStatus.initial,
                password: const PasswordInput.pure()))) {
    on<SignAndSubmitClicked>(_handleSignAndSubmitClicked);
    on<PasswordPromptCancelClicked>(_handlePasswordPromptCancelClicked);
    on<PasswordPromptSubmitted>(_handlePasswordPromptSubmitted);
  }

  _handlePasswordPromptSubmitted(
      PasswordPromptSubmitted event, Emitter emit) async {
    if (event.password.isEmpty) {
      emit(state.copyWith(
          passwordFormModel: state.passwordFormModel.copyWith(
              error: "Password is required",
              password: PasswordInput.dirty(event.password),
              status: FormzSubmissionStatus.failure)));
      return;
    }

    emit(state.copyWith(
        passwordFormModel: state.passwordFormModel.copyWith(
      status: FormzSubmissionStatus.inProgress,
      password: PasswordInput.dirty(event.password),
    )));

    try {
      final wallet = await GetIt.I<WalletRepository>().getCurrentWallet();

      await encryptionService.decrypt(wallet!.encryptedPrivKey, event.password);

      emit(state.copyWith(
        showPasswordModal: false,
      ));

      await _signAndBroadcastWithPassword((txHex, txHash) async {
        emit(state.copyWith(
            // showPasswordModal: false,
            formModel: state.formModel.copyWith(
              status: FormzSubmissionStatus.success,
              txHex: txHex,
              txHash: txHash,
            )));
      }, (error) async {
        emit(state.copyWith(
            formModel: state.formModel
                .copyWith(status: FormzSubmissionStatus.failure)));
      });
    } catch (e) {
      emit(state.copyWith(
          passwordFormModel: state.passwordFormModel.copyWith(
              password: PasswordInput.dirty(event.password),
              error: "Invalid password",
              status: FormzSubmissionStatus.failure)));
    }
  }

  _handlePasswordPromptCancelClicked(
      PasswordPromptCancelClicked event, Emitter emit) async {
    emit(state.copyWith(showPasswordModal: false));
  }

  _handleSignAndSubmitClicked(SignAndSubmitClicked event, Emitter emit) async {
    emit(state.copyWith(
        formModel: state.formModel
            .copyWith(status: FormzSubmissionStatus.inProgress)));

    if (state.passwordRequired) {
      emit(state.copyWith(showPasswordModal: true));
      return;
    }

    await _signAndBroadcastWithInMemoryKey((txHex, txHash) async {
      emit(state.copyWith(
          formModel: state.formModel.copyWith(
              status: FormzSubmissionStatus.success,
              txHex: txHex,
              txHash: txHash)));
    }, (error) async {
      emit(state.copyWith(
          formModel:
              state.formModel.copyWith(status: FormzSubmissionStatus.failure)));
    });
  }

  Future<void> _signAndBroadcastWithInMemoryKey(
    Future<void> Function(String, String) onSuccess,
    Future<void> Function(String) onError,
  ) async {
    if (state.passwordRequired) {
      throw Exception("Password is required");
    }

    await _signAndBroadcast(InMemoryKey(), onSuccess, onError);
  }

  Future<void> _signAndBroadcastWithPassword(
    Future<void> Function(String, String) onSuccess,
    Future<void> Function(String) onError,
  ) async {
    await _signAndBroadcast(
        Password(state.passwordFormModel.password.value), onSuccess, onError);
  }

  Future<void> _signAndBroadcast(
    DecryptionStrategy decryptionStrategy,
    Future<void> Function(String, String) onSuccess,
    Future<void> Function(String) onError,
  ) async {
    print(
        "sign and broadcast called with decryptionStrategy $decryptionStrategy");

    await signAndBroadcastTransactionUseCase.call(
        decryptionStrategy: decryptionStrategy,
        source: getSource(composeResponse),
        rawtransaction: composeResponse.rawtransaction,
        onSuccess: (txHex, txHash) async {
          await writelocalTransactionUseCase.call(txHex, txHash);

          logger.info('send broadcasted txHash: $txHash');

          analyticsService.trackAnonymousEvent('broadcast_tx_${name}',
              properties: {'distinct_id': uuid.v4()});

          print("shouldn't on success be called?");
          onSuccess(txHex, txHash);
        },
        onError: (msg) {
          print("on error is called $msg");
          onError(msg);
        });
  }
}
