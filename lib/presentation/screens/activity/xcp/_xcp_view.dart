import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/common/tx_hash_display.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/screens/transactions/rbf/view/rbf_page.dart';
import 'package:horizon/utils/app_icons.dart';

import "./bloc/xcp_activity_bloc.dart";
import "./xcp_view.dart" show XcpActivityActions;

class PullToRevealRefreshList extends StatelessWidget {
  const PullToRevealRefreshList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.hasBanner = false,
    this.bannerBuilder,
  });

  final List<dynamic> items;
  final IndexedWidgetBuilder itemBuilder;
  final Future<void> Function() onRefresh;

  final bool hasBanner;
  final Widget Function()? bannerBuilder;

  static const double _headerHeight = 72; // how tall the reveal area gets
  static const double _triggerOffset =
      64; // how far to pull before auto-refresh

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // Hidden at rest; shows only while pulling down.
        SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0, // no visible app bar chrome
          collapsedHeight: 0, // keep it fully hidden when not stretched
          expandedHeight: _headerHeight,
          stretch: true,
          stretchTriggerOffset: _triggerOffset,
          onStretchTrigger: () async {
            // Auto-trigger refresh when the pull exceeds _triggerOffset.
            await onRefresh();
          },
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              // Animate the button’s visibility as the header stretches
              final t = (constraints.maxHeight / _headerHeight).clamp(0.0, 1.0);
              return Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Opacity(
                    opacity: Curves.easeOut.transform(t),
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: onRefresh, // manual tap to refresh
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        if (hasBanner && bannerBuilder != null)
          SliverToBoxAdapter(child: bannerBuilder!()),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < items.length) {
                return itemBuilder(context, index);
              }
              // Footer (“Load more”)
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Load More'),
                  ),
                ),
              );
            },
            childCount: items.length + 1,
          ),
        ),
      ],
    );
  }
}

class SendTitle extends StatelessWidget {
  final String quantityNormalized;
  final String asset;
  final bool? isMpma;
  const SendTitle({
    super.key,
    required this.quantityNormalized,
    required this.asset,
    this.isMpma,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SelectableText(
          "Send ${isMpma == true ? ' MPMA' : ''}",
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
  final bool? isMpma;
  const ReceiveTitle({
    super.key,
    required this.quantityNormalized,
    required this.asset,
    this.isMpma,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SelectableText(
          "Receive${isMpma == true ? ' MPMA' : ''}",
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
          TransactionStatus.mempool => 'Mempool',
          TransactionStatus.confirmed => 'Confirmed',
        };
  }

  Color _getBackgroundColor() {
    return switch (status) {
      TransactionStatus.mempool => Colors.orange[500]!.withOpacity(0.1),
      TransactionStatus.confirmed => Colors.green[500]!.withOpacity(0.1)
    };
  }

  Color _getTextColor() {
    return switch (status) {
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
        context.read<XcpActivityBloc>().add(const Load());
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
    if (quantity.contains(".")) {
      return quantity.replaceFirst(RegExp(r'\.?0*$'), '');
    }
    return quantity;
    // return quantity
    //     .replaceAll(RegExp(r'(?<=\d)0+$'), '')
    //     .replaceAll(RegExp(r'\.$'), '');
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
    if (item.event != null && item.event!.state is EventStateMempool) {
      return _buildRBFEvent(item.event!);
    }
    return null;
  }

  Widget? _buildRBFEvent(Event event) {
    return switch (event) {
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        RBF(txHash: params.txHash, address: params.source),
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        RBF(txHash: params.txHash, address: params.source),
      VerboseMpmaSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        RBF(txHash: params.txHash, address: params.source),
      VerboseAssetIssuanceEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseResetIssuanceEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,

      // for dispense, source and destination are inverted
      VerboseDispenseEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseOpenDispenserEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseRefillDispenserEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseDispenserUpdateEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseNewFairmintEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseNewFairminterEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseOpenOrderEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseCancelOrderEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseAttachToUtxoEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseDetachFromUtxoEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      AssetDestructionEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      AssetDividendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      SweepEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      BurnEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      _ => null,
    };
  }

  Widget _buildTitle() {
    if (item.event != null) {
      return _buildEventTitle(item.event!);
    }
    return const SelectableText('No details available');
  }

  SendSide _getSendSide(String address) {
    if (addresses.any((a) => a == address)) {
      return SendSide.source;
    } else {
      return SendSide.destination;
    }
  }

  Widget _buildEventTitle(Event event) {
    return switch (event) {
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        SendTitle(
            asset: params.asset,
            quantityNormalized: _formatQuantity(params.quantityNormalized),
            isMpma: false),
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        ReceiveTitle(
            quantityNormalized: _formatQuantity(params.quantityNormalized),
            asset: params.asset),
      VerboseMpmaSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        SendTitle(
          quantityNormalized: _formatQuantity(params.quantityNormalized),
          asset: params.asset,
          isMpma: true,
        ),
      VerboseMpmaSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        ReceiveTitle(
          quantityNormalized: _formatQuantity(params.quantityNormalized),
          asset: params.asset,
          isMpma: true,
        ),
      VerboseAssetIssuanceEvent(params: var params) =>
        _buildAssetIssuanceTitle(params),
      VerboseResetIssuanceEvent(params: var params) => Row(
          children: [
            _buildTitleText("Reset"),
            const Spacer(),
            _buildAssetDisplay(params.asset, params.assetLongname),
          ],
        ),
      VerboseDispenseEvent(params: var params) => Row(
          children: [
            _buildTitleText('Dispense'),
            const Spacer(),
            _buildQuantityNormalizedText(
                "${_formatQuantity(params.dispenseQuantityNormalized)} "),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseOpenDispenserEvent(params: var params) => Row(
          children: [
            _buildTitleText('Open Dispenser'),
            const Spacer(),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseRefillDispenserEvent(params: var params) => Row(
          children: [
            _buildTitleText('Refill Dispenser'),
            const Spacer(),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseDispenserUpdateEvent(params: var params) => Row(
          children: [
            _buildTitleText(
              params.status == 10 || params.status == 11
                  ? "Close Dispenser"
                  : "Update Dispenser",
            ),
            const Spacer(),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseNewFairmintEvent(params: var params) => Row(
          children: [
            SelectableText(
              params.status?.contains('invalid') ?? false
                  ? "Fairmint (INVALID)"
                  : "Fairmint",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: params.status?.contains('invalid') ?? false
                    ? redErrorText
                    : null,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseNewFairminterEvent(params: var params) => Row(
          children: [
            SelectableText(
              params.status?.contains('invalid') ?? false
                  ? "Fairminter (INVALID)"
                  : "Fairminter",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: params.status?.contains('invalid') ?? false
                    ? redErrorText
                    : null,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseOpenOrderEvent(params: var params) => Row(
          children: [
            _buildTitleText('Open Order'),
            const Spacer(),
            _buildQuantityNormalizedText(
                "${_formatQuantity(params.giveQuantityNormalized)} "),
            _buildAssetDisplay(params.giveAsset),
            _buildQuantityNormalizedText(
                " / ${_formatQuantity(params.getQuantityNormalized)} "),
            _buildAssetDisplay(params.getAsset),
          ],
        ),
      VerboseOrderMatchEvent(params: var params) => Row(
          children: [
            _buildTitleText('Order Match'),
            const Spacer(),
            _buildQuantityNormalizedText(
                "${_formatQuantity(params.forwardQuantityNormalized)} "),
            _buildAssetDisplay(params.forwardAsset),
            _buildQuantityNormalizedText(
                " / ${_formatQuantity(params.backwardQuantityNormalized)} "),
            _buildAssetDisplay(params.backwardAsset),
          ],
        ),
      VerboseOrderUpdateEvent() => Row(
          children: [
            _buildTitleText('Order Update'),
          ],
        ),
      VerboseOrderFilledEvent(params: var _) => Row(
          children: [_buildTitleText('Order Filled')],
        ),
      VerboseCancelOrderEvent(params: var _) => Row(
          children: [_buildTitleText('Cancel Order')],
        ),
      VerboseOrderExpirationEvent(params: var _) => Row(
          children: [_buildTitleText('Order Expiration')],
        ),
      VerboseAttachToUtxoEvent(params: var params) => Row(
          children: [
            _buildTitleText('Attach to UTXO'),
            const Spacer(),
            _buildQuantityNormalizedText(
                "${_formatQuantity(params.quantityNormalized)} "),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseDetachFromUtxoEvent(params: var params) => Row(
          children: [
            _buildTitleText('Detach from UTXO'),
            const Spacer(),
            _buildQuantityNormalizedText(
                "${_formatQuantity(params.quantityNormalized)} "),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseMoveToUtxoEvent(params: var params) => Row(
          children: [
            _buildTitleText('Move to UTXO'),
            const Spacer(),
            _buildQuantityNormalizedText(
                "${_formatQuantity(params.quantityNormalized)} "),
            _buildAssetDisplay(params.asset),
          ],
        ),
      AtomicSwapEvent(params: var params) => Row(
          children: [
            _buildTitleText('Swap'),
            const Spacer(),
            _buildQuantityNormalizedText(
                "${_formatQuantity(params.quantityNormalized)} "),
            _buildAssetDisplay(params.asset),
            _buildQuantityNormalizedText(
                ' for ${_formatQuantity(params.bitcoinSwapAmount)} BTC'),
          ],
        ),
      AssetDestructionEvent(params: var params) => Row(
          children: [
            _buildTitleText('Destroy'),
            const Spacer(),
            _buildQuantityNormalizedText(
                "${_formatQuantity(params.quantityNormalized)} "),
            _buildAssetDisplay(params.asset),
          ],
        ),
      AssetDividendEvent(params: var params) => Row(
          children: [
            _buildTitleText('Dividend'),
            const Spacer(),
            _buildQuantityNormalizedText(
                "${_formatQuantity(params.quantityPerUnitNormalized)} "),
            _buildAssetDisplay(params.dividendAsset),
            _buildQuantityNormalizedText(
                " ${_formatQuantity(params.quantityPerUnitNormalized)} per unit"),
          ],
        ),
      SweepEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        Row(
          children: [
            _buildTitleText('Sweep out'),
            const Spacer(),
            SelectableText(
              "${flagMapper[params.flags]}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      SweepEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        Row(
          children: [
            _buildTitleText('Sweep in'),
            const Spacer(),
            SelectableText(
              "${flagMapper[params.flags]}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      BurnEvent(params: var params) => Row(
          children: [
            _buildTitleText('Burn'),
            const Spacer(),
            _buildQuantityNormalizedText(
                '${params.burnedNormalized} BTC for ${params.earnedNormalized} XCP'),
          ],
        ),
      _ => SelectableText(
          'Invariant: title unsupported event type: ${event.runtimeType}'),
    };
  }

  Widget _buildAssetIssuanceTitle(VerboseAssetIssuanceParams params) {
    if (params.transfer && params.assetEvents != 'fairmint') {
      if (addresses.any((a) => a == params.source)) {
        return Row(
          children: [
            _buildTitleText('Transfer Out'),
            const Spacer(),
            _buildAssetDisplay(params.asset, params.assetLongname),
          ],
        );
      } else {
        return Row(
          children: [
            _buildTitleText('Transfer In'),
            const Spacer(),
            _buildAssetDisplay(params.asset, params.assetLongname),
          ],
        );
      }
    }
    if (params.assetEvents != null && params.assetEvents!.isNotEmpty) {
      return switch (params.assetEvents) {
        "reissuance" => Row(
            children: [
              _buildTitleText('Reissue'),
              const Spacer(),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "lock_quantity" => Row(
            children: [
              _buildTitleText('Lock Quantity'),
              const Spacer(),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "lock_quantity reissuance" => Row(
            children: [
              _buildTitleText('Lock Quantity'),
              const Spacer(),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "change_description" => Row(
            children: [
              _buildTitleText('Change Description'),
              const Spacer(),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "lock_description" => Row(
            children: [
              _buildTitleText('Lock Description'),
              const Spacer(),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "open_fairminter" => Row(
            children: [
              _buildTitleText('Fairminter'),
              const Spacer(),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "fairmint" => Row(
            children: [
              _buildTitleText('Fairmint'),
              const Spacer(),
              _buildQuantityNormalizedText(
                  " ${_formatQuantity(params.quantityNormalized)} "),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "transfer" => addresses.any((a) => a == params.source)
            ? Row(
                children: [
                  _buildTitleText('Transfer Out'),
                  const Spacer(),
                  _buildAssetDisplay(params.asset, params.assetLongname),
                ],
              )
            : Row(
                children: [
                  _buildTitleText('Transfer In'),
                  const Spacer(),
                  _buildAssetDisplay(params.asset, params.assetLongname),
                ],
              ),
        _ => Row(
            children: [
              _buildTitleText('Issue'),
              const Spacer(),
              _buildQuantityNormalizedText(
                  "${_formatQuantity(params.quantityNormalized)} "),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
      };
    }
    if (params.asset == null || params.quantityNormalized == null) {
      return const Row(
        children: [
          SelectableText(
            "Issue (INVALID)",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: redErrorText,
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        _buildTitleText('Issue'),
        const Spacer(),
        _buildQuantityNormalizedText(
            "${_formatQuantity(params.quantityNormalized)} "),
        _buildAssetDisplay(params.asset, params.assetLongname),
      ],
    );
  }

  Widget _buildSubtitle() {
    if (item.event != null) {
      return _buildEventSubtitle(item.event!);
    }
    return const SelectableText('No details available');
  }
}

Widget _buildEventSubtitle(Event event) {
  return switch (event) {
    VerboseAssetIssuanceEvent(txHash: var hash, params: var params) => Row(
        children: [
          hash != null
              ? TxHashDisplay(hash: hash, uriType: URIType.hoex)
              : const SizedBox.shrink(),
          switch (params.status) {
            EventStatusValid() => const SizedBox.shrink(),
            EventStatusInvalid(reason: var reason) => Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Row(
                  children: [
                    AppIcons.warningIcon(
                      width: 16.0,
                      height: 16.0,
                      color: red1,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                      child: SelectableText(reason,
                          style: const TextStyle(color: red1, fontSize: 12)),
                    ),
                  ],
                ),
              ),
          },
          const Spacer(),
          TransactionStatusPill(
            status: switch (event.state) {
              EventStateMempool() => TransactionStatus.mempool,
              EventStateConfirmed() => TransactionStatus.confirmed,
            },
          ),
        ],
      ),
    VerboseOrderExpirationEvent(params: var params) => Row(
        children: [
          const Text("order hash:"),
          const SizedBox(width: 10.0),
          TxHashDisplay(hash: params.orderHash, uriType: URIType.hoex),
          const Spacer(),
          TransactionStatusPill(
            status: switch (event.state) {
              EventStateMempool() => TransactionStatus.mempool,
              EventStateConfirmed() => TransactionStatus.confirmed,
            },
          ),
        ],
      ),
    VerboseEvent(txHash: var hash) => Row(
        children: [
          hash != null
              ? TxHashDisplay(hash: hash, uriType: URIType.hoex)
              : const SizedBox.shrink(),
          const Spacer(),
          TransactionStatusPill(
            status: switch (event.state) {
              EventStateMempool() => TransactionStatus.mempool,
              EventStateConfirmed() => TransactionStatus.confirmed,
            },
          ),
        ],
      ),
    _ => SelectableText(
        'Invariant: subtitle unsupported event type: ${event.runtimeType}'),
  };
}

Widget _buildAssetText(String text) {
  return MiddleTruncatedText(
    text: text,
    width: 100,
    charsToShow: 8,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );
}

Widget _buildAssetDisplay(String? asset, [String? assetLongname]) {
  final displayName = assetLongname != null && assetLongname.isNotEmpty
      ? assetLongname
      : asset ?? '';
  return _buildAssetText(displayName);
}

Widget _buildTitleText(String title) {
  return SelectableText(
    title,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );
}

Widget _buildQuantityNormalizedText(String quantityNormalized) {
  return SelectableText(
    quantityNormalized,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );
}

class XCPActivityViewInternal extends StatefulWidget {
  final XcpActivityActions actions;
  final XcpActivityState state;

  final List<String> addresses; // this is always = [sourceAddress]
  const XCPActivityViewInternal({
    super.key,
    required this.addresses,
    required this.actions,
    required this.state,
  });

  @override
  XCPActivityViewInternalState createState() => XCPActivityViewInternalState();
}

class XCPActivityViewInternalState extends State<XCPActivityViewInternal> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<XcpActivityBloc, XcpActivityState>(
      listener: (context, state) {},
      builder: (context, state) {
        return state.remoteState.fold(
          onInitial: () => const Center(
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          onLoading: () => const Center(
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          onFailure: (error) => Center(
            child: SizedBox(
              height: 200,
              child: Center(child: SelectableText('Error: $error')),
            ),
          ),
          onSuccess: (replete) {
            final items = replete.items;
            final hasFooter = replete.cursor != null; // more to load?

            // total rows: banner? + items + footer?
            final itemCount = items.length + (hasFooter ? 1 : 0);

            return ListView.builder(
              primary: true,
              shrinkWrap: true,
              itemCount: itemCount,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                // 0) Optional banner

                // Shift index if banner is present
                final baseIndex = index;

                // 1) Feed items
                if (baseIndex < items.length) {
                  final item = items[baseIndex];
                  return ActivityFeedListItem(
                    key: Key(item.id),
                    item: item,
                    addresses: widget.addresses,
                    isMobile: MediaQuery.of(context).size.width < 600,
                  );
                }

                // 2) Footer (“Load more”)
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 48,
                    child: HorizonOutlinedButton(
                        buttonText: 'Load More',
                        onPressed: () => widget.actions.loadMore()),
                  ),
                );
              },
            );
          },
          onRefreshing: (replete) {
            final items = replete.items;

            // while refreshing, always show a footer row that says “Loading…”
            final itemCount = items.length + 1;

            return Stack(
              children: [
                ListView.builder(
                  itemCount: itemCount,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final baseIndex = index;

                    if (baseIndex < items.length) {
                      final item = items[baseIndex];
                      return ActivityFeedListItem(
                        key: Key(item.id),
                        item: item,
                        addresses: widget.addresses,
                        isMobile: MediaQuery.of(context).size.width < 600,
                      );
                    }

                    // Loading footer
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 48,
                        child: HorizonOutlinedButton(
                          buttonText: 'Loading...',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
