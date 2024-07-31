import "package:horizon/data/sources/local/db.dart";

typedef TransactionModel = Transaction;

class TransactionUnpacked {
  final String messageType;
  final Map<String, dynamic> messageData;

  const TransactionUnpacked(
      {required this.messageType, required this.messageData});

  factory TransactionUnpacked.fromJson(Map<String, dynamic> json) {
    return TransactionUnpacked(
        messageType: json["messageType"],
        messageData: json["messageData"] as Map<String, dynamic>);
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
      : super(messageType: "enhanced_send", messageData: {
          "asset": asset,
          "quantity": quantity,
          "address": address,
          "memo": memo
        });

  factory EnhancedSendUnpacked.fromJson(Map<String, dynamic> json) {
    return EnhancedSendUnpacked(
        asset: json["asset"],
        quantity: json["quantity"],
        address: json["address"],
        memo: json["memo"]);
  }
}
