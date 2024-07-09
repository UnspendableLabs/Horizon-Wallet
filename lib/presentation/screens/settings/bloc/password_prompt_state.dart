import 'package:freezed_annotation/freezed_annotation.dart';

part "password_prompt_state.freezed.dart";

@freezed
class PasswordPromptState with _$PasswordPromptState {
  const factory PasswordPromptState.initial([int? gapLimit]) = _Initial;
  const factory PasswordPromptState.prompt(int oldValue) = _Prompt;
  const factory PasswordPromptState.validate() = _Validate;
  const factory PasswordPromptState.success(String password, int gapLimit) =
      _Success;
  const factory PasswordPromptState.error(String error) = _Error;
}
