import "package:fpdart/fpdart.dart" as fp;
import "package:horizon/domain/entities/order.dart";
import 'package:horizon/domain/entities/http_config.dart';

abstract class OrderRepository {
  fp.TaskEither<String, List<Order>> getByAddress(
      {required String address,
      String? status,
      required HttpConfig httpConfig});
}
