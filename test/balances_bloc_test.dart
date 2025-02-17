import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fairminter.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:mocktail/mocktail.dart';

// Mock Classes

class MockBalanceRepository extends Mock implements BalanceRepository {}

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

    const addresses = ['mocked-address'];

    late List<Balance> allBalances;
    late Map<String, List<Balance>> aggregatedBalances;

    setUpAll(() {
      registerFallbackValue(FakeBalance());
      registerFallbackValue(FakeAsset());
      registerFallbackValue(FakeFairminter());
    });

    setUp(() {
      mockBalanceRepository = MockBalanceRepository();

      balancesBloc = BalancesBloc(
        balanceRepository: mockBalanceRepository,
        addresses: addresses,
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
        allBalances = <Balance>[
          Balance(
            asset: 'ASSET1',
            quantity: 100000000, // 1.00000000
            quantityNormalized: '1.00000000',
            address: addresses.first,
            assetInfo: const AssetInfo(
              assetLongname: null,
              divisible: true,
            ),
            utxo: null,
            utxoAddress: null,
          ),
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

        // Set up the mock
        when(() => mockBalanceRepository.getBalancesForAddresses(addresses))
            .thenAnswer((_) async => allBalances);

        // Compute expected aggregated balances
        aggregatedBalances = aggregateBalancesByAsset(allBalances);
      },
      build: () => balancesBloc,
      act: (bloc) => bloc.add(Fetch()),
      expect: () => [
        const BalancesState.loading(),
        BalancesState.complete(Result.ok(aggregatedBalances)),
      ],
      verify: (bloc) {
        verify(() => mockBalanceRepository.getBalancesForAddresses(addresses))
            .called(1);
      },
    );

    blocTest<BalancesBloc, BalancesState>(
      'emits [loading, complete with error] when Fetch fails',
      build: () {
        when(() => mockBalanceRepository.getBalancesForAddresses(addresses))
            .thenThrow(Exception('Failed to fetch balances'));
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
      },
    );

    test('starts polling on Start event and stops on Stop event', () async {
      when(() => mockBalanceRepository.getBalancesForAddresses(addresses))
          .thenAnswer((_) async => []);

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
                  ok: (aggregated) => true,
                  orElse: () => false,
                );
              },
              orElse: () => false,
            );
          }),
        );
      }

      // Verify that the repository method was called multiple times
      verify(() => mockBalanceRepository.getBalancesForAddresses(addresses))
          .called(greaterThanOrEqualTo(3));
    });
  });

  group('aggregateBalancesByAsset', () {
    test('should return empty map when given empty list', () {
      final result = aggregateBalancesByAsset([]);
      expect(result, isEmpty);
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
      expect(result.length, 1);
      expect(result['Bitcoin']!.length, 1);
      expect(result['Bitcoin']!.first, balance);
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
      expect(result.length, 1);
      expect(result['Bitcoin']!.length, 2);
      expect(result['Bitcoin']!.map((b) => b.quantity).toList(), [100, 50]);
    });

    test('should use asset name when assetLongname is null', () {
      const assetInfo = AssetInfo(
        divisible: true,
        description: 'Test Asset',
        assetLongname: null,
        issuer: 'issuer',
      );

      final balance = Balance(
        address: 'addr1',
        quantity: 100,
        quantityNormalized: '100',
        asset: 'TEST',
        assetInfo: assetInfo,
      );

      final result = aggregateBalancesByAsset([balance]);
      expect(result.length, 1);
      expect(result['TEST']!.length, 1);
      expect(result['TEST']!.first, balance);
    });
  });
}

// Helper function for balance comparison
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
