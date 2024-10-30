import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_state.freezed.dart';

@freezed
class LogoutState with _$LogoutState {
  const factory LogoutState({
    @Default(LoggedIn) logoutState,
    @Default(false) bool hasConfirmedUnderstanding,
    @Default('') String resetConfirmationText,
  }) = _LogoutState;
}

abstract class LoggedInOrOut {}

class LoggedIn extends LoggedInOrOut {}

class LoggedOut extends LoggedInOrOut {}
