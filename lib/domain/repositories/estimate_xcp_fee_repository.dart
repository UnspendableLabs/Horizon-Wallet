import 'package:horizon/domain/entities/http_config.dart';

abstract class EstimateXcpFeeRepository {
  Future<int> estimateDividendXcpFees({
    required String address,
    required String asset,
    required HttpConfig httpConfig,
  });

  Future<int> estimateSweepXcpFees({
    required String address,
    required HttpConfig httpConfig,
  });

  Future<int> estimateAttachXcpFees({
    required String address,
    required HttpConfig httpConfig,
  });
}
