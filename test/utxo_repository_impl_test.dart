import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/data/sources/network/esplora_client.dart';
import 'package:horizon/data/sources/repositories/utxo_repository_impl.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:mocktail/mocktail.dart';

class MockV2Api extends Mock implements V2Api {}

class MockEsploraApi extends Mock implements EsploraApi {}

class MockCacheProvider extends Mock implements CacheProvider {}

class MockEsploraUtxo extends Mock implements EsploraUtxo {}

void main() {
  late UtxoRepositoryImpl repository;
  late MockV2Api mockApi;
  late MockEsploraApi mockEsploraApi;
  late MockCacheProvider mockCacheProvider;

  setUp(() {
    mockApi = MockV2Api();
    mockEsploraApi = MockEsploraApi();
    mockCacheProvider = MockCacheProvider();
    repository = UtxoRepositoryImpl(
      api: mockApi,
      esploraApi: mockEsploraApi,
      cacheProvider: mockCacheProvider,
    );
  });

  group('getUnspentForAddress', () {
    test('should return all UTXOs when excludeCached is false', () async {
      // Arrange
      const address = 'test_address';
      final mockUtxos = [
        _createMockEsploraUtxo('tx1', 0, 1000),
        _createMockEsploraUtxo('tx1', 1, 2000),
        _createMockEsploraUtxo('tx2', 0, 3000),
      ];

      when(() => mockEsploraApi.getUtxosForAddress(address))
          .thenAnswer((_) async => mockUtxos);
      when(() => mockCacheProvider.getValue(any())).thenReturn(['tx1']);

      // Act
      final result = await repository.getUnspentForAddress(address);

      // Assert
      expect(result.length, equals(3));
      verifyNever(() => mockCacheProvider.getValue(any()));
      _verifyUtxoList(result, mockUtxos);
    });

    test('should filter cached UTXOs with vout 0 when excludeCached is true',
        () async {
      // Arrange
      const address = 'test_address';
      final mockUtxos = [
        _createMockEsploraUtxo('cached_tx1', 0, 1000), // Should be excluded
        _createMockEsploraUtxo('cached_tx1', 1, 2000), // Should be included
        _createMockEsploraUtxo('cached_tx2', 0, 3000), // Should be excluded
        _createMockEsploraUtxo('normal_tx', 0, 4000), // Should be included
        _createMockEsploraUtxo('normal_tx', 1, 5000), // Should be included
      ];

      when(() => mockEsploraApi.getUtxosForAddress(address))
          .thenAnswer((_) async => mockUtxos);
      when(() => mockCacheProvider.getValue(address))
          .thenReturn(['cached_tx1', 'cached_tx2']);

      // Act
      final result = await repository.getUnspentForAddress(
        address,
        excludeCached: true,
      );

      // Assert
      expect(result.length, equals(3));
      verify(() => mockCacheProvider.getValue(address)).called(1);

      // Verify specific UTXOs
      expect(
          result
              .where((utxo) => utxo.txid == 'cached_tx1' && utxo.vout == 0)
              .isEmpty,
          isTrue);
      expect(
          result
              .where((utxo) => utxo.txid == 'cached_tx2' && utxo.vout == 0)
              .isEmpty,
          isTrue);
      expect(
          result
              .where((utxo) => utxo.txid == 'cached_tx1' && utxo.vout == 1)
              .length,
          equals(1));
      expect(
          result.where((utxo) => utxo.txid == 'normal_tx').length, equals(2));
    });

    test('should handle empty cache when excludeCached is true', () async {
      // Arrange
      const address = 'test_address';
      final mockUtxos = [
        _createMockEsploraUtxo('tx1', 0, 1000),
        _createMockEsploraUtxo('tx2', 0, 2000),
      ];

      when(() => mockEsploraApi.getUtxosForAddress(address))
          .thenAnswer((_) async => mockUtxos);
      when(() => mockCacheProvider.getValue(address)).thenReturn(null);

      // Act
      final result = await repository.getUnspentForAddress(
        address,
        excludeCached: true,
      );

      // Assert
      expect(result.length, equals(2));
      verify(() => mockCacheProvider.getValue(address)).called(1);
      _verifyUtxoList(result, mockUtxos);
    });

    test('should handle null cache value when excludeCached is true', () async {
      // Arrange
      const address = 'test_address';
      final mockUtxos = [
        _createMockEsploraUtxo('tx1', 0, 1000),
        _createMockEsploraUtxo('tx2', 0, 2000),
      ];

      when(() => mockEsploraApi.getUtxosForAddress(address))
          .thenAnswer((_) async => mockUtxos);
      when(() => mockCacheProvider.getValue(address)).thenReturn(null);

      // Act
      final result = await repository.getUnspentForAddress(
        address,
        excludeCached: true,
      );

      // Assert
      expect(result.length, equals(2));
      verify(() => mockCacheProvider.getValue(address)).called(1);
      _verifyUtxoList(result, mockUtxos);
    });
  });
}

// Helper functions
EsploraUtxo _createMockEsploraUtxo(String txid, int vout, int value) {
  final status = EsploraUtxoStatus(
    confirmed: true,
    blockHeight: 100,
    blockHash: 'mock_hash',
    blockTime: 1234567890,
  );

  return EsploraUtxo(
    txid: txid,
    vout: vout,
    status: status,
    value: value,
  );
}

void _verifyUtxoList(List<Utxo> actual, List<EsploraUtxo> expected) {
  expect(actual.length, equals(expected.length));

  for (var i = 0; i < actual.length; i++) {
    expect(actual[i].txid, equals(expected[i].txid));
    expect(actual[i].vout, equals(expected[i].vout));
    expect(actual[i].value, equals(expected[i].value));
    expect(actual[i].height, equals(expected[i].status.blockHeight));
  }
}
