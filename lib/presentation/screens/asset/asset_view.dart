import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/common/filter_bar.dart';
import 'package:horizon/presentation/common/icon_item_button.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/asset/bloc/asset_view_bloc.dart';
import 'package:horizon/presentation/screens/asset/bloc/asset_view_event.dart';
import 'package:horizon/presentation/screens/dashboard/view/asset_icon.dart';
import 'package:horizon/presentation/screens/transactions/send/view/send_page.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
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

  bool get _isBitcoin => widget.assetName.toUpperCase() == 'BTC';

  @override
  void initState() {
    super.initState();
    context.read<AssetViewBloc>().add(PageLoaded());
    _tabController = TabController(length: _isBitcoin ? 1 : 2, vsync: this);
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

  // Show the send page in a fullscreen dialog
  void _showTransactionPage({required TransactionType type}) {
    final session = context.read<SessionStateCubit>().state;

    final page = switch (type) {
      TransactionType.send => SendPage(
          assetName: widget.assetName,
          addresses: session.allAddresses,
        ),
    };

    switch (type) {
      case TransactionType.send:
        showDialog(
          context: context,
          builder: (dialogContext) {
            return Dialog.fullscreen(
              child: page,
            );
          },
        );
        break;
    }
    showDialog(
      context: context,
      builder: (dialogContext) {
        final session = context.read<SessionStateCubit>().state;
        return Dialog.fullscreen(
          child: SendPage(
            assetName: widget.assetName,
            addresses: session.allAddresses,
          ),
        );
      },
    );
  }

  // Helper method to build the asset page header
  Widget _buildHeader({
    required BuildContext context,
    bool isLoading = false,
    MultiAddressBalance? balance,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                Theme.of(context).inputDecorationTheme.outlineBorder?.color ??
                    transparentBlack8,
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
          isLoading
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                            .inputDecorationTheme
                            .outlineBorder
                            ?.color ??
                        transparentBlack8,
                    shape: BoxShape.circle,
                  ),
                )
              : AssetIcon(asset: balance!.asset, size: 40),
          const SizedBox(width: 8),
          isLoading
              ? _buildLoadingTextPlaceholders(context)
              : _buildAssetInfo(context, balance!),
        ],
      ),
    );
  }

  // Helper method to build asset info text fields
  Widget _buildAssetInfo(BuildContext context, MultiAddressBalance balance) {
    return Column(
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
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context)
                            .textButtonTheme
                            .style
                            ?.foregroundColor
                            ?.resolve({}) ??
                        Colors.grey,
                    fontSize: 12))
            : const SizedBox.shrink(),
        SelectableText(
          balance.totalNormalized,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context)
                      .textButtonTheme
                      .style
                      ?.foregroundColor
                      ?.resolve({}) ??
                  Colors.grey,
              fontSize: 12),
        ),
      ],
    );
  }

  // Helper method to build text placeholders for loading state
  Widget _buildLoadingTextPlaceholders(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        SelectableText(
          widget.assetName,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Container(
          width: 150,
          height: 12,
          decoration: BoxDecoration(
            color:
                Theme.of(context).inputDecorationTheme.outlineBorder?.color ??
                    transparentBlack8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 12,
          decoration: BoxDecoration(
            color:
                Theme.of(context).inputDecorationTheme.outlineBorder?.color ??
                    transparentBlack8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  // Helper method to build tabs
  Widget _buildTabs(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                Theme.of(context).inputDecorationTheme.outlineBorder?.color ??
                    transparentBlack8,
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
            unselectedLabelColor: Theme.of(context)
                    .textButtonTheme
                    .style
                    ?.foregroundColor
                    ?.resolve({}) ??
                Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            tabAlignment: TabAlignment.center,
            isScrollable: false,
            tabs: [
              const Tab(
                child: Text(
                  'Balance Actions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!_isBitcoin)
                const Tab(
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
    );
  }

  // Helper method to build action button skeletons for loading state
  Widget _buildLoadingActionButtons(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: List.generate(count, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context)
                        .inputDecorationTheme
                        .outlineBorder
                        ?.color ??
                    transparentBlack8,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Helper method to build the content area
  Widget _buildTabContent({
    required BuildContext context,
    required bool isLoading,
  }) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Balance Actions Tab
          isLoading
              ? Column(
                  children: [
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildLoadingActionButtons(context, 6),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    if (!_isBitcoin)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FilterBar(
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
                          disabledOptions:
                              _isBitcoin ? [BalanceViewFilter.utxo] : [],
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            if (_isBitcoin) ...[
                              IconItemButton(
                                title: 'Send',
                                icon: AppIcons.sendIcon(
                                  context: context,
                                ),
                                onTap: () {
                                  _showTransactionPage(
                                      type: TransactionType.send);
                                },
                              ),
                              IconItemButton(
                                title: 'Receive',
                                icon: AppIcons.receiveIcon(
                                  context: context,
                                ),
                                onTap: () {
                                  // Handle Receive
                                },
                              ),
                            ] else if (_currentFilter ==
                                BalanceViewFilter.address) ...[
                              IconItemButton(
                                title: 'Send',
                                icon: AppIcons.sendIcon(
                                  context: context,
                                ),
                                onTap: () {
                                  _showTransactionPage(
                                      type: TransactionType.send);
                                },
                              ),
                              IconItemButton(
                                title: 'Receive',
                                icon: AppIcons.receiveIcon(
                                  context: context,
                                ),
                                onTap: () {
                                  // Handle Receive
                                },
                              ),
                              IconItemButton(
                                title: 'Attach',
                                icon: AppIcons.attachIcon(
                                  context: context,
                                ),
                                onTap: () {
                                  // Handle Attach
                                },
                              ),
                              IconItemButton(
                                title: 'Order',
                                icon: AppIcons.orderIcon(
                                  context: context,
                                ),
                                onTap: () {
                                  // Handle Order
                                },
                              ),
                              IconItemButton(
                                title: 'Destroy',
                                icon: AppIcons.destroyIcon(
                                  context: context,
                                ),
                                onTap: () {
                                  // Handle Destroy
                                },
                              ),
                              IconItemButton(
                                title: 'Dispenser',
                                icon: AppIcons.dispenserIcon(
                                  context: context,
                                ),
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
                                onTap: () {
                                  // Handle UTXO Send
                                },
                              ),
                              IconItemButton(
                                title: 'Detach',
                                icon: AppIcons.detachIcon(
                                  context: context,
                                ),
                                onTap: () {
                                  // Handle Detach
                                },
                              ),
                              IconItemButton(
                                title: 'Swap',
                                icon: AppIcons.swapIcon(
                                  context: context,
                                ),
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
          if (!_isBitcoin)
            isLoading
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildLoadingActionButtons(context, 9),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconItemButton(
                          title: 'Pay Dividend',
                          icon: AppIcons.dividendIcon(
                            context: context,
                          ),
                          onTap: () {
                            // Handle Pay Dividend
                          },
                        ),
                        IconItemButton(
                          title: 'Reset Asset',
                          icon: AppIcons.resetIcon(
                            context: context,
                          ),
                          onTap: () {
                            // Handle Reset Asset
                          },
                        ),
                        IconItemButton(
                          title: 'Create Fairminter',
                          icon: AppIcons.mintIcon(
                            context: context,
                          ),
                          onTap: () {
                            // Handle Create Fairminter
                          },
                        ),
                        IconItemButton(
                          title: 'Issue More',
                          icon: AppIcons.plusIcon(
                            context: context,
                          ),
                          onTap: () {
                            // Handle Issue More
                          },
                        ),
                        IconItemButton(
                          title: 'Issue Subasset',
                          icon: AppIcons.plusIcon(
                            context: context,
                          ),
                          onTap: () {
                            // Handle Issue Subasset
                          },
                        ),
                        IconItemButton(
                          title: 'Update Description',
                          icon: AppIcons.editIcon(
                            context: context,
                          ),
                          onTap: () {
                            // Handle Update Description
                          },
                        ),
                        IconItemButton(
                          title: 'Lock Supply',
                          icon: AppIcons.lockIcon(
                            context: context,
                          ),
                          onTap: () {
                            // Handle Lock Supply
                          },
                        ),
                        IconItemButton(
                          title: 'Lock Description',
                          icon: AppIcons.lockIcon(
                            context: context,
                          ),
                          onTap: () {
                            // Handle Lock Description
                          },
                        ),
                        IconItemButton(
                          title: 'Transfer Issuance Rights',
                          icon: AppIcons.transferIcon(
                            context: context,
                          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssetViewBloc, RemoteDataState<MultiAddressBalance>>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => Column(
            children: [
              _buildHeader(context: context, isLoading: true),
              _buildTabs(context),
              _buildTabContent(context: context, isLoading: true),
            ],
          ),
          error: (error) => SelectableText(error),
          success: (balance) => Column(
            children: [
              _buildHeader(
                  context: context, isLoading: false, balance: balance),
              _buildTabs(context),
              _buildTabContent(context: context, isLoading: false),
            ],
          ),
        );
      },
    );
  }
}
