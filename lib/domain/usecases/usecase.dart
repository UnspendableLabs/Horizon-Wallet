import 'package:fpdart/fpdart.dart';

abstract interface class UseCase<Out, In> {
  Future<Out> call(In input);
}

class NoParams {
  const NoParams();
}

typedef ErrorMapper<L> = L Function(Object error, StackTrace stack);

/// ─────────────────────────────────────────────────────────────────────────
/// 1) UseCase that returns Either<L, R>  → TaskEither<L, R>
///    No error mapper needed.
/// ─────────────────────────────────────────────────────────────────────────
extension UseCaseEitherAsTaskEither<L, R, I> on UseCase<Either<L, R>, I> {
  TaskEither<L, R> toTaskEither({required I input}) =>
      TaskEither<L, R>(() => call(input));
}

extension UseCaseEitherAsTaskEither0<L, R> on UseCase<Either<L, R>, NoParams> {
  TaskEither<L, R> toTaskEither0() =>
      TaskEither<L, R>(() => call(const NoParams()));
}

/// ─────────────────────────────────────────────────────────────────────────
/// 2) UseCase<void, I>  → TaskEither<L, Unit>
/// ─────────────────────────────────────────────────────────────────────────
extension UseCaseVoidAsTaskEither<L, I> on UseCase<void, I> {
  TaskEither<L, Unit> toTaskEither({
    required I input,
    required ErrorMapper<L> onError,
  }) =>
      TaskEither<L, Unit>.tryCatch(() async {
        await call(input);
        return unit;
      }, onError);
}

extension UseCaseVoidAsTaskEither0<L> on UseCase<void, NoParams> {
  TaskEither<L, Unit> toTaskEither0({
    required ErrorMapper<L> onError,
  }) =>
      TaskEither<L, Unit>.tryCatch(() async {
        await call(const NoParams());
        return unit;
      }, onError);
}

/// ─────────────────────────────────────────────────────────────────────────
/// 3) UseCase<Unit, I>  → TaskEither<L, Unit>
/// ─────────────────────────────────────────────────────────────────────────
extension UseCaseUnitAsTaskEither<L, I> on UseCase<Unit, I> {
  TaskEither<L, Unit> toTaskEither({
    required I input,
    required ErrorMapper<L> onError,
  }) =>
      TaskEither<L, Unit>.tryCatch(() => call(input), onError);
}

extension UseCaseUnitAsTaskEither0<L> on UseCase<Unit, NoParams> {
  TaskEither<L, Unit> toTaskEither0({
    required ErrorMapper<L> onError,
  }) =>
      TaskEither<L, Unit>.tryCatch(() => call(const NoParams()), onError);
}

/// ─────────────────────────────────────────────────────────────────────────
/// 4) Generic plain-value UseCase<R, I>  → TaskEither<L, R>
///    Use a DIFFERENT method name to avoid ambiguity.
/// ─────────────────────────────────────────────────────────────────────────
extension UseCaseValueAsTaskEither<L, R, I> on UseCase<R, I> {
  TaskEither<L, R> toTaskEitherValue({
    required I input,
    required ErrorMapper<L> onError,
  }) =>
      TaskEither<L, R>.tryCatch(() => call(input), onError);
}

extension UseCaseValueAsTaskEither0<L, R> on UseCase<R, NoParams> {
  TaskEither<L, R> toTaskEitherValue0({
    required ErrorMapper<L> onError,
  }) =>
      TaskEither<L, R>.tryCatch(() => call(const NoParams()), onError);
}
