import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:timeago_flutter/timeago_flutter.dart';
import 'package:horizon/utils/app_icons.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/presentation/common/filter_bar.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/domain/entities/address_index_set.dart';
import 'package:horizon/domain/entities/address_v2.dart';

import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

import './btc/btc_view.dart';
import './xcp/xcp_view.dart';

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

/// -----------------------------
/// ACTIVITY VIEW (single scroll view)
/// -----------------------------
// class ActivityView extends StatefulWidget {
//   final AddressV2 initialAddress;
//
//   const ActivityView({super.key, required this.initialAddress});
//
//   @override
//   State<ActivityView> createState() => _ActivityViewState();
// }
//
// class _ActivityViewState extends State<ActivityView> {
//   late AddressV2 _selectedAddress;
//   TransactionType _txFilter = TransactionType.btc;
//
//   @override
//   void initState() {
//     _selectedAddress = widget.initialAddress;
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final session = context.watch<SessionStateCubit>().state.successOrThrow();
//     final vm = session.addressIndexSet.toViewModel();
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         elevation: 0,
//         centerTitle: false,
//         leadingWidth: 40,
//         toolbarHeight: 48,
//         title: Padding(
//           padding: const EdgeInsets.fromLTRB(6, 12, 0, 0),
//           child: Text(
//             "Activity",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: Theme.of(context).textTheme.bodyMedium?.color,
//             ),
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(
//               top: 12,
//               right: 18,
//             ),
//             child: AppIcons.iconButton(
//                 context: context,
//                 width: 32,
//                 height: 32,
//                 icon: Icon(LucideIcons.rotateCw, size: 24),
//                 onPressed: () {
//                   //  chat: i need tdo be able to call provider actions here
//                 }),
//           )
//         ],
//       ),
//       body: CustomScrollView(
//         slivers: [
//           // Address picker
//           // Tx type filter
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: TransactionTypeFilter(
//                 itemGap: 18,
//                 current: _txFilter,
//                 onChanged: (t) {
//                   if (t != null) setState(() => _txFilter = t);
//                 },
//               ),
//             ),
//           ),
//           const SliverToBoxAdapter(child: SizedBox(height: 12)),
//           switch (vm) {
//             AddressIndexSetSingle() =>
//               const SliverToBoxAdapter(child: SizedBox.shrink()),
//             AddressIndexSetMultiple(addresses: final addresses) =>
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: SizedBox(
//                     height: 42,
//                     child: HorizonDrawerSelect<AddressV2>(
//                       options: addresses,
//                       value: _selectedAddress,
//                       labelFor: (addr) => addr.address,
//                       onChanged: (addr) =>
//                           setState(() => _selectedAddress = addr),
//                     ),
//                   ),
//                 ),
//               ),
//           },
//
//           if (_selectedAddress == null)
//             const SliverToBoxAdapter(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Text('No address available.'),
//               ),
//             )
//           else if (_txFilter == TransactionType.btc)
//             SliverToBoxAdapter(
//               child: BTCActivityProvider(
//                 httpConfig: session.httpConfig,
//                 address: _selectedAddress,
//                 builder: (actions, state) => BTCActivityView(
//                     actions: actions, state: state, address: _selectedAddress),
//               ),
//             )
//           else
//             SliverToBoxAdapter(
//               child: XCPActivityProvider(
//                 httpConfig: session.httpConfig,
//                 address: _selectedAddress,
//                 builder: (actions, state) => XCPActivityView(
//                     state: state, actions: actions, address: _selectedAddress),
//               ),
//             ),
//
//           const SliverToBoxAdapter(child: SizedBox(height: 24)),
//         ],
//       ),
//     );
//   }
// }

class ActivityView extends StatefulWidget {
  final AddressV2 initialAddress;

  const ActivityView({super.key, required this.initialAddress});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  late AddressV2 _selectedAddress;
  TransactionType _txFilter = TransactionType.btc;
  DateTime? _lastdUpdatedAt;

  // ⬇️ Hold onto the actions so AppBar can trigger them
  BtcActivityActions? _btcActions;
  XcpActivityActions? _xcpActions;

  @override
  void initState() {
    _selectedAddress = widget.initialAddress;
    super.initState();
  }

  void _triggerRefresh() {
    switch (_txFilter) {
      case TransactionType.btc:
        // Prefer a lightweight refresh if you have it; fall back to load()
        _btcActions?.load();
        break;
      case TransactionType.xcp:
        _xcpActions?.load();
        break;
    }
  }

  void _handleLastUpdatedAtChange(DateTime newTime) {
    setState(() {
      _lastdUpdatedAt = newTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final vm = session.addressIndexSet.toViewModel();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            centerTitle: false,
            leadingWidth: 40,
            toolbarHeight: 48,
            title: Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 0, 0),
              child: Text(
                "Activity",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 12, right: 18),
                child: Row(
                  children: [
                    AppIcons.iconButton(
                      context: context,
                      width: 32,
                      height: 32,
                      icon: Icon(LucideIcons.rotateCw, size: 24),
                      onPressed:
                          _triggerRefresh, // ⬅️ calls captured provider actions
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Tx type filter
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TransactionTypeFilter(
                itemGap: 18,
                current: _txFilter,
                onChanged: (t) {
                  if (t != null) setState(() => _txFilter = t);
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Address picker (when multiple)
          switch (vm) {
            AddressIndexSetSingle() =>
              const SliverToBoxAdapter(child: SizedBox.shrink()),
            AddressIndexSetMultiple(addresses: final addresses) =>
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    height: 42,
                    child: HorizonDrawerSelect<AddressV2>(
                      options: addresses,
                      value: _selectedAddress,
                      labelFor: (addr) => addr.address,
                      onChanged: (addr) =>
                          setState(() => _selectedAddress = addr),
                    ),
                  ),
                ),
              ),
          },

          if (_lastdUpdatedAt != null)
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Timeago(
                        date: _lastdUpdatedAt!,
                        builder: (_, value) => Text("Last updated $value",
                            style: TextStyle(
                              fontSize: 10, // smaller
                              fontStyle: FontStyle.italic, // italicized
                              color: Colors.grey, // de-emphasized
                            )),
                        refreshRate: const Duration(minutes: 1)),
                  ),
                ],
              ),
            ),
          if (_txFilter == TransactionType.btc)
            // ---- BTC ----
            SliverToBoxAdapter(
              child: BTCActivityProvider(
                key: Key('btc-activity-provider-${_selectedAddress.address}'),
                onLastUpdatedAtChange: _handleLastUpdatedAtChange,
                httpConfig: session.httpConfig,
                address: _selectedAddress,
                builder: (actions, state) {
                  // capture actions for AppBar button
                  _btcActions = actions;
                  return BTCActivityView(
                    actions: actions,
                    state: state,
                    address: _selectedAddress,
                  );
                },
              ),
            )
          else
            // ---- XCP ----
            SliverToBoxAdapter(
              child: XCPActivityProvider(
                key: Key('xcp-activity-provider-${_selectedAddress.address}'),
                onLastUpdatedAtChange: _handleLastUpdatedAtChange,
                httpConfig: session.httpConfig,
                address: _selectedAddress,
                builder: (actions, state) {
                  // capture actions for AppBar button
                  _xcpActions = actions;
                  return XCPActivityView(
                    actions: actions,
                    state: state,
                    address: _selectedAddress,
                  );
                },
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
