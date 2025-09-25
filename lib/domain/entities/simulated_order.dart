import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';

sealed class SimulatedOrder extends Equatable {
  final AssetQuantity give;
  final AssetQuantity get;

  const SimulatedOrder({required this.give, required this.get});

  @override
  List<Object?> get props => [runtimeType, give, get];

  @override
  String toString() => '$runtimeType(give: $give, get: $get)';
}

class SimulatedOrderMatch extends SimulatedOrder {
  const SimulatedOrderMatch({required super.give, required super.get});
}

class SimulatedOrderCreate extends SimulatedOrder {
  const SimulatedOrderCreate({required super.give, required super.get});
}

class SimulatedOrderSummary {
  AssetQuantity totalGive;
  AssetQuantity giveNow;
  AssetQuantity giveEscrow;
  AssetQuantity getNow;

  SimulatedOrderSummary({
    required this.totalGive,
    required this.giveNow,
    required this.giveEscrow,
    required this.getNow,
  });
}
