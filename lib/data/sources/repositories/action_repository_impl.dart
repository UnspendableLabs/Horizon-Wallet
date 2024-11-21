import "dart:convert";
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
      [
        "open_order",
        String giveAsset,
        String giveQuantity,
        String getAsset,
        String getQuantity,
      ] =>
        OpenOrderAction(
            giveQuantity: int.tryParse(giveQuantity)!,
            giveAsset: giveAsset,
            getQuantity: int.tryParse(getQuantity)!,
            getAsset: getAsset,
            caller: CallerType.app),
      ["dispense", String address] => DispenseAction(address, CallerType.app),
      ["dispense:ext", String address] =>
        DispenseAction(address, CallerType.extension),
      ["fairmint", String fairminterTxHash] =>
        FairmintAction(fairminterTxHash, CallerType.app),
      ["fairmint:ext", String fairminterTxHash] =>
        FairmintAction(fairminterTxHash, CallerType.extension),
      ["getAddresses:ext", String tabId, String requestId] =>
        RPCGetAddressesAction(
            int.tryParse(tabId)!, requestId), // TODO:be more paranoid
      [
        "signPsbt:ext",
        String tabId,
        String requestId,
        String psbt,
        String signInputs
      ] =>
        RPCSignPsbtAction(int.tryParse(tabId)!, requestId, psbt,
            _parseSignInputs(signInputs)),
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

  Map<String, List<int>> _parseSignInputs(String signInputsStr) {
    try {
      final decoded = Uri.decodeComponent(signInputsStr);
      final jsonMap = json.decode(decoded) as Map<String, dynamic>;

      // Convert to Map<String, List<int>>
      return jsonMap.map((key, value) {
        if (value is List) {
          return MapEntry(key, value.cast<int>());
        } else {
          throw FormatException("Invalid signInputs format");
        }
      });
    } catch (e) {
      throw FormatException("Failed to parse signInputs: $e");
    }
  }
}
