
import "package:fpdart/fpdart.dart";

final noop = () => ();
final noop1 = (dynamic thing) => ();


T unwrapOrThrow<L extends Object, T>(Either<L, T> either) {
  return either.fold(
    (l) => throw l,
    (r) => r,
  );
}
