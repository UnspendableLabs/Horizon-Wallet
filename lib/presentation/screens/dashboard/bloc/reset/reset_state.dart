import 'package:freezed_annotation/freezed_annotation.dart';

part 'reset_state.freezed.dart';

@freezed
class ResetState with _$ResetState {
  const factory ResetState({
    @Default(In) resetState,
  }) = _ResetState;
}

abstract class LoggedInOrOut {}

class In extends LoggedInOrOut {}

class Out extends LoggedInOrOut {}
