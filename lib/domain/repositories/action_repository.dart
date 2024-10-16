import "package:horizon/domain/entities/action.dart";
import "package:fpdart/fpdart.dart";

abstract class ActionRepository {
  Either<String, Action> fromString(String a);
  void enqueue(Action action); // Set the single action
  Option<Action> dequeue();
}
