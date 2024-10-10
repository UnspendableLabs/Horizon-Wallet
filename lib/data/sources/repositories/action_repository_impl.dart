import "package:horizon/domain/repositories/action_repository.dart";
import "package:horizon/domain/entities/action.dart";
import "package:fpdart/fpdart.dart";

class ActionRepositoryImpl implements ActionRepository {
  @override
  Either<String, Action> fromString(String str) {
    return Either.tryCatch(
        () => _parse(str), (_, __) => "Failed to parse action");
  }

  Action _parse(String str) {
    final arr =
        str.split(',').map((element) => Uri.decodeComponent(element)).toList();

    return switch ((arr[0], arr[1])) {
      ("dispense", String address) => DispenseAction(address),
      _ => throw Exception()
    };
  }
}
