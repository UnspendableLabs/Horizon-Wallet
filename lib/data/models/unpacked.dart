import 'package:horizon/domain/entities/transaction_unpacked.dart' as domain;

class TransactionUnpacked {
  final String messageType;

  const TransactionUnpacked({required this.messageType});

  factory TransactionUnpacked.fromJson(Map<String, dynamic> json) {
    final messageType = json["message_type"];
    switch (messageType) {
      case "enhanced_send":
        return EnhancedSendUnpacked.fromJson(json);
      default:
        return TransactionUnpacked(
          messageType: json["message_type"],
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "message_type": messageType,
    };
  }

  factory TransactionUnpacked.fromDomain(domain.TransactionUnpacked u) {
    return switch (u) {
      domain.EnhancedSendUnpacked() => EnhancedSendUnpacked(
          asset: u.asset,
          quantity: u.quantity,
          address: u.address,
          memo: u.memo),
      _ => TransactionUnpacked(
          messageType: u.messageType,
        )
    };
  }
}

class EnhancedSendUnpacked extends TransactionUnpacked {
  final String asset;
  final int quantity;
  final String address;
  final String? memo;
  EnhancedSendUnpacked(
      {required this.asset,
      required this.quantity,
      required this.address,
      required this.memo})
      : super(
          messageType: "enhanced_send",
        );

  factory EnhancedSendUnpacked.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];

    return EnhancedSendUnpacked(
        asset: messageData["asset"],
        quantity: messageData["quantity"],
        address: messageData["address"],
        memo: messageData["memo"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "message_type": "enhanced_send",
      "message_data": {
        "asset": asset,
        "quantity": quantity,
        "address": address,
        "memo": memo,
      }
    };
  }
}
