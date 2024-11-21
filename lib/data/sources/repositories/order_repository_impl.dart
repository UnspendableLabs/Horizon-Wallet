import "package:fpdart/fpdart.dart";
import "package:horizon/domain/entities/order.dart" as e;
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/order_repository.dart';

import 'package:horizon/data/models/cursor.dart' as cursor_model;

class OrderRepositoryImpl implements OrderRepository {
  final V2Api api;
  final Logger? logger;
  OrderRepositoryImpl({required this.api, this.logger});

  @override
  TaskEither<String, List<e.Order>> getByAddress(
      String address, String? status) {
    return TaskEither.tryCatch(() => _getByAddress(address, status),
        (error, stacktrace) {
      logger?.error("OrderRepository.getByAdress", null, stacktrace);
      return "GetOrdersByAddress failure";
    });
  }

  Future<List<e.Order>> _getByAddress(String address, String? status) async {
    int limit = 50;
    cursor_model.CursorModel? cursor;
    final List<e.Order> orders = [];

    while (true) {
      final response =
          await api.getOrdersByAddressVerbose(address, status, cursor, limit);
      final result = response.result ?? [];

      orders.addAll(result.map((order) => order.toDomain()));

      cursor = response.nextCursor;
      if (cursor == null) break;
    }
    return orders;
  }
}
