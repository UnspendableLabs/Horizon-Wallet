import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/presentation/screens/send/bloc/send_compose_form_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';

class SendReviewFormEvent {}

class SignAndSubmitClicked extends SendReviewFormEvent {
  SignAndSubmitClicked();
}

class CloseSignModalClicked extends SendReviewFormEvent {
  CloseSignModalClicked();
}

class SendReviewFormModel with FormzMixin {
  final FormzSubmissionStatus submissionStatus;
  final List<SendEntryFormModel> sendEntries;
  final ComposeSendUnion composeResponse;
  final String signedTxHex;
  final String signedTxHash;

  final bool showSignTransactionModal;

  SendReviewFormModel(
      {required this.submissionStatus,
      required this.sendEntries,
      required this.composeResponse,
      required this.signedTxHex,
      required this.signedTxHash,
      required this.showSignTransactionModal});

  @override
  List<FormzInput> get inputs => [];

  SendReviewFormModel copyWith(
      {FormzSubmissionStatus? submissionStatus,
      ComposeSendUnion? composeResponse,
      List<SendEntryFormModel>? sendEntries,
      String? signedTxHex,
      String? signedTxHash,
      Option<bool> showSignTransactionModal = const None()}) {
    return SendReviewFormModel(
        showSignTransactionModal: showSignTransactionModal
            .getOrElse(() => this.showSignTransactionModal),
        submissionStatus: submissionStatus ?? this.submissionStatus,
        sendEntries: sendEntries ?? this.sendEntries,
        composeResponse: composeResponse ?? this.composeResponse,
        signedTxHex: signedTxHex ?? this.signedTxHex,
        signedTxHash: signedTxHash ?? this.signedTxHash);
  }
}

class SendReviewFormBloc
    extends Bloc<SendReviewFormEvent, SendReviewFormModel> {
  final List<SendEntryFormModel> sendEntries;
  final ComposeSendUnion composeResponse;
  SendReviewFormBloc({required this.sendEntries, required this.composeResponse})
      : super(SendReviewFormModel(
          showSignTransactionModal: false,
          submissionStatus: FormzSubmissionStatus.initial,
          sendEntries: sendEntries,
          composeResponse: composeResponse,
          signedTxHex: "",
          signedTxHash: "",
        )) {
    on<SignAndSubmitClicked>(_handleSignAndSubmit);
    on<CloseSignModalClicked>(_handleCloseSignModal);
  }

  _handleCloseSignModal(
    CloseSignModalClicked event,
    Emitter<SendReviewFormModel> emit,
  ) {
    emit(state.copyWith(
      showSignTransactionModal: const Some(false),
    ));
  }

  _handleSignAndSubmit(
      SignAndSubmitClicked event, Emitter<SendReviewFormModel> emit) async {
    emit(state.copyWith(
      showSignTransactionModal: const Some(true),
    ));

    // emit(state.copyWith(
    // submissionStatus: FormzSubmissionStatus.inProgress));

    // TODO: Implement sign and submit

    // emit(state.copyWith(
    //     submissionStatus: FormzSubmissionStatus.success,
    //     signedTxHex:
    //         "02000000xcadxc000000000001976a91462e907b17c1d4b80e28614e46f04f2c4167afee88ac00000000",
    //     signedTxHash:
    //         "6a6890705f4fe6d438983ed65d01452a8a8823f1a187982a1745c6b24e4d3409"));
  }
}
