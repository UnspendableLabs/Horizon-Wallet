import 'package:horizon/domain/entities/dispenser.dart';

abstract class DispenserRepository {
  Future<List<Dispenser>> getDispenserByAddress(String address);
}
