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
    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: TextField(
          //           key: const Key('search_input'), // Add this line
          //           controller: _searchController,
          //           decoration: InputDecoration(
          //             labelText: 'Search assets',
          //             prefixIcon: const Icon(Icons.search),
          //             border: OutlineInputBorder(
          //               borderRadius: BorderRadius.circular(10),
          //             ),
          //           ),
          //         ),
          //       ),
          //       // const SizedBox(width: 8),
          //       Column(
          //         children: [
          //           Row(
          //             children: [
          //               Checkbox(
          //                 value: _showOwnedOnly,
          //                 onChanged: (value) {
          //                   setState(() {
          //                     _showOwnedOnly = value ?? false;
          //                   });
          //                 },
          //                 fillColor: WidgetStateProperty.resolveWith<Color>(
          //                     (Set<WidgetState> states) {
          //                   return widget.isDarkTheme
          //                       ? darkThemeInputColor
          //                       : whiteLightTheme; // Use transparent for unchecked state
          //                 }),
          //                 key: const Key('owned_checkbox'), // Add this line
          //               ),
          //               const Text('My issuances'),
          //             ],
          //           ),
          //           Row(
          //             children: [
          //               Checkbox(
          //                 value: _showUtxoOnly,
          //                 onChanged: (value) {
          //                   setState(() {
          //                     _showUtxoOnly = value ?? false;
          //                   });
          //                 },
          //                 fillColor: WidgetStateProperty.resolveWith<Color>(
          //                     (Set<WidgetState> states) {
          //                   return widget.isDarkTheme
          //                       ? darkThemeInputColor
          //                       : whiteLightTheme; // Use transparent for unchecked state
          //                 }),
          //                 key: const Key('utxo_checkbox'), // Add this line
          //               ),
          //               const Text('Utxo attached'),
          //             ],
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          BalancesSliver(
            isDarkTheme: widget.isDarkTheme,
          ),
        ],
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
          physics: const NeverScrollableScrollPhysics(),
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

        // Build the table
        return [
          Table(
            children: [
              // Convert entries to TableRow widgets
              ...balanceEntries.entries.map((entry) => TableRow(
                    children: [
                      // Asset name/longname column
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      // Quantity column
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          entry.value.quantityNormalized,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ];
      },
    );
  }
}
