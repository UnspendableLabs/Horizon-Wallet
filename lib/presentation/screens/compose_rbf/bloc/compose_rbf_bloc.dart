import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';

abstract class Step extends Equatable {}

class Form extends Step {
  @override
  List<Object> get props => [];
}

class Review extends Step {
  @override
  List<Object> get props => [];
}

class Password extends Step {
  @override
  List<Object> get props => [];
}

class ComposeRBFState extends Equatable {
  final Step step;

  const ComposeRBFState({required this.step});
  @override
  List<Object> get props => [step];

  ComposeRBFState copyWith({Step? step}) {
    return ComposeRBFState(step: step ?? this.step);
  }
}

class ComposeRBFEvent extends Equatable {
  const ComposeRBFEvent();
  @override
  List<Object> get props => [];
}

class FormSubmitted extends ComposeRBFEvent {
  const FormSubmitted();
}

class ReviewSubmitted extends ComposeRBFEvent {
  const ReviewSubmitted();
}

class PasswordSubmitted extends ComposeRBFEvent {
  const PasswordSubmitted();
}

class ComposeRBFBloc extends Bloc<ComposeRBFEvent, ComposeRBFState> {
  ComposeRBFBloc() : super(ComposeRBFState(step: Form())) {
    on<FormSubmitted>((event, emit) {
      emit(state.copyWith(step: Review()));
    });
  }
}
