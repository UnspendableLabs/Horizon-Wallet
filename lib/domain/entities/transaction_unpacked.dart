class TransactionUnpacked {
  final String messageType;
  final Map<String, dynamic> messageData;

  const TransactionUnpacked(
      {required this.messageType, required this.messageData});
}
