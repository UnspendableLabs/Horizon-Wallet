import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/usecases/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/forms/send_transfer/bloc/send_transfer_bloc.dart';
import 'package:horizon/presentation/forms/send_transfer/bloc/send_transfer_event.dart';
import 'package:horizon/presentation/forms/send_transfer/bloc/send_transfer_state.dart';

class MockGetFeeEstimatesUseCase extends Mock
    implements GetFeeEstimatesUseCase {}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockComposeSendResponse extends Mock implements ComposeSendResponse {}

class MockAddressV2 extends Mock implements AddressV2 {}

void main() {
  late MockGetFeeEstimatesUseCase mockGetFeeEstimatesUseCase;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockComposeRepository mockComposeRepository;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockComposeSendResponse mockComposeSendResponse;
  late MockAddressV2 mockSource;
  // Shared gate between build() and act() for the re-entrancy test.
  late Completer<void> broadcastGate;

  final httpConfig = HttpConfig.mainnet();
  const feeEstimates = FeeEstimates(fast: 5, medium: 3, slow: 1);

  setUpAll(() {
    registerFallbackValue(GetFeeEstimatesParams(httpConfig: httpConfig));
    registerFallbackValue(ComposeSendParams(
      source: 'bc1qsource',
      destination: 'bc1qdest',
      asset: 'BTC',
      quantity: 1,
    ));
    // mocktail resolves `any(named: 'composeFn')` by an `is ComposeFunction`
    // check; this lambda's reified type satisfies it, so no annotation/cast is
    // needed.
    registerFallbackValue(
        (fee, inputs, params, cfg) async => MockComposeSendResponse());
    registerFallbackValue(SignAndBroadcastTransactionParams(
      source: MockAddressV2(),
      decryptionStrategy: InMemoryKey(),
      rawtransaction: 'raw',
      httpConfig: httpConfig,
    ));
    registerFallbackValue(httpConfig);
  });

  setUp(() {
    mockGetFeeEstimatesUseCase = MockGetFeeEstimatesUseCase();
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockComposeRepository = MockComposeRepository();
    mockSignAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    mockComposeSendResponse = MockComposeSendResponse();
    mockSource = MockAddressV2();

    when(() => mockSource.address).thenReturn('bc1qsource');
    when(() => mockComposeSendResponse.rawtransaction).thenReturn('rawtxhex');
    when(() => mockComposeSendResponse.btcFee).thenReturn(250);
  });

  SendTransferBloc buildBloc() => SendTransferBloc(
        source: mockSource,
        destination: 'bc1qdest',
        amount: 100000,
        httpConfig: httpConfig,
        // No password so the Confirm path doesn't depend on form input.
        passwordRequired: false,
        getFeeEstimatesUseCase: mockGetFeeEstimatesUseCase,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        signAndBroadcastTransactionUseCase:
            mockSignAndBroadcastTransactionUseCase,
      );

  void stubComposeSucceeds() {
    when(() => mockGetFeeEstimatesUseCase.call(any()))
        .thenAnswer((_) => TaskEither.right(feeEstimates));
    when(() => mockComposeTransactionUseCase
            .callT<ComposeSendParams, ComposeSendResponse>(
          feeRate: any(named: 'feeRate'),
          source: any(named: 'source'),
          params: any(named: 'params'),
          composeFn: any(named: 'composeFn'),
          httpConfig: any(named: 'httpConfig'),
        )).thenAnswer((_) => TaskEither.right(mockComposeSendResponse));
  }

  group('SendTransferBloc re-entrancy', () {
    blocTest<SendTransferBloc, SendTransferState>(
      'broadcasts exactly once when ConfirmSend fires twice',
      build: () {
        stubComposeSucceeds();
        // Gate the broadcast so both ConfirmSend events are processed while the
        // first is still in flight (status == broadcasting). Without the guard
        // the cached transaction would be signed and broadcast twice.
        broadcastGate = Completer<void>();
        when(() => mockSignAndBroadcastTransactionUseCase.call(any()))
            .thenAnswer((_) => TaskEither(() async {
                  await broadcastGate.future;
                  return Either<String, BroadcastResponse>.right(
                      const BroadcastResponse(hex: 'h', hash: 'txhash'));
                }));
        return buildBloc();
      },
      act: (bloc) async {
        // Wait for the auto-compose to settle into review.
        await bloc.stream
            .firstWhere((s) => s.status == SendTransferStatus.review);
        bloc.add(ConfirmSend());
        bloc.add(ConfirmSend());
        // Let both events be processed while the broadcast is gated.
        await Future<void>.delayed(const Duration(milliseconds: 10));
        broadcastGate.complete();
      },
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        verify(() => mockSignAndBroadcastTransactionUseCase.call(any()))
            .called(1);
      },
    );

    blocTest<SendTransferBloc, SendTransferState>(
      'ignores ConfirmSend after a successful broadcast',
      build: () {
        stubComposeSucceeds();
        when(() => mockSignAndBroadcastTransactionUseCase.call(any()))
            .thenAnswer((_) => TaskEither.right(
                const BroadcastResponse(hex: 'h', hash: 'txhash')));
        return buildBloc();
      },
      act: (bloc) async {
        await bloc.stream
            .firstWhere((s) => s.status == SendTransferStatus.review);
        bloc.add(ConfirmSend());
        await bloc.stream
            .firstWhere((s) => s.status == SendTransferStatus.success);
        // A late confirm (e.g. a stray re-tap) must not re-broadcast.
        bloc.add(ConfirmSend());
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        verify(() => mockSignAndBroadcastTransactionUseCase.call(any()))
            .called(1);
      },
    );
  });

  group('SendTransferBloc failure classification', () {
    blocTest<SendTransferBloc, SendTransferState>(
      'emits composeFailure (fatal) when compose fails',
      build: () {
        when(() => mockGetFeeEstimatesUseCase.call(any()))
            .thenAnswer((_) => TaskEither.right(feeEstimates));
        when(() => mockComposeTransactionUseCase
                .callT<ComposeSendParams, ComposeSendResponse>(
              feeRate: any(named: 'feeRate'),
              source: any(named: 'source'),
              params: any(named: 'params'),
              composeFn: any(named: 'composeFn'),
              httpConfig: any(named: 'httpConfig'),
            )).thenAnswer((_) => TaskEither.left('insufficient funds'));
        return buildBloc();
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<SendTransferState>()
            .having((s) => s.status, 'status', SendTransferStatus.composing),
        isA<SendTransferState>()
            .having(
                (s) => s.status, 'status', SendTransferStatus.composeFailure)
            .having((s) => s.error, 'error', 'insufficient funds'),
      ],
      verify: (_) {
        verifyNever(() => mockSignAndBroadcastTransactionUseCase.call(any()));
      },
    );

    blocTest<SendTransferBloc, SendTransferState>(
      'emits broadcastFailure (retryable) when broadcast fails',
      build: () {
        stubComposeSucceeds();
        when(() => mockSignAndBroadcastTransactionUseCase.call(any()))
            .thenAnswer((_) => TaskEither.left('node unreachable'));
        return buildBloc();
      },
      act: (bloc) async {
        await bloc.stream
            .firstWhere((s) => s.status == SendTransferStatus.review);
        bloc.add(ConfirmSend());
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.status, SendTransferStatus.broadcastFailure);
        expect(bloc.state.error, 'node unreachable');
      },
    );
  });
}
