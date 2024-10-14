import 'package:horizon/data/sources/network/api/v2_api.dart' as v2_api;
import 'package:horizon/domain/entities/dispenser.dart' as entity;
import 'package:horizon/domain/repositories/dispenser_repository.dart';

class DispenserRepositoryImpl implements DispenserRepository {
  final v2_api.V2Api api;

  DispenserRepositoryImpl({required this.api});

  @override
  Future<List<entity.Dispenser>> getDispenserByAddress(String address) async {
    final response = await api.getDispenserByAddress(address, 'open');

    if (response.result == null) {
      return [];
    }
    // return response.data;
    final List<v2_api.Dispenser> dispenser = response.result!;

    return dispenser
        .map((d) => entity.Dispenser(
              assetName: d.asset,
              openAddress: d.source,
              giveQuantity: d.giveQuantity,
              escrowQuantity: d.escrowQuantity,
              mainchainrate: d.satoshirate,
              status: d.status,
            ))
        .toList();
  }
}
