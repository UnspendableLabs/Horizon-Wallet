import 'package:horizon/domain/entities/atomic_swap/on_chain_payment.dart';
import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/http_config.dart';


abstract class AtomicSwapRepository {
  Future<OnChainPayment> createOnChainPayment({
    required HttpConfig httpConfig,
    required String address,
    required List<String> utxoSetIds,
    required num satsPerVbyte,
  });
}

extension AtomicSwapRepositoryX on AtomicSwapRepository {
  TaskEither<String, OnChainPayment> createOnChainPaymentT({
    required HttpConfig httpConfig,
    required String address,
    required List<String> utxoSetIds,
    required num satsPerVbyte,
    String Function(Object error, StackTrace stacktrace)? onError,
  }) {
    return TaskEither.tryCatch(
        () => createOnChainPayment(
              httpConfig: httpConfig,
              address: address,
              utxoSetIds: utxoSetIds,
              satsPerVbyte: satsPerVbyte,
            ),
        (error, stacktrace) =>
            onError != null ? onError(error, stacktrace) : error.toString());
  }
}
