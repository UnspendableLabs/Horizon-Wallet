import 'package:horizon/domain/entities/atomic_swap/on_chain_payment.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap_buy.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap_sale.dart';
import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/http_config.dart';

// typescript api
// public async atomicSwapBuy(
//   id: string,
//   data: Omit<AtomicSwapBuyArgs, "id" | "tx_id"> & { psbt_hex: string },
// ): Promise<NonNullable<PendingSaleCreateReturns>> {
//   return this.request("PUT", `/atomic-swaps/${id}/buy`, data);
// }
//
//
// export type AtomicSwapBuyArgs = {
//   readonly "buyer_address": string;
//   readonly "tx_id": string;
//   readonly "id": string;
// };
//   export type PendingSaleCreateReturns = { "atomic_swap": { "id": string; };
//   "buyer_address": string;
//   "tx_id": string;
// };

abstract class AtomicSwapRepository {
  Future<AtomicSwapSale> atomicSwapSale(
      {required HttpConfig httpConfig,
      required String psbtHex,
      required String sellerAddress,
      required UtxoID assetUtxoId,
      required BigInt assetUtxoValue,
      required String assetName,
      required BigInt assetQuantity,
      required BigInt price,
      required DateTime expiresAt,
      required String feePaymentId,
      required String feeHex});

  Future<AtomicSwapBuy> atomicSwapBuy({
    required HttpConfig httpConfig,
    required String id,
    required String psbtHex,
    required String buyerAddress,
  });

  Future<OnChainPayment> createOnChainPayment({
    required HttpConfig httpConfig,
    required String address,
    required List<String> utxoSetIds,
    required num satsPerVbyte,
  });

  Future<List<AtomicSwap>> getSwapsByAsset({
    required HttpConfig httpConfig,
    required String asset,
    required String orderBy,
    required String order,
  });
}

extension AtomicSwapRepositoryX on AtomicSwapRepository {
  TaskEither<String, AtomicSwapBuy> atomicSwapBuyT({
    required HttpConfig httpConfig,
    required String id,
    required String psbtHex,
    required String buyerAddress,
    String Function(Object error, StackTrace stacktrace)? onError,
  }) {
    return TaskEither.tryCatch(
      () => atomicSwapBuy(
        httpConfig: httpConfig,
        id: id,
        psbtHex: psbtHex,
        buyerAddress: buyerAddress,
      ),
      (error, stacktrace) =>
          onError != null ? onError(error, stacktrace) : error.toString(),
    );
  }

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

  TaskEither<String, List<AtomicSwap>> getSwapsByAssetT({
    required HttpConfig httpConfig,
    required String asset,
    required String orderBy,
    required String order,
    String Function(Object error, StackTrace stacktrace)? onError,
  }) {
    return TaskEither.tryCatch(
      () => getSwapsByAsset(
        httpConfig: httpConfig,
        asset: asset,
        orderBy: orderBy,
        order: order,
      ),
      (error, stacktrace) =>
          onError != null ? onError(error, stacktrace) : error.toString(),
    );
  }
}
