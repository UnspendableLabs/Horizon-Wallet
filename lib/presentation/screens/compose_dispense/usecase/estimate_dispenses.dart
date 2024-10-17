import "package:decimal/decimal.dart";
import "package:horizon/domain/entities/dispenser.dart";
import "package:horizon/common/format.dart";

enum EstimatedDispenseAnnotations {
  overpay,
}

class EstimatedDispense {
  final int estimatedUnits;
  final int estimatedQuantity;
  final Decimal estimatedQuantityNormalized;
  final List<EstimatedDispenseAnnotations> annotations;
  final Dispenser dispenser;

  EstimatedDispense({
    required this.estimatedUnits,
    required this.estimatedQuantity,
    required this.estimatedQuantityNormalized,
    required this.annotations,
    required this.dispenser,
  });

  @override
  String toString() =>
      'EstimatedDispense(asset: ${dispenser.asset}, units: $estimatedUnits, quantity: $estimatedQuantity)';
}

class EstimateDispensesUseCase {
  List<EstimatedDispense> call({
    required int quantity,
    required List<Dispenser> dispensers,
  }) {
    // Loop over dispensers and estimate dispenses
    return dispensers.map((dispenser) {
      return estimatedDispenseForDispenserAndQuantity(dispenser, quantity);
    }).toList();
  }
}

// Pull the logic for estimating a dispense into its own function
EstimatedDispense estimatedDispenseForDispenserAndQuantity(
    Dispenser dispenser, int quantity) {
  List<EstimatedDispenseAnnotations> annotations = [];

  int unitsToDispense = quantity ~/ dispenser.satoshirate;
  int quantityToDispense = unitsToDispense * dispenser.giveQuantity;

  if (quantityToDispense > dispenser.giveRemaining) {
    // Adjust for overpayment if needed
    quantityToDispense = dispenser.giveRemaining;
    unitsToDispense = quantityToDispense ~/ dispenser.giveQuantity;
    if (quantityToDispense > 0) {
      annotations.add(EstimatedDispenseAnnotations.overpay);
    }
  } else {
    if (unitsToDispense * dispenser.satoshirate < quantity) {
      annotations.add(EstimatedDispenseAnnotations.overpay);
    }
  }

  if (quantityToDispense > 0) {
    print(annotations);
    return EstimatedDispense(
        annotations: annotations,
        dispenser: dispenser,
        estimatedUnits: unitsToDispense,
        estimatedQuantity: quantityToDispense,
        estimatedQuantityNormalized: quantityToQuantityNormalized(
            quantityToDispense, dispenser.assetInfo.divisible));
  } else {
    return EstimatedDispense(
        annotations: annotations,
        dispenser: dispenser,
        estimatedUnits: 0,
        estimatedQuantity: 0,
        estimatedQuantityNormalized: quantityToQuantityNormalized(
            quantityToDispense, dispenser.assetInfo.divisible));
  }
}
