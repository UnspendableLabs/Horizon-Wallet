import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';

import './review_event.dart';
import './review_state.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';

class ReviewBloc<TComposeResponse extends ComposeResponse>
    extends Bloc<ReviewEvent, ReviewState> {
  final TComposeResponse composeResponse;
  final SignAndBroadcastTransactionUseCase signAndBroadcastTransactionUseCase;
  final String Function(TComposeResponse) getSource;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;

  ReviewBloc(
      {required this.getSource,
      required this.composeResponse,
      SettingsRepository? settingsRepository,
      WalletRepository? walletRepository,
      EncryptionService? encryptionService,
      SignAndBroadcastTransactionUseCase? signAndBroadcastTransactionUseCase})
      : walletRepository = walletRepository ?? GetIt.I<WalletRepository>(),
        encryptionService = encryptionService ?? GetIt.I<EncryptionService>(),
        signAndBroadcastTransactionUseCase =
            signAndBroadcastTransactionUseCase ??
                GetIt.I<SignAndBroadcastTransactionUseCase>(),
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

  // _handlePasswordInputChanged(
  //   PasswordInputChanged event,
  //   Emitter emit,
  // ) {
  //   emit(state.copyWith(
  //       formModel: state.formModel
  //           .copyWith(password: PasswordInput.dirty(event.value))));
  // }

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
        passwordFormModel: state.passwordFormModel
            .copyWith(status: FormzSubmissionStatus.inProgress)));

    try {
      final wallet = await GetIt.I<WalletRepository>().getCurrentWallet();

      await encryptionService.decrypt(wallet!.encryptedPrivKey, event.password);

      emit(state.copyWith(
        showPasswordModal: false,
      ));
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
    } else {
      await signAndBroadcastTransactionUseCase.call(
          decryptionStrategy: state.passwordRequired
              ? Password(state.passwordFormModel.password.value)
              : InMemoryKey(),
          source: getSource(composeResponse),
          rawtransaction: composeResponse.rawtransaction,
          onSuccess: (txHex, txHash) async {
            print(txHex);
            print(txHash);
          },
          onError: (msg) {
            print(msg);
          });
    }
  }
}
