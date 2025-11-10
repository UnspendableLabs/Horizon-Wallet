import 'package:horizon/domain/entities/atomic_swap/on_chain_payment.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap_buy.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap_create.dart';
import "package:fpdart/fpdart.dart";
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/network_error.dart';

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
  Future<Map<String, bool>> getUtxoSwapMap({
    required HttpConfig httpConfig,
    required String sellerAddress,
  });

  Future<AtomicSwapCreate> atomicSwapCreate({
    required HttpConfig httpConfig,
    required String psbtHex,
    required String sellerAddress,
    required String assetUtxoId,
    required int assetUtxoValue,
    required String assetName,
    required int assetQuantity,
    required int price,
    required DateTime? expiresAt,
    required String feePaymentId,
    required String feePaymentPsbtHex,
    required bool assetDivisible,
  });

  Future<List<AtomicSwapBuy>> atomicSwapMultiBuy({
    required HttpConfig httpConfig,
    required List<String> ids,
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

  Future<List<AtomicSwap>> searchSwaps({
    required HttpConfig httpConfig,
    required String search,
    String orderBy = "price",
    String order = "asc",
  });
}
