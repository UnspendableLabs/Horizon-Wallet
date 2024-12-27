import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/data/sources/repositories/events_repository_impl.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:mocktail/mocktail.dart';

class MockCacheProvider extends Mock implements CacheProvider {}

class MockVerboseEvent extends Mock implements VerboseEvent {}

class MockVerboseAttachToUtxoEvent extends Mock
    implements VerboseAttachToUtxoEvent {}

void main() {
  late MockCacheProvider mockCacheProvider;

  setUp(() {
    mockCacheProvider = MockCacheProvider();
    registerFallbackValue([]);

    // Setup default responses for async methods
    when(() => mockCacheProvider.setObject(any(), any()))
        .thenAnswer((_) async => {});
    when(() => mockCacheProvider.remove(any())).thenAnswer((_) async => {});
  });

  group('CacheInvalidator', () {
    test('should not modify cache for non-AttachToUtxo events', () async {
      // Arrange
      final events = [MockVerboseEvent()];
      const address = 'test_address';

      // Act
      await CacheInvalidator.invalidateAttachToUtxoCache(
          events, address, mockCacheProvider);

      // Assert
      verifyNever(() => mockCacheProvider.getValue(any()));
      verifyNever(() => mockCacheProvider.setObject(any(), any()));
      verifyNever(() => mockCacheProvider.remove(any()));
    });

    test('should remove txHash from cache for confirmed AttachToUtxo event',
        () async {
      // Arrange
      final event = MockVerboseAttachToUtxoEvent();
      const address = 'test_address';
      const txHash = 'test_hash';
      final existingTxHashes = ['other_hash', txHash, 'another_hash'];

      when(() => event.state).thenReturn(
        EventStateConfirmed(blockHeight: 1, blockTime: 1),
      );
      when(() => event.txHash).thenReturn(txHash);
      when(() => mockCacheProvider.getValue(address))
          .thenReturn(existingTxHashes);

      // Act
      await CacheInvalidator.invalidateAttachToUtxoCache(
          [event], address, mockCacheProvider);

      // Assert
      verify(() => mockCacheProvider.setObject(
          address,
          any(
            that: predicate<List<dynamic>>((list) =>
                list.length == 2 &&
                list.contains('other_hash') &&
                list.contains('another_hash') &&
                !list.contains(txHash)),
          ))).called(1);
    });

    test('should remove cache entry when last txHash is removed', () async {
      // Arrange
      final event = MockVerboseAttachToUtxoEvent();
      const address = 'test_address';
      const txHash = 'test_hash';

      when(() => event.state).thenReturn(
        EventStateConfirmed(blockHeight: 1, blockTime: 1),
      );
      when(() => event.txHash).thenReturn(txHash);
      when(() => mockCacheProvider.getValue(address)).thenReturn([txHash]);

      // Act
      await CacheInvalidator.invalidateAttachToUtxoCache(
          [event], address, mockCacheProvider);

      // Assert
      verify(() => mockCacheProvider.remove(address)).called(1);
      verifyNever(() => mockCacheProvider.setObject(any(), any()));
    });

    test('should handle non-confirmed AttachToUtxo events', () async {
      // Arrange
      final event = MockVerboseAttachToUtxoEvent();
      const address = 'test_address';

      when(() => event.state).thenReturn(EventStateMempool());

      // Act
      await CacheInvalidator.invalidateAttachToUtxoCache(
          [event], address, mockCacheProvider);

      // Assert
      verifyNever(() => mockCacheProvider.getValue(any()));
      verifyNever(() => mockCacheProvider.setObject(any(), any()));
      verifyNever(() => mockCacheProvider.remove(any()));
    });

    test('should handle null txHash', () async {
      // Arrange
      final event = MockVerboseAttachToUtxoEvent();
      const address = 'test_address';

      when(() => event.state).thenReturn(
        EventStateConfirmed(blockHeight: 1, blockTime: 1),
      );
      when(() => event.txHash).thenReturn(null);
      when(() => mockCacheProvider.getValue(address)).thenReturn(['some_hash']);

      // Act
      await CacheInvalidator.invalidateAttachToUtxoCache(
          [event], address, mockCacheProvider);

      // Assert
      verifyNever(() => mockCacheProvider.setObject(any(), any()));
      verifyNever(() => mockCacheProvider.remove(any()));
    });
  });
}
