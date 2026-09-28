import "package:equatable/equatable.dart";

/// A Counterparty message as `GET /v2/transactions/unpack?verbose=true`
/// decodes it: its type and its fields, kept as returned by the node.
class CounterpartyMessage extends Equatable {
  final String messageType;
  final int? messageTypeId;
  final Map<String, dynamic> messageData;

  const CounterpartyMessage({
    required this.messageType,
    required this.messageTypeId,
    required this.messageData,
  });

  @override
  List<Object?> get props => [messageType, messageTypeId, messageData];
}

/// How much a Counterparty reveal can do once the user signs it.
enum RevealRisk {
  /// An ordinary message: shown for information.
  normal,

  /// A message that moves or exposes the whole address (sweep), transfers or
  /// resets an asset, opens an order or a dispenser, attaches or detaches
  /// assets, or publishes a broadcast with a value: needs an explicit
  /// acknowledgement.
  high,

  /// The message could not be decoded, or the node does not know its type:
  /// the user is signing something the wallet cannot describe.
  unrecognized,
}

/// What the wallet knows about the Counterparty message carried by a reveal
/// PSBT before the user signs it. With `require_reveal_source_signature` the
/// signature IS the consent to this message: a dApp can hand the wallet a
/// perfectly well-formed reveal whose envelope holds anything, so the user
/// must see the decoded message, not only the input being spent.
class CounterpartyRevealInfo extends Equatable {
  /// The wallet address whose key closes the envelope (the message source).
  final String sourceAddress;

  /// Whether the envelope key is really a key of [sourceAddress].
  final bool sourceKeyMatches;

  /// The message bytes rebuilt from the envelope, hex.
  final String messageHex;

  final CounterpartyMessage? message;

  /// Why the message could not be decoded, when it could not.
  final String? decodeError;

  final RevealRisk risk;
  final String riskReason;

  const CounterpartyRevealInfo({
    required this.sourceAddress,
    required this.sourceKeyMatches,
    required this.messageHex,
    required this.message,
    required this.decodeError,
    required this.risk,
    required this.riskReason,
  });

  bool get requiresAcknowledgement => risk != RevealRisk.normal;

  /// Human readable message type.
  String get messageTypeLabel =>
      message == null ? "unknown" : _label(message!.messageType);

  /// The message fields as label/value pairs for display: normalized
  /// quantities replace raw ones, nested objects and nulls are skipped, sweep
  /// flags are spelled out.
  List<MapEntry<String, String>> get entries {
    final m = message;
    if (m == null) return const [];
    final data = m.messageData;
    final out = <MapEntry<String, String>>[];
    for (final key in data.keys) {
      final value = data[key];
      if (value == null) continue;
      if (value is Map || value is List) continue;
      if (key.endsWith("_normalized")) {
        out.add(MapEntry(_label(key.substring(0, key.length - 11)),
            value.toString()));
        continue;
      }
      if (data.containsKey("${key}_normalized")) continue;
      if (key == "flags" && m.messageType == "sweep" && value is int) {
        out.add(MapEntry("flags", _sweepFlags(value)));
        continue;
      }
      if (key == "asset_id" || key == "status" || key == "error") continue;
      out.add(MapEntry(_label(key), _truncate(value.toString())));
    }
    return out;
  }

  static String _label(String key) => key.replaceAll("_", " ");

  static String _truncate(String s) =>
      s.length > 200 ? "${s.substring(0, 200)}…" : s;

  static String _sweepFlags(int flags) {
    final parts = <String>[
      if (flags & 1 != 0) "balances",
      if (flags & 2 != 0) "ownership",
      if (flags & 4 != 0) "binary memo",
    ];
    return parts.isEmpty ? "none ($flags)" : "${parts.join(", ")} ($flags)";
  }

  @override
  List<Object?> get props => [
        sourceAddress,
        sourceKeyMatches,
        messageHex,
        message,
        decodeError,
        risk,
        riskReason,
      ];
}

/// Classifies a decoded reveal message. `hasDestination` is true when the
/// reveal transaction has a Counterparty destination, i.e. an address output
/// placed before the `OP_RETURN CNTRPRTY` output (the parser ignores address
/// outputs after the data, beyond the change). The composer never produces
/// one for a taproot encoding, a hand-built PSBT can; for an issuance the
/// destination becomes the asset's issuer.
({RevealRisk risk, String reason}) classifyRevealMessage(
  CounterpartyMessage? message, {
  required bool hasDestination,
}) {
  if (message == null || message.messageType == "unknown") {
    return (
      risk: RevealRisk.unrecognized,
      reason: "The Counterparty message in this reveal is not recognized.",
    );
  }
  final data = message.messageData;
  switch (message.messageType) {
    case "sweep":
      return (
        risk: RevealRisk.high,
        reason:
            "A sweep transfers every balance and/or asset ownership of the source address to the destination.",
      );
    case "issuance":
      if (hasDestination) {
        return (
          risk: RevealRisk.high,
          reason:
              "This issuance has a destination: that address becomes the owner of the asset.",
        );
      }
      if (data["reset"] == true) {
        return (
          risk: RevealRisk.high,
          reason: "This issuance resets the asset supply.",
        );
      }
      return (risk: RevealRisk.normal, reason: "");
    case "order":
      return (
        risk: RevealRisk.high,
        reason: "An order escrows the give quantity on the DEX.",
      );
    case "dispenser":
      return (
        risk: RevealRisk.high,
        reason: "A dispenser escrows assets and sells them for BTC.",
      );
    case "attach":
    case "detach":
      return (
        risk: RevealRisk.high,
        reason: "This moves assets between the address and a UTXO.",
      );
    case "broadcast":
      final value = data["value"];
      if (value is num && value != 0) {
        return (
          risk: RevealRisk.high,
          reason: "A broadcast with a value can settle bets on this feed.",
        );
      }
      return (risk: RevealRisk.normal, reason: "");
    default:
      return (risk: RevealRisk.normal, reason: "");
  }
}
