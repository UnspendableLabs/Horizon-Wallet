abstract class EstimateXcpFeeRepository {
  Future<int> estimateDividendXcpFees(String address);
  Future<int> estimateSweepXcpFees(String address);
  Future<int> estimateAttachXcpFees(String address);
}
