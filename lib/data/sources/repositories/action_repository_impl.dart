import "dart:convert";
import "package:horizon/domain/repositories/action_repository.dart";
import "package:horizon/domain/entities/action.dart";
import "package:fpdart/fpdart.dart";

class ActionRepositoryImpl implements ActionRepository {
  Action? _currentAction;

  @override
  Either<String, Action> fromString(String str) {
    return Either.tryCatch(() {
      return _parse(str);
    }, (e, __) => "Failed to parse action");
  }

  Action _parse(String str) {
    final arr = Uri.decodeComponent(str).split(',').toList();

    return switch (arr) {
      [
        "getAddresses",
        String tabId,
        String requestId,
        String origin,
        String title,
        String favicon
      ] =>
        RPCGetAddressesAction(
            int.tryParse(tabId)!,
            requestId,
            Uri.decodeComponent(origin),
            Uri.decodeComponent(title),
            Uri.decodeComponent(favicon)),
      [
        "signPsbt",
        String tabId,
        String requestId,
        String origin,
        String title,
        String favicon,
        String psbt,
        String signInputs,
        String sighashTypes,
      ] =>
        RPCSignPsbtAction(
            int.tryParse(tabId)!,
            requestId,
            Uri.decodeComponent(origin),
            Uri.decodeComponent(title),
            Uri.decodeComponent(favicon),
            psbt,
            _parseSignInputs(signInputs),
            _parseSighashTypes(sighashTypes)),
      [
        "signPsbt",
        String tabId,
        String requestId,
        String origin,
        String title,
        String favicon,
        String psbt,
        String signInputs,
      ] =>
        RPCSignPsbtAction(
            int.tryParse(tabId)!,
            requestId,
            Uri.decodeComponent(origin),
            Uri.decodeComponent(title),
            Uri.decodeComponent(favicon),
            psbt,
            _parseSignInputs(signInputs),
            null),
      [
        "signMessage",
        String tabId,
        String requestId,
        String origin,
        String title,
        String favicon,
        String message,
        String address,
      ] =>
        RPCSignMessageAction(
            int.tryParse(tabId)!,
            requestId,
            Uri.decodeComponent(origin),
            Uri.decodeComponent(title),
            Uri.decodeComponent(favicon),
            message,
            address),
      _ => throw Exception()
    };
  }

  @override
  void enqueue(Action action) {
    _currentAction = action; // Store the single action
  }

  @override
  Option<Action> peek() {
    return Option.fromNullable(_currentAction);
  }

  @override
  Option<Action> dequeue() {
    final action = _currentAction;
    _currentAction = null; // Clear the action after dequeuing
    return Option.fromNullable(action);
  }

  List<int>? _parseSighashTypes(String sighashTypesStr) {
    try {
      final value = json.decode(utf8.decode(base64.decode(sighashTypesStr)));
      if (value is List) {
        return value.cast<int>();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Map<String, List<int>> _parseSignInputs(String signInputsStr) {
    try {
      final str = utf8.decode(base64.decode(signInputsStr));
      final jsonMap = json.decode(str) as Map<String, dynamic>;

      // Convert to Map<String, List<int>>
      return jsonMap.map((key, value) {
        if (value is List) {
          return MapEntry(key, value.cast<int>());
        } else {
          throw const FormatException("Invalid signInputs format");
        }
      });
    } catch (e) {
      throw FormatException("Failed to parse signInputs: $e");
    }
  }
}
