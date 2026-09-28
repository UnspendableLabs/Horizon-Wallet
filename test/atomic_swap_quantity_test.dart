import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/data/sources/network/atomic_swap_quantity_converter.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client.dart';

Map<String, dynamic> swapJson(Object? quantity) => {
      'id': 'test-swap',
      'funded': true,
      'filled': false,
      'delisted': false,
      'expired': false,
      'pending': false,
      'anomalous': false,
      'confirmed': true,
      'tx_id': null,
      'seller_delisted': false,
      'seller_address': 'seller',
      'buyer_address': null,
      'asset_utxo_id': '${'0' * 64}:0',
      'asset_utxo_value': 330,
      'asset_name': 'TEST',
      'asset_quantity': quantity,
      'price': 1500,
      'price_per_unit': 5,
      'created_at': '2026-09-18T00:00:00Z',
      'updated_at': '2026-09-18T00:00:00Z',
      'expires_at': null,
    };

void main() {
  const converter = AtomicSwapQuantityConverter();
  for (final value in [
    '30000000000',
    '9007199254740993',
    '9223372036854775807'
  ]) {
    test('decodes $value exactly through model and domain mapping', () {
      final model = AtomicSwapModel.fromJson(swapJson(value));
      expect(model.assetQuantity, BigInt.parse(value));
      expect(model.toEntity().assetQuantity.quantity, BigInt.parse(value));
      expect(converter.toJson(model.assetQuantity), value);
    });
  }
  test('accepts legacy safe integer JSON and zero', () {
    expect(AtomicSwapModel.fromJson(swapJson(30000000000)).assetQuantity,
        BigInt.parse('30000000000'));
    expect(converter.fromJson(0), BigInt.zero);
    expect(converter.fromJson(42.0), BigInt.from(42));
  });
  for (final value in [
    null,
    true,
    '',
    '1.5',
    '1e3',
    '-1',
    ' 1',
    -1,
    1.5,
    double.nan,
    double.infinity,
    9007199254740992
  ]) {
    test('rejects invalid or imprecise quantity $value', () {
      expect(() => converter.fromJson(value), throwsFormatException);
    });
  }
  test('decodes the swap search response envelope', () {
    final response = AtomicSwapListResponseData.fromJson({
      'count': 1,
      'atomic_swaps': [swapJson('30000000000')],
    });
    expect(
        response.atomicSwaps.single.assetQuantity, BigInt.parse('30000000000'));
  });
}
