class OnChainPayment {
  final String psbt;
  final List<int> inputsToSign;
  final String rawTransaction;
  final String feePaymentId;

  OnChainPayment({
    required this.psbt,
    required this.inputsToSign,
    required this.rawTransaction,
    required this.feePaymentId,
  });
}
