abstract class EstimateXcpFeeRepository {
  Future<int> estimateDividendXcpFees(String address, String asset);
  Future<int> estimateSweepXcpFees(String address);
  Future<int> estimateAttachXcpFees(String address);
}
