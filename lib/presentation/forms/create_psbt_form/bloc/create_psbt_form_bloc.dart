import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';

enum BtcPriceInputError { required, isNaN, isNegative }

class BtcPriceInput extends FormzInput<String, BtcPriceInputError> {
  const BtcPriceInput.pure() : super.pure('');
  const BtcPriceInput.dirty({required String value}) : super.dirty(value);
  @override
  BtcPriceInputError? validator(String value) {
    if (value.isEmpty) {
      return BtcPriceInputError.required;
    }

    return asDecimal.fold(
      () => BtcPriceInputError.isNaN,
      (decimal) =>
          decimal <= Decimal.zero ? BtcPriceInputError.isNegative : null,
    );
  }

  Option<Decimal> get asDecimal {
    return Option.tryCatch(() => Decimal.parse(value));
  }
}

class CreatePsbtFormModel with FormzMixin {
  final BtcPriceInput btcPriceInput;
  final FormzSubmissionStatus submissionStatus;

  CreatePsbtFormModel(
      {required this.btcPriceInput, required this.submissionStatus});

  @override
  List<FormzInput> get inputs => [btcPriceInput];

  CreatePsbtFormModel copyWith({
    BtcPriceInput? btcPriceInput,
    FormzSubmissionStatus? submissionStatus,
  }) =>
      CreatePsbtFormModel(
          btcPriceInput: btcPriceInput ?? this.btcPriceInput,
          submissionStatus: submissionStatus ?? this.submissionStatus);

  get submitDisabled => isNotValid || submissionStatus.isInProgress;
}

sealed class CreatePsbtFormEvent extends Equatable {
  const CreatePsbtFormEvent();

  @override
  List<Object?> get props => [];
}

class BtcPriceInputChanged extends CreatePsbtFormEvent {
  final String value;

  const BtcPriceInputChanged({required this.value});
}

class SubmitClicked extends CreatePsbtFormEvent {}

class CreatePsbtFormBloc
    extends Bloc<CreatePsbtFormEvent, CreatePsbtFormModel> {
  CreatePsbtFormBloc()
      : super(
          CreatePsbtFormModel(
            btcPriceInput:
                const BtcPriceInput.dirty(value: "0.00"), // const value
            submissionStatus: FormzSubmissionStatus.initial,
          ),
        ) {
    on<BtcPriceInputChanged>(_onBtcPriceInputChanged); // handler wired up once
    on<SubmitClicked>(_onSubmitClicked);
  }

  // give the handler an explicit return type
  void _onBtcPriceInputChanged(
    BtcPriceInputChanged event,
    Emitter<CreatePsbtFormModel> emit,
  ) {
    emit(
      state.copyWith(
        btcPriceInput: BtcPriceInput.dirty(value: event.value), // mark it dirty
        submissionStatus: FormzSubmissionStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitClicked(
    SubmitClicked event,
    Emitter<CreatePsbtFormModel> emit,
  ) async {
    print("der event $event");
    // no op for now
  }
}
