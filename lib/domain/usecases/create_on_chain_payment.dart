import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/atomic_swap/on_chain_payment.dart";
import "package:horizon/domain/repositories/atomic_swap_repository.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

class CreateOnChainPaymentParams {
  final HttpConfig httpConfig;
  final String address;
  final List<String> utxoSetIds;
  final num satsPerVbyte;

  const CreateOnChainPaymentParams({
    required this.httpConfig,
    required this.address,
    required this.utxoSetIds,
    required this.satsPerVbyte,
  });
}

class CreateOnChainPaymentUseCase
    implements UseCaseTE<OnChainPayment, CreateOnChainPaymentParams, String> {
  final AtomicSwapRepository _atomicSwapRepository;
  final ErrorService _errorService;

  CreateOnChainPaymentUseCase({
    AtomicSwapRepository? atomicSwapRepository,
    ErrorService? errorService,
  })  : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, OnChainPayment> call(CreateOnChainPaymentParams params,
      {int maxRetries = 1}) {
    return handleNetworkCall(
      () async {
        return await _atomicSwapRepository.createOnChainPayment(
          httpConfig: params.httpConfig,
          address: params.address,
          utxoSetIds: params.utxoSetIds,
          satsPerVbyte: params.satsPerVbyte,
        );
      },
      maxRetries: maxRetries,
    ).tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to create on-chain payment",
        context: {
          "message": error.message,
          "endpoint": error.endpoint,
          "fullUrl": error.fullUrl,
          "statusCode": error.statusCode,
          "utxoSetIds": params.utxoSetIds,
        },
      );
    }).mapLeft((error) => error.message);
  }
}
