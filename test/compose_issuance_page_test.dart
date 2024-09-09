import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/presentation/screens/compose_issuance/view/compose_issuance_page.dart';

void main() {
  test('generateNumericAssetName produces valid numeric asset names', () {
    final min = BigInt.from(26).pow(12) + BigInt.one;
    final max = BigInt.from(256).pow(8);

    for (int i = 0; i < 50; i++) {
      final assetName = generateNumericAssetName();

      // Check if the asset name starts with 'A'
      expect(assetName.startsWith('A'), true);

      // Extract the numeric part and convert it to BigInt
      final numericPart = BigInt.parse(assetName.substring(1));

      // Check if the numeric part is within the valid range
      expect(numericPart >= min, true);
      expect(numericPart <= max, true);

      // Check if the numeric part is an integer (no decimal point)
      expect(assetName.contains('.'), false);
    }
  });

  test('generateNumericAssetName produces unique names', () {
    final nameSet = <String>{};
    for (int i = 0; i < 50; i++) {
      final assetName = generateNumericAssetName();
      nameSet.add(assetName);
    }

    // Check if all 50 generated names are unique
    expect(nameSet.length, 50);
  });
}
