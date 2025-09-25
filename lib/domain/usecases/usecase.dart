import 'package:fpdart/fpdart.dart';

abstract interface class UseCase<Out, In> {
  Out call(In input);
}

abstract interface class UseCaseFuture<Out, In> {
  Future<Out> call(In input);
}

abstract interface class UseCaseT<Out, In, E> {
  Task<Out> call(In input);
}

abstract interface class UseCaseTE<Out, In, E> {
  TaskEither<E, Out> call(In input);
}

class NoParams {
  const NoParams();
}
