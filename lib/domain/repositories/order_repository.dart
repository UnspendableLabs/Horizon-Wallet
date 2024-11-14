import "package:fpdart/fpdart.dart" as fp;
import "package:horizon/domain/entities/order.dart";

abstract class OrderRepository {
  fp.TaskEither<String, List<Order>> getByAddress(
      String address, String? status);
}
