import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_state.freezed.dart';

@freezed
class LogoutState with _$LogoutState {
  const factory LogoutState({
    @Default(LoggedIn) logoutState,
  }) = _LogoutState;
}

abstract class LoggedInOrOut {}

class LoggedIn extends LoggedInOrOut {}

class LoggedOut extends LoggedInOrOut {}
