import "package:formz/formz.dart";

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

class SignPsbtState with FormzMixin {
  final PasswordInput password;
  final FormzSubmissionStatus submissionStatus;
  final String? signedPsbt;
  final String? error;

  final PsbtSignTypeEnum? psbtSignType;
  final String? asset;
  final String? getAmount;
  final double? bitcoinAmount;
  final double? fee;
  final bool isFormDataLoaded;

  SignPsbtState({
    this.password = const PasswordInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.signedPsbt,
    this.error,
    this.psbtSignType,
    this.asset,
    this.getAmount,
    this.bitcoinAmount,
    this.fee,
    this.isFormDataLoaded = false,
  });

  @override
  List<FormzInput> get inputs => [password];

  SignPsbtState copyWith({
    PasswordInput? password,
    FormzSubmissionStatus? submissionStatus,
    String? signedPsbt,
    String? error,
    PsbtSignTypeEnum? psbtSignType,
    String? asset,
    String? getAmount,
    double? bitcoinAmount,
    double? fee,
    bool? isFormDataLoaded,
  }) {
    return SignPsbtState(
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      signedPsbt: signedPsbt ?? this.signedPsbt,
      error: error ?? this.error,
      psbtSignType: psbtSignType ?? this.psbtSignType,
      asset: asset ?? this.asset,
      getAmount: getAmount ?? this.getAmount,
      bitcoinAmount: bitcoinAmount ?? this.bitcoinAmount,
      fee: fee ?? this.fee,
      isFormDataLoaded: isFormDataLoaded ?? this.isFormDataLoaded,
    );
  }
}
