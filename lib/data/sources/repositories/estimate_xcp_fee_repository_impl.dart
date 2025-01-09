import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/repositories/estimate_xcp_fee_repository.dart';

class EstimateXcpFeeRepositoryImpl implements EstimateXcpFeeRepository {
  final V2Api api;

  EstimateXcpFeeRepositoryImpl({required this.api});

  @override
  Future<int> estimateDividendXcpFees(String address, String asset) async {
    final response = await api.estimateDividendXcpFees(address, asset);
    if (response.result == null) {
      throw Exception('Failed to estimate compose attach xcp fees');
    }
    return response.result!;
  }

  @override
  Future<int> estimateSweepXcpFees(String address) async {
    final response = await api.estimateSweepXcpFees(address);
    if (response.result == null) {
      throw Exception('Failed to estimate compose attach xcp fees');
    }
    return response.result!;
  }

  @override
  Future<int> estimateAttachXcpFees(String address) async {
    final response = await api.estimateAttachXcpFees(address);
    if (response.result == null) {
      throw Exception('Failed to estimate compose attach xcp fees');
    }
    return response.result!;
  }
}
