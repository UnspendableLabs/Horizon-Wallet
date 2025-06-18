import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/compose_response.dart';
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
          )) {
    on<OnSignAndSubmitEvent>(_handleSignAndSubmit);
  }

  _handleSignAndSubmit(OnSignAndSubmitEvent event, Emitter<SendReviewFormModel> emit) async {
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    // TODO: Implement sign and submit

    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.success));
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
  SendReviewFormModel({required this.submissionStatus, required this.sendEntries, required this.composeResponse});

  @override
  List<FormzInput> get inputs => [];

  SendReviewFormModel copyWith({FormzSubmissionStatus? submissionStatus, ComposeSendUnion? composeResponse, List<SendEntryFormModel>? sendEntries}) {
    return SendReviewFormModel(
        submissionStatus: submissionStatus ?? this.submissionStatus,
        sendEntries: sendEntries ?? this.sendEntries,
        composeResponse: composeResponse ?? this.composeResponse);
  }
}
