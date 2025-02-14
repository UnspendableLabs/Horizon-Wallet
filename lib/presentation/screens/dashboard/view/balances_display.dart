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
          child: Center(child: Text(error)),
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
              ...balanceEntries.entries
                  .map((entry) => TableRow(
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
                      ))
                  ,
            ],
          ),
        ];
      },
    );
  }
}

// Future<void> _launchAssetUrl(String asset) async {
//   final url = "${_config.horizonExplorerBase}/assets/$asset";
//   if (await canLaunchUrlString(url)) {
//     await launchUrlString(url);
//   } else {
//     // ignore: use_build_context_synchronously
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Could not launch $url')),
//     );
//   }
// }

// List<Widget> _buildContent(BalancesState state) {
//   return state.when(
//     initial: () => [const SizedBox.shrink()],
//     loading: () => [
//       const SizedBox(
//         height: 200,
//         child: Center(child: CircularProgressIndicator()),
//       )
//     ],
//     complete: (result) => _buildBalanceList(result),
//     reloading: (result) => _buildBalanceList(result),
//   );
// }

// TableCell _buildTableCell1(
//   String assetName,
//   String? assetLongname,
//   bool isClickable,
//   Color textColor,
// ) {
//   return TableCell(
//     verticalAlignment: TableCellVerticalAlignment.middle,
//     child: Padding(
//       padding: const EdgeInsets.fromLTRB(16.0, 8.0, 4.0, 8.0),
//       child: SelectableText.rich(
//         TextSpan(
//           children: [
//             TextSpan(
//               text: (assetLongname != '' && assetLongname != null)
//                   ? assetLongname
//                   : assetName,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: textColor,
//               ),
//               recognizer: isClickable
//                   ? (TapGestureRecognizer()
//                     ..onTap = () => _launchAssetUrl(assetName))
//                   : null,
//             ),
//           ],
//         ),
//         key: Key('assetName_$assetName'),
//       ),
//     ),
//   );
// }

// TableCell _buildTableCell2(String quantityNormalized, Color textColor) =>
//     TableCell(
//       verticalAlignment: TableCellVerticalAlignment.middle,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16.0, 8.0, 4.0, 8.0),
//         child: SelectableText(
//           quantityNormalized,
//           style: const TextStyle(fontSize: 14),
//         ),
//       ),
//     );

// TableCell _buildTableCell3(
//     String assetName,
//     String? assetLongname,
//     Color textColor,
//     bool isOwner,
//     Asset? currentOwnedAsset,
//     int quantity,
//     List<String> fairminterAssets,
//     String? utxo,
//     String? utxoAddress) {
//   return TableCell(
//     verticalAlignment: TableCellVerticalAlignment.middle,
//     child: Container(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           if (assetName == 'BTC' &&
//               _config.network == Network.testnet4 &&
//               quantity > 0)
//             SizedBox(
//               width: 32,
//               height: 32,
//               child: IconButton(
//                 padding: EdgeInsets.zero,
//                 iconSize: 16.0,
//                 icon: const Icon(Icons.local_fire_department),
//                 onPressed: () {
//                   HorizonUI.HorizonDialog.show(
//                     context: context,
//                     body: HorizonUI.HorizonDialog(
//                       title: 'Burn BTC',
//                       body: ComposeBurnPageWrapper(
//                         currentAddress: widget.currentAddress,
//                         dashboardActivityFeedBloc:
//                             BlocProvider.of<DashboardActivityFeedBloc>(
//                                 context),
//                       ),
//                       includeBackButton: false,
//                       includeCloseButton: true,
//                       onBackButtonPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           if (utxo == null && quantity > 0 && assetName != 'BTC')
//             SizedBox(
//               width: 32,
//               height: 32,
//               child: IconButton(
//                 padding: EdgeInsets.zero,
//                 onPressed: () {
//                   HorizonUI.HorizonDialog.show(
//                     context: context,
//                     body: HorizonUI.HorizonDialog(
//                       title: 'Attach UTXO',
//                       body: ComposeAttachUtxoPageWrapper(
//                           dashboardActivityFeedBloc:
//                               BlocProvider.of<DashboardActivityFeedBloc>(
//                                   context),
//                           currentAddress: widget.currentAddress,
//                           assetName: assetName,
//                           assetLongname: assetLongname),
//                       includeBackButton: false,
//                       includeCloseButton: true,
//                       onBackButtonPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   );
//                 },
//                 icon: const Icon(Icons.attach_file, size: 16.0),
//               ),
//             ),
//           if (utxo != null)
//             SizedBox(
//               width: 32,
//               height: 32,
//               child: IconButton(
//                 padding: EdgeInsets.zero,
//                 onPressed: () {
//                   HorizonUI.HorizonDialog.show(
//                     context: context,
//                     body: HorizonUI.HorizonDialog(
//                       title: 'Detach UTXO',
//                       body: ComposeDetachUtxoPageWrapper(
//                         dashboardActivityFeedBloc:
//                             BlocProvider.of<DashboardActivityFeedBloc>(
//                                 context),
//                         currentAddress: widget.currentAddress,
//                         assetName: assetName,
//                         utxo: utxo,
//                       ),
//                       includeBackButton: false,
//                       includeCloseButton: true,
//                       onBackButtonPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   );
//                 },
//                 icon: const Icon(Icons.link_off, size: 16.0),
//               ),
//             ),
//           if (quantity > 0)
//             SizedBox(
//               width: 32,
//               height: 32,
//               child: IconButton(
//                 padding: EdgeInsets.zero,
//                 iconSize: 16.0,
//                 icon: const Icon(Icons.send),
//                 onPressed: () {
//                   if (utxo == null) {
//                     HorizonUI.HorizonDialog.show(
//                       context: context,
//                       body: HorizonUI.HorizonDialog(
//                         title: 'Compose Send',
//                         body: ComposeSendPageWrapper(
//                           currentAddress: widget.currentAddress,
//                           dashboardActivityFeedBloc:
//                               BlocProvider.of<DashboardActivityFeedBloc>(
//                                   context),
//                           asset: assetName,
//                         ),
//                         includeBackButton: false,
//                         includeCloseButton: true,
//                       ),
//                     );
//                   } else {
//                     HorizonUI.HorizonDialog.show(
//                       context: context,
//                       body: HorizonUI.HorizonDialog(
//                         title: 'Move to UTXO',
//                         body: ComposeMoveToUtxoPageWrapper(
//                           currentAddress: widget.currentAddress,
//                           dashboardActivityFeedBloc:
//                               BlocProvider.of<DashboardActivityFeedBloc>(
//                                   context),
//                           assetName: assetName,
//                           utxo: utxo,
//                         ),
//                         includeBackButton: false,
//                         includeCloseButton: true,
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ),
//           if (isOwner)
//             SizedBox(
//               width: 32,
//               height: 32,
//               child: PopupMenuButton<IssuanceActionType>(
//                 padding: EdgeInsets.zero,
//                 iconSize: 16.0,
//                 icon: const Icon(Icons.more_vert),
//                 onSelected: (IssuanceActionType result) {
//                   if (result == IssuanceActionType.dividend) {
//                     HorizonUI.HorizonDialog.show(
//                       context: context,
//                       body: HorizonUI.HorizonDialog(
//                         title: "Dividend",
//                         body: ComposeDividendPageWrapper(
//                           currentAddress: widget.currentAddress,
//                           dashboardActivityFeedBloc:
//                               BlocProvider.of<DashboardActivityFeedBloc>(
//                                   context),
//                           assetName: currentOwnedAsset!.asset,
//                         ),
//                         includeBackButton: false,
//                         includeCloseButton: true,
//                         onBackButtonPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     );
//                   } else {
//                     HorizonUI.HorizonDialog.show(
//                       context: context,
//                       body: HorizonUI.HorizonDialog(
//                         title: "Update Issuance",
//                         body: UpdateIssuancePageWrapper(
//                           currentAddress: widget.currentAddress,
//                           assetName: currentOwnedAsset!.asset,
//                           assetLongname: currentOwnedAsset.assetLongname,
//                           actionType: result,
//                           dashboardActivityFeedBloc:
//                               BlocProvider.of<DashboardActivityFeedBloc>(
//                                   context),
//                         ),
//                         includeBackButton: false,
//                         includeCloseButton: true,
//                         onBackButtonPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     );
//                   }
//                 },
//                 itemBuilder: (BuildContext context) =>
//                     <PopupMenuEntry<IssuanceActionType>>[
//                   PopupMenuItem<IssuanceActionType>(
//                     value: IssuanceActionType.reset,
//                     enabled: currentOwnedAsset?.locked != true &&
//                         !fairminterAssets.contains(currentOwnedAsset?.asset),
//                     child: const Text('Reset Asset'),
//                   ),
//                   PopupMenuItem<IssuanceActionType>(
//                     value: IssuanceActionType.lockQuantity,
//                     enabled: currentOwnedAsset?.locked != true &&
//                         !fairminterAssets.contains(currentOwnedAsset?.asset),
//                     child: const Text('Lock Quantity'),
//                   ),
//                   PopupMenuItem<IssuanceActionType>(
//                     value: IssuanceActionType.lockDescription,
//                     enabled: currentOwnedAsset?.locked != true &&
//                         !fairminterAssets.contains(currentOwnedAsset?.asset),
//                     child: const Text('Lock Description'),
//                   ),
//                   PopupMenuItem<IssuanceActionType>(
//                     value: IssuanceActionType.changeDescription,
//                     enabled: currentOwnedAsset?.locked != true &&
//                         !fairminterAssets.contains(currentOwnedAsset?.asset),
//                     child: const Text('Change Description'),
//                   ),
//                   PopupMenuItem<IssuanceActionType>(
//                     value: IssuanceActionType.issueMore,
//                     enabled: currentOwnedAsset?.locked != true &&
//                         !fairminterAssets.contains(currentOwnedAsset?.asset),
//                     child: const Text('Issue More'),
//                   ),
//                   const PopupMenuItem<IssuanceActionType>(
//                     value: IssuanceActionType.issueSubasset,
//                     child: Text('Issue Subasset'),
//                   ),
//                   const PopupMenuItem<IssuanceActionType>(
//                     value: IssuanceActionType.transferOwnership,
//                     child: Text('Transfer Ownership'),
//                   ),
//                   if (utxo == null)
//                     const PopupMenuItem<IssuanceActionType>(
//                       value: IssuanceActionType.dividend,
//                       child: Text('Dividend'),
//                     ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     ),
//   );
// }
// }
