import 'package:freezed_annotation/freezed_annotation.dart';

part 'reset_state.freezed.dart';

enum ResetStatus { initial, completed }

@freezed
class ResetState with _$ResetState {
  const factory ResetState({
    @Default(ResetStatus.initial) ResetStatus status,
    String? errorMessage,
  }) = _ResetState;
}
