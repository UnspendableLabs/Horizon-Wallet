import 'package:test/test.dart';
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_state.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockTransactionLocalRepository extends Mock
    implements TransactionLocalRepository {}

void main() {
  group("add StartPolling", () {
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "sets timer",
        build: () => DashboardActivityFeedBloc(
            pageSize: 10,
            accountUuid: "123",
            transactionLocalRepository: MockTransactionLocalRepository(),
            transactionRepository: MockTransactionRepository()),
        act: (bloc) =>
            bloc.add(const StartPolling(interval: Duration(seconds: 5))),
        wait: const Duration(milliseconds: 1),
        // expect: () => [
        //       DashboardActivityFeedStateLoading(),
        //       isA<DashboardActivityFeedState>()
        //     ],
        verify: (bloc) {
          expect(bloc.timer, isA<Timer>());
        });
  });

  group("add StartPolling, add StopPolliong", () {
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "clears timer",
        build: () => DashboardActivityFeedBloc(
            pageSize: 10,
            accountUuid: "123",
            transactionLocalRepository: MockTransactionLocalRepository(),
            transactionRepository: MockTransactionRepository()),
        act: (bloc) => bloc
          ..add(const StartPolling(interval: Duration(seconds: 5)))
          ..add(const StopPolling()),
        wait: const Duration(milliseconds: 1),
        // expect: () => [
        //       DashboardActivityFeedStateLoading(),
        //       isA<DashboardActivityFeedState>()
        //     ],
        verify: (bloc) {
          expect(bloc.timer, isNull);
        });
  });

  group("add Load", () {
    blocTest("emits loading state when load event is added",
        build: () => DashboardActivityFeedBloc(
            pageSize: 10,
            accountUuid: "123",
            transactionLocalRepository: MockTransactionLocalRepository(),
            transactionRepository: MockTransactionRepository()),
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(milliseconds: 1),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              isA<DashboardActivityFeedState>()
            ]);
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "emits reloading ok when state is complete ok",
        build: () => DashboardActivityFeedBloc(
            pageSize: 10,
            accountUuid: "123",
            transactionLocalRepository: MockTransactionLocalRepository(),
            transactionRepository: MockTransactionRepository()),
        seed: () => const DashboardActivityFeedStateCompleteOk(
            transactions: [], newTransactionCount: 0),
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(milliseconds: 1),
        expect: () => [
              const DashboardActivityFeedStateReloadingOk(
                transactions: [],
                newTransactionCount: 0,
              ),
              isA<DashboardActivityFeedState>()
            ]);
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "emits reloading error when state is complete error",
        build: () => DashboardActivityFeedBloc(
            pageSize: 10,
            accountUuid: "123",
            transactionLocalRepository: MockTransactionLocalRepository(),
            transactionRepository: MockTransactionRepository()),
        seed: () =>
            const DashboardActivityFeedStateCompleteError(error: "error"),
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(milliseconds: 1),
        expect: () => [
              const DashboardActivityFeedStateReloadingError(
                error: "error",
              ),
              isA<DashboardActivityFeedState>()
            ]);
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "basic merge of local / confirmed",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();

          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => []);

          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => []);

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: MockTransactionRepository());
        },
        seed: () =>
            const DashboardActivityFeedStateCompleteError(error: "error"),
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(milliseconds: 1),
        expect: () => [
              const DashboardActivityFeedStateReloadingError(
                error: "error",
              ),
              isA<DashboardActivityFeedState>()
            ]);
  });
}
