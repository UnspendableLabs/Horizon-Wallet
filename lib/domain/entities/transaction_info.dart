import "transaction_unpacked.dart";

class TransactionInfo {
  final String hash;
  final String raw;
  final String source;
  final String? destination;
  final int btcAmount;
  final int fee;
  final String data;

  final TransactionUnpacked unpackedData;

  const TransactionInfo(
      {required this.raw,
      required this.hash,
      required this.source,
      required this.destination,
      required this.btcAmount,
      required this.fee,
      required this.data,
      required this.unpackedData});
}
