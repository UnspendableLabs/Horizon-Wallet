import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/common/filter_bar.dart';
import 'package:horizon/presentation/common/icon_item_button.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/asset/bloc/asset_view_bloc.dart';
import 'package:horizon/presentation/screens/asset/bloc/asset_view_event.dart';
import 'package:horizon/presentation/screens/dashboard/view/asset_icon.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';
import 'package:horizon/utils/app_icons.dart';

enum BalanceViewFilter { address, utxo }

class AssetView extends StatefulWidget {
  final String assetName;

  const AssetView({
    super.key,
    required this.assetName,
  });

  @override
  State<AssetView> createState() => _AssetViewState();
}

class _AssetViewState extends State<AssetView> with TickerProviderStateMixin {
  late TabController _tabController;
  BalanceViewFilter _currentFilter = BalanceViewFilter.address;

  @override
  void initState() {
    super.initState();
    context.read<AssetViewBloc>().add(PageLoaded());
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setFilter(Object filter) {
    setState(() {
      _currentFilter = filter as BalanceViewFilter;
    });
  }

  void _clearFilter() {
    setState(() {
      _currentFilter = BalanceViewFilter.address;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AssetViewBloc, RemoteDataState<MultiAddressBalance>>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (error) => SelectableText(error),
          success: (balance) => Column(
            children: [
              // Asset page header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkTheme
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    AppIcons.iconButton(
                      context: context,
                      icon: AppIcons.backArrowIcon(
                        context: context,
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () {
                        context.go('/dashboard');
                      },
                    ),
                    const SizedBox(width: 4),
                    AssetIcon(asset: balance.asset, size: 40),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 8),
                        SelectableText(
                          balance.asset,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        balance.assetLongname != null
                            ? SelectableText(
                                textAlign: TextAlign.left,
                                balance.assetLongname!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: isDarkTheme
                                            ? transparentWhite33
                                            : transparentBlack33,
                                        fontSize: 12))
                            : const SizedBox.shrink(),
                        SelectableText(
                          balance.totalNormalized,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: isDarkTheme
                                      ? transparentWhite33
                                      : transparentBlack33,
                                  fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Tabs
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkTheme
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    child: TabBar(
                      controller: _tabController,
                      indicatorWeight: 2,
                      indicatorColor: transparentPurple33,
                      labelColor: Theme.of(context).textTheme.bodyMedium?.color,
                      unselectedLabelColor:
                          isDarkTheme ? transparentWhite33 : transparentBlack33,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabAlignment: TabAlignment.center,
                      isScrollable: false,
                      tabs: const [
                        Tab(
                          child: Text(
                            'Balance Actions',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Issuance Actions',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Asset page content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Balance Actions Tab
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: FilterBar(
                            isDarkTheme: isDarkTheme,
                            currentFilter: _currentFilter,
                            onFilterSelected: _setFilter,
                            onClearFilter: _clearFilter,
                            filterOptions: const [
                              FilterOption(
                                  label: 'Address Balances',
                                  value: BalanceViewFilter.address),
                              FilterOption(
                                  label: 'Utxo Balances',
                                  value: BalanceViewFilter.utxo),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                if (_currentFilter ==
                                    BalanceViewFilter.address) ...[
                                  IconItemButton(
                                    title: 'Send',
                                    icon: AppIcons.sendIcon(
                                      context: context,
                                    ),
                                    isDarkTheme: isDarkTheme,
                                    onTap: () {
                                      // Handle Send
                                    },
                                  ),
                                  IconItemButton(
                                    title: 'Receive',
                                    icon: AppIcons.receiveIcon(
                                      context: context,
                                    ),
                                    isDarkTheme: isDarkTheme,
                                    onTap: () {
                                      // Handle Receive
                                    },
                                  ),
                                  IconItemButton(
                                    title: 'Attach',
                                    icon: AppIcons.attachIcon(
                                      context: context,
                                    ),
                                    isDarkTheme: isDarkTheme,
                                    onTap: () {
                                      // Handle Attach
                                    },
                                  ),
                                  IconItemButton(
                                    title: 'Order',
                                    icon: AppIcons.orderIcon(
                                      context: context,
                                    ),
                                    isDarkTheme: isDarkTheme,
                                    onTap: () {
                                      // Handle Order
                                    },
                                  ),
                                  IconItemButton(
                                    title: 'Destroy',
                                    icon: AppIcons.destroyIcon(
                                      context: context,
                                    ),
                                    isDarkTheme: isDarkTheme,
                                    onTap: () {
                                      // Handle Destroy
                                    },
                                  ),
                                  IconItemButton(
                                    title: 'Dispenser',
                                    icon: AppIcons.dispenserIcon(
                                      context: context,
                                    ),
                                    isDarkTheme: isDarkTheme,
                                    onTap: () {
                                      // Handle Dispenser
                                    },
                                  ),
                                ] else if (_currentFilter ==
                                    BalanceViewFilter.utxo) ...[
                                  IconItemButton(
                                    title: 'Send',
                                    icon: AppIcons.sendIcon(
                                      context: context,
                                    ),
                                    isDarkTheme: isDarkTheme,
                                    onTap: () {
                                      // Handle UTXO Send
                                    },
                                  ),
                                  IconItemButton(
                                    title: 'Detach',
                                    icon: AppIcons.detachIcon(
                                      context: context,
                                    ),
                                    isDarkTheme: isDarkTheme,
                                    onTap: () {
                                      // Handle Detach
                                    },
                                  ),
                                  IconItemButton(
                                    title: 'Swap',
                                    icon: AppIcons.swapIcon(
                                      context: context,
                                    ),
                                    isDarkTheme: isDarkTheme,
                                    onTap: () {
                                      // Handle Swap
                                    },
                                  ),
                                ],
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Issuance Actions Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconItemButton(
                            title: 'Pay Dividend',
                            icon: AppIcons.dividendIcon(
                              context: context,
                            ),
                            isDarkTheme: isDarkTheme,
                            onTap: () {
                              // Handle Pay Dividend
                            },
                          ),
                          IconItemButton(
                            title: 'Reset Asset',
                            icon: AppIcons.resetIcon(
                              context: context,
                            ),
                            isDarkTheme: isDarkTheme,
                            onTap: () {
                              // Handle Reset Asset
                            },
                          ),
                          IconItemButton(
                            title: 'Create Fairminter',
                            icon: AppIcons.mintIcon(
                              context: context,
                            ),
                            isDarkTheme: isDarkTheme,
                            onTap: () {
                              // Handle Create Fairminter
                            },
                          ),
                          IconItemButton(
                            title: 'Issue More',
                            icon: AppIcons.plusIcon(
                              context: context,
                            ),
                            isDarkTheme: isDarkTheme,
                            onTap: () {
                              // Handle Issue More
                            },
                          ),
                          IconItemButton(
                            title: 'Issue Subasset',
                            icon: AppIcons.plusIcon(
                              context: context,
                            ),
                            isDarkTheme: isDarkTheme,
                            onTap: () {
                              // Handle Issue Subasset
                            },
                          ),
                          IconItemButton(
                            title: 'Update Description',
                            icon: AppIcons.editIcon(
                              context: context,
                            ),
                            isDarkTheme: isDarkTheme,
                            onTap: () {
                              // Handle Update Description
                            },
                          ),
                          IconItemButton(
                            title: 'Lock Supply',
                            icon: AppIcons.lockIcon(
                              context: context,
                            ),
                            isDarkTheme: isDarkTheme,
                            onTap: () {
                              // Handle Lock Supply
                            },
                          ),
                          IconItemButton(
                            title: 'Lock Description',
                            icon: AppIcons.lockIcon(
                              context: context,
                            ),
                            isDarkTheme: isDarkTheme,
                            onTap: () {
                              // Handle Lock Description
                            },
                          ),
                          IconItemButton(
                            title: 'Transfer Issuance Rights',
                            icon: AppIcons.transferIcon(
                              context: context,
                            ),
                            isDarkTheme: isDarkTheme,
                            onTap: () {
                              // Handle Transfer Issuance Rights
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
