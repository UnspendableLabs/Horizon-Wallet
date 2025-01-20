import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

abstract class FormEvent extends Equatable {
  const FormEvent();
  @override
  List<Object?> get props => [];
}

class PasswordChanged extends FormEvent {
  const PasswordChanged(this.password);
  final String password;
  @override
  List<Object?> get props => [password];
}

class FormSubmitted extends FormEvent {}

class FormState with FormzMixin {
  FormState({
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
  });

  final Password password;
  final FormzSubmissionStatus status;

  FormState copyWith({
    Password? password,
    FormzSubmissionStatus? status,
  }) {
    return FormState(
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [password];
}

enum PasswordValidationError { empty }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure([super.value = '']) : super.pure();

  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return PasswordValidationError.empty;
    }
    return null;
  }
}

class LoginFormBloc extends Bloc<FormEvent, FormState> {
  LoginFormBloc() : super(FormState()) {
    on<PasswordChanged>(_onPasswordChanged);
  }

  _onPasswordChanged(PasswordChanged event, Emitter<FormState> emit) {
    emit(
      state.copyWith(
        password: Password.dirty(event.password),
      ),
    );
  }

  _onFormSubmitted(FormSubmitted event, Emitter<FormState> emit) {
    print("form submitted");
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
      ),
    );
  }
}
