import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
// import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_mpma_send.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_mpma/bloc/compose_mpma_bloc.dart';
import 'package:horizon/presentation/screens/compose_mpma/bloc/compose_mpma_event.dart';
import 'package:horizon/presentation/screens/compose_mpma/bloc/compose_mpma_state.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class MockComposeMpmaSendResponse extends Mock
    implements ComposeMpmaSendResponse {}

class MockTransactionService extends Mock implements TransactionService {}

class MockLogger extends Mock implements Logger {}

class MockErrorService extends Mock implements ErrorService {}

void main() {
  late ComposeMpmaBloc bloc;
  late MockBalanceRepository balanceRepository;
  late MockComposeRepository composeRepository;
  late MockAnalyticsService analyticsService;
  late MockGetFeeEstimatesUseCase getFeeEstimatesUseCase;
  late MockComposeTransactionUseCase composeTransactionUseCase;
  late MockSignAndBroadcastTransactionUseCase
      signAndBroadcastTransactionUseCase;
  late MockWriteLocalTransactionUseCase writeLocalTransactionUseCase;
  late MockTransactionService transactionService;
  late MockLogger logger;
  late MockErrorService mockErrorService;

  const testAddress = 'test_address';
  const mockFeeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);

  setUp(() {
    balanceRepository = MockBalanceRepository();
    composeRepository = MockComposeRepository();
    analyticsService = MockAnalyticsService();
    getFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    composeTransactionUseCase = MockComposeTransactionUseCase();
    signAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    writeLocalTransactionUseCase = MockWriteLocalTransactionUseCase();
    transactionService = MockTransactionService();
    logger = MockLogger();
    mockErrorService = MockErrorService();

    // Register the ErrorService mock with GetIt
    GetIt.I.registerSingleton<ErrorService>(mockErrorService);

    bloc = ComposeMpmaBloc(
      balanceRepository: balanceRepository,
      composeRepository: composeRepository,
      analyticsService: analyticsService,
      getFeeEstimatesUseCase: getFeeEstimatesUseCase,
      composeTransactionUseCase: composeTransactionUseCase,
      signAndBroadcastTransactionUseCase: signAndBroadcastTransactionUseCase,
      writelocalTransactionUseCase: writeLocalTransactionUseCase,
      transactionService: transactionService,
      logger: logger,
    );
  });

  tearDown(() {
    bloc.close();
    // Reset GetIt instance after each test
    GetIt.I.reset();
  });

  group('ComposeMpmaBloc', () {
    blocTest<ComposeMpmaBloc, ComposeMpmaState>(
      'emits initial state correctly',
      build: () => bloc,
      verify: (bloc) {
        final state = bloc.state;
        expect(state.feeState, const FeeState.initial());
        expect(state.balancesState, const BalancesState.initial());
        expect(state.feeOption, isA<Medium>());
        expect(state.submitState, isA<SubmitInitial>());
        expect(state.entries, [MpmaEntry.initial()]);
        expect(state.composeSendError, null);
      },
    );

    blocTest<ComposeMpmaBloc, ComposeMpmaState>(
      'adds new entry when NewEntryAdded is added',
      build: () => bloc,
      act: (bloc) => bloc.add(NewEntryAdded()),
      expect: () => [
        predicate<ComposeMpmaState>((state) =>
            state.entries.length == 2 &&
            state.entries.last == MpmaEntry.initial()),
      ],
    );

    blocTest<ComposeMpmaBloc, ComposeMpmaState>(
      'updates entry destination when EntryDestinationUpdated is added',
      build: () => bloc,
      act: (bloc) => bloc.add(EntryDestinationUpdated(
        destination: 'new_destination',
        entryIndex: 0,
      )),
      expect: () => [
        predicate<ComposeMpmaState>(
            (state) => state.entries[0].destination == 'new_destination'),
      ],
    );

    blocTest<ComposeMpmaBloc, ComposeMpmaState>(
      'updates entry asset when EntryAssetUpdated is added',
      build: () => bloc,
      act: (bloc) => bloc.add(EntryAssetUpdated(
        asset: 'new_asset',
        entryIndex: 0,
      )),
      expect: () => [
        predicate<ComposeMpmaState>(
            (state) => state.entries[0].asset == 'new_asset'),
      ],
    );

    blocTest<ComposeMpmaBloc, ComposeMpmaState>(
      'removes entry when EntryRemoved is added',
      seed: () => ComposeMpmaState.initial().copyWith(
        entries: [
          MpmaEntry.initial(),
          MpmaEntry.initial(),
        ],
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(EntryRemoved(entryIndex: 1)),
      expect: () => [
        predicate<ComposeMpmaState>((state) => state.entries.length == 1),
      ],
    );
    group('FetchFormData', () {
      blocTest<ComposeMpmaBloc, ComposeMpmaState>(
        'emits loading and success states when data fetching succeeds',
        setUp: () {
          when(() => balanceRepository.getBalancesForAddress(any(), true))
              .thenAnswer((_) async => []);
          when(() => getFeeEstimatesUseCase.call())
              .thenAnswer((_) async => mockFeeEstimates);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(FetchFormData(currentAddress: 'test-address')),
        expect: () => [
          isA<ComposeMpmaState>()
              .having((s) => s.feeState, 'feeState', const FeeState.initial())
              .having((s) => s.balancesState, 'balancesState',
                  const BalancesState.loading())
              .having((s) => s.submitState, 'submitState', isA<SubmitInitial>())
              .having((s) => s.feeOption, 'feeOption', isA<Medium>())
              .having((s) => s.entries, 'entries', [
            MpmaEntry.initial()
          ]).having((s) => s.composeSendError, 'composeSendError', null),
          isA<ComposeMpmaState>()
              .having((s) => s.feeState, 'feeState',
                  const FeeState.success(mockFeeEstimates))
              .having((s) => s.balancesState, 'balancesState',
                  const BalancesState.success([]))
              .having((s) => s.submitState, 'submitState', isA<SubmitInitial>())
              .having((s) => s.feeOption, 'feeOption', isA<Medium>())
              .having((s) => s.entries, 'entries', [
            MpmaEntry.initial()
          ]).having((s) => s.composeSendError, 'composeSendError', null),
        ],
        verify: (_) {
          verify(() =>
                  balanceRepository.getBalancesForAddress('test-address', true))
              .called(1);
          verify(() => getFeeEstimatesUseCase.call()).called(1);
        },
      );

      blocTest<ComposeMpmaBloc, ComposeMpmaState>(
        'emits error state when fetching balances fails',
        setUp: () {
          when(() => balanceRepository.getBalancesForAddress(any(), true))
              .thenThrow(Exception('Failed to fetch balances'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(FetchFormData(currentAddress: 'test-address')),
        expect: () => [
          isA<ComposeMpmaState>()
              .having((s) => s.feeState, 'feeState', const FeeState.initial())
              .having((s) => s.balancesState, 'balancesState',
                  const BalancesState.loading())
              .having((s) => s.submitState, 'submitState', isA<SubmitInitial>())
              .having((s) => s.feeOption, 'feeOption', isA<Medium>())
              .having((s) => s.entries, 'entries', [
            MpmaEntry.initial()
          ]).having((s) => s.composeSendError, 'composeSendError', null),
          isA<ComposeMpmaState>()
              .having((s) => s.feeState, 'feeState', const FeeState.initial())
              .having(
                (s) => s.balancesState,
                'balancesState',
                isA<BalancesState>().having(
                  (e) => e.toString(),
                  'error',
                  contains('Failed to fetch balances'),
                ),
              )
              .having((s) => s.submitState, 'submitState', isA<SubmitInitial>())
              .having((s) => s.feeOption, 'feeOption', isA<Medium>())
              .having((s) => s.entries, 'entries', [
            MpmaEntry.initial()
          ]).having((s) => s.composeSendError, 'composeSendError', null),
        ],
      );
    });

    group('Balance validation', () {
      final mockBalances = [
        Balance(
          asset: 'TEST_ASSET',
          address: 'test-address',
          quantity: 1200000000, // 12 TEST_ASSET (divisible)
          quantityNormalized: '12',
          assetInfo: const AssetInfo(
            assetLongname: null,
            divisible: true,
          ),
        ),
        Balance(
          asset: 'INDIVISIBLE',
          address: 'test-address',
          quantity: 10, // 10 INDIVISIBLE (non-divisible)
          quantityNormalized: '10',
          assetInfo: const AssetInfo(
            assetLongname: null,
            divisible: false,
          ),
        ),
      ];

      blocTest<ComposeMpmaBloc, ComposeMpmaState>(
        'getRemainingBalanceForAsset correctly calculates remaining balance',
        build: () => bloc,
        seed: () => ComposeMpmaState.initial().copyWith(
          balancesState: BalancesState.success(mockBalances),
          entries: [
            MpmaEntry.initial().copyWith(
              asset: 'TEST_ASSET',
              quantity: '5',
            ),
            MpmaEntry.initial().copyWith(
              asset: 'TEST_ASSET',
              quantity: '3',
            ),
          ],
        ),
        verify: (bloc) {
          // Should have 4 TEST_ASSET remaining (12 - 5 - 3 = 4)
          expect(
            bloc.getRemainingBalanceForAsset('TEST_ASSET', 2),
            Decimal.parse('4'),
          );

          // When checking entry 0, should exclude its own quantity from total used
          expect(
            bloc.getRemainingBalanceForAsset('TEST_ASSET', 0),
            Decimal.parse(
                '9'), // 12 - 3 = 9 (excluding entry 0's quantity of 5)
          );

          // For unused asset, should return full balance
          expect(
            bloc.getRemainingBalanceForAsset('INDIVISIBLE', 0),
            Decimal.parse('10'),
          );

          // For non-existent asset, should return zero
          expect(
            bloc.getRemainingBalanceForAsset('NONEXISTENT', 0),
            Decimal.zero,
          );
        },
      );

      blocTest<ComposeMpmaBloc, ComposeMpmaState>(
        'EntryQuantityUpdated validates against remaining balance',
        build: () => bloc,
        seed: () => ComposeMpmaState.initial().copyWith(
          balancesState: BalancesState.success(mockBalances),
          entries: [
            MpmaEntry.initial().copyWith(
              asset: 'TEST_ASSET',
              quantity: '5',
            ),
            MpmaEntry.initial().copyWith(
              asset: 'TEST_ASSET',
              quantity: '',
            ),
          ],
        ),
        act: (bloc) => bloc.add(EntryQuantityUpdated(
          quantity: '8',
          entryIndex: 1,
        )),
        expect: () => [
          isA<ComposeMpmaState>()
              .having(
                (state) => state.composeSendError,
                'composeSendError',
                "Quantity exceeds available balance",
              )
              .having(
                (state) => state.entries[1].quantity,
                'second entry quantity',
                '',
              ),
        ],
      );

      blocTest<ComposeMpmaBloc, ComposeMpmaState>(
        'EntrySendMaxToggled sets maximum available quantity',
        build: () => bloc,
        seed: () => ComposeMpmaState.initial().copyWith(
          balancesState: BalancesState.success(mockBalances),
          entries: [
            MpmaEntry.initial().copyWith(
              asset: 'TEST_ASSET',
              quantity: '5',
            ),
            MpmaEntry.initial().copyWith(
              asset: 'TEST_ASSET',
              quantity: '',
            ),
          ],
        ),
        act: (bloc) => bloc.add(EntrySendMaxToggled(
          value: true,
          entryIndex: 1,
        )),
        expect: () => [
          predicate<ComposeMpmaState>((state) =>
              state.entries[1].quantity == '7' && // 12 - 5 = 7 remaining
              state.entries[1].sendMax == true),
        ],
      );

      blocTest<ComposeMpmaBloc, ComposeMpmaState>(
        'EntryQuantityUpdated allows valid remaining balance',
        build: () => bloc,
        seed: () => ComposeMpmaState.initial().copyWith(
          balancesState: BalancesState.success(mockBalances),
          entries: [
            MpmaEntry.initial().copyWith(
              asset: 'TEST_ASSET',
              quantity: '5',
            ),
            MpmaEntry.initial().copyWith(
              asset: 'TEST_ASSET',
              quantity: '',
            ),
          ],
        ),
        act: (bloc) => bloc.add(EntryQuantityUpdated(
          quantity: '6',
          entryIndex: 1,
        )),
        expect: () => [
          isA<ComposeMpmaState>()
              .having(
                (state) => state.entries[1].quantity,
                'second entry quantity',
                '6',
              )
              .having(
                (state) => state.composeSendError,
                'composeSendError',
                null,
              ),
        ],
      );

      blocTest<ComposeMpmaBloc, ComposeMpmaState>(
        'EntryQuantityUpdated handles empty and invalid quantities',
        build: () => bloc,
        seed: () => ComposeMpmaState.initial().copyWith(
          balancesState: BalancesState.success(mockBalances),
          entries: [
            MpmaEntry.initial().copyWith(
              asset: 'TEST_ASSET',
              quantity: '',
            ),
          ],
        ),
        act: (bloc) => bloc.add(EntryQuantityUpdated(
          quantity: 'invalid',
          entryIndex: 0,
        )),
        expect: () => [
          isA<ComposeMpmaState>()
              .having(
                (state) => state.entries[0].quantity,
                'entry quantity',
                'invalid',
              )
              .having(
                (state) => state.composeSendError,
                'composeSendError',
                null,
              ),
        ],
      );
    });
  });
}
