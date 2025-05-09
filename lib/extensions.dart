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
