import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/presentation/screens/send/bloc/send_compose_form_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';

class SendReviewFormBloc
    extends Bloc<SendReviewFormEvent, SendReviewFormModel> {
  final List<SendEntryFormModel> sendEntries;
  final ComposeSendUnion composeResponse;
  SendReviewFormBloc({required this.sendEntries, required this.composeResponse})
      : super(SendReviewFormModel(
          submissionStatus: FormzSubmissionStatus.initial,
          sendEntries: sendEntries,
          composeResponse: composeResponse,
          signedTxHex: "",
          signedTxHash: "",
        )) {
    on<OnSignAndSubmitEvent>(_handleSignAndSubmit);
  }

  _handleSignAndSubmit(
      OnSignAndSubmitEvent event, Emitter<SendReviewFormModel> emit) async {
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    // TODO: Implement sign and submit

    emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.success,
        signedTxHex:
            "02000000xcadxc000000000001976a91462e907b17c1d4b80e28614e46f04f2c4167afee88ac00000000",
        signedTxHash:
            "6a6890705f4fe6d438983ed65d01452a8a8823f1a187982a1745c6b24e4d3409"));
  }
}

class SendReviewFormEvent {}

class OnSignAndSubmitEvent extends SendReviewFormEvent {
  OnSignAndSubmitEvent();
}

class SendReviewFormModel with FormzMixin {
  final FormzSubmissionStatus submissionStatus;
  final List<SendEntryFormModel> sendEntries;
  final ComposeSendUnion composeResponse;
  final String signedTxHex;
  final String signedTxHash;
  SendReviewFormModel(
      {required this.submissionStatus,
      required this.sendEntries,
      required this.composeResponse,
      required this.signedTxHex,
      required this.signedTxHash});

  @override
  List<FormzInput> get inputs => [];

  SendReviewFormModel copyWith(
      {FormzSubmissionStatus? submissionStatus,
      ComposeSendUnion? composeResponse,
      List<SendEntryFormModel>? sendEntries,
      String? signedTxHex,
      String? signedTxHash}) {
    return SendReviewFormModel(
        submissionStatus: submissionStatus ?? this.submissionStatus,
        sendEntries: sendEntries ?? this.sendEntries,
        composeResponse: composeResponse ?? this.composeResponse,
        signedTxHex: signedTxHex ?? this.signedTxHex,
        signedTxHash: signedTxHash ?? this.signedTxHash);
  }
}
