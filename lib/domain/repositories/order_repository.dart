import "package:horizon/domain/entities/order.dart";
import 'package:horizon/domain/entities/http_config.dart';

abstract class OrderRepository {
  Future<List<Order>> getByAddress(
      {required String address,
      String? status,
      required HttpConfig httpConfig});

  Future<List<Order>> getByPair(
      {required String giveAsset,
      required String getAsset,
      String? status,
      String? sort,
      required HttpConfig httpConfig});
}
