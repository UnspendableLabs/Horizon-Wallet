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

    resetBloc = ResetBloc(
      walletRepository: mockWalletRepository,
      accountRepository: mockAccountRepository,
      addressRepository: mockAddressRepository,
      importedAddressRepository: mockImportedAddressRepository,
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

      blocTest<ResetBloc, ResetState>(
        'handles wallet repository failure gracefully',
        build: () {
          when(() => mockWalletRepository.deleteAllWallets())
              .thenThrow(Exception('Failed to delete wallets'));

          return resetBloc;
        },
        act: (bloc) => bloc.add(ResetEvent()),
        expect: () => [
          const ResetState(
            status: ResetStatus.error,
            errorMessage: 'Exception: Failed to delete wallets',
          ),
        ],
        verify: (_) {
          verify(() => mockWalletRepository.deleteAllWallets()).called(1);
          verifyNever(() => mockAccountRepository.deleteAllAccounts());
          verifyNever(() => mockAddressRepository.deleteAllAddresses());
          verifyNever(
              () => mockImportedAddressRepository.deleteAllImportedAddresses());
        },
      );

      blocTest<ResetBloc, ResetState>(
        'handles account repository failure gracefully',
        build: () {
          when(() => mockWalletRepository.deleteAllWallets())
              .thenAnswer((_) async => {});
          when(() => mockAccountRepository.deleteAllAccounts())
              .thenThrow(Exception('Failed to delete accounts'));

          return resetBloc;
        },
        act: (bloc) => bloc.add(ResetEvent()),
        expect: () => [
          const ResetState(
            status: ResetStatus.error,
            errorMessage: 'Exception: Failed to delete accounts',
          ),
        ],
        verify: (_) {
          verify(() => mockWalletRepository.deleteAllWallets()).called(1);
          verify(() => mockAccountRepository.deleteAllAccounts()).called(1);
          verifyNever(() => mockAddressRepository.deleteAllAddresses());
          verifyNever(
              () => mockImportedAddressRepository.deleteAllImportedAddresses());
        },
      );

      blocTest<ResetBloc, ResetState>(
        'handles address repository failure gracefully',
        build: () {
          when(() => mockWalletRepository.deleteAllWallets())
              .thenAnswer((_) async => {});
          when(() => mockAccountRepository.deleteAllAccounts())
              .thenAnswer((_) async => {});
          when(() => mockAddressRepository.deleteAllAddresses())
              .thenThrow(Exception('Failed to delete addresses'));

          return resetBloc;
        },
        act: (bloc) => bloc.add(ResetEvent()),
        expect: () => [
          const ResetState(
            status: ResetStatus.error,
            errorMessage: 'Exception: Failed to delete addresses',
          ),
        ],
        verify: (_) {
          verify(() => mockWalletRepository.deleteAllWallets()).called(1);
          verify(() => mockAccountRepository.deleteAllAccounts()).called(1);
          verify(() => mockAddressRepository.deleteAllAddresses()).called(1);
          verifyNever(
              () => mockImportedAddressRepository.deleteAllImportedAddresses());
        },
      );

      blocTest<ResetBloc, ResetState>(
        'handles imported address repository failure gracefully',
        build: () {
          when(() => mockWalletRepository.deleteAllWallets())
              .thenAnswer((_) async => {});
          when(() => mockAccountRepository.deleteAllAccounts())
              .thenAnswer((_) async => {});
          when(() => mockAddressRepository.deleteAllAddresses())
              .thenAnswer((_) async => {});
          when(() => mockImportedAddressRepository.deleteAllImportedAddresses())
              .thenThrow(Exception('Failed to delete imported addresses'));

          return resetBloc;
        },
        act: (bloc) => bloc.add(ResetEvent()),
        expect: () => [
          const ResetState(
            status: ResetStatus.error,
            errorMessage: 'Exception: Failed to delete imported addresses',
          ),
        ],
        verify: (_) {
          verify(() => mockWalletRepository.deleteAllWallets()).called(1);
          verify(() => mockAccountRepository.deleteAllAccounts()).called(1);
          verify(() => mockAddressRepository.deleteAllAddresses()).called(1);
          verify(() =>
                  mockImportedAddressRepository.deleteAllImportedAddresses())
              .called(1);
          verifyNever(() => mockInMemoryKeyRepository.delete());
        },
      );

      blocTest<ResetBloc, ResetState>(
        'handles in memory key repository failure gracefully',
        build: () {
          when(() => mockWalletRepository.deleteAllWallets())
              .thenAnswer((_) async => {});
          when(() => mockAccountRepository.deleteAllAccounts())
              .thenAnswer((_) async => {});
          when(() => mockAddressRepository.deleteAllAddresses())
              .thenAnswer((_) async => {});
          when(() => mockImportedAddressRepository.deleteAllImportedAddresses())
              .thenAnswer((_) async => {});
          when(() => mockInMemoryKeyRepository.delete())
              .thenThrow(Exception('Failed to delete in memory key'));

          return resetBloc;
        },
        act: (bloc) => bloc.add(ResetEvent()),
        expect: () => [
          const ResetState(
            status: ResetStatus.error,
            errorMessage: 'Exception: Failed to delete in memory key',
          ),
        ],
        verify: (_) {
          verify(() => mockWalletRepository.deleteAllWallets()).called(1);
          verify(() => mockAccountRepository.deleteAllAccounts()).called(1);
          verify(() => mockAddressRepository.deleteAllAddresses()).called(1);
          verify(() =>
                  mockImportedAddressRepository.deleteAllImportedAddresses())
              .called(1);
          verify(() => mockInMemoryKeyRepository.delete()).called(1);
          verifyNever(
              () => mockSecureKVService.delete(key: kInactivityDeadlineKey));
        },
      );

      blocTest<ResetBloc, ResetState>(
        'handles secure kv service failure gracefully',
        build: () {
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
              .thenThrow(Exception('Failed to delete kv service key'));

          return resetBloc;
        },
        act: (bloc) => bloc.add(ResetEvent()),
        expect: () => [
          const ResetState(
            status: ResetStatus.error,
            errorMessage: 'Exception: Failed to delete kv service key',
          ),
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
          verifyNever(() => mockCacheProvider.getBool("isDarkMode"));
        },
      );

      blocTest<ResetBloc, ResetState>(
        'handles cache provider failure gracefully',
        build: () {
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
          when(() => mockCacheProvider.getBool("isDarkMode"))
              .thenThrow(Exception('Failed to get dark mode'));

          return resetBloc;
        },
        act: (bloc) => bloc.add(ResetEvent()),
        expect: () => [
          const ResetState(
            status: ResetStatus.error,
            errorMessage: 'Exception: Failed to get dark mode',
          ),
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
          verifyNever(() => mockCacheProvider.removeAll());
        },
      );

      blocTest<ResetBloc, ResetState>(
        'handles analytics service failure gracefully',
        build: () {
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
          when(() => mockAnalyticsService.reset())
              .thenThrow(Exception('Failed to reset analytics'));

          return resetBloc;
        },
        act: (bloc) => bloc.add(ResetEvent()),
        expect: () => [
          const ResetState(
            status: ResetStatus.error,
            errorMessage: 'Exception: Failed to reset analytics',
          ),
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
          verifyNever(() => mockCacheProvider.setBool("isDarkMode", true));
        },
      );
    });
  });
}
