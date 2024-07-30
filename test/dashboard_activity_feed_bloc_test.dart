import 'package:test/test.dart';
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_state.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:mocktail/mocktail.dart';

final DEFAULT_WHITELIST = [
  "CREDIT",
  "DEBIT",
];

extension DateTimeExtension on DateTime {
  DateTime stripMilliseconds() {
    return isUtc
        ? DateTime.utc(year, month, day, hour, minute, second)
        : DateTime(year, month, day, hour, minute, second);
  }
}

class PastDateTime extends DateTime {
  PastDateTime._(super.year,
      [super.month,
      super.day,
      super.hour,
      super.minute,
      super.second,
      super.millisecond,
      super.microsecond]);

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

class MockEventsRepository extends Mock implements EventsRepository {}

class MockTransactionLocalRepository extends Mock
    implements TransactionLocalRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

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

class MockEvent extends Mock implements VerboseEvent {
  @override
  final String txHash;
  @override
  final EventState state;

  MockEvent({
    required this.txHash,
    required this.state,
  });
}

class MockEventFactory {
  static MockEvent create({
    required String txHash,
    required EventState state,
  }) {
    return MockEvent(
      txHash: txHash,
      state: state,
    );
  }

  static List<MockEvent> createMultiple(
    List<(String, EventState)> eventSpecs,
  ) {
    return eventSpecs.map((spec) {
      return create(
        txHash: spec.$1,
        state: spec.$2,
      );
    }).toList();
  }
}

void main() {
  final mockAddressRepository = MockAddressRepository();
  when(() => mockAddressRepository.getAllByAccountUuid("123")).thenAnswer(
      (_) async =>
          [const Address(index: 0, address: "0x123", accountUuid: "123")]);

  group("add StartPolling", () {
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "sets timer",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();

          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => []);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                addresses: ["0x123"],
                limit: 10,
                unconfirmed: false,
                whitelist: DEFAULT_WHITELIST,
              )).thenAnswer((_) async => (<VerboseEvent>[], 1, 0));

          when(() => mockEventsRepository.getByAddressesVerbose(
              addresses: ["0x123"],
              unconfirmed: true,
              whitelist: DEFAULT_WHITELIST,
              limit: 10)).thenAnswer((_) async => (<VerboseEvent>[], 1, 0));

          return DashboardActivityFeedBloc(
            pageSize: 10,
            eventsRepository: mockEventsRepository,
            accountUuid: "123",
            transactionLocalRepository: mockTransactionLocalRepository,
            addressRepository: mockAddressRepository,
          );
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

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false,
                  whitelist: DEFAULT_WHITELIST))
              .thenAnswer((_) async => (<VerboseEvent>[], 1, 0));

          when(() => mockEventsRepository.getByAddressesVerbose(
              whitelist: DEFAULT_WHITELIST,
              addresses: ["0x123"],
              unconfirmed: true,
              limit: 10)).thenAnswer((_) async => (<VerboseEvent>[], 1, 0));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              eventsRepository: mockEventsRepository,
              addressRepository: mockAddressRepository);
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

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => (<VerboseEvent>[], 1, 0));

          when(() => mockEventsRepository.getByAddressesVerbose(
              addresses: ["0x123"],
              whitelist: DEFAULT_WHITELIST,
              unconfirmed: true,
              limit: 10)).thenAnswer((_) async => (<VerboseEvent>[], 1, 0));

          return DashboardActivityFeedBloc(
            pageSize: 10,
            accountUuid: "123",
            transactionLocalRepository: mockTransactionLocalRepository,
            eventsRepository: mockEventsRepository,
            addressRepository: mockAddressRepository,
          );
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

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => (<VerboseEvent>[], 1, 0));

          when(() => mockEventsRepository.getByAddressesVerbose(
              whitelist: DEFAULT_WHITELIST,
              addresses: ["0x123"],
              unconfirmed: true,
              limit: 10)).thenAnswer((_) async => (<VerboseEvent>[], 1, 0));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              eventsRepository: mockEventsRepository);
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

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => (<VerboseEvent>[], 1, 0));

          when(() => mockEventsRepository.getByAddressesVerbose(
              whitelist: DEFAULT_WHITELIST,
              addresses: ["0x123"],
              unconfirmed: true,
              limit: 10)).thenAnswer((_) async => (<VerboseEvent>[], 1, 0));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              eventsRepository: mockEventsRepository);
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

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => (<VerboseEvent>[], 1, 0));

          when(() => mockEventsRepository.getByAddressesVerbose(
              whitelist: DEFAULT_WHITELIST,
              addresses: ["0x123"],
              unconfirmed: true,
              limit: 10)).thenAnswer((_) async => (<VerboseEvent>[], 1, 0));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              eventsRepository: mockEventsRepository);
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
    late List<MockEvent> mockedRemote;

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

          mockedRemote = MockEventFactory.createMultiple([
            ("0004", EventStateMempool()),
            ("0005", EventStateConfirmed(blockHeight: 1, blockTime: 1)),
            ("0006", EventStateConfirmed(blockHeight: 1, blockTime: 1)),
          ]);

          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => mockedLocal);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => (<VerboseEvent>[], 1, 3));

          when(() => mockEventsRepository.getByAddressesVerbose(
              whitelist: DEFAULT_WHITELIST,
              addresses: ["0x123"],
              unconfirmed: true,
              limit: 10)).thenAnswer((_) async => (mockedRemote, null, 3));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              eventsRepository: mockEventsRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  ActivityFeedItem(hash: "0001", info: mockedLocal[0]),
                  ActivityFeedItem(hash: "0002", info: mockedLocal[1]),
                  ActivityFeedItem(hash: "0003", info: mockedLocal[2]),
                  ActivityFeedItem(hash: "0004", event: mockedRemote[0]),
                  ActivityFeedItem(hash: "0005", event: mockedRemote[1]),
                  ActivityFeedItem(hash: "0006", event: mockedRemote[2]),
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

          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => mockedLocal);

          final mockEventsRepository = MockEventsRepository();

          mockedRemote = MockEventFactory.createMultiple([
            ("0002", EventStateMempool()),
            ("0003", EventStateConfirmed(blockHeight: 1, blockTime: 1)),
          ]);

          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => (<VerboseEvent>[], 1, 2));

          when(() => mockEventsRepository.getByAddressesVerbose(
              whitelist: DEFAULT_WHITELIST,
              addresses: ["0x123"],
              unconfirmed: true,
              limit: 10)).thenAnswer((_) async => (mockedRemote, null, 2));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              eventsRepository: mockEventsRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  ActivityFeedItem(hash: "0001", info: mockedLocal[0]),
                  ActivityFeedItem(hash: "0002", event: mockedRemote[0]),
                  ActivityFeedItem(hash: "0003", event: mockedRemote[1]),
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
              "123", mostRecentConfirmedBlocktime)).thenAnswer((_) async => []);

          final mockEventsRepository = MockEventsRepository();

          mockedRemote = MockEventFactory.createMultiple([
            ("0005", EventStateMempool()),
            (
              "0004",
              EventStateConfirmed(
                  blockHeight: 1,
                  blockTime:
                      mostRecentConfirmedBlocktime.toUtc().toIntDividedBy1000())
            ),
          ]);

          // Return the most recent confirmed transaction
          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => ([mockedRemote[1]], 1, 2));

          // Return all transactions
          when(() => mockEventsRepository.getByAddressesVerbose(
              whitelist: DEFAULT_WHITELIST,
              unconfirmed: true,
              addresses: ["0x123"],
              limit: 10)).thenAnswer((_) async => (mockedRemote, 1, 2));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              eventsRepository: mockEventsRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                  transactions: [
                    ActivityFeedItem(hash: "0005", event: mockedRemote[0]),
                    ActivityFeedItem(hash: "0004", event: mockedRemote[1]),
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
    late List<MockEvent> mockedRemote;
    late List<MockEvent> mockedRemote2;

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

          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => mockedLocal);

          final mockEventsRepository = MockEventsRepository();

          mockedRemote = MockEventFactory.createMultiple([
            ("0002", EventStateMempool()),
            ("0003", EventStateConfirmed(blockHeight: 1, blockTime: 1)),
          ]);

          mockedRemote2 = MockEventFactory.createMultiple([
            ("0004", EventStateMempool()),
            ("0005", EventStateConfirmed(blockHeight: 1, blockTime: 1)),
          ]);

          // `LoadMore`
          when(() => mockEventsRepository.getByAddressesVerbose(
              whitelist: DEFAULT_WHITELIST,
              unconfirmed: true,
              addresses: ["0x123"],
              limit: 10,
              cursor: 4)).thenAnswer((_) async => (mockedRemote2, null, 2));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              eventsRepository: mockEventsRepository);
        },
        seed: () => DashboardActivityFeedStateCompleteOk(
              transactions: [
                ActivityFeedItem(hash: "0001", info: mockedLocal[0]),
                ActivityFeedItem(hash: "0002", event: mockedRemote[0]),
                ActivityFeedItem(hash: "0003", event: mockedRemote[1]),
              ],
              newTransactionCount: 0,
              nextCursor: 4,
              mostRecentRemoteHash: "0002",
            ),
        act: (bloc) => bloc..add(const LoadMore()),
        expect: () => [
              DashboardActivityFeedStateReloadingOk(
                transactions: [
                  ActivityFeedItem(hash: "0001", info: mockedLocal[0]),
                  ActivityFeedItem(hash: "0002", event: mockedRemote[0]),
                  ActivityFeedItem(hash: "0003", event: mockedRemote[1]),
                ],
                newTransactionCount: 0,
              ),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  ActivityFeedItem(hash: "0001", info: mockedLocal[0]),
                  ActivityFeedItem(hash: "0002", event: mockedRemote[0]),
                  ActivityFeedItem(hash: "0003", event: mockedRemote[1]),
                  ActivityFeedItem(hash: "0004", event: mockedRemote2[0]),
                  ActivityFeedItem(hash: "0005", event: mockedRemote2[1]),
                ],
                newTransactionCount: 0,
                nextCursor: null,
                mostRecentRemoteHash: "0002",
              ),
            ]);

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "does nothing when no cursor",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: MockTransactionLocalRepository(),
              addressRepository: MockAddressRepository(),
              eventsRepository: MockEventsRepository());
        },
        seed: () => const DashboardActivityFeedStateCompleteOk(
              transactions: [],
              newTransactionCount: 0,
              nextCursor: null,
              mostRecentRemoteHash: "0002",
            ),
        act: (bloc) => bloc..add(const LoadMore()),
        expect: () => []);
  });

  group("LoadQuiet", () {
    late List<MockTransactionInfo> mockedLocal;
    late List<MockEvent> mockedRemote;

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

          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => mockedLocal);

          final mockEventsRepository = MockEventsRepository();

          mockedRemote = MockEventFactory.createMultiple([
            ("0004", EventStateMempool()),
            ("0005", EventStateConfirmed(blockHeight: 1, blockTime: 1)),
            ("0002", EventStateMempool()),
            ("0003", EventStateConfirmed(blockHeight: 1, blockTime: 1)),
          ]);

          // `LoadMore`
          when(() => mockEventsRepository.getByAddressesVerbose(
                unconfirmed: true,
                addresses: ["0x123"],
                cursor: null,
                limit: 10,
                whitelist: DEFAULT_WHITELIST,
              )).thenAnswer((_) async => (mockedRemote, null, null));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              accountUuid: "123",
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              eventsRepository: mockEventsRepository);
        },
        seed: () => DashboardActivityFeedStateCompleteOk(
              transactions: [
                ActivityFeedItem(hash: "0001", info: mockedLocal[0]),
                ActivityFeedItem(hash: "0002", event: mockedRemote[2]),
                ActivityFeedItem(hash: "0003", event: mockedRemote[3]),
              ],
              newTransactionCount: 0,
              nextCursor: 4, // doesn't matter since we are prepending
              mostRecentRemoteHash: "0002",
            ),
        act: (bloc) => bloc..add(const LoadQuiet()),
        expect: () => [
              // isA<DashboardActivityFeedStateReloadingOk>(),
              isA<DashboardActivityFeedStateCompleteOk>()
                  .having(
                    (state) => state.transactions,
                    'transactions',
                    [
                      isA<ActivityFeedItem>()
                          .having((item) => item.hash, 'hash', '0001')
                          .having((item) => item.info, 'info',
                              isA<MockTransactionInfo>()),
                      isA<ActivityFeedItem>()
                          .having((item) => item.hash, 'hash', '0002')
                          .having(
                              (item) => item.event, 'event', isA<MockEvent>()),
                      isA<ActivityFeedItem>()
                          .having((item) => item.hash, 'hash', '0003')
                          .having(
                              (item) => item.event, 'event', isA<MockEvent>()),
                    ],
                  )
                  .having((state) => state.newTransactionCount,
                      'newTransactionCount', 2)
                  .having((state) => state.nextCursor, 'nextCursor', 4)
                  .having((state) => state.mostRecentRemoteHash,
                      'mostRecentRemoteHash', '0002'),
            ]);
  });
}
