import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/data/sources/repositories/network_error_helpers.dart';
import 'package:horizon/domain/entities/network_error.dart';
import "package:horizon/domain/repositories/atomic_swap_repository.dart";
import 'package:horizon/domain/entities/atomic_swap/on_chain_payment.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap_create.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client_factory.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap_buy.dart';

class AtomicSwapRepositoryImpl implements AtomicSwapRepository {
  final HorizonExplorerClientFactory _horizonExplorerClientFactory;

  AtomicSwapRepositoryImpl({
    HorizonExplorerClientFactory? horizonExplorerClientFactory,
  }) : _horizonExplorerClientFactory = horizonExplorerClientFactory ??
            GetIt.I<HorizonExplorerClientFactory>();

  @override
  TaskEither<NetworkError, Map<String, bool>> getUtxoSwapMap({
    required HttpConfig httpConfig,
    required String sellerAddress,
  }) {
    return handleNetworkCall(() async {
      final client = _horizonExplorerClientFactory.getClient(httpConfig);

      final res = await client.getUtxoSwapMap(
        sellerAddress: sellerAddress,
      );

      return res.data.map;
    });
  }

  @override
  TaskEither<NetworkError, AtomicSwapCreate> atomicSwapCreate({
    required HttpConfig httpConfig,
    required String psbtHex,
    required String sellerAddress,
    required String assetUtxoId,
    required int assetUtxoValue,
    required String assetName,
    required bool assetDivisible,
    required int assetQuantity,
    required int price,
    required DateTime? expiresAt,
    required String feePaymentId,
    required String feePaymentPsbtHex,
  }) {
    return handleNetworkCall(() async {
      final client = _horizonExplorerClientFactory.getClient(httpConfig);

      final res = await client.createAtomicSwap(
        divisible: assetDivisible,
        psbtHex: psbtHex,
        sellerAddress: sellerAddress,
        assetUtxoId: assetUtxoId,
        assetUtxoValue: assetUtxoValue,
        assetName: assetName,
        assetQuantity: assetQuantity,
        price: price,
        expiresAt: expiresAt,
        feePaymentId: feePaymentId,
        feePaymentPsbtHex: feePaymentPsbtHex,
      );

      return AtomicSwapCreate(
        id: res.data.id,
      );
    });
  }

  @override
  TaskEither<NetworkError, OnChainPayment> createOnChainPayment({
    required HttpConfig httpConfig,
    required String address,
    required List<String> utxoSetIds,
    required num satsPerVbyte,
  }) {
    return handleNetworkCall(() async {
      final client = _horizonExplorerClientFactory.getClient(httpConfig);

      final res = await client.createOnChainPayment(
          address: address, utxoSetIds: utxoSetIds, satsPerVbyte: satsPerVbyte);
      return res.data.toEntity();
    });
  }

  @override
  TaskEither<NetworkError, List<AtomicSwap>> getSwapsByAsset({
    required HttpConfig httpConfig,
    required String asset,
    required String orderBy,
    required String order,
  }) {
    return handleNetworkCall(() async {
      // TODO: handle pagination?

      final client = _horizonExplorerClientFactory.getClient(httpConfig);

      final res = await client.getAtomicSwaps(
          assetName: asset, orderBy: orderBy, order: order);

      return res.data.atomicSwaps
          .map((swap) => swap.toEntity())
          .where((swap) => !swap.pendingSales)
          .toList();
    });
  }

  @override
  TaskEither<NetworkError, List<AtomicSwap>> searchSwaps({
    required HttpConfig httpConfig,
    required String search,
    String orderBy = "price",
    String order = "asc",
    String Function(NetworkError error)? onError,
  }) {
    return handleNetworkCall(() async {
      // TODO: handle pagination?

      final client = _horizonExplorerClientFactory.getClient(httpConfig);

      final res = await client.getAtomicSwaps(
          search: search, orderBy: orderBy, order: order);

      return res.data.atomicSwaps
          .map((swap) => swap.toEntity())
          .where((swap) => !swap.pendingSales)
          .toList();
    });
  }

  @override
  TaskEither<NetworkError, List<AtomicSwapBuy>> atomicSwapMultiBuy({
    required HttpConfig httpConfig,
    required List<String> ids,
    required String psbtHex,
    required String buyerAddress,
  }) {
    return handleNetworkCall(() async {
      final client = _horizonExplorerClientFactory.getClient(httpConfig);

      final res = await client.atomicSwapMultiBuy(
        ids: ids,
        psbtHex: psbtHex,
        buyerAddress: buyerAddress,
      );

      return res.data
          .map((buy) => AtomicSwapBuy(
                atomicSwapId: buy.atomicSwap.id,
                buyerAddress: buy.buyerAddress,
                txId: buy.txId,
              ))
          .toList();
    });
  }
}
