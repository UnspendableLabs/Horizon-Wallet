import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/common/no_data.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';

class BalancesDisplay extends StatefulWidget {
  final bool isDarkTheme;

  const BalancesDisplay({super.key, required this.isDarkTheme});

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
        ),
      ),
    );
  }
}

class BalanceEntry {
  final String asset;
  final String? assetLongname;
  final String quantityNormalized;
  final String quantity;

  BalanceEntry({
    required this.asset,
    required this.assetLongname,
    required this.quantityNormalized,
    required this.quantity,
  });
}

class BalancesSliver extends StatefulWidget {
  final bool isDarkTheme;

  const BalancesSliver({
    super.key,
    required this.isDarkTheme,
  });

  @override
  BalancesSliverState createState() => BalancesSliverState();
}

class BalancesSliverState extends State<BalancesSliver> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalancesBloc, BalancesState>(
      builder: (context, state) {
        return ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: _buildContent(state),
        );
      },
    );
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
      ok: (aggregated) {
        if (aggregated.isEmpty) {
          return [
            const NoData(
              title: 'No Balances',
            )
          ];
        }

        final Map<String, BalanceEntry> balanceEntries = {};

        // Iterate through each asset and its list of balances
        for (final entry in aggregated.entries) {
          final String asset = entry.key;
          final List<Balance> balances = entry.value;

          // Get the first balance to access asset info
          final Balance firstBalance = balances.first;

          // Sum up the normalized quantities
          double totalNormalized = 0.0;
          int totalQuantity = 0;

          // Add up all quantities for this asset
          for (final balance in balances) {
            totalNormalized += double.parse(balance.quantityNormalized);
            totalQuantity += balance.quantity;
          }

          // Format the total normalized quantity based on divisibility
          final totalQuantityNormalized = firstBalance.assetInfo.divisible
              ? totalNormalized.toStringAsFixed(8)
              : totalNormalized.toStringAsFixed(0);

          balanceEntries[asset] = BalanceEntry(
            asset: asset,
            assetLongname: firstBalance.assetInfo.assetLongname,
            quantityNormalized: totalQuantityNormalized,
            quantity: totalQuantity.toString(),
          );
        }

        // Build the list of asset entries
        return [
          Column(
            children: balanceEntries.entries.map((entry) {
              return SizedBox(
                // padding: const EdgeInsets.symmetric(horizontal: 10.0),
                height: 54,
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
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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
                          entry.value.quantityNormalized,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ];
      },
    );
  }
}
