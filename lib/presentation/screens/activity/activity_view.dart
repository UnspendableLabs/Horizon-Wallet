import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/dashboard/view/activity_feed.dart';
import 'package:fpdart/fpdart.dart' hide State;

import 'package:horizon/domain/entities/activity_feed_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/remote_data.dart';

import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import "package:get_it/get_it.dart";
import 'package:horizon/presentation/common/filter_bar.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/domain/entities/address_index_set.dart';
import 'package:horizon/domain/entities/address_v2.dart';

import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

/// -----------------------------
/// TX TYPE FILTER (FilterBar skin)
/// -----------------------------
enum TransactionType { btc, xcp }

extension TxTypeLabel on TransactionType {
  String get label => switch (this) {
        TransactionType.btc => 'BTC',
        TransactionType.xcp => 'XCP',
      };
}

class TransactionTypeFilter extends StatelessWidget {
  const TransactionTypeFilter({
    super.key,
    required this.current,
    required this.onChanged,
    this.allowDeselect = false,
    this.disabled = const <TransactionType>{},
    this.paddingHorizontal,
    this.itemGap,
  });

  final TransactionType current;
  final ValueChanged<TransactionType?> onChanged;
  final bool allowDeselect;
  final Set<TransactionType> disabled;
  final double? paddingHorizontal;
  final double? itemGap;

  @override
  Widget build(BuildContext context) {
    return FilterBar(
      currentFilter: current,
      allowDeselect: allowDeselect,
      paddingHorizontal: paddingHorizontal,
      itemGap: itemGap,
      disabledOptions: disabled.toList(),
      filterOptions: const [
        FilterOption(label: 'BTC', value: TransactionType.btc),
        FilterOption(label: 'XCP', value: TransactionType.xcp),
      ],
      onFilterSelected: (obj) => onChanged(obj as TransactionType),
      onClearFilter: () => onChanged(null),
    );
  }
}

/// -----------------------------
/// BTC activity (uses the builder)
/// -----------------------------
class BtcActivityList extends StatelessWidget {
  final AddressV2 address;
  final HttpConfig httpConfig;
  final BitcoinRepository _bitcoinRepository;

  BtcActivityList({
    super.key,
    required this.address,
    required this.httpConfig,
    BitcoinRepository? bitcoinRepository,
  }) : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>();

  @override
  Widget build(BuildContext context) {
    return RemoteDataPagedTaskEitherBuilder<Object, BitcoinTx, String>(
      // Loader: repo returns one page (List<BitcoinTx>) given lastSeenTxid
      loadPage: (nextKey) => _bitcoinRepository
          .getConfirmedTransactionsPaginatedT(
            address: address.address,
            httpConfig: httpConfig,
            lastSeenTxid: nextKey,
            onError: (_) => "error", // TODO
          )
          .map((pageItems) => PagedResult<BitcoinTx, String>(
                items: pageItems,
                nextKey: pageItems.isEmpty ? null : pageItems.last.txid,
              )),
      itemKey: (tx) => tx.txid, // dedupe if backend overlaps pages
      builder: (context, state, refresh, fetchNext, hasMore, isFetchingNext) {
        final stateType = state.fold(
          onInitial: () => 'Initial',
          onLoading: () => 'Loading',
          onFailure: (err) => 'Failure',
          onRefreshing: (data) => 'Refreshing',
          onSuccess: (data) {
            return "Success";
          },
        );

        return state.fold(
          onInitial: () => const SizedBox.shrink(),
          onLoading: () => const Center(child: CircularProgressIndicator()),
          onFailure: (err) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load transactions:\n$err'),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: refresh, child: const Text('Retry')),
                ],
              ),
            ),
          ),
          onRefreshing: (data) => Stack(
            children: [
              _TxList(
                  data
                      .map((btcTx) => ActivityFeedItem(
                          id: btcTx.txid, hash: btcTx.txid, bitcoinTx: btcTx))
                      .toList(),
                  fetchNext,
                  hasMore,
                  isFetchingNext,
                  address),
              const Positioned.fill(
                child: IgnorePointer(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
          onSuccess: (data) => RefreshIndicator(
            onRefresh: refresh,
            child: _TxList(
                data
                    .map((btcTx) => ActivityFeedItem(
                        id: btcTx.txid, hash: btcTx.txid, bitcoinTx: btcTx))
                    .toList(),
                fetchNext,
                hasMore,
                isFetchingNext,
                address),
          ),
        );
      },
    );
  }
}

class _TxList extends StatefulWidget {
  final AddressV2 address;
  final List<ActivityFeedItem> data;
  final Future<void> Function() fetchNext;
  final bool hasMore;
  final bool isFetchingNext;

  const _TxList(this.data, this.fetchNext, this.hasMore, this.isFetchingNext,
      this.address,
      {super.key});

  @override
  State<_TxList> createState() => _TxListState();
}

class _TxListState extends State<_TxList> {
  // late final ScrollController _controller;

  // how close to the bottom (in pixels) before we load the next page
  static const double _kFetchThresholdPx = 400;

  @override
  void initState() {
    super.initState();
    // _controller = ScrollController()..addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _TxList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If we finished a fetch, and there is still more, we just keep listening.
    // No special handling needed here.
  }

  // void _onScroll() {
  //   if (!_controller.hasClients) return;
  //   if (!widget.hasMore || widget.isFetchingNext) return;
  //
  //   final extentAfter = _controller.position.extentAfter;
  //   if (extentAfter < _kFetchThresholdPx) {
  //     // debounce a tad to avoid multiple calls in a single frame
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted && widget.hasMore && !widget.isFetchingNext) {
  //         widget.fetchNext();
  //       }
  //     });
  //   }
  // }

  // @override
  // void dispose() {
  //   _controller.removeListener(_onScroll);
  //   _controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.data.length + (widget.hasMore ? 1 : 0);

    return ListView.builder(
      // controller: _controller,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Tail loader row
        final isLoaderRow = widget.hasMore && index == widget.data.length;
        if (isLoaderRow) {
          // If we scrolled to the loader row and we’re not already fetching, kick it.
          if (!widget.isFetchingNext) {
            // schedule to avoid setState during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && widget.hasMore && !widget.isFetchingNext) {
                // widget.fetchNext();
              }
            });
          }
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final tx = widget.data[index];
        return ActivityFeedListItem(
          addresses: [widget.address.address], // TODO: fill out,,
          isMobile: true,
          item: tx,
        );
      },
    );
  }
}

/// -----------------------------
/// ACTIVITY VIEW (single scroll view)
/// -----------------------------
class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView>
    with AutomaticKeepAliveClientMixin {
  AddressV2? _selectedAddress;
  TransactionType _txFilter = TransactionType.btc;

  void _syncSelectedAddress(AddressIndexSetViewModel vm) {
    switch (vm) {
      case AddressIndexSetSingle(address: final a):
        _selectedAddress = a;
      case AddressIndexSetMultiple(addresses: final list):
        if (_selectedAddress == null || !list.contains(_selectedAddress)) {
          _selectedAddress = list.isNotEmpty ? list.first : null;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final vm = session.addressIndexSet.toViewModel();
    _syncSelectedAddress(vm);

    return CustomScrollView(
      slivers: [
        // Address picker
        switch (vm) {
          AddressIndexSetSingle() =>
            const SliverToBoxAdapter(child: SizedBox.shrink()),
          AddressIndexSetMultiple(addresses: final addresses) =>
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: HorizonDrawerSelect<AddressV2>(
                  options: addresses,
                  value: _selectedAddress!,
                  labelFor: (addr) => addr.address,
                  onChanged: (addr) => setState(() => _selectedAddress = addr),
                ),
              ),
            ),
        },

        // Tx type filter
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: 180,
              child: TransactionTypeFilter(
                itemGap: 18,
                current: _txFilter,
                onChanged: (t) {
                  if (t != null) setState(() => _txFilter = t);
                },
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        if (_selectedAddress == null)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No address available.'),
            ),
          )
        else if (_txFilter == TransactionType.btc)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 600,
              child: BtcActivityList(
                address: _selectedAddress!,
                httpConfig: session.httpConfig,
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'XCP activity for ${_selectedAddress!.address}',
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
