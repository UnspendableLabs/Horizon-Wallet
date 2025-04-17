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

  // Helper function
  api.VerboseAttachToUtxoParams createMockParams(String txHash) {
    return api.VerboseAttachToUtxoParams(
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
      txHash: txHash,
      txIndex: 1,
      quantity: 100,
      assetInfo: AssetInfoModel(
        divisible: true,
        description: 'description',
        locked: true,
      ),
    );
  }

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
      final result = await repository.getByAddressesVerbose(
        addresses: ['test_address'],
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
      await repository.getByAddressesVerbose(addresses: ['test_address']);

      // Assert
      verify(() => mockCacheProvider.getValue('test_address')).called(1);
      verify(() => mockCacheProvider.setObject(
            'test_address',
            any(
                that: predicate<List<dynamic>>((list) =>
                    list.length == 2 &&
                    list.contains('keep_hash') &&
                    list.contains('another_keep_hash') &&
                    !list.contains('remove_hash1') &&
                    !list.contains('remove_hash2'))),
          )).called(1);
    });
  });

  group('updateAttachToUtxoCache', () {
    test('should not modify cache for non-AttachToUtxo events', () async {
      // Arrange
      final events = [
        VerboseEvent(
          state: EventStateConfirmed(blockHeight: 1, blockTime: 1),
          eventIndex: 1,
          event: 'OTHER_EVENT',
          txHash: 'hash1',
          blockIndex: 1,
          blockTime: 1,
        )
      ];
      const address = 'test_address';
      when(() => mockCacheProvider.getValue(any())).thenReturn(['hash1']);

      // Act
      await EventsRepositoryImpl.updateAttachToUtxoCache(
        events,
        [address],
        mockCacheProvider,
      );

      // Assert
      verify(() => mockCacheProvider.getValue(address)).called(1);
      verifyNever(() => mockCacheProvider.setObject(any(), any()));
      verifyNever(() => mockCacheProvider.remove(any()));
    });

    test('should update cache once when multiple confirmed events are found',
        () async {
      // Arrange
      final events = [
        api.VerboseAttachToUtxoEvent(
          eventIndex: 1,
          event: 'ATTACH_TO_UTXO',
          txHash: 'remove_hash1',
          blockIndex: 1,
          blockTime: 1,
          params: createMockParams('remove_hash1'),
        ),
        api.VerboseAttachToUtxoEvent(
          eventIndex: 2,
          event: 'ATTACH_TO_UTXO',
          txHash: 'remove_hash2',
          blockIndex: 2,
          blockTime: 2,
          params: createMockParams('remove_hash2'),
        ),
      ].map((e) => VerboseAttachToUtxoEventMapper.toDomain(e)).toList();

      const address = 'test_address';
      final cachedHashes = [
        'keep_hash',
        'remove_hash1',
        'remove_hash2',
        'another_keep_hash'
      ];
      when(() => mockCacheProvider.getValue(address)).thenReturn(cachedHashes);

      // Act
      await EventsRepositoryImpl.updateAttachToUtxoCache(
        events,
        [address],
        mockCacheProvider,
      );

      // Assert
      verify(() => mockCacheProvider.getValue(address)).called(1);
      verify(() => mockCacheProvider.setObject(
            address,
            any(
                that: predicate<List<dynamic>>((list) =>
                    list.length == 2 &&
                    list.contains('keep_hash') &&
                    list.contains('another_keep_hash') &&
                    !list.contains('remove_hash1') &&
                    !list.contains('remove_hash2'))),
          )).called(1);
      verifyNever(() => mockCacheProvider.remove(any()));
    });

    test('should remove cache entry when all txHashes are confirmed', () async {
      // Arrange
      final events = [
        api.VerboseAttachToUtxoEvent(
          eventIndex: 1,
          event: 'ATTACH_TO_UTXO',
          txHash: 'hash1',
          blockIndex: 1,
          blockTime: 1,
          params: createMockParams('hash1'),
        ),
      ].map((e) => VerboseAttachToUtxoEventMapper.toDomain(e)).toList();

      const address = 'test_address';
      when(() => mockCacheProvider.getValue(address)).thenReturn(['hash1']);

      // Act
      await EventsRepositoryImpl.updateAttachToUtxoCache(
        events,
        [address],
        mockCacheProvider,
      );

      // Assert
      verify(() => mockCacheProvider.getValue(address)).called(1);
      verify(() => mockCacheProvider.remove(address)).called(1);
      verifyNever(() => mockCacheProvider.setObject(any(), any()));
    });

    test('should early return when no confirmed txHashes are found', () async {
      // Arrange
      final events = [
        api.VerboseAttachToUtxoEvent(
          eventIndex: 1,
          event: 'ATTACH_TO_UTXO',
          txHash: 'hash1',
          blockIndex: null, // Makes it a mempool event
          blockTime: null,
          params: createMockParams('hash1'),
        ),
      ].map((e) => VerboseAttachToUtxoEventMapper.toDomain(e)).toList();

      const address = 'test_address';
      when(() => mockCacheProvider.getValue(address)).thenReturn(['hash1']);

      // Act
      await EventsRepositoryImpl.updateAttachToUtxoCache(
        events,
        [address],
        mockCacheProvider,
      );

      // Assert
      verify(() => mockCacheProvider.getValue(address)).called(1);
      verifyNever(() => mockCacheProvider.setObject(any(), any()));
      verifyNever(() => mockCacheProvider.remove(any()));
    });
  });

  group('multiple addresses', () {
    test('getByAddressesVerbose returns events for multiple addresses',
        () async {
      // Arrange
      final addresses = ['addr1', 'addr2', 'addr3'];

      final apiEvents = [
        // Events for addr1
        api.VerboseDispenseEvent(
          eventIndex: 1,
          event: 'DISPENSE',
          txHash: 'hash1',
          blockIndex: 1,
          blockTime: 1,
          params: api.VerboseDispenseParams(
            asset: 'TEST1',
            blockIndex: 1,
            destination: 'addr1',
            source: 'source',
            txHash: 'hash1',
            txIndex: 1,
            btcAmount: 100,
            dispenseIndex: 1,
            dispenseQuantity: 100,
            dispenserTxHash: 'hash1',
            btcAmountNormalized: '100',
            dispenseQuantityNormalized: '100',
          ),
        ),
        // Events for addr2
        api.VerboseAssetIssuanceEvent(
          eventIndex: 2,
          event: 'ASSET_ISSUANCE',
          txHash: 'hash2',
          blockIndex: 2,
          blockTime: 2,
          params: api.VerboseAssetIssuanceParams(
            asset: 'TEST2',
            assetEvents: 'reset',
            assetLongname: 'Test Asset 2',
            quantity: 1000,
            source: 'addr2',
            status: 'valid',
            transfer: false,
            quantityNormalized: '1000',
            feePaidNormalized: '0.001',
            blockTime: 2,
          ),
        ),
        // Events for addr3
        api.VerboseAttachToUtxoEvent(
          eventIndex: 3,
          event: 'ATTACH_TO_UTXO',
          txHash: 'hash3',
          blockIndex: 3,
          blockTime: 3,
          params: api.VerboseAttachToUtxoParams(
            asset: 'TEST3',
            blockIndex: 3,
            destination: 'addr3',
            feePaid: 100,
            quantityNormalized: '100',
            feePaidNormalized: '100',
            msgIndex: 1,
            blockTime: 3,
            source: 'source',
            status: 'valid',
            txHash: 'hash3',
            txIndex: 1,
            quantity: 100,
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
      when(() => response.resultCount).thenReturn(apiEvents.length);

      when(() => mockApi.getEventsByAddressesVerbose(
            'addr1,addr2,addr3',
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => response);

      // Act
      final result = await repository.getByAddressesVerbose(
        addresses: addresses,
        limit: 10,
        cursor: Cursor.fromInt(1),
      );

      // Assert
      verify(() => mockApi.getEventsByAddressesVerbose(
            'addr1,addr2,addr3',
            any(that: isA<cursor_model.CursorModel>()),
            10,
            null,
          )).called(1);

      // Verify we got all events
      expect(result.$1.length, 3);
      expect(result.$3, 3); // resultCount should be 3

      // Verify events are mapped correctly
      final events = result.$1;
      expect(events[0].event, equals('DISPENSE'));
      expect(events[0].txHash, equals('hash1'));
      expect(events[1].event, equals('ASSET_ISSUANCE'));
      expect(events[1].txHash, equals('hash2'));
      expect(events[2].event, equals('ATTACH_TO_UTXO'));
      expect(events[2].txHash, equals('hash3'));

      // Verify event states
      for (var event in events) {
        expect(event.state, isA<EventStateConfirmed>());
        expect(event.blockIndex, isNotNull);
      }
    });
  });
}
