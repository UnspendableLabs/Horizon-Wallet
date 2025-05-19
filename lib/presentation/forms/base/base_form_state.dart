import 'package:equatable/equatable.dart';

sealed class BaseFormState<T> extends Equatable {
  const BaseFormState();

  @override
  List<Object?> get props => [];
}

final class Initial<T> extends BaseFormState<T> {
  const Initial();

  @override
  String toString() => 'Initial';
}

final class Loading<T> extends BaseFormState<T> {
  const Loading();

  @override
  String toString() => 'Loading';
}

final class Refreshing<T> extends BaseFormState<T> {
  final T value;

  const Refreshing(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Refreshing: $value';
}

final class Success<T> extends BaseFormState<T> {
  final T value;

  const Success(this.value) : assert(value != null);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Success: $value';
}

final class Failure<T> extends BaseFormState<T> {
  final Object error;

  const Failure(this.error);

  @override
  List<Object?> get props => [error];

  @override
  String toString() => 'Failure: $error';
}
