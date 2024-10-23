import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/no_data.dart';
import 'package:horizon/presentation/screens/compose_send/view/compose_send_page.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/screens/update_issuance/view/update_issuance_page.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BalancesDisplay extends StatefulWidget {
  final bool isDarkTheme;
  final List<Address> addresses;
  final String accountUuid;
  final Address currentAddress;
  final int initialItemCount;

  const BalancesDisplay(
      {super.key,
      required this.isDarkTheme,
      required this.addresses,
      required this.accountUuid,
      required this.currentAddress,
      required this.initialItemCount});

  @override
  BalancesDisplayState createState() => BalancesDisplayState();
}

class BalancesDisplayState extends State<BalancesDisplay> {
  final TextEditingController _searchController = TextEditingController();
  bool _showOwnedOnly = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('search_input'), // Add this line
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search assets',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _showOwnedOnly,
                      onChanged: (value) {
                        setState(() {
                          _showOwnedOnly = value ?? false;
                        });
                      },
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                        return widget.isDarkTheme
                            ? darkThemeInputColor
                            : whiteLightTheme; // Use transparent for unchecked state
                      }),
                      key: const Key('owned_checkbox'), // Add this line
                    ),
                    const Text('Owned'),
                  ],
                ),
              ],
            ),
          ),
          BalancesSliver(
            isDarkTheme: widget.isDarkTheme,
            addresses: widget.addresses,
            currentAddress: widget.currentAddress,
            initialItemCount: widget.initialItemCount,
            searchTerm: _searchController.text,
            showOwnedOnly: _showOwnedOnly,
          ),
        ],
      ),
    );
  }
}

class BalancesSliver extends StatefulWidget {
  final bool isDarkTheme;
  final List<Address> addresses;
  final int initialItemCount;
  final Address currentAddress;
  final String searchTerm;
  final bool showOwnedOnly;

  const BalancesSliver({
    super.key,
    required this.isDarkTheme,
    required this.addresses,
    required this.initialItemCount,
    required this.currentAddress,
    required this.searchTerm,
    required this.showOwnedOnly,
  });

  @override
  BalancesSliverState createState() => BalancesSliverState();
}

class BalancesSliverState extends State<BalancesSliver> {
  bool _viewAll = false;
  final Config _config = GetIt.I<Config>();

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

  List<Widget> _buildBalanceList(Result result) {
    return result.when(
      ok: (balances, aggregated, ownedAssets) {
        if (balances.isEmpty && ownedAssets.isEmpty) {
          return [
            const NoData(
              title: 'No Balances',
            )
          ];
        }

        final entries = aggregated.entries.toList();

        // Find BTC and XCP entries
        final btcEntry = entries.where((e) => e.key == 'BTC').singleOrNull;
        final xcpEntry = entries.where((e) => e.key == 'XCP').singleOrNull;

        // Remove BTC and XCP from the original list if they exist
        entries.removeWhere((e) => e.key == 'BTC' || e.key == 'XCP');

        // Create a new list with BTC and XCP at the beginning, if they exist
        final orderedEntries = [
          if (btcEntry != null) btcEntry,
          if (xcpEntry != null) xcpEntry,
          ...entries,
        ];

        final ownedAssetsNotIncludedInEntries = ownedAssets
            .where((asset) =>
                !orderedEntries.any((entry) => entry.key == asset.asset))
            .toList();

        final List<TableRow> rows = [];
        final balanceRows = orderedEntries
            .where((entry) =>
                _matchesSearch(entry.key, entry.value.assetInfo.assetLongname))
            .where((entry) => (widget.showOwnedOnly
                ? _isOwned(ownedAssets
                    .firstWhereOrNull((asset) => asset.asset == entry.key))
                : true))
            .map((entry) {
          final isClickable = entry.key != 'BTC';

          final Color textColor = isClickable
              ? (widget.isDarkTheme
                  ? darkThemeAssetLinkColor
                  : lightThemeAssetLinkColor)
              : (widget.isDarkTheme
                  ? greyDashboardTextDarkTheme
                  : greyDashboardTextLightTheme);

          Asset? currentOwnedAsset =
              ownedAssets.firstWhereOrNull((asset) => asset.asset == entry.key);

          final bool isOwner = _isOwned(currentOwnedAsset);

          return TableRow(
            children: [
              _buildTableCell1(entry.key, entry.value.assetInfo.assetLongname,
                  isClickable, textColor),
              _buildTableCell2(entry.value.quantityNormalized, textColor),
              _buildTableCell3(entry.key, textColor, isOwner, currentOwnedAsset,
                  entry.value.quantity)
            ],
          );
        }).toList();

        final ownedAssetRows = ownedAssetsNotIncludedInEntries
            .where((asset) => _matchesSearch(asset.asset, asset.assetLongname))
            .map((asset) {
          final textColor = widget.isDarkTheme
              ? darkThemeAssetLinkColor
              : lightThemeAssetLinkColor;
          return TableRow(
            children: [
              _buildTableCell1(
                  asset.asset, asset.assetLongname, true, textColor),
              _buildTableCell2(asset.divisible == true ? '0.00000000' : '0',
                  textColor), // these are zero balances
              _buildTableCell3(asset.asset, textColor, true, asset, 0)
            ],
          );
        }).toList();

        rows.addAll(balanceRows);
        rows.addAll(ownedAssetRows);

        final displayedRows =
            _viewAll ? rows : rows.take(widget.initialItemCount).toList();

        List<Widget> widgets = [
          LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: Table(
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: widget.isDarkTheme ? Colors.white24 : Colors.black12,
                    width: 1,
                  ),
                ),
                columnWidths: {
                  0: FlexColumnWidth(
                      MediaQuery.of(context).size.width < 600 ? 1 : 2),
                  1: const FlexColumnWidth(1),
                  2: FlexColumnWidth(
                      MediaQuery.of(context).size.width < 600 ? 1 : 1),
                },
                children: displayedRows,
              ),
            );
          }),
        ];

        if (!_viewAll && rows.length > widget.initialItemCount) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _viewAll = true;
                  });
                },
                child: const Text("View All"),
              ),
            ),
          );
        }

        return widgets;
      },
      error: (error) => [
        SizedBox(
          height: 200,
          child: Center(child: Text(error)),
        )
      ],
    );
  }

  bool _matchesSearch(String assetName, String? assetLongname) {
    final searchTerm = widget.searchTerm.toLowerCase();
    return assetName.toLowerCase().startsWith(searchTerm) ||
        (assetLongname != null &&
            assetLongname.isNotEmpty &&
            assetLongname.toLowerCase().startsWith(searchTerm));
  }

  bool _isOwned(Asset? asset) {
    return asset?.owner == widget.currentAddress.address;
  }

  bool _isIssuer(Asset? asset) {
    return asset?.issuer == widget.currentAddress.address;
  }

  Future<void> _launchAssetUrl(String asset) async {
    final url = "${_config.horizonExplorerBase}/assets/$asset";
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
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

  TableCell _buildTableCell1(String assetName, String? assetLongname,
      bool isClickable, Color textColor) {
    return TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 4.0, 8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SelectableText.rich(
                TextSpan(
                  text: (assetLongname != '' && assetLongname != null)
                      ? assetLongname
                      : assetName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  recognizer: isClickable
                      ? (TapGestureRecognizer()
                        ..onTap = () => _launchAssetUrl(assetName))
                      : null,
                ),
                key: Key('assetName_$assetName'),
              );
            },
          ),
        ));
  }

  TableCell _buildTableCell2(String quantityNormalized, Color textColor) =>
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 4.0, 8.0),
          child: SelectableText(
            quantityNormalized,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );

  TableCell _buildTableCell3(String assetName, Color textColor, bool isOwner,
      Asset? currentOwnedAsset, int quantity) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4.0, 8.0, 2.0, 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (quantity > 0)
              IconButton(
                iconSize: 16.0,
                icon: const Icon(Icons.send),
                onPressed: () {
                  HorizonUI.HorizonDialog.show(
                    context: context,
                    body: HorizonUI.HorizonDialog(
                      title: 'Compose Send',
                      body: ComposeSendPageWrapper(
                        dashboardActivityFeedBloc:
                            BlocProvider.of<DashboardActivityFeedBloc>(context),
                        asset: assetName,
                      ),
                      includeBackButton: false,
                      includeCloseButton: true,
                    ),
                  );
                },
              ),
            if (!isOwner) SizedBox(width: 38),
            if (isOwner)
              PopupMenuButton<IssuanceActionType>(
                icon: const Icon(Icons.more_vert),
                onSelected: (IssuanceActionType result) {
                  HorizonUI.HorizonDialog.show(
                    context: context,
                    body: HorizonUI.HorizonDialog(
                      title: "Update Issuance",
                      body: UpdateIssuancePageWrapper(
                        assetName: currentOwnedAsset!.asset,
                        assetLongname: currentOwnedAsset.assetLongname,
                        actionType: result,
                        dashboardActivityFeedBloc:
                            BlocProvider.of<DashboardActivityFeedBloc>(context),
                      ),
                      includeBackButton: false,
                      includeCloseButton: true,
                      onBackButtonPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<IssuanceActionType>>[
                  PopupMenuItem<IssuanceActionType>(
                    value: IssuanceActionType.reset,
                    enabled: currentOwnedAsset?.locked != true,
                    child: const Text('Reset Asset'),
                  ),
                  PopupMenuItem<IssuanceActionType>(
                    value: IssuanceActionType.lockQuantity,
                    enabled: currentOwnedAsset?.locked != true,
                    child: const Text('Lock Quantity'),
                  ),
                  PopupMenuItem<IssuanceActionType>(
                    value: IssuanceActionType.lockDescription,
                    enabled: currentOwnedAsset?.locked != true,
                    child: const Text('Lock Description'),
                  ),
                  PopupMenuItem<IssuanceActionType>(
                    value: IssuanceActionType.changeDescription,
                    enabled: currentOwnedAsset?.locked != true,
                    child: const Text('Change Description'),
                  ),
                  PopupMenuItem<IssuanceActionType>(
                    value: IssuanceActionType.issueMore,
                    enabled: currentOwnedAsset?.locked != true,
                    child: const Text('Issue More'),
                  ),
                  const PopupMenuItem<IssuanceActionType>(
                    value: IssuanceActionType.issueSubasset,
                    child: Text('Issue Subasset'),
                  ),
                  const PopupMenuItem<IssuanceActionType>(
                    value: IssuanceActionType.transferOwnership,
                    child: Text('Transfer Ownership'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
