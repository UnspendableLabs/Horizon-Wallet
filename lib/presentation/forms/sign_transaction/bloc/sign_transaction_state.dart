import "package:formz/formz.dart";
import "./sign_transaction_bloc.dart";

enum PasswordValidationError { empty }

class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    return value.isNotEmpty ? null : PasswordValidationError.empty;
  }
}

enum PsbtSignTypeEnum { buy, sell }

class SignTransactionState with FormzMixin {
  final PasswordInput password;
  final FormzSubmissionStatus submissionStatus;
  final String? signedPsbt;
  final String? error;

  final List<AssetDebit>? debits;
  final List<AssetCredit>? credits;
  final List<AugmentedInput>? augmentedInputs;
  final List<AugmentedOutput>? augmentedOutputs;
  final bool isFormDataLoaded;

  SignTransactionState({
    this.debits,
    this.credits,
    this.augmentedInputs,
    this.augmentedOutputs,
    this.password = const PasswordInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.signedPsbt,
    this.error,
    this.isFormDataLoaded = false,
  });

  @override
  List<FormzInput> get inputs => [password];

  SignTransactionState copyWith({
    List<AssetDebit>? debits,
    List<AssetCredit>? credits,
    PasswordInput? password,
    FormzSubmissionStatus? submissionStatus,
    String? signedPsbt,
    String? error,
    bool? isFormDataLoaded,
    List<AugmentedInput>? augmentedInputs,
    List<AugmentedOutput>? augmentedOutputs,
  }) {
    return SignTransactionState(
      debits: debits ?? this.debits,
      credits: credits ?? this.credits,
      augmentedOutputs: augmentedOutputs ?? this.augmentedOutputs,
      augmentedInputs: augmentedInputs ?? this.augmentedInputs,
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      signedPsbt: signedPsbt ?? this.signedPsbt,
      error: error ?? this.error,
      isFormDataLoaded: isFormDataLoaded ?? this.isFormDataLoaded,
    );
  }
}
