import 'package:get_it/get_it.dart';
import "package:horizon/domain/repositories/atomic_swap_repository.dart";
import 'package:horizon/domain/entities/atomic_swap/on_chain_payment.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client_factory.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap_buy.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap_sale.dart';

class AtomicSwapRepositoryImpl implements AtomicSwapRepository {
  final HorizonExplorerClientFactory _horizonExplorerClientFactory;

  AtomicSwapRepositoryImpl({
    HorizonExplorerClientFactory? horizonExplorerClientFactory,
  }) : _horizonExplorerClientFactory = horizonExplorerClientFactory ??
            GetIt.I<HorizonExplorerClientFactory>();

  @override
  Future<OnChainPayment> createOnChainPayment({
    required HttpConfig httpConfig,
    required String address,
    required List<String> utxoSetIds,
    required num satsPerVbyte,
  }) async {
    final client = _horizonExplorerClientFactory.getClient(httpConfig);

    final res = await client.createOnChainPayment(
        address: address, utxoSetIds: utxoSetIds, satsPerVbyte: satsPerVbyte);

    return res.data.toEntity();
  }

  @override
  Future<List<AtomicSwap>> getSwapsByAsset({
    required HttpConfig httpConfig,
    required String asset,
    required String orderBy,
    required String order,
  }) async {
    // TODO: handle pagination?

    final client = _horizonExplorerClientFactory.getClient(httpConfig);

    final res = await client.getAtomicSwaps(
        assetName: asset, orderBy: orderBy, order: order);

    return res.data.atomicSwaps
        .map((swap) => swap.toEntity())
        .where((swap) => !swap.pendingSales)
        .toList();
  }

  @override
  Future<AtomicSwapBuy> atomicSwapBuy({
    required HttpConfig httpConfig,
    required String id,
    required String psbtHex,
    required String buyerAddress,
  }) async {
    final client = _horizonExplorerClientFactory.getClient(httpConfig);

    final res = await client.atomicSwapBuy(
      id: id,
      psbtHex: psbtHex,
      buyerAddress: buyerAddress,
    );

    return AtomicSwapBuy(
      atomicSwapId: res.data.atomicSwap.id,
      buyerAddress: res.data.buyerAddress,
      txId: res.data.txId,
    );
  }

  @override
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
      required String feeHex}) async {
    final client = _horizonExplorerClientFactory.getClient(httpConfig);

    final res = await client.atomicSwapSale(
      psbtHex: psbtHex,
      sellerAddress: sellerAddress,
      assetUtxoId: assetUtxoId,
      assetUtxoValue: assetUtxoValue,
      assetName: assetName,
      assetQuantity: assetQuantity,
      price: price,
      expiresAt: expiresAt,
      feePaymentId: feePaymentId,
      feeHex: feeHex,
    );

    return AtomicSwapSale(
      id: res.data.id,
    );
  }
}
