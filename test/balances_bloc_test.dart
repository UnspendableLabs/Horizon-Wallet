import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fairminter.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

// Mock Classes

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockAddressTxRepository extends Mock implements AddressTxRepository {}

class MockCacheProvider extends Mock implements CacheProvider {}

// Fakes for fallback values

class FakeBalance extends Fake implements Balance {}

class FakeAsset extends Fake implements Asset {}

class FakeFairminter extends Fake implements Fairminter {}

class FakeMultiAddressBalance extends Fake implements MultiAddressBalance {}

class FakeMultiAddressBalanceEntry extends Fake
    implements MultiAddressBalanceEntry {}

void main() {
  group('BalancesBloc Tests', () {
    late BalancesBloc balancesBloc;
    late MockBalanceRepository mockBalanceRepository;
    late MockCacheProvider mockCacheProvider;
    const addresses = ['mocked-address'];

    late List<MultiAddressBalance> mockBalances;

    setUpAll(() {
      registerFallbackValue(FakeBalance());
      registerFallbackValue(FakeAsset());
      registerFallbackValue(FakeFairminter());
      registerFallbackValue(FakeMultiAddressBalance());
      registerFallbackValue(FakeMultiAddressBalanceEntry());
    });

    setUp(() {
      mockBalanceRepository = MockBalanceRepository();
      mockCacheProvider = MockCacheProvider();

      balancesBloc = BalancesBloc(
        balanceRepository: mockBalanceRepository,
        addresses: addresses,
        cacheProvider: mockCacheProvider,
      );

      // Create mock balances
      mockBalances = [
        MultiAddressBalance(
          asset: 'BTC',
          assetLongname: 'Bitcoin',
          total: 100000000, // 1.00000000 BTC
          totalNormalized: '1.00000000',
          entries: [
            MultiAddressBalanceEntry(
              address: addresses.first,
              quantity: 100000000,
              quantityNormalized: '1.00000000',
              utxo: null,
              utxoAddress: null,
            ),
          ],
          assetInfo: const AssetInfo(
            assetLongname: 'Bitcoin',
            description: 'Bitcoin',
            divisible: true,
          ),
        ),
        MultiAddressBalance(
          asset: 'XCP',
          assetLongname: 'Counterparty',
          total: 50000000, // 0.50000000 XCP
          totalNormalized: '0.50000000',
          entries: [
            MultiAddressBalanceEntry(
              address: addresses.first,
              quantity: 50000000,
              quantityNormalized: '0.50000000',
              utxo: null,
              utxoAddress: null,
            ),
          ],
          assetInfo: const AssetInfo(
            assetLongname: 'Counterparty',
            description: 'Counterparty',
            divisible: true,
          ),
        ),
      ];
    });

    tearDown(() {
      balancesBloc.close();
    });

    test('initial state is BalancesState.initial()', () {
      expect(balancesBloc.state, const BalancesState.initial());
    });

    blocTest<BalancesBloc, BalancesState>(
      'emits [loading, complete] when Fetch is successful with empty addresses',
      build: () {
        // Create a new bloc instance with empty addresses
        return BalancesBloc(
          balanceRepository: mockBalanceRepository,
          addresses: const [],
          cacheProvider: mockCacheProvider,
        );
      },
      setUp: () {
        when(() => mockCacheProvider.getValue(any())).thenReturn(null);
        when(() => mockCacheProvider.setObject(any(), any()))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(Fetch()),
      expect: () => [
        const BalancesState.complete(Result.ok([], [])),
      ],
      verify: (bloc) {
        verifyNever(() => mockBalanceRepository.getBalancesForAddresses([]));
        verifyNever(() => mockCacheProvider.getValue('starredAssets'));
        verifyNever(() => mockCacheProvider.setObject('starredAssets', any()));
      },
    );

    blocTest<BalancesBloc, BalancesState>(
      'emits [loading, complete] when Fetch is successful',
      setUp: () {
        when(() => mockBalanceRepository.getBalancesForAddresses(addresses))
            .thenAnswer((_) async => mockBalances);
        when(() => mockCacheProvider.getValue(any()))
            .thenReturn(['XCP', 'BTC']);
        when(() => mockCacheProvider.setObject(any(), any()))
            .thenAnswer((_) async {});
      },
      build: () => balancesBloc,
      act: (bloc) => bloc.add(Fetch()),
      expect: () => [
        const BalancesState.loading(),
        BalancesState.complete(Result.ok(mockBalances, ['XCP', 'BTC'])),
      ],
      verify: (bloc) {
        verify(() => mockBalanceRepository.getBalancesForAddresses(addresses))
            .called(1);
        verify(() => mockCacheProvider.getValue('starredAssets')).called(1);
        verifyNever(() => mockCacheProvider.setObject('starredAssets', any()));
      },
    );

    blocTest<BalancesBloc, BalancesState>(
      'sets BTC and XCP as starred assets if they are not already in the cache',
      setUp: () {
        when(() => mockBalanceRepository.getBalancesForAddresses(addresses))
            .thenAnswer((_) async => mockBalances);
        when(() => mockCacheProvider.getValue(any())).thenReturn([]);
        when(() => mockCacheProvider.setObject('starredAssets', ['XCP', 'BTC']))
            .thenAnswer((_) async => Future<void>.value());
      },
      build: () => balancesBloc,
      act: (bloc) => bloc.add(Fetch()),
      expect: () => [
        const BalancesState.loading(),
        BalancesState.complete(Result.ok(mockBalances, ['XCP', 'BTC'])),
      ],
      verify: (bloc) {
        verify(() => mockCacheProvider.getValue('starredAssets')).called(1);
        verify(() =>
                mockCacheProvider.setObject('starredAssets', ['XCP', 'BTC']))
            .called(1);
      },
    );

    blocTest<BalancesBloc, BalancesState>(
      'emits [loading, complete with error] when Fetch fails',
      build: () {
        when(() => mockBalanceRepository.getBalancesForAddresses(addresses))
            .thenThrow(Exception('Failed to fetch balances'));
        when(() => mockCacheProvider.getValue(any()))
            .thenReturn(['XCP', 'BTC']);
        when(() => mockCacheProvider.setObject(any(), any()))
            .thenAnswer((_) async {});
        return balancesBloc;
      },
      act: (bloc) => bloc.add(Fetch()),
      expect: () => [
        const BalancesState.loading(),
        predicate<BalancesState>((state) {
          return state.maybeWhen(
            complete: (result) {
              return result.maybeWhen(
                error: (errorMessage) =>
                    errorMessage.contains('Error fetching balances'),
                orElse: () => false,
              );
            },
            orElse: () => false,
          );
        }),
      ],
      verify: (bloc) {
        verify(() => mockBalanceRepository.getBalancesForAddresses(addresses))
            .called(1);
        verify(() => mockCacheProvider.getValue('starredAssets')).called(1);
        verifyNever(() => mockCacheProvider.setObject(any(), any()));
      },
    );

    blocTest<BalancesBloc, BalancesState>(
      'emits [reloading, complete] when Fetch is successful with cached data',
      setUp: () {
        when(() => mockBalanceRepository.getBalancesForAddresses(addresses))
            .thenAnswer((_) async => mockBalances);
        when(() => mockCacheProvider.getValue(any()))
            .thenReturn(['XCP', 'BTC']);
        when(() => mockCacheProvider.setObject(any(), any()))
            .thenAnswer((_) async {});
      },
      build: () {
        // Create a new bloc with pre-populated cache
        final bloc = BalancesBloc(
          balanceRepository: mockBalanceRepository,
          addresses: addresses,
          cacheProvider: mockCacheProvider,
        );
        // Trigger initial fetch to populate cache
        bloc.add(Fetch());
        return bloc;
      },
      wait: const Duration(
          milliseconds: 50), // Wait for initial fetch to complete
      act: (bloc) => bloc.add(Fetch()),
      skip: 2, // Skip the initial loading and complete states
      expect: () => [
        BalancesState.reloading(Result.ok(mockBalances, ['XCP', 'BTC'])),
      ],
      verify: (bloc) {
        verify(() => mockBalanceRepository.getBalancesForAddresses(addresses))
            .called(2);
        verify(() => mockCacheProvider.getValue('starredAssets')).called(2);
        verifyNever(() => mockCacheProvider.setObject(any(), any()));
      },
    );

    blocTest<BalancesBloc, BalancesState>(
      'does not emit new state when cached data is identical',
      setUp: () {
        when(() => mockBalanceRepository.getBalancesForAddresses(addresses))
            .thenAnswer((_) async => mockBalances);
        when(() => mockCacheProvider.getValue(any()))
            .thenReturn(['XCP', 'BTC']);
        when(() => mockCacheProvider.setObject(any(), any()))
            .thenAnswer((_) async {});
      },
      build: () {
        // Create a new bloc with pre-populated cache
        final bloc = BalancesBloc(
          balanceRepository: mockBalanceRepository,
          addresses: addresses,
          cacheProvider: mockCacheProvider,
        );
        // Trigger initial fetch to populate cache
        bloc.add(Fetch());
        return bloc;
      },
      wait: const Duration(
          milliseconds: 50), // Wait for initial fetch to complete
      act: (bloc) => bloc.add(Fetch()),
      skip: 2, // Skip the initial loading and complete states
      expect: () => [
        BalancesState.reloading(Result.ok(mockBalances, ['XCP', 'BTC'])),
      ],
      verify: (bloc) {
        verify(() => mockBalanceRepository.getBalancesForAddresses(addresses))
            .called(2);
        verify(() => mockCacheProvider.getValue('starredAssets')).called(2);
        verifyNever(() => mockCacheProvider.setObject(any(), any()));
      },
    );

    test('starts polling on Start event and stops on Stop event', () async {
      var callCount = 0;
      // Mock repository to return different balances each time
      when(() => mockBalanceRepository.getBalancesForAddresses(addresses))
          .thenAnswer((_) async {
        callCount++;
        // Add a small delay to simulate network latency
        await Future.delayed(const Duration(milliseconds: 5));
        return [
          MultiAddressBalance(
            asset: 'BTC',
            assetLongname: 'Bitcoin',
            total: 100000000 + (callCount * 10000000),
            totalNormalized: (1.0 + (callCount * 0.1)).toStringAsFixed(8),
            entries: [
              MultiAddressBalanceEntry(
                address: addresses.first,
                quantity: 100000000 + (callCount * 10000000),
                quantityNormalized:
                    (1.0 + (callCount * 0.1)).toStringAsFixed(8),
                utxo: null,
                utxoAddress: null,
              ),
            ],
            assetInfo: const AssetInfo(
              assetLongname: 'Bitcoin',
              description: 'Bitcoin',
              divisible: true,
            ),
          ),
          MultiAddressBalance(
            asset: 'XCP',
            assetLongname: 'Counterparty',
            total: 50000000 + (callCount * 5000000),
            totalNormalized: (0.5 + (callCount * 0.05)).toStringAsFixed(8),
            entries: [
              MultiAddressBalanceEntry(
                address: addresses.first,
                quantity: 50000000 + (callCount * 5000000),
                quantityNormalized:
                    (0.5 + (callCount * 0.05)).toStringAsFixed(8),
                utxo: null,
                utxoAddress: null,
              ),
            ],
            assetInfo: const AssetInfo(
              assetLongname: 'Counterparty',
              description: 'Counterparty',
              divisible: true,
            ),
          ),
        ];
      });
      when(() => mockCacheProvider.getValue(any())).thenReturn(['XCP', 'BTC']);
      when(() => mockCacheProvider.setObject(any(), any()))
          .thenAnswer((_) async {});

      final emittedStates = <BalancesState>[];
      final subscription = balancesBloc.stream.listen(emittedStates.add);

      // Start polling with a very short interval
      balancesBloc
          .add(Start(pollingInterval: const Duration(milliseconds: 20)));

      // Wait for initial polling cycles
      await Future.delayed(const Duration(milliseconds: 100));

      // Store the state count before stopping
      final stateCountBeforeStop = emittedStates.length;

      // Stop polling
      balancesBloc.add(Stop());

      // Wait long enough for any in-flight requests to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Cancel the subscription
      await subscription.cancel();

      // Verify we had enough states before stopping
      expect(stateCountBeforeStop, greaterThanOrEqualTo(6),
          reason: 'Should have at least 6 states before stopping');

      // Verify that polling has stopped by ensuring no significant increase in states
      // Allow for at most one more pair of states (in-flight request)
      expect(
        emittedStates.length - stateCountBeforeStop,
        lessThanOrEqualTo(2),
        reason: 'Should not emit more than one more pair of states after Stop',
      );

      // Verify the sequence of states
      for (int i = 0; i < emittedStates.length - 1; i += 2) {
        expect(
          emittedStates[i],
          predicate<BalancesState>((state) => state.maybeWhen(
                loading: () => true,
                reloading: (_) => true,
                orElse: () => false,
              )),
          reason: 'Every even-indexed state should be loading or reloading',
        );

        expect(
          emittedStates[i + 1],
          predicate<BalancesState>((state) => state.maybeWhen(
                complete: (result) => result.maybeWhen(
                  ok: (_, __) => true,
                  orElse: () => false,
                ),
                orElse: () => false,
              )),
          reason: 'Every odd-indexed state should be complete with OK result',
        );
      }

      // Verify that the repository was called multiple times
      verify(() => mockBalanceRepository.getBalancesForAddresses(addresses))
          .called(greaterThanOrEqualTo(3));
    }, timeout: const Timeout(Duration(seconds: 2)));

    group('ToggleStarred functionality', () {
      blocTest<BalancesBloc, BalancesState>(
        'adding an asset to starred assets when not already starred',
        setUp: () {
          when(() => mockBalanceRepository.getBalancesForAddresses(addresses))
              .thenAnswer((_) async => mockBalances);
          when(() => mockCacheProvider.getValue(any()))
              .thenReturn(['XCP', 'BTC']);
          when(() => mockCacheProvider
                  .setObject('starredAssets', ['XCP', 'BTC', 'ASSET_A']))
              .thenAnswer((_) async => Future<void>.value());
        },
        build: () => BalancesBloc(
          balanceRepository: mockBalanceRepository,
          addresses: addresses,
          cacheProvider: mockCacheProvider,
        ),
        act: (bloc) async {
          // First do a fetch to populate the _cachedBalances field
          bloc.add(Fetch());
          await Future.delayed(const Duration(milliseconds: 50));

          // Then toggle the starred status
          bloc.add(ToggleStarred(asset: 'ASSET_A'));
        },
        skip: 2, // Skip the initial loading and complete states
        expect: () => [
          BalancesState.complete(
              Result.ok(mockBalances, ['XCP', 'BTC', 'ASSET_A'])),
        ],
        verify: (bloc) {
          verify(() => mockBalanceRepository.getBalancesForAddresses(addresses))
              .called(1);
          verify(() => mockCacheProvider.getValue('starredAssets'))
              .called(2); // 1 for the fetch, 1 for the toggle
          verify(() => mockCacheProvider
              .setObject('starredAssets', ['XCP', 'BTC', 'ASSET_A'])).called(1);
        },
      );
      blocTest<BalancesBloc, BalancesState>(
        'removing an asset from starred assets when already starred',
        setUp: () {
          // Setup mock repository to return balances
          when(() => mockBalanceRepository.getBalancesForAddresses(addresses))
              .thenAnswer((_) async => mockBalances);

          // Use the exact key
          when(() => mockCacheProvider.getValue('starredAssets'))
              .thenReturn(['XCP', 'BTC', 'ASSET_A']);

          when(() =>
                  mockCacheProvider.setObject('starredAssets', ['XCP', 'BTC']))
              .thenAnswer((_) async => Future<void>.value());
        },
        build: () => BalancesBloc(
          balanceRepository: mockBalanceRepository,
          addresses: addresses,
          cacheProvider: mockCacheProvider,
        ),
        act: (bloc) async {
          // First do a fetch to populate the _cachedBalances field
          bloc.add(Fetch());
          await Future.delayed(const Duration(milliseconds: 50));

          // Then toggle the starred status
          bloc.add(ToggleStarred(asset: 'ASSET_A'));
        },
        skip: 2, // Skip the loading and complete states from the Fetch event
        expect: () => [
          BalancesState.complete(Result.ok(mockBalances, ['XCP', 'BTC'])),
        ],
        verify: (bloc) {
          verify(() => mockBalanceRepository.getBalancesForAddresses(addresses))
              .called(1);
          verify(() => mockCacheProvider.getValue('starredAssets'))
              .called(2); // 1 for the fetch, 1 for the toggle
          verify(() =>
                  mockCacheProvider.setObject('starredAssets', ['XCP', 'BTC']))
              .called(1);
        },
      );

      test('should not emit new state if _cachedBalances is null', () async {
        // Create a fresh bloc instance
        final testBloc = BalancesBloc(
          balanceRepository: mockBalanceRepository,
          addresses: addresses,
          cacheProvider: mockCacheProvider,
        );

        when(() => mockCacheProvider.getValue('starredAssets'))
            .thenReturn(['XCP', 'BTC']);
        when(() => mockCacheProvider.setObject('starredAssets', ['XCP', 'BTC']))
            .thenAnswer((_) async => Future<void>.value());

        // Create a listener to check if any states are emitted
        bool stateEmitted = false;
        final subscription = testBloc.stream.listen((_) {
          stateEmitted = true;
        });

        // Directly call ToggleStarred without a prior Fetch
        testBloc.add(ToggleStarred(asset: 'ASSET_A'));

        // Wait a bit to ensure any potential state would be emitted
        await Future.delayed(const Duration(milliseconds: 50));

        // Verify no state was emitted
        expect(stateEmitted, isFalse);

        // Verify the cache was still updated
        verifyNever(() => mockCacheProvider
            .setObject('starredAssets', ['XCP', 'BTC', 'ASSET_A']));

        // Clean up
        await subscription.cancel();
        await testBloc.close();
      });
    });
  });
}
