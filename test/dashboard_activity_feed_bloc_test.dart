import 'package:test/test.dart';
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_state.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/entities/display_transaction.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockTransactionLocalRepository extends Mock
    implements TransactionLocalRepository {}

class MockTransactionInfo extends Mock implements TransactionInfo {
  @override
  final String hash;
  @override
  final TransactionInfoDomain domain;
  @override
  final String source;
  @override
  final String? destination;
  @override
  final int btcAmount;
  @override
  final int fee;
  @override
  final String data;
  @override
  final TransactionUnpacked unpackedData;

  MockTransactionInfo({
    required this.hash,
    required this.domain,
    required this.source,
    this.destination,
    required this.btcAmount,
    required this.fee,
    required this.data,
    required this.unpackedData,
  });
}

class MockTransactionInfoFactory {
  static int _counter = 0;

  static MockTransactionInfo create({
    required String hash,
    required TransactionInfoDomain domain,
    String? source,
    String? destination,
    int? btcAmount,
    int? fee,
    String? data,
    TransactionUnpacked? unpackedData,
  }) {
    _counter++;
    return MockTransactionInfo(
      hash: hash,
      domain: domain,
      source: source ?? 'mockedSource$_counter',
      destination: destination,
      btcAmount: btcAmount ?? 1000 * _counter,
      fee: fee ?? 100 * _counter,
      data: data ?? 'mockedData$_counter',
      unpackedData: unpackedData ?? MockTransactionUnpacked(),
    );
  }

  static List<MockTransactionInfo> createMultiple(
    List<(String, TransactionInfoDomain)> hashDomainPairs,
  ) {
    return hashDomainPairs.map((pair) {
      return create(
        hash: pair.$1,
        domain: pair.$2,
      );
    }).toList();
  }
}

class MockTransactionUnpacked extends Mock implements TransactionUnpacked {}

void main() {
  group("add StartPolling", () {
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "sets timer",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();
          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => []);

          final mockTransactionRepository = MockTransactionRepository();
          when(() => mockTransactionRepository.getByAccount(accountUuid: "123"))
              .thenAnswer((_) async => (<TransactionInfo>[], 1));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        act: (bloc) =>
            bloc.add(const StartPolling(interval: Duration(seconds: 5))),
        wait: const Duration(milliseconds: 1),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              isA<DashboardActivityFeedState>()
            ],
        verify: (bloc) {
          expect(bloc.timer, isA<Timer>());
        });
  });

  group("add StartPolling, add StopPolliong", () {
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "clears timer",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();
          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => []);

          final mockTransactionRepository = MockTransactionRepository();
          when(() => mockTransactionRepository.getByAccount(accountUuid: "123"))
              .thenAnswer((_) async => (<TransactionInfo>[], 1));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
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
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();
          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => []);

          final mockTransactionRepository = MockTransactionRepository();
          when(() => mockTransactionRepository.getByAccount(accountUuid: "123"))
              .thenAnswer((_) async => (<TransactionInfo>[], 1));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(milliseconds: 1),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              isA<DashboardActivityFeedState>()
            ]);
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "emits reloading ok when state is complete ok",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();
          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => []);

          final mockTransactionRepository = MockTransactionRepository();
          when(() => mockTransactionRepository.getByAccount(accountUuid: "123"))
              .thenAnswer((_) async => (<TransactionInfo>[], 1));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
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
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();
          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => []);

          final mockTransactionRepository = MockTransactionRepository();
          when(() => mockTransactionRepository.getByAccount(accountUuid: "123"))
              .thenAnswer((_) async => (<TransactionInfo>[], 1));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
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

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "basic merge of local / remote t",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();
          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => []);

          final mockTransactionRepository = MockTransactionRepository();
          when(() => mockTransactionRepository.getByAccount(accountUuid: "123"))
              .thenAnswer((_) async => (<TransactionInfo>[], 1));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
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

  group("interleaving", () {
    late List<MockTransactionInfo> mockedLocal;
    late List<MockTransactionInfo> mockedRemote;

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "non overlapping",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();

          mockedLocal = MockTransactionInfoFactory.createMultiple([
            ("0001", TransactionInfoDomainLocal(raw: "")),
            ("0002", TransactionInfoDomainLocal(raw: "")),
            ("0003", TransactionInfoDomainLocal(raw: "")),
          ]);

          when(() =>
                  mockTransactionLocalRepository.getAllByAccount("account-id"))
              .thenAnswer((_) async => mockedLocal);

          final mockTransactionRepository = MockTransactionRepository();

          mockedRemote = MockTransactionInfoFactory.createMultiple([
            ("0004", TransactionInfoDomainMempool()),
            (
              "0005",
              TransactionInfoDomainConfirmed(blockHeight: 1, blockTime: 1)
            ),
            (
              "0006",
              TransactionInfoDomainConfirmed(blockHeight: 1, blockTime: 1)
            ),
          ]);
          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "account-id"))
              .thenAnswer((_) async => (mockedRemote, null));

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "account-id"))
              .thenAnswer((_) async => (mockedRemote, null));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "account-id",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(milliseconds: 1),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  DisplayTransaction(hash: "0001", info: mockedLocal[0]),
                  DisplayTransaction(hash: "0002", info: mockedLocal[1]),
                  DisplayTransaction(hash: "0003", info: mockedLocal[2]),
                  DisplayTransaction(hash: "0004", info: mockedRemote[0]),
                  DisplayTransaction(hash: "0005", info: mockedRemote[1]),
                  DisplayTransaction(hash: "0006", info: mockedRemote[2]),
                ],
                newTransactionCount: 0,
              ),
            ]);

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "overlapping",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();

          mockedLocal = MockTransactionInfoFactory.createMultiple([
            ("0001", TransactionInfoDomainLocal(raw: "")),
            ("0002", TransactionInfoDomainLocal(raw: "")),
            ("0003", TransactionInfoDomainLocal(raw: "")),
          ]);

          when(() =>
                  mockTransactionLocalRepository.getAllByAccount("account-id"))
              .thenAnswer((_) async => mockedLocal);

          final mockTransactionRepository = MockTransactionRepository();

          mockedRemote = MockTransactionInfoFactory.createMultiple([
            ("0002", TransactionInfoDomainMempool()),
            (
              "0003",
              TransactionInfoDomainConfirmed(blockHeight: 1, blockTime: 1)
            ),
          ]);
          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "account-id"))
              .thenAnswer((_) async => (mockedRemote, null));

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "account-id"))
              .thenAnswer((_) async => (mockedRemote, null));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "account-id",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(milliseconds: 1),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  DisplayTransaction(hash: "0001", info: mockedLocal[0]),
                  DisplayTransaction(hash: "0002", info: mockedRemote[0]),
                  DisplayTransaction(hash: "0003", info: mockedRemote[1]),
                ],
                newTransactionCount: 0,
              ),
            ]);
  });
}
