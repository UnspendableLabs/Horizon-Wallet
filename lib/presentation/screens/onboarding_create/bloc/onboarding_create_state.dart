import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_create_state.freezed.dart';

enum OnboardingCreateStep {
  showMnemonic,
  confirmMnemonic,
  createPassword,
}

@freezed
class OnboardingCreateState with _$OnboardingCreateState {
  const factory OnboardingCreateState({
    @Default(null) MnemonicErrorState? mnemonicError,
    @Default(MnemonicGeneratedStateNotAsked) mnemonicState,
    @Default(CreateStateNotAsked) createState,
    @Default(OnboardingCreateStep.showMnemonic)
    OnboardingCreateStep currentStep,
  }) = _OnboardingCreateState;
}

abstract class MnemonicGeneratedState {}

class MnemonicGeneratedStateNotAsked extends MnemonicGeneratedState {}

class MnemonicGeneratedStateLoading extends MnemonicGeneratedState {}

class MnemonicGeneratedStateGenerated extends MnemonicGeneratedState {
  final String mnemonic;
  MnemonicGeneratedStateGenerated({required this.mnemonic});
}

class MnemonicGeneratedStateUnconfirmed extends MnemonicGeneratedState {
  final String mnemonic;
  MnemonicGeneratedStateUnconfirmed({required this.mnemonic});
}

class MnemonicGeneratedStateSuccess extends MnemonicGeneratedState {
  final String mnemonic;
  MnemonicGeneratedStateSuccess({required this.mnemonic});
}

class MnemonicGeneratedStateError extends MnemonicGeneratedState {
  final String message;
  MnemonicGeneratedStateError({required this.message});
}

abstract class CreateState {}

class CreateStateNotAsked extends CreateState {}

class CreateStateMnemonicUnconfirmed extends CreateState {}

class CreateStateMnemonicConfirmed extends CreateState {}

class CreateStateLoading extends CreateState {}

class CreateStateSuccess extends CreateState {}

class CreateStateError extends CreateState {
  final String message;
  final List<int>? incorrectIndexes;
  CreateStateError({required this.message, this.incorrectIndexes});
}

class MnemonicErrorState {
  final String message;
  final List<int>? incorrectIndexes;
  MnemonicErrorState({required this.message, this.incorrectIndexes});
}
