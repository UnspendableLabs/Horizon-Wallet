import "package:horizon/domain/repositories/action_repository.dart";
import "package:horizon/domain/entities/action.dart";
import "package:fpdart/fpdart.dart";

class ActionRepositoryImpl implements ActionRepository {
  Action? _currentAction;

  @override
  Either<String, Action> fromString(String str) {
    return Either.tryCatch(
        () => _parse(str), (_, __) => "Failed to parse action");
  }

  Action _parse(String str) {
    final arr =
        str.split(',').map((element) => Uri.decodeComponent(element)).toList();

    return switch (arr) {
      ["dispense", String address] => DispenseAction(address),
      ["fairmint", String fairminterTxHash] => FairmintAction(fairminterTxHash),
      [
        "order",
        String giveAsset,
        String giveQuantity,
        String getAsset,
        String getQuantity,
      ] =>
        OrderAction(
            giveQuantity: int.tryParse(giveQuantity)!,
            giveAsset: giveAsset,
            getQuantity: int.tryParse(getQuantity)!,
            getAsset: getAsset),
      _ => throw Exception()
    };
  }

  @override
  void enqueue(Action action) {
    _currentAction = action; // Store the single action
  }

  @override
  Option<Action> dequeue() {
    return Option.fromNullable(_currentAction);
  }
}
