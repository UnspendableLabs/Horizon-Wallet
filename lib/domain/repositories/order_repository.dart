import "package:fpdart/fpdart.dart" hide Order;
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
      required HttpConfig httpConfig});
}

extension OrderRepositoryExtension on OrderRepository {
  TaskEither<String, List<Order>> getByAddressTE(
      {required String address,
      String? status,
      required HttpConfig httpConfig,
      String Function(Object error, StackTrace stacktrace)? onError}) {
    return TaskEither.tryCatch(
        () => getByAddress(
              address: address,
              status: status,
              httpConfig: httpConfig,
            ),
        (error, callsack) =>
            onError?.call(error, callsack) ?? error.toString());
  }

  TaskEither<String, List<Order>> getByPairTE(
      {required String giveAsset,
      required String getAsset,
      String? status,
      required HttpConfig httpConfig,
      String Function(Object error, StackTrace stacktrace)? onError}) {
    return TaskEither.tryCatch(
        () => getByPair(
              giveAsset: giveAsset,
              getAsset: getAsset,
              status: status,
              httpConfig: httpConfig,
            ),
        (error, callsack) =>
            onError?.call(error, callsack) ?? error.toString());
  }
}
