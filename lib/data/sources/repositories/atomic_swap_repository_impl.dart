import 'package:get_it/get_it.dart';
import "package:horizon/domain/repositories/atomic_swap_repository.dart";
import 'package:horizon/domain/entities/atomic_swap/on_chain_payment.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client_factory.dart';
import 'package:horizon/domain/entities/http_config.dart';

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
}
