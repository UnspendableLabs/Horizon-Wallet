import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

sealed class RemoteData<T> extends Equatable {
  const RemoteData();

  @override
  List<Object?> get props => [];
}

final class Initial<T> extends RemoteData<T> {
  const Initial();

  @override
  String toString() => 'Initial';
}

final class Loading<T> extends RemoteData<T> {
  const Loading();

  @override
  String toString() => 'Loading';
}

final class Refreshing<T> extends RemoteData<T> {
  final T value;

  const Refreshing(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Refreshing: $value';
}

final class Success<T> extends RemoteData<T> {
  final T value;

  const Success(this.value) : assert(value != null);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Success: $value';
}

final class Failure<T> extends RemoteData<T> {
  final Object error;

  const Failure(this.error);

  @override
  List<Object?> get props => [error];

  @override
  String toString() => 'Failure: $error';
}

extension RemoteDataX<T> on RemoteData<T> {
  RemoteData<R> map<R>(R Function(T value) f) => switch (this) {
        Success(value: final v) => Success<R>(f(v)),
        Refreshing(value: final v) => Refreshing<R>(f(v)),
        Initial() => Initial<R>(),
        Loading() => Loading<R>(),
        Failure(error: final e) => Failure<R>(e),
      };

  RemoteData<R> flatMap<R>(
    RemoteData<R> Function(T value) f,
  ) =>
      switch (this) {
        Success(value: final v) => f(v),
        Refreshing(value: final v) => f(v),
        Initial() => Initial<R>(),
        Loading() => Loading<R>(),
        Failure(error: final e) => Failure<R>(e),
      };

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
  bool get isLoading => this is Loading<T>;
  bool get isRefreshing => this is Refreshing<T>;
  bool get isInitial => this is Initial<T>;

  T? getOrNull() => switch (this) {
        Success(value: final v) => v,
        Refreshing(value: final v) => v,
        _ => null,
      };

  Option<T> get toOption => Option.fromNullable(getOrNull());

  R fold<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(T value) onRefreshing,
    required R Function(T value) onSuccess,
    required R Function(Object error) onFailure,
  }) =>
      switch (this) {
        Initial() => onInitial(),
        Loading() => onLoading(),
        Refreshing(value: final v) => onRefreshing(v),
        Success(value: final v) => onSuccess(v),
        Failure(error: final e) => onFailure(e),
      };

  R replete<R>({
    required R Function() onNone,
    required R Function(T value) onReplete,
  }) =>
      switch (this) {
        Initial() => onNone(),
        Loading() => onNone(),
        Refreshing(value: final v) => onReplete(v),
        Success(value: final v) => onReplete(v),
        Failure() => onNone(),
      };

  R fold3<R>({
    required R Function() onNone,
    required R Function(T value) onReplete,
    required R Function(Object error) onFailure,
  }) =>
      fold(
          onInitial: onNone,
          onLoading: onNone,
          onRefreshing: onReplete,
          onSuccess: onReplete,
          onFailure: onFailure);

  R maybeWhen<R>({
    R Function()? onInitial,
    R Function()? onLoading,
    R Function(T value)? onRefreshing,
    R Function(T value)? onSuccess,
    R Function(Object error)? onFailure,
    required R Function() orElse,
  }) {
    return switch (this) {
      Initial() => onInitial != null ? onInitial() : orElse(),
      Loading() => onLoading != null ? onLoading() : orElse(),
      Refreshing(value: final v) =>
        onRefreshing != null ? onRefreshing(v) : orElse(),
      Success(value: final v) => onSuccess != null ? onSuccess(v) : orElse(),
      Failure(error: final e) => onFailure != null ? onFailure(e) : orElse(),
    };
  }
}

extension RemoteDataCombineX<A> on RemoteData<A> {
  RemoteData<R> combine<B, R>(
    RemoteData<B> other,
    R Function(A a, B b) combine,
  ) {
    if (this is Failure) return Failure<R>((this as Failure).error);
    if (other is Failure) return Failure<R>((other as Failure).error);

    if (this is Loading || other is Loading) return Loading<R>();
    if (this is Initial || other is Initial) return Initial<R>();

    final a = (this is Success<A>
        ? (this as Success<A>).value
        : (this as Refreshing<A>).value);

    final b =
        (other is Success<B> ? (other).value : (other as Refreshing<B>).value);
    final merged = combine(a, b);

    return (this is Refreshing || other is Refreshing)
        ? Refreshing<R>(merged)
        : Success<R>(merged);
  }
}
