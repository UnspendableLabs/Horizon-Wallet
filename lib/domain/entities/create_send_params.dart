class CreateSendParams {
  final String source;
  final String destination;
  final String asset;
  final int quantity;

  const CreateSendParams({
    required this.source,
    required this.destination,
    required this.asset,
    required this.quantity,
  });
}
