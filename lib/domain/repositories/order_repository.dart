import "package:fpdart/fpdart.dart" hide Order;
import "package:horizon/domain/entities/network_error.dart";
import "package:horizon/domain/entities/order.dart";
import 'package:horizon/domain/entities/http_config.dart';

abstract class OrderRepository {
  TaskEither<NetworkError, List<Order>> getByAddress(
      {required String address,
      String? status,
      required HttpConfig httpConfig});

  TaskEither<NetworkError, List<Order>> getByPair(
      {required String giveAsset,
      required String getAsset,
      String? status,
      String? sort,
      required HttpConfig httpConfig});
}
