import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fairminter.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/fairminter_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:mocktail/mocktail.dart';

// Mock Classes

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockAssetRepository extends Mock implements AssetRepository {}

class MockFairminterRepository extends Mock implements FairminterRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockAddressTxRepository extends Mock implements AddressTxRepository {}

// Fakes for fallback values

class FakeBalance extends Fake implements Balance {}

class FakeAsset extends Fake implements Asset {}

class FakeFairminter extends Fake implements Fairminter {}

void main() {
  group('BalancesBloc Tests', () {
    late BalancesBloc balancesBloc;
    late MockBalanceRepository mockBalanceRepository;
    late MockAssetRepository mockAssetRepository;
    late MockFairminterRepository mockFairminterRepository;

    const currentAddress = 'mocked-address';

    // Declare your variables here so they are accessible in both build and expect blocks
    late List<Balance> balances;
    late List<Balance> utxoBalances;
    late List<Balance> allBalances;
    late Map<String, Balance> aggregatedBalances;
    late List<Balance> expectedUtxoBalances;
    late List<Asset> ownedAssets;
    late List<Fairminter> fairminters;

    setUpAll(() {
      registerFallbackValue(FakeBalance());
      registerFallbackValue(FakeAsset());
      registerFallbackValue(FakeFairminter());
    });

    setUp(() {
      mockBalanceRepository = MockBalanceRepository();
      mockAssetRepository = MockAssetRepository();
      mockFairminterRepository = MockFairminterRepository();

      balancesBloc = BalancesBloc(
        balanceRepository: mockBalanceRepository,
        assetRepository: mockAssetRepository,
        fairminterRepository: mockFairminterRepository,
        currentAddress: currentAddress,
        accountRepository: MockAccountRepository(),
        addressRepository: MockAddressRepository(),
        addressTxRepository: MockAddressTxRepository(),
      );
    });

    tearDown(() {
      balancesBloc.close();
    });

    test('initial state is BalancesState.initial()', () {
      expect(balancesBloc.state, const BalancesState.initial());
    });

    blocTest<BalancesBloc, BalancesState>(
      'emits [loading, complete] when Fetch is successful',
      setUp: () {
        // Initialize your variables here
        balances = <Balance>[
          Balance(
            asset: 'ASSET1',
            quantity: 100000000, // 1.00000000
            quantityNormalized: '1.00000000',
            address: currentAddress,
            assetInfo: const AssetInfo(
              assetLongname: null,
              divisible: true,
            ),
            utxo: null,
            utxoAddress: null,
          ),
          // Add more balances if needed
        ];

        utxoBalances = <Balance>[
          Balance(
            asset: 'UTXO_ASSET',
            quantity: 50000000, // 0.50000000
            quantityNormalized: '0.50000000',
            address: null,
            assetInfo: const AssetInfo(
              assetLongname: null,
              divisible: true,
            ),
            utxo: 'utxo-id',
            utxoAddress: 'utxo-address',
          ),
        ];

        ownedAssets = <Asset>[
          const Asset(
            asset: 'ASSET1',
            assetLongname: null,
            owner: currentAddress,
            issuer: null,
            divisible: true,
            locked: false,
          ),
        ];

        fairminters = <Fairminter>[
          const Fairminter(
            asset: 'FAIRMINTER1',
            txHash: 'tx-id',
            txIndex: 0,
            source: currentAddress,
            quantityByPrice: 100000000,
            hardCap: 100,
            softCap: null,
            maxMintPerTx: 10,
            premintQuantity: 100,
            startBlock: null,
            endBlock: null,
            mintedAssetCommissionInt: null,
            softCapDeadlineBlock: null,
          ),
        ];

        allBalances = [...balances, ...utxoBalances]; // Combine balances

        // Set up the mocks
        when(() => mockBalanceRepository.getBalancesForAddresses(any()))
            .thenAnswer((_) async => allBalances);

        when(() => mockAssetRepository.getValidAssetsByOwnerVerbose(any()))
            .thenAnswer((_) async => ownedAssets);

        when(() =>
                mockFairminterRepository.getFairmintersByAddress(any(), any()))
            .thenAnswer((_) => TaskEither.of(fairminters));

        // Compute expected aggregated balances
        final aggregatedAndUtxoBalances =
            aggregateAndSortBalancesByAsset(allBalances);

        aggregatedBalances = aggregatedAndUtxoBalances.$1;
        expectedUtxoBalances = aggregatedAndUtxoBalances.$2;
      },
      build: () {
        return balancesBloc;
      },
      act: (bloc) => bloc.add(Fetch()),
      expect: () => [
        const BalancesState.loading(),
        predicate<BalancesState>((state) {
          return state.maybeWhen(
            complete: (result) {
              return result.maybeWhen(
                ok: (balancesResult, aggregatedResult, utxoBalancesResult,
                    ownedAssetsResult, fairmintersResult) {
                  // Custom comparisons using helper functions
                  // Compare balances
                  if (balancesResult.length != allBalances.length) return false;
                  for (int i = 0; i < balancesResult.length; i++) {
                    if (!compareBalances(balancesResult[i], allBalances[i])) {
                      return false;
                    }
                  }

                  // Compare aggregated balances
                  if (aggregatedResult.length != aggregatedBalances.length) {
                    return false;
                  }
                  for (final key in aggregatedResult.keys) {
                    if (!aggregatedBalances.containsKey(key) ||
                        !compareBalances(
                            aggregatedResult[key]!, aggregatedBalances[key]!)) {
                      return false;
                    }
                  }

                  // Compare UTXO balances
                  if (utxoBalancesResult.length != expectedUtxoBalances.length) {
                    return false;
                  }
                  for (int i = 0; i < utxoBalancesResult.length; i++) {
                    if (!compareBalances(
                        utxoBalancesResult[i], expectedUtxoBalances[i])) {
                      return false;
                    }
                  }

                  // Compare owned assets
                  if (ownedAssetsResult.length != ownedAssets.length) {
                    return false;
                  }
                  for (int i = 0; i < ownedAssetsResult.length; i++) {
                    if (!compareAssets(ownedAssetsResult[i], ownedAssets[i])) {
                      return false;
                    }
                  }

                  // Compare fairminters
                  if (fairmintersResult.length != fairminters.length) {
                    return false;
                  }
                  for (int i = 0; i < fairmintersResult.length; i++) {
                    if (!compareFairminters(
                        fairmintersResult[i], fairminters[i])) return false;
                  }

                  return true;
                },
                orElse: () => false,
              );
            },
            orElse: () => false,
          );
        }),
      ],
      verify: (bloc) {
        verify(() => mockBalanceRepository.getBalancesForAddresses(any()))
            .called(1);
        verify(() => mockAssetRepository.getValidAssetsByOwnerVerbose(any()))
            .called(1);
        verify(() =>
                mockFairminterRepository.getFairmintersByAddress(any(), any()))
            .called(1);
      },
    );

    blocTest<BalancesBloc, BalancesState>(
      'emits [loading, complete with error] when Fetch fails in getBalances',
      build: () {
        when(() => mockBalanceRepository.getBalancesForAddresses(any()))
            .thenThrow(Exception('Failed to fetch balances'));
        // Other methods are not expected to be called
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
        verify(() => mockBalanceRepository.getBalancesForAddresses(any()))
            .called(1);
        verifyNever(
            () => mockAssetRepository.getValidAssetsByOwnerVerbose(any()));
        verifyNever(() =>
            mockFairminterRepository.getFairmintersByAddress(any(), any()));
      },
    );

    blocTest<BalancesBloc, BalancesState>(
      'emits [loading, complete with error] when Fetch fails in getFairmintersByAddress',
      setUp: () {
        // Initialize your variables and mocks as needed
        balances = <Balance>[
          Balance(
            asset: 'ASSET1',
            quantity: 100000000, // 1.00000000
            quantityNormalized: '1.00000000',
            address: currentAddress,
            assetInfo: const AssetInfo(
              assetLongname: null,
              divisible: true,
            ),
            utxo: null,
            utxoAddress: null,
          ),
        ];

        utxoBalances = <Balance>[
          Balance(
            asset: 'UTXO_ASSET',
            quantity: 50000000, // 0.50000000
            quantityNormalized: '0.50000000',
            address: null,
            assetInfo: const AssetInfo(
              assetLongname: null,
              divisible: true,
            ),
            utxo: 'utxo-id',
            utxoAddress: 'utxo-address',
          ),
        ];

        ownedAssets = <Asset>[
          const Asset(
            asset: 'ASSET1',
            assetLongname: null,
            owner: currentAddress,
            issuer: null,
            divisible: true,
            locked: false,
          ),
        ];

        allBalances = [...balances, ...utxoBalances];

        // Set up the mocks
        when(() => mockBalanceRepository.getBalancesForAddresses(any()))
            .thenAnswer((_) async => allBalances);

        when(() => mockAssetRepository.getValidAssetsByOwnerVerbose(any()))
            .thenAnswer((_) async => ownedAssets);

        // Mock failure for getFairmintersByAddress
        when(() =>
                mockFairminterRepository.getFairmintersByAddress(any(), any()))
            .thenThrow(Exception('Failed to fetch fairminters'));

        // Compute expected aggregated balances
        final aggregatedAndUtxoBalances =
            aggregateAndSortBalancesByAsset(allBalances);
        aggregatedBalances = aggregatedAndUtxoBalances.$1;
        expectedUtxoBalances = aggregatedAndUtxoBalances.$2;
      },
      build: () => balancesBloc,
      act: (bloc) => bloc.add(Fetch()),
      expect: () => [
        const BalancesState.loading(),
        predicate<BalancesState>((state) {
          return state.maybeWhen(
            complete: (result) {
              return result.maybeWhen(
                error: (errorMessage) {
                  // Adjust the assertion to match the actual error message
                  return errorMessage ==
                      'Error fetching balances for mocked-address';
                },
                orElse: () => false,
              );
            },
            orElse: () => false,
          );
        }),
      ],
      verify: (bloc) {
        verify(() => mockBalanceRepository.getBalancesForAddresses(any()))
            .called(1);
        verify(() => mockAssetRepository.getValidAssetsByOwnerVerbose(any()))
            .called(1);
        verify(() =>
                mockFairminterRepository.getFairmintersByAddress(any(), any()))
            .called(1);
      },
    );

    // Additional tests for Start and Stop events
    test('starts polling on Start event and stops on Stop event', () async {
      // Mock the repository methods to return appropriate responses
      when(() => mockBalanceRepository.getBalancesForAddresses(any()))
          .thenAnswer((_) async => []); // Return empty list
      when(() => mockAssetRepository.getValidAssetsByOwnerVerbose(any()))
          .thenAnswer((_) async => []);
      when(() => mockFairminterRepository.getFairmintersByAddress(any(), any()))
          .thenAnswer(
              (_) => TaskEither.of([])); // Assuming it returns a TaskEither

      // Collect the emitted states
      final emittedStates = <BalancesState>[];
      final subscription = balancesBloc.stream.listen(emittedStates.add);

      // Start polling
      balancesBloc
          .add(Start(pollingInterval: const Duration(milliseconds: 50)));

      // Wait enough time to allow multiple polls to occur
      await Future.delayed(const Duration(milliseconds: 160));

      // Stop polling
      balancesBloc.add(Stop());

      // Wait a bit to ensure no further states are emitted after stop
      await Future.delayed(const Duration(milliseconds: 100));

      // Cancel the subscription
      await subscription.cancel();

      // Verify that states were emitted multiple times due to polling
      // For 160ms with polling interval of 50ms, we expect approximately 3 cycles

      // Check that at least three cycles of Loading/Reloading and Complete were emitted
      expect(emittedStates.length, greaterThanOrEqualTo(6));

      // Verify the sequence of states
      for (int i = 0; i < emittedStates.length; i += 2) {
        // Expect a loading or reloading state
        expect(
          emittedStates[i],
          predicate<BalancesState>((state) {
            return state.maybeWhen(
              loading: () => true,
              reloading: (_) => true,
              orElse: () => false,
            );
          }),
        );
        // Expect a complete state with OK result
        expect(
          emittedStates[i + 1],
          predicate<BalancesState>((state) {
            return state.maybeWhen(
              complete: (result) {
                return result.maybeWhen(
                  ok: (_, __, ___, ____, _____) => true,
                  orElse: () => false,
                );
              },
              orElse: () => false,
            );
          }),
        );
      }

      // Verify that the repositories' methods were called multiple times
      verify(() => mockBalanceRepository.getBalancesForAddresses(any()))
          .called(greaterThanOrEqualTo(3));
      verify(() => mockAssetRepository.getValidAssetsByOwnerVerbose(any()))
          .called(greaterThanOrEqualTo(3));
      verify(() =>
              mockFairminterRepository.getFairmintersByAddress(any(), any()))
          .called(greaterThanOrEqualTo(3));
    });
  });
  group('aggregateBalancesByAsset', () {
    test('should return empty maps when given empty list', () {
      final result = aggregateBalancesByAsset([]);
      expect(result.$1, isEmpty);
      expect(result.$2, isEmpty);
    });

    test('should correctly aggregate single balance', () {
      final balance = Balance(
        address: 'addr1',
        quantity: 100,
        quantityNormalized: '1.00000000',
        asset: 'BTC',
        assetInfo: const AssetInfo(
          divisible: true,
          description: 'Bitcoin',
          assetLongname: 'Bitcoin',
          issuer: 'satoshi',
        ),
      );

      final result = aggregateBalancesByAsset([balance]);
      expect(result.$1.length, 1);
      expect(result.$1['BTC']?.quantity, 100);
      expect(result.$1['BTC']?.quantityNormalized, '1.00000000');
      expect(result.$2, isEmpty);
    });

    test('should aggregate multiple balances of same asset', () {
      const assetInfo = AssetInfo(
        divisible: true,
        description: 'Bitcoin',
        assetLongname: 'Bitcoin',
        issuer: 'satoshi',
      );

      final balances = [
        Balance(
          address: 'addr1',
          quantity: 100,
          quantityNormalized: '1.00000000',
          asset: 'BTC',
          assetInfo: assetInfo,
        ),
        Balance(
          address: 'addr2',
          quantity: 50,
          quantityNormalized: '0.50000000',
          asset: 'BTC',
          assetInfo: assetInfo,
        ),
      ];

      final result = aggregateBalancesByAsset(balances);
      expect(result.$1.length, 1);
      expect(result.$1['BTC']?.quantity, 150);
      expect(result.$1['BTC']?.quantityNormalized, '1.50000000');
      expect(result.$2, isEmpty);
    });

    test('should separate UTXO balances', () {
      const assetInfo = AssetInfo(
        divisible: true,
        description: 'Bitcoin',
        assetLongname: 'Bitcoin',
        issuer: 'satoshi',
      );

      final balances = [
        Balance(
          address: 'addr1',
          quantity: 100,
          quantityNormalized: '1.00000000',
          asset: 'BTC',
          assetInfo: assetInfo,
          utxo: 'utxo1',
          utxoAddress: 'utxoAddr1',
        ),
        Balance(
          address: 'addr2',
          quantity: 50,
          quantityNormalized: '0.50000000',
          asset: 'BTC',
          assetInfo: assetInfo,
        ),
      ];

      final result = aggregateBalancesByAsset(balances);
      expect(result.$1.length, 1);
      expect(result.$1['BTC']?.quantity, 50);
      expect(result.$2.length, 1);
      expect(result.$2.first.utxo, 'utxo1');
    });

    test('should handle non-divisible assets correctly', () {
      const assetInfo = AssetInfo(
        divisible: false,
        description: 'NFT Collection',
        assetLongname: 'My NFT',
        issuer: 'creator',
      );

      final balances = [
        Balance(
          address: 'addr1',
          quantity: 100,
          quantityNormalized: '100',
          asset: 'NFT',
          assetInfo: assetInfo,
        ),
        Balance(
          address: 'addr2',
          quantity: 50,
          quantityNormalized: '50',
          asset: 'NFT',
          assetInfo: assetInfo,
        ),
      ];

      final result = aggregateBalancesByAsset(balances);
      expect(result.$1['NFT']?.quantity, 150);
      expect(result.$1['NFT']?.quantityNormalized, '150');
    });
  });

  group('aggregateAndSortBalancesByAsset', () {
    test('should sort aggregated balances by quantity descending', () {
      final balances = [
        Balance(
          address: 'addr1',
          quantity: 100,
          quantityNormalized: '1.00000000',
          asset: 'BTC',
          assetInfo: const AssetInfo(
            divisible: true,
            description: 'Bitcoin',
            assetLongname: 'Bitcoin',
            issuer: 'satoshi',
          ),
        ),
        Balance(
          address: 'addr2',
          quantity: 500,
          quantityNormalized: '5.00000000',
          asset: 'ETH',
          assetInfo: const AssetInfo(
            divisible: true,
            description: 'Ethereum',
            assetLongname: 'Ethereum',
            issuer: 'vitalik',
          ),
        ),
        Balance(
          address: 'addr3',
          quantity: 200,
          quantityNormalized: '2.00000000',
          asset: 'XRP',
          assetInfo: const AssetInfo(
            divisible: true,
            description: 'Ripple',
            assetLongname: 'Ripple',
            issuer: 'ripple',
          ),
        ),
      ];

      final result = aggregateAndSortBalancesByAsset(balances);
      final sortedAssets = result.$1.keys.toList();
      expect(sortedAssets, ['ETH', 'XRP', 'BTC']);
      expect(result.$1['ETH']?.quantity, 500);
      expect(result.$1['XRP']?.quantity, 200);
      expect(result.$1['BTC']?.quantity, 100);
    });

    test('should sort UTXO balances by quantity descending', () {
      const assetInfo = AssetInfo(
        divisible: true,
        description: 'Bitcoin',
        assetLongname: 'Bitcoin',
        issuer: 'satoshi',
      );

      final balances = [
        Balance(
          address: 'addr1',
          quantity: 100,
          quantityNormalized: '1.00000000',
          asset: 'BTC',
          assetInfo: assetInfo,
          utxo: 'utxo1',
          utxoAddress: 'utxoAddr1',
        ),
        Balance(
          address: 'addr2',
          quantity: 300,
          quantityNormalized: '3.00000000',
          asset: 'BTC',
          assetInfo: assetInfo,
          utxo: 'utxo2',
          utxoAddress: 'utxoAddr2',
        ),
      ];

      final result = aggregateAndSortBalancesByAsset(balances);
      expect(result.$2.length, 2);
      expect(result.$2[0].quantity, 300);
      expect(result.$2[1].quantity, 100);
    });
  });
}

// Helper functions for comparisons
bool compareBalances(Balance a, Balance b) {
  return a.asset == b.asset &&
      a.quantity == b.quantity &&
      a.quantityNormalized == b.quantityNormalized &&
      a.address == b.address &&
      compareAssetInfo(a.assetInfo, b.assetInfo) &&
      a.utxo == b.utxo &&
      a.utxoAddress == b.utxoAddress;
}

bool compareAssetInfo(AssetInfo a, AssetInfo b) {
  return a.assetLongname == b.assetLongname && a.divisible == b.divisible;
}

bool compareAssets(Asset a, Asset b) {
  return a.asset == b.asset &&
      a.assetLongname == b.assetLongname &&
      a.owner == b.owner &&
      a.issuer == b.issuer &&
      a.divisible == b.divisible &&
      a.locked == b.locked;
}

bool compareFairminters(Fairminter a, Fairminter b) {
  return a.asset == b.asset &&
      a.txHash == b.txHash &&
      a.txIndex == b.txIndex &&
      a.source == b.source &&
      a.quantityByPrice == b.quantityByPrice &&
      a.hardCap == b.hardCap &&
      a.softCap == b.softCap &&
      a.maxMintPerTx == b.maxMintPerTx &&
      a.premintQuantity == b.premintQuantity &&
      a.startBlock == b.startBlock &&
      a.endBlock == b.endBlock &&
      a.mintedAssetCommissionInt == b.mintedAssetCommissionInt &&
      a.softCapDeadlineBlock == b.softCapDeadlineBlock;
}
