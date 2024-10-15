import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/estimate_dispenses.dart';

class FakeAssetInfo extends Fake implements AssetInfo {
  final bool _divisible;

  FakeAssetInfo({required bool divisible}) : _divisible = divisible;

  @override
  bool get divisible => _divisible;
}

class FakeDispenser extends Fake implements Dispenser {
  final String _asset;
  final int _giveQuantity;
  final int _satoshirate;
  final int _giveRemaining;
  final AssetInfo _assetInfo;

  FakeDispenser({
    required String asset,
    required int giveQuantity,
    required int satoshirate,
    required int giveRemaining,
    required AssetInfo assetInfo,
  })  : _asset = asset,
        _giveQuantity = giveQuantity,
        _satoshirate = satoshirate,
        _giveRemaining = giveRemaining,
        _assetInfo = assetInfo;

  @override
  String get asset => _asset;

  @override
  int get giveQuantity => _giveQuantity;

  @override
  int get satoshirate => _satoshirate;

  @override
  int get giveRemaining => _giveRemaining;

  @override
  AssetInfo get assetInfo => _assetInfo;
}

void main() {
  group("happy path", () {
    test("divisible: true", () {
      // Arrange
      final dispenser = FakeDispenser(
        asset: "TEST",
        giveQuantity: 100,
        satoshirate: 5000,
        giveRemaining: 500,
        assetInfo: FakeAssetInfo(divisible: true),
      );

      const quantity = 25000; // The BTC amount user sends

      // Act
      final estimatedDispense =
          estimatedDispenseForDispenserAndQuantity(dispenser, quantity);

      // Assert
      expect(estimatedDispense.estimatedUnits, 5); // 25000 / 5000 = 5 units
      expect(estimatedDispense.estimatedQuantity, 500); // 5 * 100 = 500
      expect(estimatedDispense.annotations.isEmpty, true); // No overpay
      expect(
          estimatedDispense.estimatedQuantityNormalized,
          (Decimal.fromInt(500) / Decimal.fromInt(100000000))
              .toDecimal()
              .round(scale: 8));
    });

    test("divisible: false", () {
      // Arrange
      final dispenser = FakeDispenser(
        asset: "TEST",
        giveQuantity: 100,
        satoshirate: 5000,
        giveRemaining: 500,
        assetInfo: FakeAssetInfo(divisible: false),
      );

      const quantity = 25000; // The BTC amount user sends

      // Act
      final estimatedDispense =
          estimatedDispenseForDispenserAndQuantity(dispenser, quantity);

      // Assert
      expect(estimatedDispense.estimatedUnits, 5); // 25000 / 5000 = 5 units
      expect(estimatedDispense.estimatedQuantity, 500); // 5 * 100 = 500
      expect(estimatedDispense.annotations.isEmpty, true); // No overpay
      expect(
          estimatedDispense.estimatedQuantityNormalized, Decimal.fromInt(500));
    });
  });

  group("overpayment", () {
    test("divisible: true", () {
      // Arrange
      final dispenser = FakeDispenser(
        asset: "OVERPAY_DIVISIBLE_TEST",
        giveQuantity: 100,
        satoshirate: 1000,
        giveRemaining: 200,
        assetInfo: FakeAssetInfo(divisible: true),
      );

      const quantity = 500000;

      // Act
      final estimatedDispense =
          estimatedDispenseForDispenserAndQuantity(dispenser, quantity);

      // Assert
      expect(estimatedDispense.estimatedUnits, 2); // Adjust to remaining units
      expect(estimatedDispense.estimatedQuantity, 200); // Max remaining
      expect(estimatedDispense.annotations,
          contains(EstimatedDispenseAnnotations.overpay));
      expect(
          estimatedDispense.estimatedQuantityNormalized,
          (Decimal.fromInt(200) / Decimal.fromInt(100000000))
              .toDecimal()
              .round(scale: 8));
    });

    test("divisible: false", () {
      // Arrange
      final dispenser = FakeDispenser(
        asset: "OVERPAY_NOT_DIVISIBLE_TEST",
        giveQuantity: 100,
        satoshirate: 1000,
        giveRemaining: 200,
        assetInfo: FakeAssetInfo(divisible: false),
      );

      const quantity = 500000;

      // Act
      final estimatedDispense =
          estimatedDispenseForDispenserAndQuantity(dispenser, quantity);

      // Assert
      expect(estimatedDispense.estimatedUnits, 2); // Adjust to remaining units
      expect(estimatedDispense.estimatedQuantity, 200); // Max remaining
      expect(estimatedDispense.annotations,
          contains(EstimatedDispenseAnnotations.overpay));
      expect(
          estimatedDispense.estimatedQuantityNormalized, Decimal.fromInt(200));
    });
  });

  group("empty dispenser", () {
    test("divisible: true", () {
      final dispenser = FakeDispenser(
        asset: "EMPTY_TEST",
        giveQuantity: 100,
        satoshirate: 1000,
        giveRemaining: 0, // Dispenser is empty
        assetInfo: FakeAssetInfo(divisible: true),
      );

      const quantity = 50000; // User sends BTC

      // Act
      final estimatedDispense =
          estimatedDispenseForDispenserAndQuantity(dispenser, quantity);

      // Assert
      expect(estimatedDispense.estimatedUnits, 0); // No units
      expect(estimatedDispense.estimatedQuantity, 0); // No quantity
      expect(estimatedDispense.annotations,
          contains(EstimatedDispenseAnnotations.dispenserIsEmpty));
      expect(estimatedDispense.estimatedQuantityNormalized,
          Decimal.zero); // Zero normalized
    });

    test("divisible: false", () {
      final dispenser = FakeDispenser(
        asset: "EMPTY_TEST_NOT_DIVISIBLE",
        giveQuantity: 100,
        satoshirate: 1000,
        giveRemaining: 0, // Dispenser is empty
        assetInfo: FakeAssetInfo(divisible: false),
      );

      const quantity = 50000; // User sends BTC

      // Act
      final estimatedDispense =
          estimatedDispenseForDispenserAndQuantity(dispenser, quantity);

      // Assert
      expect(estimatedDispense.estimatedUnits, 0); // No units
      expect(estimatedDispense.estimatedQuantity, 0); // No quantity
      expect(estimatedDispense.annotations,
          contains(EstimatedDispenseAnnotations.dispenserIsEmpty));
      expect(estimatedDispense.estimatedQuantityNormalized,
          Decimal.zero); // Zero normalized
    });
  });
}
