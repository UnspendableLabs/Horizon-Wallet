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

  /// Why the node could not unpack the message, when it could not: it then
  /// names the message type but returns `{"error": ...}` as its data.
  String? get unpackError => messageData["error"]?.toString();

  @override
  List<Object?> get props => [messageType, messageTypeId, messageData];
}

/// How much a Counterparty reveal can do once the user signs it.
enum RevealRisk {
  /// A message that only publishes something from the address: an issuance
  /// of the address' own asset, a broadcast without a value, a fairminter, a
  /// cancellation, a BTC payment. Shown for information.
  normal,

  /// Anything else: a message that sends, sweeps, destroys, escrows or pays
  /// out assets of the address, transfers or resets an asset, or publishes a
  /// broadcast with a value. Needs an explicit acknowledgement.
  high,

  /// The message could not be decoded, or the node does not know its type:
  /// the user is signing something the wallet cannot describe.
  unrecognized,
}

/// The content of an ordinals envelope (the inscription itself) left out of
/// the message the node decoded, because it made it too long to send.
class OmittedContent extends Equatable {
  /// The content length, in bytes.
  final int length;

  /// The mime type of the envelope, "" when it has none.
  final String mimeType;

  const OmittedContent({required this.length, required this.mimeType});

  String get label => [
        if (mimeType.isNotEmpty) mimeType,
        "$length bytes, too long to decode: not shown",
      ].join(", ");

  @override
  List<Object?> get props => [length, mimeType];
}

/// What the wallet knows about the Counterparty message carried by a reveal
/// PSBT before the user signs it. With `require_reveal_source_signature` the
/// signature IS the consent to this message: a dApp can hand the wallet a
/// perfectly well-formed reveal whose envelope holds anything, so the user
/// must see the decoded message, not only the input being spent.
class CounterpartyRevealInfo extends Equatable {
  /// The wallet address whose key closes the envelope (the message source).
  final String sourceAddress;

  /// The `TapLeaf` hash (hex) of the envelope leaf: the wallet signs this
  /// leaf, and only this one, once the user has seen its message.
  final String leafHashHex;

  /// The message bytes rebuilt from the envelope, hex.
  final String messageHex;

  final CounterpartyMessage? message;

  /// Why the message could not be decoded, when it could not.
  final String? decodeError;

  /// The inscription content the node decoded the message without, when it
  /// was left out: the field it fills reads empty in [message].
  final OmittedContent? omittedContent;

  /// The Counterparty destinations of the reveal: the addresses of the
  /// outputs placed before its `CNTRPRTY` output.
  final List<String> destinations;

  final RevealRisk risk;
  final String riskReason;

  const CounterpartyRevealInfo({
    required this.sourceAddress,
    required this.leafHashHex,
    required this.messageHex,
    required this.message,
    required this.decodeError,
    required this.omittedContent,
    required this.destinations,
    required this.risk,
    required this.riskReason,
  });

  bool get requiresAcknowledgement => risk != RevealRisk.normal;

  /// Human readable message type.
  String get messageTypeLabel =>
      message == null ? "unknown" : _label(message!.messageType);

  /// The message fields as label/value pairs for display: normalized
  /// quantities replace raw ones, nested objects and nulls are skipped, sweep
  /// flags are spelled out, each send of an MPMA send gets its own line. An
  /// omitted content is described in the field it fills (the description of
  /// an issuance or a fairminter, the text of a broadcast), or on its own
  /// line.
  List<MapEntry<String, String>> get entries {
    final m = message;
    if (m == null) return const [];
    final data = m.messageData;
    final out = <MapEntry<String, String>>[];
    var contentShown = false;
    for (final key in data.keys) {
      final value = data[key];
      if (value == null) continue;
      if (omittedContent != null &&
          !contentShown &&
          value == "" &&
          (key == "description" || key == "text")) {
        out.add(MapEntry(key, omittedContent!.label));
        contentShown = true;
        continue;
      }
      if (key == "sends" && value is List) {
        for (final send in value.whereType<Map>()) {
          out.add(MapEntry("send", _describeSend(send)));
        }
        continue;
      }
      if (value is Map || value is List) continue;
      if (key.endsWith("_normalized")) {
        out.add(MapEntry(
            _label(key.substring(0, key.length - 11)), value.toString()));
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
    if (omittedContent != null && !contentShown) {
      out.add(MapEntry("content", omittedContent!.label));
    }
    return out;
  }

  static String _describeSend(Map send) {
    final quantity = send["quantity_normalized"] ?? send["quantity"];
    final memo = send["memo"];
    return [
      "$quantity ${send["asset"]} to ${send["destination"]}",
      if (memo != null) "memo ${_truncate(memo.toString())}",
    ].join(", ");
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
        leafHashHex,
        messageHex,
        message,
        decodeError,
        omittedContent,
        destinations,
        risk,
        riskReason,
      ];
}

/// Classifies a decoded reveal message. `hasDestination` is true when the
/// reveal transaction has a Counterparty destination, i.e. an address output
/// placed before its `CNTRPRTY` output (the parser ignores address outputs
/// after the data, beyond the change). The composer never produces one for a
/// taproot encoding, a hand-built PSBT can; for an issuance the destination
/// becomes the asset's issuer.
///
/// Only the message types that cannot take anything from the address are
/// ordinary; every other type, known or added later, needs the user's
/// acknowledgement.
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
  final unpackError = message.unpackError;
  if (unpackError != null) {
    return (
      risk: RevealRisk.unrecognized,
      reason:
          "The ${message.messageType} message in this reveal cannot be decoded: $unpackError",
    );
  }
  const normal = (risk: RevealRisk.normal, reason: "");
  final data = message.messageData;
  switch (message.messageType) {
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
      return normal;
    case "broadcast":
      // broadcast.parse leaves the bets on the feed alone only for no value
      // or a negative one: -2 cancels its open bets, -3 its pending bet
      // matches, and any value from 0 up settles its bet matches.
      final value = data["value"];
      if (value == null ||
          (value is num && value < 0 && value != -2 && value != -3)) {
        return normal;
      }
      return (
        risk: RevealRisk.high,
        reason: switch (value) {
          -2 => "This broadcast cancels the open bets on this feed.",
          -3 => "This broadcast cancels the pending bet matches on this feed.",
          _ => "A broadcast with a value can settle bets on this feed.",
        },
      );
    case "fairminter":
    case "cancel":
    case "btcpay":
    case "dispense":
      return normal;
    case "sweep":
      return (
        risk: RevealRisk.high,
        reason:
            "A sweep transfers every balance and/or asset ownership of the source address to the destination.",
      );
    case "send":
    case "enhanced_send":
    case "mpma_send":
      return (
        risk: RevealRisk.high,
        reason: "This sends assets from your address.",
      );
    case "destroy":
      return (
        risk: RevealRisk.high,
        reason: "This destroys assets of your address for good.",
      );
    case "dividend":
      return (
        risk: RevealRisk.high,
        reason:
            "A dividend pays every holder of the asset out of your address' balance.",
      );
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
    case "utxo":
      return (
        risk: RevealRisk.high,
        reason: "This moves assets between the address and a UTXO.",
      );
    case "fairmint":
      return (
        risk: RevealRisk.high,
        reason: "A fairmint pays the mint price out of your address' balance.",
      );
    case "bet":
      return (
        risk: RevealRisk.high,
        reason: "A bet escrows the wager out of your address' balance.",
      );
    case "pooldeposit":
    case "poolwithdraw":
      return (
        risk: RevealRisk.high,
        reason: "This moves assets between your address and a pool.",
      );
    default:
      return (
        risk: RevealRisk.high,
        reason:
            "A ${message.messageType} message can move or commit assets of your address.",
      );
  }
}
