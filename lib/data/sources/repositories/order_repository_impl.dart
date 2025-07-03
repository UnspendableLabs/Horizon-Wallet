import "package:fpdart/fpdart.dart" hide Order;
import 'package:get_it/get_it.dart';
import "package:horizon/domain/entities/order.dart";
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/order_repository.dart';

import 'package:horizon/data/models/cursor.dart' as cursor_model;
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';

class OrderRepositoryImpl implements OrderRepository {
  final CounterpartyClientFactory _counterpartyClientFactory;
  final Logger? logger;
  OrderRepositoryImpl(
      {CounterpartyClientFactory? counterpartyClientFactory, this.logger})
      : _counterpartyClientFactory =
            counterpartyClientFactory ?? GetIt.I<CounterpartyClientFactory>();

  @override
  Future<List<Order>> getByAddress(
      {required String address,
      String? status,
      required HttpConfig httpConfig}) async {
    int limit = 50;
    cursor_model.CursorModel? cursor;
    final List<Order> orders = [];

    while (true) {
      final response = await _counterpartyClientFactory
          .getClient(httpConfig)
          .getOrdersByAddressVerbose(address, status, cursor, limit);
      final result = response.result ?? [];

      orders.addAll(result.map((order) => order.toDomain()));

      cursor = response.nextCursor;
      if (cursor == null) break;
    }
    return orders;
  }

  @override
  Future<List<Order>> getByPair(
      {
      required String giveAsset,
      required String receiveAsset,
      String? status,
      required HttpConfig httpConfig}) async {
    int limit = 50;
    cursor_model.CursorModel? cursor;
    final List<Order> orders = [];

    while (true) {
      final response = await _counterpartyClientFactory
          .getClient(httpConfig)
          .getOrders(status, receiveAsset, giveAsset, cursor, limit);
      final result = response.result ?? [];

      orders.addAll(result.map((order) => order.toDomain()));

      cursor = response.nextCursor;
      if (cursor == null) break;
    }
    return orders;
  }
}
