import 'package:rational/rational.dart';
import 'package:horizon/domain/entities/order.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/simulated_order.dart';
import "./usecase.dart";
export "./usecase.dart";

Rational rationalMinList(List<Rational> values) {
  if (values.isEmpty) throw ArgumentError('List cannot be empty');
  return values.reduce((a, b) => a < b ? a : b);
}

class SimulateOrdersParams {
  final List<Order> asks;
  final AssetQuantity giveQuantity;
  final AssetQuantity getQuantity;

  SimulateOrdersParams({
    required this.asks,
    required this.giveQuantity,
    required this.getQuantity,
  });
}

// TODO: assert orders are sorted correctly
final class SimulateOrdersUseCase
    implements UseCase<List<SimulatedOrder>, SimulateOrdersParams> {
  SimulateOrdersUseCase();

  @override
  List<SimulatedOrder> call(SimulateOrdersParams params) {
    BigInt tx1GiveQuantity = params.giveQuantity.quantity;
    BigInt tx1GetQuantity = params.getQuantity.quantity;

    BigInt tx1GiveRemaining = tx1GiveQuantity;
    BigInt tx1GetRemaining = tx1GetQuantity;

    bool giveDivisible = params.giveQuantity.divisible;
    bool getDivisible = params.getQuantity.divisible;

    final simulatedOrders = <SimulatedOrder>[];

    for (final tx0 in params.asks) {
      if (tx1GetRemaining <= BigInt.zero) {
        break;
      }

      final tx0GiveRemaining = Rational.fromInt(tx0.giveRemaining);
      final tx0Price = Rational.fromInt(tx0.getQuantity, tx0.giveQuantity);
      final tx1InversePrice = Rational(tx1GiveRemaining, tx1GetRemaining);

      if (tx0Price > tx1InversePrice) {
        continue;
      }

      final forwardQuantity = Rational(rationalMinList([
        tx0GiveRemaining,
        Rational(tx1GiveRemaining) / tx0Price,
      ]).toBigInt());

      final backwardQuantity = forwardQuantity * tx0Price;

      if (forwardQuantity == Rational.zero ||
          backwardQuantity == Rational.zero) {
        continue;
      }

      tx1GiveRemaining = tx1GiveRemaining - backwardQuantity.toBigInt();
      tx1GetRemaining = tx1GetRemaining - forwardQuantity.toBigInt();

      simulatedOrders.add(SimulatedOrderMatch(
        give: AssetQuantity(
            divisible: giveDivisible, quantity: backwardQuantity.toBigInt()),
        get: AssetQuantity(
            divisible: getDivisible, quantity: forwardQuantity.toBigInt()),
      ));
    }

    if (tx1GiveRemaining > BigInt.zero) {
      final giveQuantity = tx1GiveRemaining;

      // get quantity is just 0 here since
      // all we are computing is an escrowed amount.
      final getQuantity = BigInt.zero;

      simulatedOrders.add(SimulatedOrderCreate(
        give: AssetQuantity(divisible: giveDivisible, quantity: giveQuantity),
        get: AssetQuantity(divisible: getDivisible, quantity: getQuantity),
      ));
    }

    return simulatedOrders;
  }
}
