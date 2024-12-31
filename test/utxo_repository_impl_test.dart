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

    test(
        'should correctly filter multiple cached transactions from a large UTXO set',
        () async {
      // Arrange
      const address = 'test_address';

      // Create 30 mock UTXOs
      final mockEsploraUtxos = List.generate(30, (i) {
        String txid;
        int vout;

        // First 6 UTXOs: 3 pairs of cached transactions with vout 0 and 1
        if (i < 6) {
          txid = 'cached_tx_${i ~/ 2}'; // Same txid for pairs
          vout = i % 2; // Alternating vout 0 and 1
        } else {
          // Remaining UTXOs: non-cached transactions
          txid = 'normal_tx_$i';
          vout = i % 2;
        }

        return EsploraUtxo(
          txid: txid,
          vout: vout,
          status: EsploraUtxoStatus(
            confirmed: true,
            blockHeight: 100 + i,
            blockHash: 'hash_$i',
            blockTime: 1000000 + i,
          ),
          value: 1000 + i,
        );
      });

      // Setup cached transaction hashes (first 3 transactions)
      final cachedTxHashes = ['cached_tx_0', 'cached_tx_1', 'cached_tx_2'];

      when(() => mockEsploraApi.getUtxosForAddress(address))
          .thenAnswer((_) async => mockEsploraUtxos);
      when(() => mockCacheProvider.getValue(address))
          .thenReturn(cachedTxHashes);

      // Act
      final result = await repository.getUnspentForAddress(
        address,
        excludeCached: true,
      );

      // Assert
      // 1. Verify total count (30 original - 3 excluded with vout 0)
      expect(result.length, equals(27));

      // 2. Verify excluded UTXOs (cached with vout 0)
      for (var i = 0; i < 6; i += 2) {
        final excludedTxid = 'cached_tx_${i ~/ 2}';
        expect(
          result
              .where((utxo) => utxo.txid == excludedTxid && utxo.vout == 0)
              .isEmpty,
          isTrue,
          reason: 'UTXO with txid $excludedTxid and vout 0 should be excluded',
        );
      }

      // 3. Verify included UTXOs (cached with vout 1)
      for (var i = 1; i < 6; i += 2) {
        final includedTxid = 'cached_tx_${i ~/ 2}';
        expect(
          result
              .where((utxo) => utxo.txid == includedTxid && utxo.vout == 1)
              .length,
          equals(1),
          reason: 'UTXO with txid $includedTxid and vout 1 should be included',
        );
      }

      // 4. Verify all non-cached UTXOs are included
      for (var i = 6; i < 30; i++) {
        final normalTxid = 'normal_tx_$i';
        expect(
          result.where((utxo) => utxo.txid == normalTxid).length,
          equals(1),
          reason: 'Normal UTXO with txid $normalTxid should be included',
        );
      }

      // 5. Verify correct mapping of properties
      for (final utxo in result) {
        final esploraUtxo = mockEsploraUtxos.firstWhere(
          (e) => e.txid == utxo.txid && e.vout == utxo.vout,
        );

        expect(utxo.value, equals(esploraUtxo.value));
        expect(utxo.height, equals(esploraUtxo.status.blockHeight));
        expect(utxo.address, equals(address));
      }

      // 6. Verify API and cache calls
      verify(() => mockEsploraApi.getUtxosForAddress(address)).called(1);
      verify(() => mockCacheProvider.getValue(address)).called(1);
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
