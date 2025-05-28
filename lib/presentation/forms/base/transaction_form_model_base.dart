import 'package:formz/formz.dart';

import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
// TODO: refine FeeOptionError

enum FeeOptionError { invalid }

class FeeOptionInput extends FormzInput<FeeOption, FeeOptionError> {
  FeeOptionInput.pure() : super.pure(Medium());
  const FeeOptionInput.dirty(super.value) : super.dirty();
  @override
  FeeOptionError? validator(FeeOption value) {
    return switch (value) {
      Custom(fee: var value) => value < 0 ? FeeOptionError.invalid : null,
      _ => null
    };
  }
}

class TransactionFormModelBase<TComposeResponse> with FormzMixin {
  final FeeEstimates feeEstimates;
  final FeeOptionInput feeOptionInput;
  final FormzSubmissionStatus submissionStatus;
  final TComposeResponse? composeResponse;
  final String? error;

  TransactionFormModelBase({
    required this.feeEstimates,
    required this.feeOptionInput,
    required this.submissionStatus,
    this.composeResponse,
    this.error,
  });

  @override
  List<FormzInput> get inputs => [feeOptionInput];

  num get getSatsPerVByte => switch (feeOptionInput.value) {
        Slow() => feeEstimates.slow,
        Medium() => feeEstimates.medium,
        Fast() => feeEstimates.fast,
        Custom(fee: var value) => value
      };
}
