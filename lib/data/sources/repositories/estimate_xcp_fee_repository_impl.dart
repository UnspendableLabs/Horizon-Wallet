import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/repositories/estimate_xcp_fee_repository.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/http_config.dart';

class EstimateXcpFeeRepositoryImpl implements EstimateXcpFeeRepository {
  final CounterpartyClientFactory _counterpartyClientFactory;

  EstimateXcpFeeRepositoryImpl({
    CounterpartyClientFactory? counterpartyClientFactory,
  }) : _counterpartyClientFactory =
            counterpartyClientFactory ?? GetIt.I<CounterpartyClientFactory>();

  @override
  Future<int> estimateDividendXcpFees(
      {required String address,
      required String asset,
      required HttpConfig httpConfig}) async {
    final response = await _counterpartyClientFactory
        .getClient(httpConfig)
        .estimateDividendXcpFees(address, asset);
    if (response.result == null) {
      throw Exception('Failed to estimate compose attach xcp fees');
    }
    return response.result!;
  }

  @override
  Future<int> estimateSweepXcpFees(
      {required String address, required HttpConfig httpConfig}) async {
    final response = await _counterpartyClientFactory
        .getClient(httpConfig)
        .estimateSweepXcpFees(address);
    if (response.result == null) {
      throw Exception('Failed to estimate compose attach xcp fees');
    }
    return response.result!;
  }

  @override
  Future<int> estimateAttachXcpFees(
      {required String address, required HttpConfig httpConfig}) async {
    final response = await _counterpartyClientFactory
        .getClient(httpConfig)
        .estimateAttachXcpFees(address);
    if (response.result == null) {
      throw Exception('Failed to estimate compose attach xcp fees');
    }
    return response.result!;
  }
}
