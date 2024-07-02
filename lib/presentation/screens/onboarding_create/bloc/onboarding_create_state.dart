import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_create_state.freezed.dart';

@freezed
class OnboardingCreateState with _$OnboardingCreateState {
  const factory OnboardingCreateState({
    String? password,
    String? passwordError,
    String? mnemonicError,
    @Default(GenerateMnemonicStateNotAsked) mnemonicState,
    @Default(CreateStateNotAsked) createState,
  }) = _OnboardingCreateState;
}

abstract class GenerateMnemonicState {}

class GenerateMnemonicStateNotAsked extends GenerateMnemonicState {}

class GenerateMnemonicStateLoading extends GenerateMnemonicState {}

class GenerateMnemonicStateGenerated extends GenerateMnemonicState {
  final String mnemonic;
  GenerateMnemonicStateGenerated({required this.mnemonic});
}

class GenerateMnemonicStateUnconfirmed extends GenerateMnemonicState {
  final String mnemonic;
  GenerateMnemonicStateUnconfirmed({required this.mnemonic});
}

class GenerateMnemonicStateSuccess extends GenerateMnemonicState {
  final String mnemonic;
  GenerateMnemonicStateSuccess({required this.mnemonic});
}

class GenerateMnemonicStateError extends GenerateMnemonicState {
  final String message;
  GenerateMnemonicStateError({required this.message});
}

abstract class CreateState {}

class CreateStateNotAsked extends CreateState {}

class CreateStateMnemonicUnconfirmed extends CreateState {}

class CreateStateMnemonicConfirmed extends CreateState {}

class CreateStateLoading extends CreateState {}

class CreateStateSuccess extends CreateState {}

class CreateStateError extends CreateState {
  final String message;
  CreateStateError({required this.message});
}
