import 'package:flutter/material.dart';
import "package:decimal/decimal.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_state.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';

import 'package:horizon/presentation/common/tx_hash_display.dart';

enum SendSide { source, destination }

// TODO: move to some util file
Decimal satoshisToBtc(int satoshis) {
  // No need to check for null as int cannot be null in non-nullable Dart

  // Conversion factor
  final Decimal btcFactor = Decimal.fromInt(100000000);

  // Perform conversion
  final btcValue = Decimal.fromInt(satoshis) / btcFactor;

  // Round to 8 decimal places
  return btcValue.toDecimal().round(scale: 8);
}

class SendTitle extends StatelessWidget {
  // final String destination;
  final String quantityNormalized;
  final String asset;
  SendTitle({
    super.key,
    // required this.destination,
    required this.quantityNormalized,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Text("Send $quantityNormalized $asset");
  }
}

class ReceiveTitle extends StatelessWidget {
  // final String source;
  final String quantityNormalized;
  final String asset;
  ReceiveTitle({
    super.key,
    // required this.source,
    required this.quantityNormalized,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Text("Receive $quantityNormalized $asset");
  }
}

enum TransactionStatus {
  local,
  mempool,
  confirmed,
}

class TransactionStatusPill extends StatelessWidget {
  final TransactionStatus status;
  final String? text;

  const TransactionStatusPill({
    Key? key,
    required this.status,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getText(),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getText() {
    return text ??
        switch (status) {
          TransactionStatus.local => 'SENT',
          TransactionStatus.mempool => 'MEMPOOL',
          TransactionStatus.confirmed => 'CONFIRMED',
        };
  }

  Color _getBackgroundColor() {
    return switch (status) {
      TransactionStatus.local => Colors.blue[500]!.withOpacity(0.1),
      TransactionStatus.mempool => Colors.orange[500]!.withOpacity(0.1),
      TransactionStatus.confirmed => Colors.green[500]!.withOpacity(0.1)
    };
  }

  Color _getTextColor() {
    return switch (status) {
      TransactionStatus.local => Colors.blue[400]!,
      TransactionStatus.mempool => Colors.orange[400]!,
      TransactionStatus.confirmed => Colors.green[400]!,
    };
  }
}

class NewTransactionsBanner extends StatelessWidget {
  final int count;
  const NewTransactionsBanner({super.key, required this.count});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<DashboardActivityFeedBloc>().add(const Load());
      },
      child: Container(
        color: Colors.blue,
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            '$count new transaction${count > 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class ActivityFeedListItem extends StatelessWidget {
  final ActivityFeedItem item;
  final List<Address> addresses;

  const ActivityFeedListItem(
      {super.key, required this.item, required this.addresses});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(),
      subtitle: _buildSubtitle(),
      leading: _buildLeadingIcon(),
      trailing: _buildTrailing(),
      onTap: () {
        // Handle item tap
        // You might want to navigate to a detail page here
      },
    );
  }

  Widget _buildTitle() {
    if (item.event != null) {
      return _buildEventTitle(item.event!);
    } else if (item.info != null) {
      return _buildTransactionInfoTitle(item.info!);
    } else if (item.bitcoinTx != null) {
      return _buildBitcoinTxTitle(item.bitcoinTx!);
    } else {
      return const Text('No details available');
    }
  }

  SendSide _getSendSide(String address) {
    if (addresses.any((a) => a.address == address)) {
      return SendSide.source;
    } else {
      return SendSide.destination;
    }
  }

  Widget _buildBitcoinTxTitle(BitcoinTx tx) {
    final addresses_ = addresses.map((a) => a.address).toList();

    return switch (tx.getTransactionType(addresses_)) {
      TransactionType.sender => SendTitle(
          // destination: tx.vout.first.scriptpubkeyAddress!,
          quantityNormalized: satoshisToBtc(tx.vout.first.value).toString(),
          asset: 'BTC',
        ),
      // TODO: assumes single party send?
      TransactionType.recipient => ReceiveTitle(
          // source: tx.vin.first.prevout!.scriptpubkeyAddress!,
          // source: " ",
          quantityNormalized: satoshisToBtc(tx.vout.first.value).toString(),
          asset: 'BTC',
        ),
      TransactionType.neither =>
        throw Exception('Invariant: account neither sender or receiver')
    };
  }

  Widget _buildEventTitle(Event event) {
    return switch (event) {
      // VerboseDebitEvent(params: var params) =>
      //   Text("Send ${params.quantityNormalized} ${params.asset}"),
      // VerboseCreditEvent(params: var params) =>
      //   Text("Receive ${params.quantityNormalized} ${params.asset}"),
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        SendTitle(
          quantityNormalized: params.quantityNormalized,
          asset: params.asset,
          // destination: params.destination,
        ),
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        ReceiveTitle(
          quantityNormalized: params.quantityNormalized,
          asset: params.asset,
          // source: params.source,
        ),
      VerboseAssetIssuanceEvent(params: var params) =>
        Text("Issue ${params.quantityNormalized} ${params.asset}"),
      // TODO: log this
      _ =>
        Text('Invariant: title unsupported event type: ${event.runtimeType}'),
    };
  }

  Widget _buildTransactionInfoTitle(TransactionInfo info) {
    return switch (info) {
      TransactionInfoEnhancedSendVerbose(
        unpackedData: var unpackedData,
        // asset: var asset,
        // address: var address,
        // quantityNormalized: var quantityNormalized,
      ) =>
        Text(
            "Send ${unpackedData.quantityNormalized} ${unpackedData.asset} to ${unpackedData.address}"),
      TransactionInfoIssuanceVerbose(
        unpackedData: var unpackedData,
      ) =>
        Text("Issue ${unpackedData.quantityNormalized} ${unpackedData.asset}"),
      // btc send
      TransactionInfoVerbose(btcAmount: var btcAmount)
          when btcAmount != null && btcAmount > 0 =>
        Text("Send ${satoshisToBtc(btcAmount)} BTC to ${info.destination}"),
      _ => Text(
          'Invariant: title unsupported TransactionInfo type: ${info.runtimeType}'),
    };
  }

  Icon _getTransactionInfoLeading(TransactionInfo info) {
    return switch (info) {
      // local can only ever be a send
      TransactionInfoEnhancedSendVerbose() =>
        const Icon(Icons.arrow_back, color: Colors.grey),
      TransactionInfoIssuanceVerbose() =>
        const Icon(Icons.toll, color: Colors.grey),
      TransactionInfoVerbose(btcAmount: var btcAmount) when btcAmount != null =>
        const Icon(Icons.arrow_back, color: Colors.grey),
      _ => const Icon(Icons.error),
    };
  }

  // return Text(info.hash);
  // return Text('Amount: ${info.btcAmount}, Fee: ${info.fee}');

  Widget _buildSubtitle() {
    if (item.event != null) {
      return _buildEventSubtitle(item.event!);
    } else if (item.info != null) {
      return _buildTransactionInfoSubtitle(item.info!);
    } else if (item.bitcoinTx != null) {
      return _buildBitcoinTxSubtitle(item.bitcoinTx!);
    } else {
      return const Text('No details available');
    }
  }

  Widget _buildEventSubtitle(Event event) {
    return switch (event) {
      // VerboseDebitEvent(txHash: var hash) => TxHashDisplay(hash: hash),
      // VerboseCreditEvent(txHash: var hash) => TxHashDisplay(hash: hash),
      VerboseAssetIssuanceEvent(txHash: var hash) => TxHashDisplay(hash: hash),
      VerboseEnhancedSendEvent(txHash: var hash) => TxHashDisplay(hash: hash),
      _ => Text(
          'Invariant: subtitle unsupported event type: ${event.runtimeType}'),
    };

    // // Customize this based on your Event structure
    // return Text("${event.event} ${event.txHash}");
    // // return Text('Event: ${event.event} - State: ${event.state}');
  }

  Widget _buildTransactionInfoSubtitle(TransactionInfo info) {
    // Customize this based on your TransactionInfo structure
    return TxHashDisplay(hash: info.hash);
    // return Text('Amount: ${info.btcAmount}, Fee: ${info.fee}');
  }

  Widget _buildBitcoinTxSubtitle(BitcoinTx btx) {
    // TODO:  switch on network
    return TxHashDisplay(
      hash: btx.txid,
    );

    return switch (btx.status) {
      Status(
        blockHeight: var blockHeight,
        blockHash: var blockHash,
        confirmed: var confirmed,
      )
          when confirmed =>
        Text('Block: $blockHeight, Hash: ${btx.txid}'),
      Status(
        blockHash: var blockHash,
      ) =>
        Text('Hash: ${btx.txid}'),
    };
    // show block index and tx hash
  }

  Widget _buildTrailing() {
    if (item.event != null) {
      return _getEventTrailing(item.event!.state);
    } else if (item.info != null) {
      return _getTransactionTrailing(item.info!.domain);
    } else if (item.bitcoinTx != null) {
      return _getBitcoinTxTrailing(item.bitcoinTx!);
    } else {
      return const Icon(Icons.error);
    }
  }

  Widget _buildLeadingIcon() {
    if (item.event != null) {
      return _getEventLeadingIcon(item.event!);
    } else if (item.info != null) {
      return _getTransactionInfoLeading(item.info!);
    } else {
      return _getBitcoinTxLeadingIcon(item.bitcoinTx!);
      // throw Exception('Invariant: Item must have either event or info');
    }
  }

  Icon _getEventLeadingIcon(Event event) {
    return switch (event) {
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        const Icon(Icons.arrow_back, color: Colors.red),
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        const Icon(Icons.arrow_forward, color: Colors.green),
      VerboseAssetIssuanceEvent(params: var params) =>
        const Icon(Icons.toll, color: Colors.grey),
      _ => const Icon(Icons.error),
    };

    // return switch (event.event) {
    //   "CREDIT" => const Icon(Icons.arrow_forward, color: Colors.green),
    //   "DEBIT" => const Icon(Icons.arrow_back, color: Colors.red),
    //   "ASSET_ISSUANCE" => const Icon(Icons.toll, color: Colors.grey),
    //   "ENHANCED_SEND" when event is  => const Icon(Icons.toll, color: Colors.grey),
    //
    //   _ => const Icon(Icons.error),
    // };
  }

  Icon _getBitcoinTxLeadingIcon(BitcoinTx btx) {
    final addresses_ = addresses.map((a) => a.address).toList();

    return switch (btx.getTransactionType(addresses_)) {
      TransactionType.sender => const Icon(Icons.arrow_back, color: Colors.red),
      // TODO: assumes single party send?
      TransactionType.recipient =>
        const Icon(Icons.arrow_forward, color: Colors.green),
      TransactionType.neither =>
        throw Exception('Invariant: account neither sender or receiver')
    };
  }

  Widget _getEventTrailing(EventState state) => switch (state) {
        // EventStateLocal() => const Icon(Icons.schedule, color: Colors.orange),
        EventStateMempool() =>
          const TransactionStatusPill(status: TransactionStatus.mempool),
        EventStateConfirmed(blockHeight: var blockHeight) =>
          TransactionStatusPill(
              status: TransactionStatus.confirmed, text: "# $blockHeight"),
      };

  Widget _getTransactionTrailing(TransactionInfoDomain domain) {
    return switch (domain) {
      TransactionInfoDomainLocal() =>
        const TransactionStatusPill(status: TransactionStatus.local),
      TransactionInfoDomainMempool() =>
        const TransactionStatusPill(status: TransactionStatus.mempool),
      TransactionInfoDomainConfirmed() =>
        const TransactionStatusPill(status: TransactionStatus.confirmed),
    };
  }

  Widget _getBitcoinTxTrailing(BitcoinTx btx) {
    return switch (btx.status) {
      Status(confirmed: var confirmed, blockHeight: var blockHeight)
          when confirmed =>
        TransactionStatusPill(
            status: TransactionStatus.confirmed, text: "# $blockHeight"),
      _ => const TransactionStatusPill(status: TransactionStatus.mempool),
    };
  }
}

class DashboardActivityFeedScreen extends StatefulWidget {
  final List<Address> addresses;

  const DashboardActivityFeedScreen({super.key, required this.addresses});

  @override
  _DashboardActivityFeedScreenState createState() =>
      _DashboardActivityFeedScreenState();
}

class _DashboardActivityFeedScreenState
    extends State<DashboardActivityFeedScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<DashboardActivityFeedBloc>()
        .add(const StartPolling(interval: Duration(seconds: 30)));
  }

  @override
  void dispose() {
    context.read<DashboardActivityFeedBloc>().add(const StopPolling());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardActivityFeedBloc, DashboardActivityFeedState>(
      listener: (context, state) {
        // print('DashboardActivityFeedBloc state changed: $state');
      },
      builder: (context, state) {
        if (state is DashboardActivityFeedStateInitial ||
            state is DashboardActivityFeedStateLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DashboardActivityFeedStateCompleteError) {
          return Center(child: Text('Error: ${state.error}'));
        } else if (state is DashboardActivityFeedStateCompleteOk ||
            state is DashboardActivityFeedStateReloadingOk) {
          final transactions =
              (state as dynamic).transactions as List<ActivityFeedItem>;
          final newTransactionCount =
              (state as dynamic).newTransactionCount as int;
          return Column(
            children: [
              if (newTransactionCount > 0)
                NewTransactionsBanner(count: newTransactionCount),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length + 1,
                itemBuilder: (context, index) {
                  if (index < transactions.length) {
                    return ActivityFeedListItem(
                      item: transactions[index],
                      addresses: widget.addresses,
                    );
                  } else if (index == transactions.length) {
                    return state is DashboardActivityFeedStateReloadingOk
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink();
                  }
                  return null;
                },
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     context
              //         .read<DashboardActivityFeedBloc>()
              //         .add(const LoadMore());
              //   },
              //   child: const Text("Load More"),
              // ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
