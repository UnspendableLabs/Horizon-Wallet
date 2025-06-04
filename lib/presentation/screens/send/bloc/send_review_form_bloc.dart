import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/presentation/screens/send/view/send_view.dart';

class SendReviewFormBloc
    extends Bloc<SendReviewFormEvent, SendReviewFormModel> {
  SendReviewFormBloc()
      : super(SendReviewFormModel(
            submissionStatus: FormzSubmissionStatus.initial)) {
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
  final SendType sendType;
  OnSignAndSubmitEvent({required this.sendType});
}

class SendReviewFormModel with FormzMixin {
  final FormzSubmissionStatus submissionStatus;
  SendReviewFormModel({required this.submissionStatus});

  @override
  List<FormzInput> get inputs => [];

  SendReviewFormModel copyWith({FormzSubmissionStatus? submissionStatus}) {
    return SendReviewFormModel(
        submissionStatus: submissionStatus ?? this.submissionStatus);
  }
}
