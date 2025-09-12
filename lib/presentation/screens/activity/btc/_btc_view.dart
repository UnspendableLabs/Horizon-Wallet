import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/common/tx_hash_display.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';
import 'package:horizon/presentation/common/no_data.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/screens/transactions/rbf/view/rbf_page.dart';
import 'package:horizon/utils/app_icons.dart';

import "./bloc/btc_activity_bloc.dart";

class SendTitle extends StatelessWidget {
  final String quantityNormalized;
  final String asset;
  const SendTitle({
    super.key,
    required this.quantityNormalized,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SelectableText(
          "Send",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        SelectableText(
          "$quantityNormalized $asset",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ReceiveTitle extends StatelessWidget {
  final String quantityNormalized;
  final String asset;
  const ReceiveTitle({
    super.key,
    required this.quantityNormalized,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SelectableText(
          "Receive",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        SelectableText(
          "$quantityNormalized $asset",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class RBF extends StatelessWidget {
  final String txHash;
  final String address;
  const RBF({
    super.key,
    required this.txHash,
    required this.address,
  });
  @override
  Widget build(BuildContext context) {
    return AppIcons.iconButton(
        context: context,
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) {
              return Dialog.fullscreen(
                child: RBFPage(txHash: txHash, address: address),
              );
            },
          );
        },
        icon: AppIcons.rocketLaunchIcon(
          context: context,
        ));
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
    super.key,
    required this.status,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SelectableText(
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
          TransactionStatus.local => 'Broadcasted',
          TransactionStatus.mempool => 'Mempool',
          TransactionStatus.confirmed => 'Confirmed',
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
        context.read<BtcActivityBloc>().add(const Load());
      },
      child: Container(
        color: Colors.blue,
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SelectableText(
            '$count new transaction${count > 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

enum SendSide { source, destination }

class ActivityFeedListItem extends StatelessWidget {
  final ActivityFeedItem item;
  final List<String> addresses;
  final bool isMobile;

  const ActivityFeedListItem(
      {super.key,
      required this.item,
      required this.addresses,
      required this.isMobile});

  String _formatQuantity(String? quantity) {
    if (quantity == null) return '';
    return quantity
        .replaceAll(RegExp(r'(?<=\d)0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(),
      subtitle: _buildSubtitle(),
      // TODO: ADD RBF
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        _buildRBF() ?? const SizedBox.shrink(),
      ]),
      // onTap: () {},
    );
  }

  Widget? _buildRBF() {
    if (item.bitcoinTx != null && item.bitcoinTx!.status.confirmed == false) {
      return _buildRBFBitcoinTx(item.bitcoinTx!);
    }
    return null;
  }

  Widget? _buildRBFBitcoinTx(BitcoinTx tx) {
    final addresses_ = addresses.map((a) => a).toList();

    return switch (tx.getTransactionType(addresses_)) {
      TransactionType.sender => RBF(txHash: tx.txid, address: addresses.first),
      _ => null
    };
  }

  Widget _buildTitle() {
    return _buildBitcoinTxTitle(item.bitcoinTx!);
  }

  SendSide _getSendSide(String address) {
    if (addresses.any((a) => a == address)) {
      return SendSide.source;
    } else {
      return SendSide.destination;
    }
  }

  Widget _buildBitcoinTxTitle(BitcoinTx tx) {
    final addresses_ = addresses.map((a) => a).toList();

    return switch (tx.getTransactionType(addresses_)) {
      TransactionType.sender => SendTitle(
          quantityNormalized: _formatQuantity(
              tx.getAmountSentNormalized(addresses_).toStringAsFixed(8)),
          asset: 'BTC',
        ),
      TransactionType.recipient => ReceiveTitle(
          quantityNormalized: _formatQuantity(
              tx.getAmountReceivedNormalized(addresses_).toStringAsFixed(8)),
          asset: 'BTC',
        ),
      TransactionType.neither => const Row(
          children: [
            SelectableText(
              "Invariant: account neither sender or receiver",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
    };
  }

  Widget _buildSubtitle() {
    return _buildBitcoinTxSubtitle(item.bitcoinTx!);
  }

  Widget _buildBitcoinTxSubtitle(BitcoinTx btx) {
    return Row(
      children: [
        TxHashDisplay(
          hash: btx.txid,
          uriType: URIType.btcexplorer,
        ),
        const Spacer(),
        TransactionStatusPill(
          status: btx.status.confirmed
              ? TransactionStatus.confirmed
              : TransactionStatus.mempool,
        ),
      ],
    );
  }
}

class BTCActivityViewInternal extends StatefulWidget {
  final List<String> addresses; // this is always = [sourceAddress]
  const BTCActivityViewInternal({
    super.key,
    required this.addresses,
  });

  @override
  BTCActivityViewInternalState createState() => BTCActivityViewInternalState();
}

class BTCActivityViewInternalState extends State<BTCActivityViewInternal> {
  BtcActivityBloc? _bloc;

  @override
  void initState() {
    super.initState();
    // Start polling after the first frame
    _bloc = context.read<BtcActivityBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc?.add(const StartPolling(interval: Duration(seconds: 30)));
    });
  }

  @override
  void dispose() {
    _bloc?.add(const StopPolling());
    super.dispose();
  }

  // Widget _buildNewTransactionsBanner(BTCActivityFeed  state) {
  //
  //   final newTransactionCount = (state as dynamic).newTransactionCount as int;
  //   if (newTransactionCount > 0) {
  //     return NewTransactionsBanner(count: newTransactionCount);
  //   }
  //   return const SizedBox.shrink();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BtcActivityBloc, BtcActivityState>(
      listener: (context, state) {},
      builder: (context, state) {
        final widgets = state.remoteState.fold(
          onInitial: () => [
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          ],
          onLoading: () => [
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          ],
          onFailure: (error) => [
            SizedBox(
              height: 200,
              child: Center(child: SelectableText('Error: $error')),
            )
          ],
          onSuccess: (replete) => [
            ...replete.items.map((item) => ActivityFeedListItem(
                  key: Key(item.hash!),
                  item: item,
                  addresses: widget.addresses,
                  isMobile: MediaQuery.of(context).size.width < 600,
                )),
            if (!replete.endReached)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 48,
                  child: HorizonOutlinedButton(
                      buttonText: 'Load More',
                      onPressed: () {
                        _bloc?.add(const LoadMore());
                      }),
                ),
              )
          ],
          onRefreshing: (replete) => [
            ...replete.items.map((item) => ActivityFeedListItem(
                  key: Key(item.hash!),
                  item: item,
                  addresses: widget.addresses,
                  isMobile: MediaQuery.of(context).size.width < 600,
                )),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 48,
                child: HorizonOutlinedButton(
                    buttonText: 'Loading...', onPressed: () {}),
              ),
            )
          ],
        );

        return SingleChildScrollView(
          child: Column(
            children: widgets,
          ),
        );
      },
    );
  }
}
