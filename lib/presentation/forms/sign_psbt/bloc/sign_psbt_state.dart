import "package:formz/formz.dart";
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';

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
  final DecodedTx? transaction;
  final PasswordInput password;
  final FormzSubmissionStatus submissionStatus;
  final String? signedPsbt;
  final String? error;

  final ParsedPsbtState? parsedPsbtState;
  final bool isFormDataLoaded;

  SignPsbtState({
    this.transaction,
    this.password = const PasswordInput.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.signedPsbt,
    this.error,
    this.parsedPsbtState,
    this.isFormDataLoaded = false,
  });

  @override
  List<FormzInput> get inputs => [password];

  SignPsbtState copyWith({
    DecodedTx? transaction,
    PasswordInput? password,
    FormzSubmissionStatus? submissionStatus,
    String? signedPsbt,
    String? error,
    ParsedPsbtState? parsedPsbtState,
    bool? isFormDataLoaded,
  }) {
    return SignPsbtState(
      transaction: transaction ?? this.transaction,
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      signedPsbt: signedPsbt ?? this.signedPsbt,
      error: error ?? this.error,
      parsedPsbtState: parsedPsbtState ?? this.parsedPsbtState,
      isFormDataLoaded: isFormDataLoaded ?? this.isFormDataLoaded,
    );
  }
}

class ParsedPsbtState {
  final PsbtSignTypeEnum? psbtSignType;
  final String? asset;
  final String? getAmount;
  final double? bitcoinAmount;
  final double? fee;

  ParsedPsbtState({
    this.psbtSignType,
    this.asset,
    this.getAmount,
    this.bitcoinAmount,
    this.fee,
  });

  ParsedPsbtState copyWith({
    PsbtSignTypeEnum? psbtSignType,
    String? asset,
    String? getAmount,
    double? bitcoinAmount,
    double? fee,
  }) {
    return ParsedPsbtState(
      psbtSignType: psbtSignType ?? this.psbtSignType,
      asset: asset ?? this.asset,
      getAmount: getAmount ?? this.getAmount,
      bitcoinAmount: bitcoinAmount ?? this.bitcoinAmount,
      fee: fee ?? this.fee,
    );
  }
}
