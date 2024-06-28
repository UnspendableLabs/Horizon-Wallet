import 'package:freezed_annotation/freezed_annotation.dart';

part "remote_data_state.freezed.dart";

// don't really like this pattern.  cumbersome to use.

@freezed
class RemoteDataState<T> with _$RemoteDataState<T> {
  const factory RemoteDataState.initial() = _Initial;
  const factory RemoteDataState.loading() = _Loading;
  const factory RemoteDataState.success(T data) = _Success<T>;
  const factory RemoteDataState.error(String error) = _Error;
}
