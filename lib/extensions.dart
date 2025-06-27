import 'package:fpdart/fpdart.dart';

extension OptionGetOrThrow<T> on Option<T> {
  /// Returns the value if [Some], otherwise throws an [Exception].
  T getOrThrow([String message = 'Called getOrThrow on None']) {
    return match(
      () => throw Exception(message),
      (t) => t,
    );
  }
}

extension TaskEitherMinimumDuration<L, R> on TaskEither<L, R> {
  TaskEither<L, R> minimumDuration(Duration duration) {
    return TaskEither.sequenceList<L, dynamic>([
      this,
      TaskEither.fromTask(Task(() async {
        await Future.delayed(duration);
        return null;
      })),
    ]).map((results) => results[0] as R);
  }
}
