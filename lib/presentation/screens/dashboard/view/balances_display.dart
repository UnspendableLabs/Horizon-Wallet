import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/common/filter_bar.dart';
import 'package:horizon/presentation/common/no_data.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

enum BalanceFilter { all, named, numeric, subassets, issuance }

extension BalanceFilterLabel on BalanceFilter {
  String get label => switch (this) {
        BalanceFilter.all => 'All',
        BalanceFilter.named => 'Named',
        BalanceFilter.numeric => 'Numeric',
        BalanceFilter.subassets => 'Subassets',
        BalanceFilter.issuance => 'Issuances',
      };
}

class BalancesDisplay extends StatefulWidget {
  final String searchQuery;
  final BalanceFilter currentFilter;

  const BalancesDisplay({
    super.key,
    this.searchQuery = '',
    required this.currentFilter,
  });

  @override
  BalancesDisplayState createState() => BalancesDisplayState();
}

class BalancesDisplayState extends State<BalancesDisplay> {
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: BalancesSliver(
          currentFilter: widget.currentFilter,
          searchQuery: widget.searchQuery,
        ),
      ),
    );
  }
}

class BalancesSliver extends StatefulWidget {
  final String searchQuery;
  final BalanceFilter currentFilter;

  const BalancesSliver({
    super.key,
    this.searchQuery = '',
    required this.currentFilter,
  });

  @override
  BalancesSliverState createState() => BalancesSliverState();
}

class BalancesSliverState extends State<BalancesSliver> {
  // TxFilter _currentFilter = TxFilter.all;

  //  void initState() {
  // super.initState();
  // _currentFilter = widget.currentFilter;
  //  }
  //
  //  void _setFilter(Object filter) {
  //    setState(() {
  //      _currentFilter = filter as BalanceFilter;
  //    });
  //  }

  // void _clearFilter() {
  //   setState(() {
  //     _currentFilter = BalanceFilter.none;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalancesBloc, BalancesState>(
      builder: (context, state) {
        final isMobile = MediaQuery.of(context).size.width < 500;
        return Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: _buildContent(state, isMobile: isMobile),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _matchesFilter(MultiAddressBalance balance) {
    // First check if it matches the search query
    if (widget.searchQuery.isNotEmpty) {
      final searchLower = widget.searchQuery.toLowerCase();
      final assetLower = balance.asset.toLowerCase();
      final assetLongnameLower = balance.assetLongname?.toLowerCase();

      if (balance.assetLongname != null && balance.assetLongname!.isNotEmpty) {
        if (!assetLongnameLower!.contains(searchLower)) {
          return false;
        }
        return true;
      }

      // Check if search query matches either the asset name or asset longname
      if (!assetLower.contains(searchLower)) {
        return false;
      }
      return true;
    }

    // Then check if it matches the selected filter
    switch (widget.currentFilter) {
      case BalanceFilter.named:
        if (balance.assetLongname != null &&
            balance.assetLongname!.isNotEmpty) {
          return !balance.assetLongname!.startsWith('A');
        }
        return !balance.asset.startsWith('A') && balance.asset != 'BTC';
      case BalanceFilter.numeric:
        if (balance.assetLongname != null &&
            balance.assetLongname!.isNotEmpty) {
          return balance.assetLongname!.startsWith('A');
        }
        return balance.asset.startsWith('A');
      case BalanceFilter.subassets:
        if (balance.assetLongname != null &&
            balance.assetLongname!.isNotEmpty) {
          return balance.assetLongname!.contains('.');
        }
        return balance.asset.contains('.');
      case BalanceFilter.issuance:
        return balance.entries.any((entry) {
          return (entry.address != null &&
                  balance.assetInfo.owner != null &&
                  entry.address == balance.assetInfo.owner) ||
              (entry.utxo != null &&
                  balance.assetInfo.owner != null &&
                  entry.utxoAddress == balance.assetInfo.owner);
        });
      case BalanceFilter.all:
        return true;
    }
  }

  List<Widget> _buildContent(BalancesState state, {bool isMobile = false}) {
    return state.when(
      initial: () => [const SizedBox.shrink()],
      loading: () => [
        const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        )
      ],
      complete: (result) => _buildBalanceList(result, isMobile: isMobile),
      reloading: (result) => _buildBalanceList(result, isMobile: isMobile),
    );
  }

  List<Widget> _buildBalanceList(Result result, {bool isMobile = false}) {
    return result.when(
      error: (error) => [
        SizedBox(
          height: 200,
          child: Center(child: SelectableText(error)),
        )
      ],
      ok: (balances, starredAssets) {
        if (balances.isEmpty) {
          return [
            const NoData(
              title: 'No Balances',
            )
          ];
        }

        final List<MultiAddressBalance> filteredBalances = [];

        // Iterate through each asset and its list of balances
        for (final balance in balances) {
          if (!_matchesFilter(balance)) {
            continue; // Pass both asset and balances
          }

          filteredBalances.add(balance);
        }

        final sortedBalances = filteredBalances
          ..sort((a, b) {
            // BTC is always first
            if (a.asset == 'BTC') return -1;
            if (b.asset == 'BTC') return 1;

            // XCP is always second
            if (a.asset == 'XCP') return -1;
            if (b.asset == 'XCP') return 1;

            // Then sort by starred status
            final aStarred = starredAssets.contains(a.asset);
            final bStarred = starredAssets.contains(b.asset);
            if (aStarred != bStarred) {
              return aStarred ? -1 : 1;
            }

            // Finally sort alphabetically
            final aName = a.assetLongname ?? a.asset;
            final bName = b.assetLongname ?? b.asset;
            return aName.compareTo(bName);
          });

        return [
          Builder(builder: (context) {
            final session =
                context.watch<SessionStateCubit>().state.successOrThrow();

            return Column(
              children: sortedBalances.map((balance) {
                final isBitcoinOrXcp =
                    balance.asset == 'BTC' || balance.asset == 'XCP';
                final appIcons = AppIcons();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MouseRegion(
                      cursor: isBitcoinOrXcp
                          ? SystemMouseCursors.basic
                          : SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => isBitcoinOrXcp
                            ? null
                            :
                            // Toggle the starred status
                            context
                                .read<BalancesBloc>()
                                .add(ToggleStarred(asset: balance.asset)),
                        child: starredAssets.contains(balance.asset)
                            ? AppIcons.starFilledIcon(
                                context: context,
                                width: 20,
                                height: 20,
                              )
                            : AppIcons.starOutlinedIcon(
                                context: context,
                                width: 20,
                                height: 20,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          height: 54,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              appIcons.assetIcon(
                                  httpConfig: session.httpConfig,
                                  assetName: balance.asset,
                                  description: balance.assetInfo.description,
                                  context: context,
                                  width: 34,
                                  height: 34),
                              const SizedBox(width: 10),
                              // Asset name and details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: MiddleTruncatedText(
                                        text: balance.assetLongname ??
                                            balance.asset,
                                        width: 150,
                                        charsToShow: isMobile ? 16 : 30,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Amount and percentage
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SelectableText(
                                    numberWithCommas.format(
                                        double.parse(balance.totalNormalized)),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          }),
        ];
      },
    );
  }
}

class MiddleTruncatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double width;
  final int charsToShow;

  const MiddleTruncatedText({
    super.key,
    required this.text,
    this.style,
    required this.width,
    this.charsToShow = 5,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = width;
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(maxWidth: double.infinity);

        if (textPainter.width <= maxWidth) {
          return Text(text, style: style);
        }
        if (text.length <= charsToShow) {
          return Text(text, style: style);
        }

        final half = (charsToShow / 2).ceil();

        return Text(
          '${text.substring(0, half)}...${text.substring(text.length - half)}',
          style: style,
          maxLines: 1,
        );
      },
    );
  }
}
