import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class PasswordPromptCancelClicked extends ReviewEvent {}

class PasswordPromptSubmitted extends ReviewEvent {
  final String password;
  const PasswordPromptSubmitted(this.password);
}

class SignAndSubmitClicked extends ReviewEvent {
  const SignAndSubmitClicked();
}
