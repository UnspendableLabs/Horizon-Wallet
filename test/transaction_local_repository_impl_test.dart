import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/data/sources/local/dao/transactions_dao.dart';
import 'package:horizon/data/sources/local/db.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/data/sources/repositories/transaction_local_repository_impl.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockTransactionsDao extends Mock implements TransactionsDao {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockApi extends Mock implements api.V2Api {}

class MockCacheProvider extends Mock implements CacheProvider {}

// Fake for Transaction
class FakeTransaction extends Fake implements Transaction {
  @override
  String toString() => 'FakeTransaction';
}

void main() {
  late TransactionLocalRepositoryImpl repository;
  late MockTransactionsDao mockTransactionsDao;
  late MockAddressRepository mockAddressRepository;
  late MockApi mockApi;
  late MockCacheProvider mockCacheProvider;

  setUpAll(() {
    registerFallbackValue(FakeTransaction());
  });

  setUp(() {
    mockTransactionsDao = MockTransactionsDao();
    mockAddressRepository = MockAddressRepository();
    mockApi = MockApi();
    mockCacheProvider = MockCacheProvider();

    // Setup GetIt for CacheProvider
    GetIt.I.registerSingleton<CacheProvider>(mockCacheProvider);

    repository = TransactionLocalRepositoryImpl(
      api_: mockApi,
      transactionDao: mockTransactionsDao,
      addressRepository: mockAddressRepository,
    );

    // Setup default responses for async methods
    when(() => mockTransactionsDao.insert(any())).thenAnswer((_) async => {});
    when(() => mockCacheProvider.setObject(any(), any()))
        .thenAnswer((_) async => {});
  });

  tearDown(() {
    GetIt.I.unregister<CacheProvider>();
  });

  group('insert', () {
    test('should update cache when inserting an attach transaction', () async {
      // Arrange
      final attachInfo = TransactionInfoAttach(
        hash: 'test_hash',
        source: 'source_address',
        destination: 'dest_address',
        btcAmount: 1000,
        fee: 100,
        data: 'test_data',
        domain: TransactionInfoDomainLocal(
          raw: 'raw_tx',
          submittedAt: DateTime.now(),
        ),
        btcAmountNormalized: '0.00001000',
        unpackedData: const AttachUnpackedVerbose(
          asset: 'TEST',
          quantityNormalized: '1.0',
          destinationVout: null,
        ),
      );

      when(() => mockCacheProvider.getValue('source_address'))
          .thenReturn(['existing_hash']);

      // Act
      await repository.insert(attachInfo);

      // Assert
      verify(() => mockTransactionsDao.insert(any())).called(1);
      verify(() => mockCacheProvider.getValue('source_address')).called(1);
      verify(() => mockCacheProvider.setObject(
            'source_address',
            any(
                that: predicate<List<dynamic>>((list) =>
                    list.length == 2 &&
                    list.contains('existing_hash') &&
                    list.contains('test_hash'))),
          )).called(1);
    });

    test('should initialize cache when no previous hashes exist', () async {
      // Arrange
      final attachInfo = TransactionInfoAttach(
        hash: 'test_hash',
        source: 'source_address',
        destination: 'dest_address',
        btcAmount: 1000,
        fee: 100,
        data: 'test_data',
        domain: TransactionInfoDomainLocal(
          raw: 'raw_tx',
          submittedAt: DateTime.now(),
        ),
        btcAmountNormalized: '0.00001000',
        unpackedData: const AttachUnpackedVerbose(
          asset: 'TEST',
          quantityNormalized: '1.0',
          destinationVout: null,
        ),
      );

      when(() => mockCacheProvider.getValue('source_address')).thenReturn(null);

      // Act
      await repository.insert(attachInfo);

      // Assert
      verify(() => mockTransactionsDao.insert(any())).called(1);
      verify(() => mockCacheProvider.getValue('source_address')).called(1);
      verify(() => mockCacheProvider.setObject(
            'source_address',
            any(
                that: predicate<List<dynamic>>(
                    (list) => list.length == 1 && list.contains('test_hash'))),
          )).called(1);
    });

    test('should not update cache for non-attach transactions', () async {
      // Arrange
      final nonAttachInfo = TransactionInfoEnhancedSend(
        hash: 'test_hash',
        source: 'source_address',
        destination: 'dest_address',
        btcAmount: 1000,
        fee: 100,
        data: 'test_data',
        domain: TransactionInfoDomainLocal(
          raw: 'raw_tx',
          submittedAt: DateTime.now(),
        ),
        btcAmountNormalized: '0.00001000',
        unpackedData: const EnhancedSendUnpackedVerbose(
          asset: 'TEST',
          quantity: 1000,
          address: 'dest_address',
          memo: 'test',
          quantityNormalized: '1.0',
        ),
      );

      // Act
      await repository.insert(nonAttachInfo);

      // Assert
      verify(() => mockTransactionsDao.insert(any())).called(1);
      verifyNever(() => mockCacheProvider.getValue(any()));
      verifyNever(() => mockCacheProvider.setObject(any(), any()));
    });

    test('should throw exception for non-local transactions', () async {
      // Arrange
      final nonLocalAttachInfo = TransactionInfoAttach(
        hash: 'test_hash',
        source: 'source_address',
        destination: 'dest_address',
        btcAmount: 1000,
        fee: 100,
        data: 'test_data',
        domain: TransactionInfoDomainMempool(),
        btcAmountNormalized: '0.00001000',
        unpackedData: const AttachUnpackedVerbose(
          asset: 'TEST',
          quantityNormalized: '1.0',
          destinationVout: null,
        ),
      );

      // Act & Assert
      expect(
        () => repository.insert(nonLocalAttachInfo),
        throwsA(isA<Exception>()),
      );
      verifyNever(() => mockTransactionsDao.insert(any()));
      verifyNever(() => mockCacheProvider.getValue(any()));
      verifyNever(() => mockCacheProvider.setObject(any(), any()));
    });
  });
}
