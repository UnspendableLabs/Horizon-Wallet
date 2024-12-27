import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/data/models/asset_info.dart';
import 'package:horizon/data/models/cursor.dart' as cursor_model;
import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/data/sources/repositories/events_repository_impl.dart';
import 'package:horizon/domain/entities/cursor.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockV2Api extends Mock implements api.V2Api {}

class MockBitcoinRepository extends Mock implements BitcoinRepository {}

class MockCacheProvider extends Mock implements CacheProvider {}

class MockVerboseEvent extends Mock implements VerboseEvent {}

class MockApiVerboseEvent extends Mock implements api.VerboseEvent {}

class MockCursorModel extends Mock implements cursor_model.CursorModel {}

class MockResponse extends Mock
    implements api.Response<List<api.VerboseEvent>> {}

void main() {
  late EventsRepositoryImpl repository;
  late MockV2Api mockApi;
  late MockBitcoinRepository mockBitcoinRepository;
  late MockCacheProvider mockCacheProvider;

  setUp(() {
    mockApi = MockV2Api();
    mockBitcoinRepository = MockBitcoinRepository();
    mockCacheProvider = MockCacheProvider();
    repository = EventsRepositoryImpl(
      api_: mockApi,
      bitcoinRepository: mockBitcoinRepository,
      cacheProvider: mockCacheProvider,
    );

    final mockCursor = MockCursorModel();
    when(() => mockCursor.intValue).thenReturn(1);
    registerFallbackValue(mockCursor);

    when(() => mockCacheProvider.setObject(any(), any()))
        .thenAnswer((_) async => Future<void>.value());
    when(() => mockCacheProvider.remove(any()))
        .thenAnswer((_) async => Future<void>.value());
  });

  group('getByAddressVerbose', () {
    test('should call API with correct parameters and return events', () async {
      // Arrange
      final apiEvent = api.VerboseAttachToUtxoEvent(
        eventIndex: 1,
        event: 'ATTACH_TO_UTXO',
        txHash: 'hash',
        blockIndex: 1,
        blockTime: 1,
        params: api.VerboseAttachToUtxoParams(
          asset: 'TEST',
          blockIndex: 1,
          destination: 'dest',
          feePaid: 100,
          quantityNormalized: '100',
          feePaidNormalized: '100',
          msgIndex: 1,
          blockTime: 1,
          source: 'source',
          status: 'valid',
          txHash: 'hash',
          txIndex: 1,
          quantity: 100,
          assetInfo: AssetInfoModel(
            divisible: true,
            description: 'description',
            locked: true,
          ),
        ),
      );

      final response = MockResponse();
      when(() => response.result).thenReturn([apiEvent]);
      when(() => response.nextCursor).thenReturn(null);
      when(() => response.resultCount).thenReturn(1);

      when(() => mockApi.getEventsByAddressesVerbose(
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => response);

      // Act
      final result = await repository.getByAddressVerbose(
        address: 'test_address',
        limit: 10,
        cursor: Cursor.fromInt(1),
      );

      // Assert
      verify(() => mockApi.getEventsByAddressesVerbose(
            'test_address',
            any(that: isA<cursor_model.CursorModel>()),
            10,
            null,
          )).called(1);

      expect(result.$1.length, 1);
      expect(result.$2, null);
      expect(result.$3, 1);
    });

    test('should invalidate cache for confirmed AttachToUtxo events', () async {
      // Arrange
      final apiEvent = api.VerboseAttachToUtxoEvent(
        eventIndex: 1,
        event: 'ATTACH_TO_UTXO',
        txHash: 'hash',
        blockIndex: 1,
        blockTime: 1,
        params: api.VerboseAttachToUtxoParams(
          asset: 'TEST',
          blockIndex: 1,
          destination: 'dest',
          feePaid: 100,
          quantityNormalized: '100',
          feePaidNormalized: '100',
          msgIndex: 1,
          blockTime: 1,
          source: 'source',
          status: 'valid',
          txHash: 'hash',
          txIndex: 1,
          quantity: 100,
          assetInfo: AssetInfoModel(
            divisible: true,
            description: 'description',
            locked: true,
          ),
        ),
      );

      final response = MockResponse();
      when(() => response.result).thenReturn([apiEvent]);
      when(() => response.nextCursor).thenReturn(null);

      when(() => mockApi.getEventsByAddressesVerbose(
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => response);

      // Act
      await repository.getByAddressVerbose(address: 'test_address');

      // Assert
      verify(() => mockCacheProvider.getValue('test_address')).called(1);
    });

    test(
        'should properly invalidate cache for multiple confirmed AttachToUtxo events',
        () async {
      // Arrange
      final existingTxHashes = [
        'keep_hash',
        'remove_hash1',
        'remove_hash2',
        'another_keep_hash'
      ];
      when(() => mockCacheProvider.getValue('test_address'))
          .thenReturn(existingTxHashes);

      final apiEvents = [
        api.VerboseAttachToUtxoEvent(
          eventIndex: 1,
          event: 'ATTACH_TO_UTXO',
          txHash: 'remove_hash1',
          blockIndex: 1,
          blockTime: 1,
          params: api.VerboseAttachToUtxoParams(
            asset: 'TEST1',
            blockIndex: 1,
            destination: 'dest1',
            feePaid: 100,
            quantityNormalized: '100',
            feePaidNormalized: '100',
            msgIndex: 1,
            blockTime: 1,
            source: 'source',
            status: 'valid',
            txHash: 'remove_hash1',
            txIndex: 1,
            quantity: 100,
            assetInfo: AssetInfoModel(
              divisible: true,
              description: 'description',
              locked: true,
            ),
          ),
        ),
        api.VerboseAttachToUtxoEvent(
          eventIndex: 2,
          event: 'ATTACH_TO_UTXO',
          txHash: 'remove_hash2',
          blockIndex: 2,
          blockTime: 2,
          params: api.VerboseAttachToUtxoParams(
            asset: 'TEST2',
            blockIndex: 2,
            destination: 'dest2',
            feePaid: 200,
            quantityNormalized: '200',
            feePaidNormalized: '200',
            msgIndex: 2,
            blockTime: 2,
            source: 'source',
            status: 'valid',
            txHash: 'remove_hash2',
            txIndex: 2,
            quantity: 200,
            assetInfo: AssetInfoModel(
              divisible: true,
              description: 'description',
              locked: true,
            ),
          ),
        ),
      ];

      final response = MockResponse();
      when(() => response.result).thenReturn(apiEvents);
      when(() => response.nextCursor).thenReturn(null);
      when(() => response.resultCount).thenReturn(2);

      when(() => mockApi.getEventsByAddressesVerbose(
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => response);

      // Act
      await repository.getByAddressVerbose(address: 'test_address');

      // Assert
      verify(() => mockCacheProvider.getValue('test_address')).called(2);
      verify(() => mockCacheProvider.setObject(
            'test_address',
            any(
                that: predicate<List<dynamic>>((list) =>
                    list.length == 2 &&
                    list.contains('keep_hash') &&
                    list.contains('another_keep_hash') &&
                    !list.contains('remove_hash1') &&
                    !list.contains('remove_hash2'))),
          )).called(2);
    });
  });
}
