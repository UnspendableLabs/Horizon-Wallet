import "dart:convert";
import "package:horizon/domain/entities/asset_quantity.dart";
import "package:horizon/domain/entities/psbt_type.dart";
import "package:horizon/domain/repositories/action_repository.dart";
import "package:horizon/domain/entities/action.dart";
import "package:fpdart/fpdart.dart";

const Set<String> originWhitelist = {
  "https://horizon.market",
  "https://horizon-market-testnet.vercel.app",
  "https://horizon-market-signet.vercel.app"
};

RPCSignPsbtAction _buildSignPsbtAction({
  required String tabId,
  required String requestId,
  required String origin,
  required String title,
  required String favicon,
  required String psbt,
  required String signInputsB64,
  required String sighashTypesB64,
  required String txInfoB64,
}) {
  final intTabId = int.parse(tabId);
  final decOrigin = Uri.decodeComponent(origin);
  final decTitle = Uri.decodeComponent(title);
  final decFavicon = Uri.decodeComponent(favicon);

  final signInputs =
      _parseSignInputs(signInputsB64); // throws on bad format (kept)
  final sighashTypes = _parseNullableSighashTypes(sighashTypesB64);
  final txInfo = _parseNullableTxInfo(txInfoB64);

  final psbtType = _derivePsbtType(origin: decOrigin, txInfo: txInfo);

  return RPCSignPsbtAction(
    intTabId,
    requestId,
    decOrigin,
    decTitle,
    decFavicon,
    psbt,
    signInputs,
    sighashTypes,
    psbtType,
  );
}

Map<String, List<int>> _parseSignInputs(String signInputsStr) {
  try {
    // Decode from base64 → UTF8 → JSON
    final str = utf8.decode(base64.decode(signInputsStr));
    final jsonMap = json.decode(str) as Map<String, dynamic>;

    // Convert JSON map to Map<String, List<int>>
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

List<int>? _parseNullableSighashTypes(String b64) {
  try {
    final bytes = base64.decode(b64);
    final v = json.decode(utf8.decode(bytes));
    if (v == null) return null; // JSON null
    if (v is List && v.every((e) => e is num)) {
      return v.map((e) => (e as num).toInt()).toList();
    }
    return null; // anything else → treat as absent
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _parseNullableTxInfo(String b64) {
  try {
    final bytes = base64.decode(b64);
    final v = json.decode(utf8.decode(bytes));
    if (v == null) return null; // JSON null
    return (v is Map<String, dynamic>) ? v : null;
  } catch (_) {
    return null;
  }
}

PsbtType _derivePsbtType({
  required String? origin,
  required Map<String, dynamic>? txInfo,
}) {
  if (txInfo == null) return OpaquePsbt();
  if (origin == null || !originWhitelist.contains(origin)) return OpaquePsbt();

  final type = txInfo["type"];
  final info = txInfo["info"];
  if (type is! String || info is! Map<String, dynamic>) return OpaquePsbt();

  switch (type) {
    case "swap-buy":
      final royaltyInt = _asInt(info["royalty"]);
      final royalty = royaltyInt == null
          ? null
          : AssetQuantity(divisible: true, quantity: BigInt.from(royaltyInt));
      return AtomicSwapBuyPsbt(royalty: royalty);
    case "swap-create-fee":
      return AtomicSwapListingFee();
    case "swap-create":
      return AtomicSwapSellPsbt();

    default:
      return OpaquePsbt();
  }
}

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

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
        String txInfo
      ] =>
        _buildSignPsbtAction(
          tabId: tabId,
          requestId: requestId,
          origin: origin,
          title: title,
          favicon: favicon,
          psbt: psbt,
          signInputsB64: signInputs,
          sighashTypesB64: sighashTypes,
          txInfoB64: txInfo,
        ),
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
