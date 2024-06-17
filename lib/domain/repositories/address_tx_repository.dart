import 'package:horizon/domain/entities/send.dart';

abstract class AddressTxRepository {
  Future<List<Send>> getSends(String address);
}
