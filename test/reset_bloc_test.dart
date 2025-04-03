import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/presentation/screens/settings/reset_wallet/bloc/reset_bloc.dart';
import 'package:horizon/presentation/screens/settings/reset_wallet/bloc/reset_event.dart';
import 'package:horizon/presentation/screens/settings/reset_wallet/bloc/reset_state.dart';
import 'package:horizon/common/constants.dart';
import 'sign_and_broadcast_transaction_usecase_test.dart';

// Mock classes
class MockWalletRepository extends Mock implements WalletRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockImportedAddressRepository extends Mock
    implements ImportedAddressRepository {}

class MockCacheProvider extends Mock implements CacheProvider {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockInMemoryKeyRepository extends Mock implements InMemoryKeyRepository {}

class MockSecureKVService extends Mock implements SecureKVService {}

void main() {
  late ResetBloc resetBloc;
  late MockWalletRepository mockWalletRepository;
  late MockAccountRepository mockAccountRepository;
  late MockAddressRepository mockAddressRepository;
  late MockImportedAddressRepository mockImportedAddressRepository;
  late MockTransactionLocalRepository mockTransactionLocalRepository;
  late MockCacheProvider mockCacheProvider;
  late MockAnalyticsService mockAnalyticsService;
  late MockInMemoryKeyRepository mockInMemoryKeyRepository;
  late MockSecureKVService mockSecureKVService;

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    mockAccountRepository = MockAccountRepository();
    mockAddressRepository = MockAddressRepository();
    mockImportedAddressRepository = MockImportedAddressRepository();
    mockCacheProvider = MockCacheProvider();
    mockAnalyticsService = MockAnalyticsService();
    mockInMemoryKeyRepository = MockInMemoryKeyRepository();
    mockSecureKVService = MockSecureKVService();
    mockTransactionLocalRepository = MockTransactionLocalRepository();
    resetBloc = ResetBloc(
      walletRepository: mockWalletRepository,
      accountRepository: mockAccountRepository,
      addressRepository: mockAddressRepository,
      importedAddressRepository: mockImportedAddressRepository,
      transactionLocalRepository: mockTransactionLocalRepository,
      cacheProvider: mockCacheProvider,
      analyticsService: mockAnalyticsService,
      inMemoryKeyRepository: mockInMemoryKeyRepository,
      kvService: mockSecureKVService,
    );
  });

  tearDown(() {
    resetBloc.close();
  });

  group('ResetBloc', () {
    test('initial state is ResetState with initial status', () {
      expect(resetBloc.state, const ResetState(status: ResetStatus.initial));
    });

    group('ResetEvent', () {
      blocTest<ResetBloc, ResetState>(
        'emits [ResetState(completed)] when reset is successful',
        build: () {
          // Setup successful repository calls
          when(() => mockWalletRepository.deleteAllWallets())
              .thenAnswer((_) async => {});
          when(() => mockAccountRepository.deleteAllAccounts())
              .thenAnswer((_) async => {});
          when(() => mockAddressRepository.deleteAllAddresses())
              .thenAnswer((_) async => {});
          when(() => mockImportedAddressRepository.deleteAllImportedAddresses())
              .thenAnswer((_) async => {});
          when(() => mockInMemoryKeyRepository.delete())
              .thenAnswer((_) async => {});
          when(() => mockSecureKVService.delete(key: kInactivityDeadlineKey))
              .thenAnswer((_) async => {});
          when(() => mockCacheProvider.getBool("isDarkMode")).thenReturn(true);
          when(() => mockCacheProvider.removeAll()).thenAnswer((_) async => {});
          when(() => mockCacheProvider.setBool("isDarkMode", true))
              .thenAnswer((_) async => {});
          when(() => mockAnalyticsService.reset()).thenAnswer((_) async => {});

          return resetBloc;
        },
        act: (bloc) => bloc.add(ResetEvent()),
        expect: () => [
          const ResetState(status: ResetStatus.completed),
        ],
        verify: (_) {
          verify(() => mockWalletRepository.deleteAllWallets()).called(1);
          verify(() => mockAccountRepository.deleteAllAccounts()).called(1);
          verify(() => mockAddressRepository.deleteAllAddresses()).called(1);
          verify(() =>
                  mockImportedAddressRepository.deleteAllImportedAddresses())
              .called(1);
          verify(() => mockInMemoryKeyRepository.delete()).called(1);
          verify(() => mockSecureKVService.delete(key: kInactivityDeadlineKey))
              .called(1);
          verify(() => mockCacheProvider.getBool("isDarkMode")).called(1);
          verify(() => mockCacheProvider.removeAll()).called(1);
          verify(() => mockAnalyticsService.reset()).called(1);
          verify(() => mockCacheProvider.setBool("isDarkMode", true)).called(1);
        },
      );

      blocTest<ResetBloc, ResetState>(
        'preserves dark mode setting when isDarkMode is false',
        build: () {
          // Setup successful repository calls with dark mode false
          when(() => mockWalletRepository.deleteAllWallets())
              .thenAnswer((_) async => {});
          when(() => mockAccountRepository.deleteAllAccounts())
              .thenAnswer((_) async => {});
          when(() => mockAddressRepository.deleteAllAddresses())
              .thenAnswer((_) async => {});
          when(() => mockImportedAddressRepository.deleteAllImportedAddresses())
              .thenAnswer((_) async => {});
          when(() => mockInMemoryKeyRepository.delete())
              .thenAnswer((_) async => {});
          when(() => mockSecureKVService.delete(key: kInactivityDeadlineKey))
              .thenAnswer((_) async => {});
          when(() => mockCacheProvider.getBool("isDarkMode")).thenReturn(false);
          when(() => mockCacheProvider.removeAll()).thenAnswer((_) async => {});
          when(() => mockCacheProvider.setBool("isDarkMode", false))
              .thenAnswer((_) async => {});
          when(() => mockAnalyticsService.reset()).thenAnswer((_) async => {});

          return resetBloc;
        },
        act: (bloc) => bloc.add(ResetEvent()),
        expect: () => [
          const ResetState(status: ResetStatus.completed),
        ],
        verify: (_) {
          verify(() => mockCacheProvider.setBool("isDarkMode", false))
              .called(1);
        },
      );

      blocTest<ResetBloc, ResetState>(
        'uses default dark mode (true) when isDarkMode is null',
        build: () {
          // Setup successful repository calls with dark mode null
          when(() => mockWalletRepository.deleteAllWallets())
              .thenAnswer((_) async => {});
          when(() => mockAccountRepository.deleteAllAccounts())
              .thenAnswer((_) async => {});
          when(() => mockAddressRepository.deleteAllAddresses())
              .thenAnswer((_) async => {});
          when(() => mockImportedAddressRepository.deleteAllImportedAddresses())
              .thenAnswer((_) async => {});
          when(() => mockInMemoryKeyRepository.delete())
              .thenAnswer((_) async => {});
          when(() => mockSecureKVService.delete(key: kInactivityDeadlineKey))
              .thenAnswer((_) async => {});
          when(() => mockCacheProvider.getBool("isDarkMode")).thenReturn(null);
          when(() => mockCacheProvider.removeAll()).thenAnswer((_) async => {});
          when(() => mockCacheProvider.setBool("isDarkMode", true))
              .thenAnswer((_) async => {});
          when(() => mockAnalyticsService.reset()).thenAnswer((_) async => {});

          return resetBloc;
        },
        act: (bloc) => bloc.add(ResetEvent()),
        expect: () => [
          const ResetState(status: ResetStatus.completed),
        ],
        verify: (_) {
          verify(() => mockCacheProvider.setBool("isDarkMode", true)).called(1);
        },
      );
    });
  });
}
