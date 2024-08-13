import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';

import "package:equatable/equatable.dart";

class ActivityFeedItem extends Equatable {
  final String hash;
  final Event? event;
  final TransactionInfo? info;
  final BitcoinTx? bitcoinTx;

  const ActivityFeedItem(
      {required this.hash, this.event, this.info, this.bitcoinTx});

  @override
  List<Object?> get props => [hash, event, info, bitcoinTx];

  int? getBlockIndex() => switch (this) {
        ActivityFeedItem(event: Event(blockIndex: final index?)) => index,
        ActivityFeedItem(
          bitcoinTx: BitcoinTx(status: Status(blockHeight: final height?))
        ) =>
          height,
        _ => null
      };

  bool isMempool() => switch (this) {
        ActivityFeedItem(event: Event(state: EventStateMempool())) => true,
        ActivityFeedItem(
          bitcoinTx: BitcoinTx(status: Status(confirmed: false))
        ) =>
          true,
        _ => false,
      };
}
