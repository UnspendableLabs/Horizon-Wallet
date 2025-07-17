abstract class ComposeResponse {
  String get psbt;
  String get rawtransaction;
  int get btcFee;
  SignedTxEstimatedSize get signedTxEstimatedSize;
}

class SignedTxEstimatedSize {
  final int virtualSize;
  final int adjustedVirtualSize;
  final int sigopsCount;

  SignedTxEstimatedSize({
    required this.virtualSize,
    required this.adjustedVirtualSize,
    required this.sigopsCount,
  });
}
