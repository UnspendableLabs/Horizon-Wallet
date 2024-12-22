import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_mpma_send.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
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
      'adds new entry when AddNewEntry is added',
      build: () => bloc,
      act: (bloc) => bloc.add(AddNewEntry()),
      expect: () => [
        predicate<ComposeMpmaState>((state) =>
            state.entries.length == 2 &&
            state.entries.last == MpmaEntry.initial()),
      ],
    );

    blocTest<ComposeMpmaBloc, ComposeMpmaState>(
      'updates entry destination when UpdateEntryDestination is added',
      build: () => bloc,
      act: (bloc) => bloc.add(UpdateEntryDestination(
        destination: 'new_destination',
        entryIndex: 0,
      )),
      expect: () => [
        predicate<ComposeMpmaState>(
            (state) => state.entries[0].destination == 'new_destination'),
      ],
    );

    blocTest<ComposeMpmaBloc, ComposeMpmaState>(
      'updates entry asset when UpdateEntryAsset is added',
      build: () => bloc,
      act: (bloc) => bloc.add(UpdateEntryAsset(
        asset: 'new_asset',
        entryIndex: 0,
      )),
      expect: () => [
        predicate<ComposeMpmaState>(
            (state) => state.entries[0].asset == 'new_asset'),
      ],
    );

    blocTest<ComposeMpmaBloc, ComposeMpmaState>(
      'removes entry when RemoveEntry is added',
      seed: () => ComposeMpmaState.initial().copyWith(
        entries: [
          MpmaEntry.initial(),
          MpmaEntry.initial(),
        ],
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(RemoveEntry(entryIndex: 1)),
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
  });
}
