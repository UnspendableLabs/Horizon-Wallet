import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/common/no_data.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';

class BalancesDisplay extends StatefulWidget {
  final bool isDarkTheme;
  final String searchQuery;

  const BalancesDisplay({
    super.key,
    required this.isDarkTheme,
    this.searchQuery = '',
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
          isDarkTheme: widget.isDarkTheme,
          searchQuery: widget.searchQuery,
        ),
      ),
    );
  }
}

enum BalanceFilter { none, named, numeric, subassets, issuances }

class BalancesSliver extends StatefulWidget {
  final bool isDarkTheme;
  final String searchQuery;

  const BalancesSliver({
    super.key,
    required this.isDarkTheme,
    this.searchQuery = '',
  });

  @override
  BalancesSliverState createState() => BalancesSliverState();
}

class BalancesSliverState extends State<BalancesSliver> {
  BalanceFilter _currentFilter = BalanceFilter.none;

  @override
  void didUpdateWidget(BalancesSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget is BalancesDisplay) {
      // _searchQuery = (widget as BalancesDisplay).searchQuery;
    }
  }

  void _setFilter(BalanceFilter filter) {
    setState(() {
      _currentFilter = _currentFilter == filter ? BalanceFilter.none : filter;
    });
  }

  void _clearFilter() {
    setState(() {
      _currentFilter = BalanceFilter.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalancesBloc, BalancesState>(
      builder: (context, state) {
        return Column(
          children: [
            FilterBar(
              isDarkTheme: widget.isDarkTheme,
              currentFilter: _currentFilter,
              onFilterSelected: _setFilter,
              onClearFilter: _clearFilter,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: _buildContent(state),
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
    switch (_currentFilter) {
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
      case BalanceFilter.issuances:
        return balance.entries.any((entry) {
          return (entry.address != null &&
                  balance.assetInfo.owner != null &&
                  entry.address == balance.assetInfo.owner) ||
              (entry.utxo != null &&
                  balance.assetInfo.owner != null &&
                  entry.utxoAddress == balance.assetInfo.owner);
        });
      case BalanceFilter.none:
        return true;
    }
  }

  List<Widget> _buildContent(BalancesState state) {
    return state.when(
      initial: () => [const SizedBox.shrink()],
      loading: () => [
        const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        )
      ],
      complete: (result) => _buildBalanceList(result),
      reloading: (result) => _buildBalanceList(result),
    );
  }

  List<Widget> _buildBalanceList(Result result) {
    return result.when(
      error: (error) => [
        SizedBox(
          height: 200,
          child: Center(child: SelectableText(error)),
        )
      ],
      ok: (balances) {
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
            if (a.asset == 'BTC') return -1;
            if (b.asset == 'BTC') return 1;
            if (a.asset == 'XCP') return -1;
            if (b.asset == 'XCP') return 1;
            return a.asset.compareTo(b.asset);
          });

        return [
          Column(
            children: sortedBalances.map((balance) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Navigate to the asset details page
                      context
                          .go('/asset/${Uri.encodeComponent(balance.asset)}');
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      // padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      height: 54,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          // Star icon (placeholder)
                          const Icon(
                            Icons.star_border_outlined,
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          // Asset icon (placeholder)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey, // Placeholder color
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Asset name and details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: MiddleTruncatedText(
                                    text:
                                        balance.assetLongname ?? balance.asset,
                                    width: 150,
                                    charsToShow: 5,
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
                              Text(
                                balance.totalNormalized,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
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

        return Text(
          '${text.substring(0, charsToShow)}...${text.substring(text.length - charsToShow)}',
          style: style,
          maxLines: 1,
        );
      },
    );
  }
}

class FilterBar extends StatelessWidget {
  final bool isDarkTheme;
  final BalanceFilter currentFilter;
  final Function(BalanceFilter) onFilterSelected;
  final VoidCallback onClearFilter;

  const FilterBar({
    super.key,
    required this.isDarkTheme,
    required this.currentFilter,
    required this.onFilterSelected,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 44,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isDarkTheme ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDarkTheme ? transparentWhite8 : transparentBlack8,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FilterButton(
              label: 'Named',
              isSelected: currentFilter == BalanceFilter.named,
              onTap: () => onFilterSelected(BalanceFilter.named),
              isDarkTheme: isDarkTheme,
            ),
            _FilterButton(
              label: 'Numeric',
              isSelected: currentFilter == BalanceFilter.numeric,
              onTap: () => onFilterSelected(BalanceFilter.numeric),
              isDarkTheme: isDarkTheme,
            ),
            _FilterButton(
              label: 'Subassets',
              isSelected: currentFilter == BalanceFilter.subassets,
              onTap: () => onFilterSelected(BalanceFilter.subassets),
              isDarkTheme: isDarkTheme,
            ),
            _FilterButton(
              label: 'Issuances',
              isSelected: currentFilter == BalanceFilter.issuances,
              onTap: () => onFilterSelected(BalanceFilter.issuances),
              isDarkTheme: isDarkTheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDarkTheme;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 32,
          // width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? transparentPurple16 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkTheme ? offWhite : offBlack,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
