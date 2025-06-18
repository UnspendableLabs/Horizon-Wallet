import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/presentation/screens/send/view/send_view.dart';

class SendReviewFormBloc
    extends Bloc<SendReviewFormEvent, SendReviewFormModel> {
  final SendFormState initialSendFormState;
  SendReviewFormBloc({required this.initialSendFormState})
      : super(SendReviewFormModel(
            submissionStatus: FormzSubmissionStatus.initial,
            sendFormState: initialSendFormState)) {
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
  final SendFormState sendFormState;
  final FormzSubmissionStatus submissionStatus;
  SendReviewFormModel({required this.submissionStatus, required this.sendFormState});

  @override
  List<FormzInput> get inputs => [];

  SendReviewFormModel copyWith({FormzSubmissionStatus? submissionStatus, SendFormState? sendFormState}) {
    return SendReviewFormModel(
        submissionStatus: submissionStatus ?? this.submissionStatus,
        sendFormState: sendFormState ?? this.sendFormState);
  }
}
