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

extension DateTimeExtension on DateTime {
  DateTime stripMilliseconds() {
    return isUtc
        ? DateTime.utc(year, month, day, hour, minute, second)
        : DateTime(year, month, day, hour, minute, second);
  }
}

class PastDateTime extends DateTime {
  PastDateTime._(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : super(year, month, day, hour, minute, second, millisecond, microsecond);

  factory PastDateTime.subtractDuration(Duration duration) {
    final now = DateTime.now();
    final past = now.subtract(duration);
    return PastDateTime._(
      past.year,
      past.month,
      past.day,
      past.hour,
      past.minute,
      past.second,
      past.millisecond,
      past.microsecond,
    );
  }

  // You can add more factory constructors or methods here if needed
}

// Extension on DateTime for easier usage
extension PastDateTimeExtension on DateTime {
  PastDateTime subtractDuration(Duration duration) {
    return PastDateTime.subtractDuration(duration);
  }
}

extension BlockTimeExtension on DateTime {
  int toIntDividedBy1000() {
    return millisecondsSinceEpoch ~/ 1000;
  }
}

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

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "123", limit: 1, unconfirmed: false))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 0));

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "123", unconfirmed: true))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 0));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        act: (bloc) =>
            bloc.add(const StartPolling(interval: Duration(seconds: 5))),
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

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "123", limit: 1, unconfirmed: false))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 0));

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "123", unconfirmed: true))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 0));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        act: (bloc) => bloc
          ..add(const StartPolling(interval: Duration(seconds: 5)))
          ..add(const StopPolling()),
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

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "123", limit: 1, unconfirmed: false))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 0));

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "123", unconfirmed: true))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 0));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        act: (bloc) => bloc.add(const Load()),
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

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "123", limit: 1, unconfirmed: false))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 0));

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "123", unconfirmed: true))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 0));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        seed: () => const DashboardActivityFeedStateCompleteOk(
            transactions: [],
            newTransactionCount: 0,
            nextCursor: null,
            mostRecentRemoteHash: null),
        act: (bloc) => bloc.add(const Load()),
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

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "123", limit: 1, unconfirmed: false))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 0));

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "123", unconfirmed: true))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 0));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        seed: () =>
            const DashboardActivityFeedStateCompleteError(error: "error"),
        act: (bloc) => bloc.add(const Load()),
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

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "123", limit: 1, unconfirmed: false))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 0));

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "123", unconfirmed: true))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 0));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        seed: () =>
            const DashboardActivityFeedStateCompleteError(error: "error"),
        act: (bloc) => bloc.add(const Load()),
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
            (
              "0001",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
            (
              "0002",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
            (
              "0003",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
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
                  accountUuid: "account-id", limit: 1, unconfirmed: false))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 3));

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "account-id", unconfirmed: true))
              .thenAnswer((_) async => (mockedRemote, null, 3));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "account-id",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        act: (bloc) => bloc.add(const Load()),
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
                nextCursor: null,
                mostRecentRemoteHash: "0004",
              ),
            ]);

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "overlapping",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();

          mockedLocal = MockTransactionInfoFactory.createMultiple([
            (
              "0001",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
            (
              "0002",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
            (
              "0003",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
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
                  accountUuid: "account-id", limit: 1, unconfirmed: false))
              .thenAnswer((_) async => (<TransactionInfo>[], 1, 2));

          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "account-id", unconfirmed: true))
              .thenAnswer((_) async => (mockedRemote, null, 2));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "account-id",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  DisplayTransaction(hash: "0001", info: mockedLocal[0]),
                  DisplayTransaction(hash: "0002", info: mockedRemote[0]),
                  DisplayTransaction(hash: "0003", info: mockedRemote[1]),
                ],
                newTransactionCount: 0,
                nextCursor: null,
                mostRecentRemoteHash: "0002",
              ),
            ]);

    // we need to query confirmed transactiuns to get account tx
    // with most recent blocktime.
    // then we need to filter out local transactions that are older
    // easiest way is to query local db submittedAd > most recent blocktime

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "first remote, newer than local",
        build: () {
          DateTime mostRecentConfirmedBlocktime =
              PastDateTime.subtractDuration(const Duration(seconds: 1))
                  .stripMilliseconds();

          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();

          // effectively asserts that right method is calleD with right args
          when(() => mockTransactionLocalRepository.getAllByAccountAfterDate(
                  "account-id", mostRecentConfirmedBlocktime))
              .thenAnswer((_) async => []);

          final mockTransactionRepository = MockTransactionRepository();

          mockedRemote = MockTransactionInfoFactory.createMultiple([
            ("0005", TransactionInfoDomainMempool()),
            (
              "0004",
              TransactionInfoDomainConfirmed(
                  blockHeight: 1,
                  blockTime:
                      mostRecentConfirmedBlocktime.toUtc().toIntDividedBy1000())
            ),
          ]);

          // Return the most recent confirmed transaction
          when(() => mockTransactionRepository.getByAccount(
                  accountUuid: "account-id", limit: 1, unconfirmed: false))
              .thenAnswer((_) async => ([mockedRemote[1]], 1, 2));

          // Return all transactions
          when(() => mockTransactionRepository.getByAccount(
                  unconfirmed: true, accountUuid: "account-id"))
              .thenAnswer((_) async => (mockedRemote, 1, 2));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "account-id",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                  transactions: [
                    DisplayTransaction(hash: "0005", info: mockedRemote[0]),
                    DisplayTransaction(hash: "0004", info: mockedRemote[1]),
                  ],
                  newTransactionCount: 0,
                  nextCursor: 1,
                  mostRecentRemoteHash: "0005"),
            ]);
  });

  // Load more appends transactions to the end of the list.  it does not
  // add any transactions to the beginning of the list

  group("LoadMore", () {
    late List<MockTransactionInfo> mockedLocal;
    late List<MockTransactionInfo> mockedRemote;
    late List<MockTransactionInfo> mockedRemote2;

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "load an additional page",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();

          mockedLocal = MockTransactionInfoFactory.createMultiple([
            (
              "0001",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
            (
              "0002",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
            (
              "0003",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
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

          mockedRemote2 = MockTransactionInfoFactory.createMultiple([
            ("0004", TransactionInfoDomainMempool()),
            (
              "0005",
              TransactionInfoDomainConfirmed(blockHeight: 1, blockTime: 1)
            ),
          ]);

          // `LoadMore`
          when(() => mockTransactionRepository.getByAccount(
              unconfirmed: true,
              accountUuid: "account-id",
              cursor: 4)).thenAnswer((_) async => (mockedRemote2, null, 2));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "account-id",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        seed: () => DashboardActivityFeedStateCompleteOk(
              transactions: [
                DisplayTransaction(hash: "0001", info: mockedLocal[0]),
                DisplayTransaction(hash: "0002", info: mockedRemote[0]),
                DisplayTransaction(hash: "0003", info: mockedRemote[1]),
              ],
              newTransactionCount: 0,
              nextCursor: 4,
              mostRecentRemoteHash: "0002",
            ),
        act: (bloc) => bloc..add(const LoadMore()),
        expect: () => [
              DashboardActivityFeedStateReloadingOk(
                transactions: [
                  DisplayTransaction(hash: "0001", info: mockedLocal[0]),
                  DisplayTransaction(hash: "0002", info: mockedRemote[0]),
                  DisplayTransaction(hash: "0003", info: mockedRemote[1]),
                ],
                newTransactionCount: 0,
              ),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  DisplayTransaction(hash: "0001", info: mockedLocal[0]),
                  DisplayTransaction(hash: "0002", info: mockedRemote[0]),
                  DisplayTransaction(hash: "0003", info: mockedRemote[1]),
                  DisplayTransaction(hash: "0004", info: mockedRemote2[0]),
                  DisplayTransaction(hash: "0005", info: mockedRemote2[1]),
                ],
                newTransactionCount: 0,
                nextCursor: null,
                mostRecentRemoteHash: "0004",
              ),
            ]);
  });

  group("LoadQuiet", () {
    late List<MockTransactionInfo> mockedLocal;
    late List<MockTransactionInfo> mockedRemote;
    late List<MockTransactionInfo> mockedRemote2;

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "returns new transactions count = all txs above the most recent remote hash",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();

          mockedLocal = MockTransactionInfoFactory.createMultiple([
            (
              "0001",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
            (
              "0002",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
            (
              "0003",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
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
            ("0002", TransactionInfoDomainMempool()),
            (
              "0003",
              TransactionInfoDomainConfirmed(blockHeight: 1, blockTime: 1)
            ),
          ]);

          // `LoadMore`
          when(() => mockTransactionRepository.getByAccount(
              unconfirmed: true,
              accountUuid: "account-id",
              cursor: null, 
              limit: 10,
              )).thenAnswer((_) async => (mockedRemote, null, null ));


          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "account-id",
              transactionLocalRepository: mockTransactionLocalRepository,
              transactionRepository: mockTransactionRepository);
        },
        seed: () => DashboardActivityFeedStateCompleteOk(
              transactions: [
                DisplayTransaction(hash: "0001", info: mockedLocal[0]),
                DisplayTransaction(hash: "0002", info: mockedRemote[2]),
                DisplayTransaction(hash: "0003", info: mockedRemote[3]),
              ],
              newTransactionCount: 0,
              nextCursor: 4, // doesn't matter since we are prepending 
              mostRecentRemoteHash: "0002",
            ),
        act: (bloc) => bloc..add(const LoadQuiet()),
        expect: () => [
              DashboardActivityFeedStateReloadingOk(
                transactions: [
                  DisplayTransaction(hash: "0001", info: mockedLocal[0]),
                  DisplayTransaction(hash: "0002", info: mockedRemote[0]),
                  DisplayTransaction(hash: "0003", info: mockedRemote[1]),
                ],
                newTransactionCount: 0,
              ),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  DisplayTransaction(hash: "0001", info: mockedLocal[0]),
                  DisplayTransaction(hash: "0002", info: mockedRemote[0]),
                  DisplayTransaction(hash: "0003", info: mockedRemote[1]),
                ],
                newTransactionCount: 2,
                nextCursor: 4,
                mostRecentRemoteHash: "0002" ,
              ),
            ]);
  });
}
