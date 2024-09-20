import 'package:decimal/decimal.dart';
import 'package:horizon/domain/entities/cursor.dart';
import 'package:test/test.dart';
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import "package:fpdart/src/either.dart";
import 'package:horizon/domain/entities/activity_feed_item.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_state.dart";
import 'package:mocktail/mocktail.dart';

// ignore: non_constant_identifier_names
final DEFAULT_WHITELIST = [
  "ENHANCED_SEND",
  "ASSET_ISSUANCE",
  "DISPENSE",
];

extension DateTimeExtension on DateTime {
  DateTime stripMilliseconds() {
    return isUtc
        ? DateTime.utc(year, month, day, hour, minute, second)
        : DateTime(year, month, day, hour, minute, second);
  }
}

class AddressMock extends Mock implements Address {
  @override
  final address = "0x123";
}

class MockBitcoinTx extends Mock implements BitcoinTx {
  @override
  final String txid;
  @override
  final Status status;

  MockBitcoinTx({
    required this.txid,
    required this.status,
  });

  @override
  TransactionType getTransactionType(List<String> addresses) =>
      TransactionType.neither;

  @override
  Decimal getAmountSent(List<String> addresses) => Decimal.zero;

  @override
  Decimal getAmountReceived(List<String> addresses) => Decimal.zero;

  @override
  bool isCounterpartyTx(List<String> addresses) => false;
}

class MockStatus extends Mock implements Status {
  @override
  final bool confirmed;
  @override
  final int? blockHeight;
  @override
  final String? blockHash;
  @override
  final int? blockTime;

  MockStatus({
    required this.confirmed,
    this.blockHeight,
    this.blockHash,
    this.blockTime,
  });
}

class MockBitcoinTxFactory {
  static MockBitcoinTx create({
    required String txid,
    required bool confirmed,
    int? blockHeight,
    String? blockHash,
    int? blockTime,
  }) {
    return MockBitcoinTx(
      txid: txid,
      status: MockStatus(
        confirmed: confirmed,
        blockHeight: blockHeight,
        blockHash: blockHash,
        blockTime: blockTime,
      ),
    );
  }

  static List<MockBitcoinTx> createMultiple(
    List<(String, bool, int?, String?, int?)> txSpecs,
  ) {
    return txSpecs.map((spec) {
      return create(
        txid: spec.$1,
        confirmed: spec.$2,
        blockHeight: spec.$3,
        blockHash: spec.$4,
        blockTime: spec.$5,
      );
    }).toList();
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

class MockBitcoinRepository extends Mock implements BitcoinRepository {}

class MockTransactionInfo extends Mock implements TransactionInfoVerbose {
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

  @override
  final int? blockIndex;

  MockEvent(
      {required this.txHash, required this.state, required this.blockIndex});
}

class MockEventFactory {
  static MockEvent create({
    required String txHash,
    required EventState state,
    int? blockIndex,
  }) {
    return MockEvent(txHash: txHash, state: state, blockIndex: blockIndex);
  }

  static List<MockEvent> createMultiple(
    List<(String, EventState, int?)> eventSpecs,
  ) {
    return eventSpecs.map((spec) {
      return create(txHash: spec.$1, state: spec.$2, blockIndex: spec.$3);
    }).toList();
  }
}

void main() {
  final mockAddressRepository = MockAddressRepository();
  when(() => mockAddressRepository.getAllByAccountUuid("123")).thenAnswer(
      (_) async =>
          [const Address(index: 0, address: "0x123", accountUuid: "123")]);

  final defaultBitcoinRepository = MockBitcoinRepository();

  when(() => defaultBitcoinRepository.getTransactions(any()))
      .thenAnswer((_) async => const Right([]));

  when(() => defaultBitcoinRepository.getMempoolTransactions(any()))
      .thenAnswer((_) async => const Right([]));

  when(() => defaultBitcoinRepository.getConfirmedTransactions(any()))
      .thenAnswer((_) async => const Right([]));

  when(() => defaultBitcoinRepository.getConfirmedTransactionsPaginated(
      any(), any())).thenAnswer((_) async => const Right([]));

  final Cursor cursor = Cursor.fromInt(1);

  when(() => defaultBitcoinRepository.getBlockHeight())
      .thenAnswer((_) async => const Right(100));

  group("StartPolling", () {
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "sets timer",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();

          when(() =>
                  mockTransactionLocalRepository.getAllByAccountVerbose("123"))
              .thenAnswer((_) async => []);

          when(() => mockTransactionLocalRepository
              .getAllByAddressesVerbose(any())).thenAnswer((_) async => []);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                addresses: ["0x123"],
                limit: 10,
                unconfirmed: false,
                whitelist: DEFAULT_WHITELIST,
              )).thenAnswer((_) async => (<VerboseEvent>[], cursor, 0));

          when(() => mockEventsRepository.getAllByAddressesVerbose(
                addresses: ["0x123"],
                unconfirmed: true,
                whitelist: DEFAULT_WHITELIST,
              )).thenAnswer((_) async => []);

          return DashboardActivityFeedBloc(
            currentAddress: AddressMock(),
            pageSize: 10,
            eventsRepository: mockEventsRepository,
            transactionLocalRepository: mockTransactionLocalRepository,
            addressRepository: mockAddressRepository,
            bitcoinRepository: defaultBitcoinRepository,
          );
        },
        act: (bloc) =>
            bloc.add(const StartPolling(interval: Duration(seconds: 2))),
        wait: const Duration(seconds: 2),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              isA<DashboardActivityFeedState>()
            ],
        verify: (bloc) {
          expect(bloc.timer, isA<Timer>());
        });
  });

  group("StopPolling", () {
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "clears timer",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();
          when(() =>
                  mockTransactionLocalRepository.getAllByAccountVerbose("123"))
              .thenAnswer((_) async => []);

          when(() => mockTransactionLocalRepository
              .getAllByAddressesVerbose(any())).thenAnswer((_) async => []);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false,
                  whitelist: DEFAULT_WHITELIST))
              .thenAnswer((_) async => (<VerboseEvent>[], cursor, 0));

          when(() => mockEventsRepository.getAllByAddressesVerbose(
                whitelist: DEFAULT_WHITELIST,
                addresses: ["0x123"],
                unconfirmed: true,
              )).thenAnswer((_) async => <VerboseEvent>[]);

          return DashboardActivityFeedBloc(
              pageSize: 10,
              currentAddress: AddressMock(),
              transactionLocalRepository: mockTransactionLocalRepository,
              eventsRepository: mockEventsRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository);
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

  group("Load", () {
    blocTest("emits loading state when load event is added",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();
          when(() =>
                  mockTransactionLocalRepository.getAllByAccountVerbose("123"))
              .thenAnswer((_) async => []);

          when(() => mockTransactionLocalRepository
              .getAllByAddressesVerbose(any())).thenAnswer((_) async => []);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => (<VerboseEvent>[], cursor, 0));

          when(() => mockEventsRepository.getAllByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                unconfirmed: true,
              )).thenAnswer((_) async => <VerboseEvent>[]);

          return DashboardActivityFeedBloc(
              pageSize: 10,
              currentAddress: AddressMock(),
              transactionLocalRepository: mockTransactionLocalRepository,
              eventsRepository: mockEventsRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(seconds: 2),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              isA<DashboardActivityFeedState>()
            ]);
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "emits reloading ok when state is complete ok",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();
          when(() =>
                  mockTransactionLocalRepository.getAllByAccountVerbose("123"))
              .thenAnswer((_) async => []);

          when(() => mockTransactionLocalRepository
              .getAllByAddressesVerbose(any())).thenAnswer((_) async => []);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => (<VerboseEvent>[], cursor, 0));
          when(() => mockEventsRepository.getAllByAddressesVerbose(
                whitelist: DEFAULT_WHITELIST,
                addresses: ["0x123"],
                unconfirmed: true,
              )).thenAnswer((_) async => <VerboseEvent>[]);

          return DashboardActivityFeedBloc(
              pageSize: 10,
              currentAddress: AddressMock(),
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        seed: () => const DashboardActivityFeedStateCompleteOk(
            transactions: [],
            newTransactionCount: 0,
            nextCursor: null,
            mostRecentCounterpartyEventHash: null,
            mostRecentBitcoinTxHash: null),
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(seconds: 2),
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

          when(() =>
                  mockTransactionLocalRepository.getAllByAccountVerbose("123"))
              .thenAnswer((_) async => []);

          when(() => mockTransactionLocalRepository
              .getAllByAddressesVerbose(any())).thenAnswer((_) async => []);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => (<VerboseEvent>[], cursor, 0));

          when(() => mockEventsRepository.getAllByAddressesVerbose(
                whitelist: DEFAULT_WHITELIST,
                addresses: ["0x123"],
                unconfirmed: true,
              )).thenAnswer((_) async => <VerboseEvent>[]);

          return DashboardActivityFeedBloc(
              pageSize: 10,
              currentAddress: AddressMock(),
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        seed: () =>
            const DashboardActivityFeedStateCompleteError(error: "error"),
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(seconds: 2),
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
          when(() =>
                  mockTransactionLocalRepository.getAllByAccountVerbose("123"))
              .thenAnswer((_) async => []);
          when(() => mockTransactionLocalRepository
              .getAllByAddressesVerbose(any())).thenAnswer((_) async => []);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => (<VerboseEvent>[], cursor, 0));

          when(() => mockEventsRepository.getAllByAddressesVerbose(
                whitelist: DEFAULT_WHITELIST,
                addresses: ["0x123"],
                unconfirmed: true,
              )).thenAnswer((_) async => <VerboseEvent>[]);

          return DashboardActivityFeedBloc(
              pageSize: 10,
              currentAddress: AddressMock(),
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        seed: () =>
            const DashboardActivityFeedStateCompleteError(error: "error"),
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(seconds: 2),
        expect: () => [
              const DashboardActivityFeedStateReloadingError(
                error: "error",
              ),
              isA<DashboardActivityFeedState>()
            ]);

    late List<MockTransactionInfo> mockedLocal;
    late List<MockEvent> mockedRemote;

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "interleaving non overlapping",
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
            ("0004", EventStateMempool(), null),
            ("0005", EventStateConfirmed(blockHeight: 1, blockTime: 1), 1),
            ("0006", EventStateConfirmed(blockHeight: 1, blockTime: 1), 1),
          ]);

          when(() => mockTransactionLocalRepository.getAllByAddressesVerbose(
              any())).thenAnswer((_) async => mockedLocal);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => (<VerboseEvent>[], cursor, 3));

          when(() => mockEventsRepository.getAllByAddressesVerbose(
                whitelist: DEFAULT_WHITELIST,
                addresses: ["0x123"],
                unconfirmed: true,
              )).thenAnswer((_) async => mockedRemote);

          return DashboardActivityFeedBloc(
              pageSize: 10,
              currentAddress: AddressMock(),
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(seconds: 2),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  ActivityFeedItem(hash: "0001", info: mockedLocal[0]),
                  ActivityFeedItem(hash: "0002", info: mockedLocal[1]),
                  ActivityFeedItem(hash: "0003", info: mockedLocal[2]),
                  ActivityFeedItem(hash: "0004", event: mockedRemote[0]),
                  ActivityFeedItem(
                      hash: "0005", event: mockedRemote[1], confirmations: 100),
                  ActivityFeedItem(
                      hash: "0006", event: mockedRemote[2], confirmations: 100),
                ],
                newTransactionCount: 0,
                nextCursor: null,
                mostRecentCounterpartyEventHash: "0004",
                mostRecentBitcoinTxHash: null,
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

          when(() => mockTransactionLocalRepository.getAllByAddressesVerbose(
              any())).thenAnswer((_) async => mockedLocal);

          final mockEventsRepository = MockEventsRepository();

          mockedRemote = MockEventFactory.createMultiple([
            ("0002", EventStateMempool(), null),
            ("0003", EventStateConfirmed(blockHeight: 1, blockTime: 1), 1),
          ]);

          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => (<VerboseEvent>[], cursor, 2));

          when(() => mockEventsRepository.getAllByAddressesVerbose(
                whitelist: DEFAULT_WHITELIST,
                addresses: ["0x123"],
                unconfirmed: true,
              )).thenAnswer((_) async => mockedRemote);

          final mockBitcoinRepository = MockBitcoinRepository();
          when(() => mockBitcoinRepository.getConfirmedTransactions(any()))
              .thenAnswer((_) async => const Right([]));
          when(() => mockBitcoinRepository.getMempoolTransactions(any()))
              .thenAnswer((_) async => const Right([]));
          when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
              any(), any())).thenAnswer((_) async => const Right([]));
          when(() => mockBitcoinRepository.getBlockHeight())
              .thenAnswer((_) async => const Right(100));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              currentAddress: AddressMock(),
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: mockBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(seconds: 2),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  ActivityFeedItem(
                      hash: "0001", info: mockedLocal[0], confirmations: null),
                  ActivityFeedItem(hash: "0002", event: mockedRemote[0]),
                  ActivityFeedItem(
                      hash: "0003", event: mockedRemote[1], confirmations: 100),
                ],
                newTransactionCount: 0,
                nextCursor: null,
                mostRecentCounterpartyEventHash: "0002",
                mostRecentBitcoinTxHash: null,
              ),
            ]);

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "first remote, newer than local",
        build: () {
          DateTime mostRecentConfirmedBlocktime =
              PastDateTime.subtractDuration(const Duration(seconds: 1))
                  .stripMilliseconds();

          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();

          final mockEventsRepository = MockEventsRepository();
          final mockBitcoinRepository = MockBitcoinRepository();
          // effectively asserts that right method is calleD with right args
          when(() => mockTransactionLocalRepository
              .getAllByAddressesVerbose(any())).thenAnswer((_) async => []);

          mockedRemote = MockEventFactory.createMultiple([
            ("0005", EventStateMempool(), null),
            (
              "0004",
              EventStateConfirmed(
                  blockHeight: 1,
                  blockTime: mostRecentConfirmedBlocktime
                      .toUtc()
                      .toIntDividedBy1000()),
              1
            ),
          ]);

          // Return the most recent confirmed transaction
          when(() => mockEventsRepository.getByAddressesVerbose(
                  whitelist: DEFAULT_WHITELIST,
                  addresses: ["0x123"],
                  limit: 10,
                  unconfirmed: false))
              .thenAnswer((_) async => ([mockedRemote[1]], cursor, 2));

          // Return all transactions
          when(() => mockEventsRepository.getAllByAddressesVerbose(
                whitelist: DEFAULT_WHITELIST,
                unconfirmed: true,
                addresses: ["0x123"],
              )).thenAnswer((_) async => mockedRemote);

          when(() => mockBitcoinRepository.getConfirmedTransactions(any()))
              .thenAnswer((_) async => const Right([]));

          when(() => mockBitcoinRepository.getMempoolTransactions(any()))
              .thenAnswer((_) async => const Right([]));

          when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
              any(), any())).thenAnswer((_) async => const Right([]));
          when(() => mockBitcoinRepository.getBlockHeight())
              .thenAnswer((_) async => const Right(100));

          return DashboardActivityFeedBloc(
              pageSize: 10,
              currentAddress: AddressMock(),
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: mockBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        wait: const Duration(seconds: 2),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  ActivityFeedItem(
                    hash: "0005",
                    event: mockedRemote[0],
                  ),
                  ActivityFeedItem(
                      hash: "0004", event: mockedRemote[1], confirmations: 100),
                ],
                newTransactionCount: 0,
                nextCursor: null,
                mostRecentCounterpartyEventHash: "0005",
                mostRecentBitcoinTxHash: null,
              ),
            ]);
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

          when(() =>
                  mockTransactionLocalRepository.getAllByAccountVerbose("123"))
              .thenAnswer((_) async => mockedLocal);

          final mockEventsRepository = MockEventsRepository();

          mockedRemote = MockEventFactory.createMultiple([
            ("0004", EventStateMempool(), null),
            ("0005", EventStateConfirmed(blockHeight: 1, blockTime: 1), 1),
            ("0002", EventStateMempool(), null),
            ("0003", EventStateConfirmed(blockHeight: 1, blockTime: 1), 1),
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
              currentAddress: AddressMock(),
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        seed: () => DashboardActivityFeedStateCompleteOk(
              transactions: [
                ActivityFeedItem(hash: "0001", info: mockedLocal[0]),
                ActivityFeedItem(hash: "0002", event: mockedRemote[2]),
                ActivityFeedItem(
                    hash: "0003", event: mockedRemote[3], confirmations: 100),
              ],
              newTransactionCount: 0,
              nextCursor:
                  Cursor.fromInt(4), // doesn't matter since we are prepending
              mostRecentCounterpartyEventHash: "0002",
              mostRecentBitcoinTxHash: null,
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
                              isA<MockTransactionInfo>())
                          .having((item) => item.confirmations, 'confirmations',
                              null),
                      isA<ActivityFeedItem>()
                          .having((item) => item.hash, 'hash', '0002')
                          .having(
                              (item) => item.event, 'event', isA<MockEvent>())
                          .having((item) => item.confirmations, 'confirmations',
                              null),
                      isA<ActivityFeedItem>()
                          .having((item) => item.hash, 'hash', '0003')
                          .having(
                              (item) => item.event, 'event', isA<MockEvent>())
                          .having((item) => item.confirmations, 'confirmations',
                              100),
                    ],
                  )
                  .having((state) => state.newTransactionCount,
                      'newTransactionCount', 2)
                  .having(
                      (state) => state.nextCursor, 'nextCursor', isA<Cursor>())
                  .having((state) => state.mostRecentCounterpartyEventHash,
                      'mostRecentCounterpartyEventHash', '0002'),
            ]);

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "replaces local with remote ",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();
          mockedLocal = MockTransactionInfoFactory.createMultiple([
            (
              "0001",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
          ]);

          when(() =>
                  mockTransactionLocalRepository.getAllByAccountVerbose("123"))
              .thenAnswer((_) async => mockedLocal);

          final mockEventsRepository = MockEventsRepository();
          mockedRemote = MockEventFactory.createMultiple([
            ("0001", EventStateMempool(), null),
            (
              "0002",
              EventStateConfirmed(
                  blockHeight: 1,
                  blockTime: DateTime.now().toIntDividedBy1000()),
              1
            ),
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
              currentAddress: AddressMock(),
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        seed: () => DashboardActivityFeedStateCompleteOk(
              transactions: [
                ActivityFeedItem(hash: "0001", info: mockedLocal[0]),
                ActivityFeedItem(
                    hash: "0002", event: mockedRemote[1], confirmations: 100),
              ],
              newTransactionCount: 0,
              nextCursor: Cursor.fromInt(4),
              mostRecentCounterpartyEventHash: "0002",
              mostRecentBitcoinTxHash: null,
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
                          .having(
                              (item) => item.event, 'event', isA<MockEvent>())
                          .having((item) => item.confirmations, 'confirmations',
                              null),
                      isA<ActivityFeedItem>()
                          .having((item) => item.hash, 'hash', '0002')
                          .having(
                              (item) => item.event, 'event', isA<MockEvent>())
                          .having((item) => item.confirmations, 'confirmations',
                              100),
                    ],
                  )
                  .having((state) => state.newTransactionCount,
                      'newTransactionCount', 0)
                  .having(
                      (state) => state.nextCursor, 'nextCursor', isA<Cursor>())
                  .having((state) => state.mostRecentCounterpartyEventHash,
                      'mostRecentCounterpartyEventHash', '0001'),
            ]);

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "replaces 2 local with remote ",
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
          ]);

          when(() =>
                  mockTransactionLocalRepository.getAllByAccountVerbose("123"))
              .thenAnswer((_) async => mockedLocal);

          final mockEventsRepository = MockEventsRepository();

          mockedRemote = MockEventFactory.createMultiple([
            (
              "0001",
              EventStateConfirmed(
                  blockHeight: 4,
                  blockTime: DateTime.now().toIntDividedBy1000()),
              4
            ),
            (
              "0002",
              EventStateConfirmed(
                  blockHeight: 5,
                  blockTime: DateTime.now().toIntDividedBy1000()),
              5
            ),
            (
              "0003",
              EventStateConfirmed(
                  blockHeight: 6,
                  blockTime: DateTime.now().toIntDividedBy1000()),
              6
            ),
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
              currentAddress: AddressMock(),
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        seed: () => DashboardActivityFeedStateCompleteOk(
              transactions: [
                ActivityFeedItem(hash: "0001", info: mockedLocal[0]),
                ActivityFeedItem(hash: "0002", info: mockedLocal[1]),
                ActivityFeedItem(
                    hash: "0003", event: mockedRemote[2], confirmations: 95),
              ],
              newTransactionCount: 0,
              nextCursor: Cursor.fromInt(4),
              mostRecentCounterpartyEventHash: "0003",
              mostRecentBitcoinTxHash: null,
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
                          .having(
                              (item) => item.event, 'event', isA<MockEvent>())
                          .having((item) => item.event!.state, 'state',
                              isA<EventStateConfirmed>())
                          .having((item) => item.confirmations, 'confirmations',
                              97),
                      isA<ActivityFeedItem>()
                          .having((item) => item.hash, 'hash', '0002')
                          .having(
                              (item) => item.event, 'event', isA<MockEvent>())
                          .having((item) => item.event!.state, 'state',
                              isA<EventStateConfirmed>())
                          .having((item) => item.confirmations, 'confirmations',
                              96),
                      isA<ActivityFeedItem>()
                          .having((item) => item.hash, 'hash', '0003')
                          .having(
                              (item) => item.event, 'event', isA<MockEvent>())
                          .having((item) => item.event!.state, 'state',
                              isA<EventStateConfirmed>())
                          .having((item) => item.confirmations, 'confirmations',
                              95),
                    ],
                  )
                  .having((state) => state.newTransactionCount,
                      'newTransactionCount', 0)
                  .having(
                      (state) => state.nextCursor, 'nextCursor', isA<Cursor>())
                  .having((state) => state.mostRecentCounterpartyEventHash,
                      'mostRecentCounterpartyEventHash', '0001'),
            ]);
  });

  group("w bitcoin_tx", () {
    group("Load", () {
      late List<MockTransactionInfo> mockedLocal;
      late List<MockBitcoinTx> mockedBtcMempool;
      late List<MockBitcoinTx> mockedBtcConfirmed;

      blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
          "interleaving 1 btx local, 1 btx mempool",
          build: () {
            // local mocks
            final mockTransactionLocalRepository =
                MockTransactionLocalRepository();
            mockedLocal = MockTransactionInfoFactory.createMultiple([
              (
                "btx_1",
                TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
              ),
            ]);
            when(() => mockTransactionLocalRepository.getAllByAddressesVerbose(
                any())).thenAnswer((_) async => mockedLocal);

            // btc mocks
            final mockBitcoinRepository = MockBitcoinRepository();
            mockedBtcMempool = MockBitcoinTxFactory.createMultiple([
              ("btx_1", false, 0, "", 0),
            ]);
            when(() => mockBitcoinRepository.getMempoolTransactions(any()))
                .thenAnswer((_) async => Right(mockedBtcMempool));

            when(() => mockBitcoinRepository.getConfirmedTransactions(any()))
                .thenAnswer((_) async => const Right([]));
            when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
                any(), any())).thenAnswer((_) async => const Right([]));
            when(() => mockBitcoinRepository.getBlockHeight())
                .thenAnswer((_) async => const Right(100));

            // cp event mocks
            final mockEventsRepository = MockEventsRepository();

            when(() => mockEventsRepository.getByAddressesVerbose(
                    whitelist: DEFAULT_WHITELIST,
                    addresses: ["0x123"],
                    limit: 10,
                    unconfirmed: false))
                .thenAnswer((_) async => (<VerboseEvent>[], null, 3));

            when(() => mockEventsRepository.getAllByAddressesVerbose(
                whitelist: DEFAULT_WHITELIST,
                addresses: ["0x123"],
                unconfirmed: true)).thenAnswer((_) async => <VerboseEvent>[]);

            return DashboardActivityFeedBloc(
                pageSize: 10,
                currentAddress: AddressMock(),
                transactionLocalRepository: mockTransactionLocalRepository,
                addressRepository: mockAddressRepository,
                bitcoinRepository: mockBitcoinRepository,
                eventsRepository: mockEventsRepository);
          },
          act: (bloc) => bloc..add(const Load()),
          wait: const Duration(seconds: 2),
          expect: () => [
                DashboardActivityFeedStateLoading(),
                DashboardActivityFeedStateCompleteOk(
                  transactions: [
                    ActivityFeedItem(
                        hash: "btx_1", bitcoinTx: mockedBtcMempool[0]),
                  ],
                  newTransactionCount: 0,
                  nextCursor: null,
                  mostRecentCounterpartyEventHash: null,
                  mostRecentBitcoinTxHash: "btx_1",
                ),
              ]);

      blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
          "interleaving 1 btx local, 1 btx confirmed",
          build: () {
            // local mocks
            final mockTransactionLocalRepository =
                MockTransactionLocalRepository();
            mockedLocal = MockTransactionInfoFactory.createMultiple([
              (
                "btx_1",
                TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
              ),
            ]);
            when(() => mockTransactionLocalRepository.getAllByAddressesVerbose(
                any())).thenAnswer((_) async => mockedLocal);

            when(() => mockTransactionLocalRepository.getAllByAddressesVerbose(
                any())).thenAnswer((_) async => mockedLocal);

            // btc mocks
            final mockBitcoinRepository = MockBitcoinRepository();
            mockedBtcConfirmed = MockBitcoinTxFactory.createMultiple([
              ("btx_1", true, 0, "", 1),
            ]);
            when(() => mockBitcoinRepository.getMempoolTransactions(any()))
                .thenAnswer((_) async => const Right([]));

            when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
                    any(), any()))
                .thenAnswer((_) async => Right(mockedBtcConfirmed));

            when(() => mockBitcoinRepository.getConfirmedTransactions(any()))
                .thenAnswer((_) async => Right(mockedBtcConfirmed));
            // cp event mocks
            final mockEventsRepository = MockEventsRepository();

            when(() => mockEventsRepository.getByAddressesVerbose(
                    whitelist: DEFAULT_WHITELIST,
                    addresses: ["0x123"],
                    limit: 10,
                    unconfirmed: false))
                .thenAnswer((_) async => (<VerboseEvent>[], null, 3));

            when(() => mockEventsRepository.getAllByAddressesVerbose(
                whitelist: DEFAULT_WHITELIST,
                addresses: ["0x123"],
                // limit: 10,
                unconfirmed: true)).thenAnswer((_) async => <VerboseEvent>[]);
            when(() => mockBitcoinRepository.getBlockHeight())
                .thenAnswer((_) async => const Right(100));

            return DashboardActivityFeedBloc(
                pageSize: 10,
                currentAddress: AddressMock(),
                transactionLocalRepository: mockTransactionLocalRepository,
                addressRepository: mockAddressRepository,
                bitcoinRepository: mockBitcoinRepository,
                eventsRepository: mockEventsRepository);
          },
          act: (bloc) => bloc..add(const Load()),
          wait: const Duration(seconds: 2),
          expect: () => [
                DashboardActivityFeedStateLoading(),
                DashboardActivityFeedStateCompleteOk(
                  transactions: [
                    ActivityFeedItem(
                        hash: "btx_1",
                        bitcoinTx: mockedBtcConfirmed[0],
                        confirmations: 101),
                  ],
                  newTransactionCount: 0,
                  nextCursor: null,
                  mostRecentCounterpartyEventHash: null,
                  mostRecentBitcoinTxHash: "btx_1",
                ),
              ]);
    });
  });
}
