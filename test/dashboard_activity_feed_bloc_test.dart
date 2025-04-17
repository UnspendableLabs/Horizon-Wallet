import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import "package:fpdart/src/either.dart";
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/cursor.dart';
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
import 'package:test/test.dart';

// ignore: non_constant_identifier_names
final DEFAULT_WHITELIST = [
  "ENHANCED_SEND",
  "MPMA_SEND",
  "ASSET_ISSUANCE",
  "DISPENSE",
  "OPEN_DISPENSER",
  "REFILL_DISPENSER",
  "RESET_ISSUANCE",
  "ASSET_CREATION",
  "DISPENSER_UPDATE",
  "NEW_FAIRMINT",
  "NEW_FAIRMINTER",
  "OPEN_ORDER",
  "ORDER_MATCH",
  "ORDER_UPDATE",
  "ORDER_FILLED",
  "CANCEL_ORDER",
  "ORDER_EXPIRATION",
  "ATTACH_TO_UTXO",
  "DETACH_FROM_UTXO",
  "UTXO_MOVE",
  "ASSET_DESTRUCTION",
  "ASSET_DIVIDEND",
  "SWEEP",
  "BURN"
];

extension DateTimeExtension on DateTime {
  DateTime stripMilliseconds() {
    return isUtc
        ? DateTime.utc(year, month, day, hour, minute, second)
        : DateTime(year, month, day, hour, minute, second);
  }
}

class LoggerFake extends Fake implements Logger {}

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
  bool isCounterpartyTx(Logger _) => false;
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

  @override
  final int? blockIndex;

  @override
  final String event;

  MockEvent(
      {required this.txHash,
      required this.state,
      required this.blockIndex,
      required this.event});
}

class MockEventFactory {
  static MockEvent create({
    required String txHash,
    required EventState state,
    required String event,
    int? blockIndex,
  }) {
    return MockEvent(
        txHash: txHash, state: state, blockIndex: blockIndex, event: event);
  }

  static List<MockEvent> createMultiple(
    List<(String, EventState, int?, String)> eventSpecs,
  ) {
    return eventSpecs.map((spec) {
      return create(
          txHash: spec.$1, state: spec.$2, blockIndex: spec.$3, event: spec.$4);
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

          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => []);

          when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
              .thenAnswer((_) async => []);

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
            logger: LoggerFake(),
            addresses: ["0x123"],
            pageSize: 10,
            eventsRepository: mockEventsRepository,
            transactionLocalRepository: mockTransactionLocalRepository,
            addressRepository: mockAddressRepository,
            bitcoinRepository: defaultBitcoinRepository,
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

  group("StopPolling", () {
    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        "clears timer",
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();
          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => []);

          when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
              .thenAnswer((_) async => []);

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
              )).thenAnswer((_) async => <VerboseEvent>[]);

          return DashboardActivityFeedBloc(
              logger: LoggerFake(),
              addresses: ["0x123"],
              pageSize: 10,
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
          when(() => mockTransactionLocalRepository.getAllByAccount("123"))
              .thenAnswer((_) async => []);

          when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
              .thenAnswer((_) async => []);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                limit: 10,
                unconfirmed: false,
              )).thenAnswer((_) async => (<VerboseEvent>[], cursor, 0));

          when(() => mockEventsRepository.getAllByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                unconfirmed: true,
              )).thenAnswer((_) async => <VerboseEvent>[]);

          return DashboardActivityFeedBloc(
              logger: LoggerFake(),
              addresses: ["0x123"],
              pageSize: 10,
              transactionLocalRepository: mockTransactionLocalRepository,
              eventsRepository: mockEventsRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository);
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

          when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
              .thenAnswer((_) async => []);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                limit: 10,
                unconfirmed: false,
              )).thenAnswer((_) async => (<VerboseEvent>[], cursor, 0));
          when(() => mockEventsRepository.getAllByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                unconfirmed: true,
              )).thenAnswer((_) async => <VerboseEvent>[]);

          return DashboardActivityFeedBloc(
              logger: LoggerFake(),
              addresses: ["0x123"],
              pageSize: 10,
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        seed: () => const DashboardActivityFeedStateCompleteOk(
            transactions: [],
            nextCursor: null,
            mostRecentCounterpartyEventHash: null,
            mostRecentBitcoinTxHash: null),
        act: (bloc) => bloc.add(const Load()),
        expect: () => [
              const DashboardActivityFeedStateReloadingOk(
                transactions: [],
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

          when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
              .thenAnswer((_) async => []);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                limit: 10,
                unconfirmed: false,
              )).thenAnswer((_) async => (<VerboseEvent>[], cursor, 0));

          when(() => mockEventsRepository.getAllByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                unconfirmed: true,
              )).thenAnswer((_) async => <VerboseEvent>[]);

          return DashboardActivityFeedBloc(
              logger: LoggerFake(),
              addresses: ["0x123"],
              pageSize: 10,
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository,
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
          when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
              .thenAnswer((_) async => []);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                limit: 10,
                unconfirmed: false,
              )).thenAnswer((_) async => (<VerboseEvent>[], cursor, 0));

          when(() => mockEventsRepository.getAllByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                unconfirmed: true,
              )).thenAnswer((_) async => <VerboseEvent>[]);

          return DashboardActivityFeedBloc(
              logger: LoggerFake(),
              addresses: ["0x123"],
              pageSize: 10,
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository,
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
            ("0004", EventStateMempool(), null, 'ASSET_CREATION'),
            (
              "0005",
              EventStateConfirmed(blockHeight: 1, blockTime: 1),
              1,
              'UTXO_MOVE'
            ),
            (
              "0006",
              EventStateConfirmed(blockHeight: 1, blockTime: 1),
              1,
              'ATTACH_UTXO'
            ),
          ]);

          when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
              .thenAnswer((_) async => mockedLocal);

          final mockEventsRepository = MockEventsRepository();

          when(() => mockEventsRepository.getByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                limit: 10,
                unconfirmed: false,
              )).thenAnswer((_) async => (<VerboseEvent>[], cursor, 3));

          when(() => mockEventsRepository.getAllByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                unconfirmed: true,
              )).thenAnswer((_) async => mockedRemote);

          return DashboardActivityFeedBloc(
              logger: LoggerFake(),
              addresses: ["0x123"],
              pageSize: 10,
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: defaultBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  ActivityFeedItem(
                      id: "0001", hash: "0001", info: mockedLocal[0]),
                  ActivityFeedItem(
                      id: "0002", hash: "0002", info: mockedLocal[1]),
                  ActivityFeedItem(
                      id: "0003", hash: "0003", info: mockedLocal[2]),
                  ActivityFeedItem(
                      id: "0004", hash: "0004", event: mockedRemote[0]),
                  ActivityFeedItem(
                      id: "0005",
                      hash: "0005",
                      event: mockedRemote[1],
                      confirmations: 100),
                  ActivityFeedItem(
                      id: "0006",
                      hash: "0006",
                      event: mockedRemote[2],
                      confirmations: 100),
                ],
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

          when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
              .thenAnswer((_) async => mockedLocal);

          final mockEventsRepository = MockEventsRepository();

          mockedRemote = MockEventFactory.createMultiple([
            ("0002", EventStateMempool(), null, 'DISPENSER_UPDATE'),
            (
              "0003",
              EventStateConfirmed(blockHeight: 1, blockTime: 1),
              1,
              'ASSET_CREATION'
            ),
          ]);

          when(() => mockEventsRepository.getByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                limit: 10,
                unconfirmed: false,
              )).thenAnswer((_) async => (<VerboseEvent>[], cursor, 2));

          when(() => mockEventsRepository.getAllByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                unconfirmed: true,
              )).thenAnswer((_) async => mockedRemote);

          final mockBitcoinRepository = MockBitcoinRepository();
          when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
              any(), any())).thenAnswer((_) async => const Right([]));
          when(() => mockBitcoinRepository.getMempoolTransactions(any()))
              .thenAnswer((_) async => const Right([]));
          when(() => mockBitcoinRepository.getBlockHeight())
              .thenAnswer((_) async => const Right(100));

          return DashboardActivityFeedBloc(
              logger: LoggerFake(),
              addresses: ["0x123"],
              pageSize: 10,
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: mockBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  ActivityFeedItem(
                      id: "0001",
                      hash: "0001",
                      info: mockedLocal[0],
                      confirmations: null),
                  ActivityFeedItem(
                      id: "0002", hash: "0002", event: mockedRemote[0]),
                  ActivityFeedItem(
                      id: "0003",
                      hash: "0003",
                      event: mockedRemote[1],
                      confirmations: 100),
                ],
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
          when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
              .thenAnswer((_) async => []);

          mockedRemote = MockEventFactory.createMultiple([
            ("0005", EventStateMempool(), null, 'OPEN_DISPENSER'),
            (
              "0004",
              EventStateConfirmed(
                  blockHeight: 1,
                  blockTime: mostRecentConfirmedBlocktime
                      .toUtc()
                      .toIntDividedBy1000()),
              1,
              'ASSET_CREATION',
            ),
          ]);

          // Return the most recent confirmed transaction
          when(() => mockEventsRepository.getByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                limit: 10,
                unconfirmed: false,
              )).thenAnswer((_) async => ([mockedRemote[1]], cursor, 2));

          // Return all transactions
          when(() => mockEventsRepository.getAllByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                unconfirmed: true,
              )).thenAnswer((_) async => mockedRemote);

          when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
              any(), any())).thenAnswer((_) async => const Right([]));

          when(() => mockBitcoinRepository.getMempoolTransactions(any()))
              .thenAnswer((_) async => const Right([]));

          when(() => mockBitcoinRepository.getBlockHeight())
              .thenAnswer((_) async => const Right(100));

          return DashboardActivityFeedBloc(
              logger: LoggerFake(),
              addresses: ["0x123"],
              pageSize: 10,
              transactionLocalRepository: mockTransactionLocalRepository,
              addressRepository: mockAddressRepository,
              bitcoinRepository: mockBitcoinRepository,
              eventsRepository: mockEventsRepository);
        },
        act: (bloc) => bloc.add(const Load()),
        expect: () => [
              DashboardActivityFeedStateLoading(),
              DashboardActivityFeedStateCompleteOk(
                transactions: [
                  ActivityFeedItem(
                    id: "0005",
                    hash: "0005",
                    event: mockedRemote[0],
                  ),
                  ActivityFeedItem(
                      id: "0004",
                      hash: "0004",
                      event: mockedRemote[1],
                      confirmations: 100),
                ],
                nextCursor: null,
                mostRecentCounterpartyEventHash: "0005",
                mostRecentBitcoinTxHash: null,
              ),
            ]);
  });
  group("LoadQuiet", () {
    late List<MockTransactionInfo> mockedLocal;
    late List<MockEvent> mockedRemote;
    late List<VerboseEvent> mockedMempool;

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        'returns new transactions count = all txs above the most recent remote hash',
        build: () {
          final mockTransactionLocalRepository =
              MockTransactionLocalRepository();
          final mockEventsRepository = MockEventsRepository();
          final mockBitcoinRepository = MockBitcoinRepository();

          // Mock local transactions
          final mockedLocal = MockTransactionInfoFactory.createMultiple([
            (
              "0001",
              TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
            ),
          ]);
          when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
              .thenAnswer((_) async => mockedLocal);

          // Mock remote events - reordered with most recent first
          final mockedRemote = MockEventFactory.createMultiple([
            // Most recent event first (highest block index)
            (
              "0003",
              EventStateConfirmed(
                blockHeight: 6,
                blockTime: DateTime.now().toIntDividedBy1000(),
              ),
              6,
              'UPDATE_DISPENSER'
            ),
            (
              "0002",
              EventStateConfirmed(
                blockHeight: 5,
                blockTime: DateTime.now().toIntDividedBy1000(),
              ),
              5,
              'DISPENSE'
            ),
            (
              "0001",
              EventStateConfirmed(
                blockHeight: 4,
                blockTime: DateTime.now().toIntDividedBy1000(),
              ),
              4,
              'ASSET_CREATION'
            ),
          ]);

          // Mock getAllByAddressesVerbose
          when(() => mockEventsRepository.getAllByAddressesVerbose(
                addresses: any(named: 'addresses'),
                unconfirmed: any(named: 'unconfirmed'),
                whitelist: any(named: 'whitelist'),
              )).thenAnswer((_) async => mockedRemote);

          // Mock getMempoolTransactions
          when(() => mockBitcoinRepository.getMempoolTransactions(any()))
              .thenAnswer((_) async => const Right([]));

          // Mock getConfirmedTransactionsPaginated
          when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
              any(), any())).thenAnswer((_) async => const Right([]));

          // Mock getBlockHeight
          when(() => mockBitcoinRepository.getBlockHeight())
              .thenAnswer((_) async => const Right(100));

          return DashboardActivityFeedBloc(
            logger: LoggerFake(),
            addresses: ["0x123"],
            pageSize: 10,
            transactionLocalRepository: mockTransactionLocalRepository,
            addressRepository: mockAddressRepository,
            bitcoinRepository: mockBitcoinRepository,
            eventsRepository: mockEventsRepository,
          );
        },
        act: (bloc) => bloc.add(const LoadQuiet()),
        expect: () => [
              isA<DashboardActivityFeedStateLoading>(),
              isA<DashboardActivityFeedStateCompleteOk>()
                  .having(
                    (state) => state.transactions,
                    'transactions',
                    [
                      isA<ActivityFeedItem>()
                          .having((item) => item.hash, 'hash', '0003')
                          .having(
                              (item) => item.event, 'event', isA<MockEvent>())
                          .having((item) => item.event!.state, 'state',
                              isA<EventStateConfirmed>())
                          .having((item) => item.confirmations, 'confirmations',
                              95),
                      isA<ActivityFeedItem>()
                          .having((item) => item.hash, 'hash', '0002')
                          .having(
                              (item) => item.event, 'event', isA<MockEvent>())
                          .having((item) => item.event!.state, 'state',
                              isA<EventStateConfirmed>())
                          .having((item) => item.confirmations, 'confirmations',
                              96),
                      isA<ActivityFeedItem>()
                          .having((item) => item.hash, 'hash', '0001')
                          .having(
                              (item) => item.event, 'event', isA<MockEvent>())
                          .having((item) => item.event!.state, 'state',
                              isA<EventStateConfirmed>())
                          .having((item) => item.confirmations, 'confirmations',
                              97),
                    ],
                  )
                  .having((state) => state.nextCursor, 'nextCursor', isNull)
                  .having(
                    (state) => state.mostRecentCounterpartyEventHash,
                    'mostRecentCounterpartyEventHash',
                    '0003',
                  ),
            ]);

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
      "replaces local with remote",
      build: () {
        final mockTransactionLocalRepository = MockTransactionLocalRepository();
        final mockEventsRepository = MockEventsRepository();
        final mockBitcoinRepository = MockBitcoinRepository();

        // Mock local transactions
        mockedLocal = MockTransactionInfoFactory.createMultiple([
          (
            "0001",
            TransactionInfoDomainLocal(raw: "", submittedAt: DateTime.now())
          ),
        ]);
        when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
            .thenAnswer((_) async => mockedLocal);

        // Mock remote events
        mockedRemote = MockEventFactory.createMultiple([
          ("0001", EventStateMempool(), null, 'DISPENSER_UPDATE'),
          (
            "0002",
            EventStateConfirmed(
              blockHeight: 1,
              blockTime: DateTime.now().toIntDividedBy1000(),
            ),
            1,
            'ASSET_ISSUANCE'
          ),
        ]);

        // Mock getAllByAddressesVerbose
        when(() => mockEventsRepository.getAllByAddressesVerbose(
              addresses: any(named: 'addresses'),
              unconfirmed: any(named: 'unconfirmed'),
              whitelist: any(named: 'whitelist'),
            )).thenAnswer((_) async => mockedRemote);

        // Mock Bitcoin repository methods
        when(() => mockBitcoinRepository.getMempoolTransactions(any()))
            .thenAnswer((_) async => const Right([]));
        when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
            any(), any())).thenAnswer((_) async => const Right([]));
        when(() => mockBitcoinRepository.getBlockHeight())
            .thenAnswer((_) async => const Right(100));

        return DashboardActivityFeedBloc(
          logger: LoggerFake(),
          addresses: ["0x123"],
          pageSize: 10,
          transactionLocalRepository: mockTransactionLocalRepository,
          addressRepository: mockAddressRepository,
          bitcoinRepository: mockBitcoinRepository,
          eventsRepository: mockEventsRepository,
        );
      },
      act: (bloc) => bloc.add(const LoadQuiet()),
      expect: () => [
        isA<DashboardActivityFeedStateLoading>(),
        isA<DashboardActivityFeedStateCompleteOk>()
            .having(
              (state) => state.transactions,
              'transactions',
              [
                isA<ActivityFeedItem>()
                    .having((item) => item.hash, 'hash', '0001')
                    .having((item) => item.event, 'event', isA<MockEvent>())
                    .having((item) => item.event!.state, 'state',
                        isA<EventStateMempool>()),
                isA<ActivityFeedItem>()
                    .having((item) => item.hash, 'hash', '0002')
                    .having((item) => item.event, 'event', isA<MockEvent>())
                    .having((item) => item.event!.state, 'state',
                        isA<EventStateConfirmed>())
                    .having((item) => item.confirmations, 'confirmations', 100),
              ],
            )
            .having((state) => state.nextCursor, 'nextCursor', isNull)
            .having(
              (state) => state.mostRecentCounterpartyEventHash,
              'mostRecentCounterpartyEventHash',
              '0001',
            ),
      ],
    );

    blocTest<DashboardActivityFeedBloc, DashboardActivityFeedState>(
      'filters fairmint events correctly',
      build: () {
        final mockTransactionLocalRepository = MockTransactionLocalRepository();
        final mockEventsRepository = MockEventsRepository();
        final mockBitcoinRepository = MockBitcoinRepository();

        when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
            .thenAnswer((_) async => []);

        when(() => mockEventsRepository.getAllByAddressesVerbose(
              addresses: any(named: 'addresses'),
              unconfirmed: any(named: 'unconfirmed'),
              whitelist: any(named: 'whitelist'),
            )).thenAnswer((_) async => [
              VerboseAssetIssuanceEvent(
                state: EventStateMempool(),
                eventIndex: 1,
                event: 'ASSET_ISSUANCE',
                txHash:
                    'a6a931dd17f83d9387caa0f72617544af607520566b062d794f9d9f8b382eef5',
                blockIndex: 9999999,
                blockTime: 1733496111,
                params: VerboseAssetIssuanceParams(
                  assetEvents: 'fairmint',
                  asset: 'fairmint',
                  assetLongname: 'fairmint',
                  quantity: 1,
                  source: 'fairmint',
                  status: EventStatusValid(),
                  transfer: true,
                  feePaidNormalized: '0',
                  blockTime: 1733496111,
                ),
              ),
              VerboseEvent(
                state: EventStateMempool(),
                eventIndex: 2,
                event: 'NEW_FAIRMINT',
                txHash:
                    'a6a931dd17f83d9387caa0f72617544af607520566b062d794f9d9f8b382eef5',
                blockIndex: 9999999,
                blockTime: 1733496111,
              ),
            ]);

        when(() => mockBitcoinRepository.getMempoolTransactions(any()))
            .thenAnswer((_) async => const Right([]));

        when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
            any(), any())).thenAnswer((_) async => const Right([]));

        when(() => mockBitcoinRepository.getBlockHeight())
            .thenAnswer((_) async => const Right(100));

        return DashboardActivityFeedBloc(
          logger: LoggerFake(),
          addresses: ["0x123"],
          pageSize: 10,
          transactionLocalRepository: mockTransactionLocalRepository,
          addressRepository: mockAddressRepository,
          bitcoinRepository: mockBitcoinRepository,
          eventsRepository: mockEventsRepository,
        );
      },
      act: (bloc) => bloc.add(const LoadQuiet()),
      expect: () => [
        isA<DashboardActivityFeedStateLoading>(),
        isA<DashboardActivityFeedStateCompleteOk>().having(
          (state) => state.transactions.length,
          'filtered transactions count',
          1, // Only the ASSET_ISSUANCE event should be present
        ),
      ],
    );
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
            when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
                .thenAnswer((_) async => mockedLocal);

            // btc mocks
            final mockBitcoinRepository = MockBitcoinRepository();
            mockedBtcMempool = MockBitcoinTxFactory.createMultiple([
              ("btx_1", false, 0, "", 0),
            ]);
            when(() => mockBitcoinRepository.getMempoolTransactions(any()))
                .thenAnswer((_) async => Right(mockedBtcMempool));

            when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
                any(), any())).thenAnswer((_) async => const Right([]));
            when(() => mockBitcoinRepository.getBlockHeight())
                .thenAnswer((_) async => const Right(100));

            // cp event mocks
            final mockEventsRepository = MockEventsRepository();

            when(() => mockEventsRepository.getByAddressesVerbose(
                    addresses: ["0x123"],
                    whitelist: DEFAULT_WHITELIST,
                    limit: 10,
                    unconfirmed: false))
                .thenAnswer((_) async => (<VerboseEvent>[], null, 3));

            when(() => mockEventsRepository.getAllByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                unconfirmed: true)).thenAnswer((_) async => <VerboseEvent>[]);

            return DashboardActivityFeedBloc(
                logger: LoggerFake(),
                addresses: ["0x123"],
                pageSize: 10,
                transactionLocalRepository: mockTransactionLocalRepository,
                addressRepository: mockAddressRepository,
                bitcoinRepository: mockBitcoinRepository,
                eventsRepository: mockEventsRepository);
          },
          act: (bloc) => bloc..add(const Load()),
          expect: () => [
                DashboardActivityFeedStateLoading(),
                DashboardActivityFeedStateCompleteOk(
                  transactions: [
                    ActivityFeedItem(
                        id: "btc_1",
                        hash: "btx_1",
                        bitcoinTx: mockedBtcMempool[0]),
                  ],
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
            when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
                .thenAnswer((_) async => mockedLocal);

            when(() => mockTransactionLocalRepository.getAllByAddresses(any()))
                .thenAnswer((_) async => mockedLocal);

            // btc mocks
            final mockBitcoinRepository = MockBitcoinRepository();
            mockedBtcConfirmed = MockBitcoinTxFactory.createMultiple([
              ("btx_1", true, 0, "", 1),
            ]);
            when(() => mockBitcoinRepository.getMempoolTransactions(any()))
                .thenAnswer((_) async => const Right([]));

            when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
                    "0x123", null))
                .thenAnswer((_) async => Right(mockedBtcConfirmed));

            when(() => mockBitcoinRepository.getConfirmedTransactionsPaginated(
                "0x123", "btx_1")).thenAnswer((_) async => const Right([]));

            // cp event mocks
            final mockEventsRepository = MockEventsRepository();

            when(() => mockEventsRepository.getByAddressesVerbose(
                    addresses: ["0x123"],
                    whitelist: DEFAULT_WHITELIST,
                    limit: 10,
                    unconfirmed: false))
                .thenAnswer((_) async => (<VerboseEvent>[], null, 3));

            when(() => mockEventsRepository.getAllByAddressesVerbose(
                addresses: ["0x123"],
                whitelist: DEFAULT_WHITELIST,
                // limit: 10,
                unconfirmed: true)).thenAnswer((_) async => <VerboseEvent>[]);
            when(() => mockBitcoinRepository.getBlockHeight())
                .thenAnswer((_) async => const Right(100));

            return DashboardActivityFeedBloc(
                logger: LoggerFake(),
                addresses: ["0x123"],
                pageSize: 10,
                transactionLocalRepository: mockTransactionLocalRepository,
                addressRepository: mockAddressRepository,
                bitcoinRepository: mockBitcoinRepository,
                eventsRepository: mockEventsRepository);
          },
          act: (bloc) => bloc..add(const Load()),
          expect: () => [
                DashboardActivityFeedStateLoading(),
                DashboardActivityFeedStateCompleteOk(
                  transactions: [
                    ActivityFeedItem(
                        id: "btc_1",
                        hash: "btx_1",
                        bitcoinTx: mockedBtcConfirmed[0],
                        confirmations: 101),
                  ],
                  nextCursor: null,
                  mostRecentCounterpartyEventHash: null,
                  mostRecentBitcoinTxHash: "btx_1",
                ),
              ]);
    });
  });
}
