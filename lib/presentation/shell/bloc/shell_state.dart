part of "shell_bloc.dart";

enum Status {
  initial,
  loading,
  success,
  error,
}


@freezed
class ShellState with _$ShellState {
  const factory ShellState({
    @Default(Status.initial) Status status,
  }) = Initial;
}







