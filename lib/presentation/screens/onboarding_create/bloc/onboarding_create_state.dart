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
    @Default(CreateMnemonicState.initial())
    CreateMnemonicState createMnemonicState,
    @Default(CreateState.initial()) CreateState createState,
    @Default(OnboardingCreateStep.showMnemonic)
    OnboardingCreateStep currentStep,
  }) = _OnboardingCreateState;
}

class MnemonicErrorState {
  final String message;
  final List<int>? incorrectIndexes;
  MnemonicErrorState({required this.message, this.incorrectIndexes});
}

@freezed
class CreateState with _$CreateState {
  const factory CreateState.initial() = CreateStateInitial;
  const factory CreateState.loading() = CreateStateLoading;
  const factory CreateState.success() = CreateStateSuccess;
  const factory CreateState.error({required String message}) = CreateStateError;
}

@freezed
class CreateMnemonicState with _$CreateMnemonicState {
  const factory CreateMnemonicState.initial() = CreateMnemonicStateInitial;
  const factory CreateMnemonicState.loading() = CreateMnemonicStateLoading;
  const factory CreateMnemonicState.success({required String mnemonic}) =
      CreateMnemonicStateSuccess;
  const factory CreateMnemonicState.error({required String message}) =
      CreateMnemonicStateError;
}
