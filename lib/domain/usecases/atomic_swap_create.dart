import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/entities/atomic_swap/atomic_swap_create.dart";
import "package:horizon/domain/repositories/atomic_swap_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class AtomicSwapCreateParams {
  final HttpConfig httpConfig;
  final String psbtHex;
  final String sellerAddress;
  final String assetUtxoId;
  final int assetUtxoValue;
  final String assetName;
  final int assetQuantity;
  final int price;
  final DateTime? expiresAt;
  final String feePaymentId;
  final String feePaymentPsbtHex;
  final bool assetDivisible;

  const AtomicSwapCreateParams({
    required this.httpConfig,
    required this.psbtHex,
    required this.sellerAddress,
    required this.assetUtxoId,
    required this.assetUtxoValue,
    required this.assetName,
    required this.assetQuantity,
    required this.price,
    required this.expiresAt,
    required this.feePaymentId,
    required this.feePaymentPsbtHex,
    required this.assetDivisible,
  });
}

class AtomicSwapCreateUseCase
    implements UseCaseTE<AtomicSwapCreate, AtomicSwapCreateParams, String> {
  final AtomicSwapRepository _atomicSwapRepository;
  final ErrorService _errorService;

  AtomicSwapCreateUseCase({
    AtomicSwapRepository? atomicSwapRepository,
    ErrorService? errorService,
  })  : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, AtomicSwapCreate> call(AtomicSwapCreateParams params) {
    final task = _atomicSwapRepository.atomicSwapCreate(
      httpConfig: params.httpConfig,
      psbtHex: params.psbtHex,
      sellerAddress: params.sellerAddress,
      assetUtxoId: params.assetUtxoId,
      assetUtxoValue: params.assetUtxoValue,
      assetName: params.assetName,
      assetQuantity: params.assetQuantity,
      price: params.price,
      expiresAt: params.expiresAt,
      feePaymentId: params.feePaymentId,
      feePaymentPsbtHex: params.feePaymentPsbtHex,
      assetDivisible: params.assetDivisible,
    );

    return task.tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to create atomic swap",
        context: error is NetworkError
            ? {
                "message": error.message,
                "endpoint": error.endpoint,
                "fullUrl": error.fullUrl,
                "statusCode": error.statusCode,
                "assetName": params.assetName,
              }
            : {
                "message": error?.toString(),
                "assetName": params.assetName,
              },
      );
    }).mapLeft((error) => error.message);
  }
}
