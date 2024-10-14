import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/dispenser.dart' as entity;
import 'package:horizon/domain/repositories/dispenser_repository.dart';

class DispenserRepositoryImpl implements DispenserRepository {
  final api.V2Api v2Api;

  DispenserRepositoryImpl({required this.v2Api});

  @override
  Future<List<entity.Dispenser>> getDispenserByAddress(String address) async {
    final response = await v2Api.getDispenserByAddress(address);

    if (response.result == null) {
      return [];
    }
    // return response.data;
    final List<api.Dispenser> dispenser = response.result!;

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
