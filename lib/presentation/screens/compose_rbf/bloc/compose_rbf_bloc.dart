import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:horizon/presentation/forms/replace_by_fee/replace_by_fee_form_bloc.dart'
    as rbfForm;
import 'package:horizon/domain/services/transaction_service.dart';

sealed class Step extends Equatable {}

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
  final MakeRBFResponse? makeRBFResponse;
  final Step step;

  const ComposeRBFState({required this.step, this.makeRBFResponse});
  @override
  List<Object> get props => [step, makeRBFResponse ?? ""];

  ComposeRBFState copyWith({Step? step, MakeRBFResponse? makeRBFResponse}) {
    return ComposeRBFState(
        makeRBFResponse: makeRBFResponse ?? this.makeRBFResponse,
        step: step ?? this.step);
  }
}

class ComposeRBFEvent extends Equatable {
  const ComposeRBFEvent();
  @override
  List<Object> get props => [];
}

class FormSubmitted extends ComposeRBFEvent {
  final MakeRBFResponse makeRBFResponse;

  const FormSubmitted({required this.makeRBFResponse});
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
      emit(state.copyWith(step: Review(), makeRBFResponse: event.makeRBFResponse));
    });
    on<ReviewSubmitted>((event, emit) {
      emit(state.copyWith(step: Password()));
    });
  }
}
