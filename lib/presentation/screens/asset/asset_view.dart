import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/common/filter_bar.dart';
import 'package:horizon/presentation/common/icon_item_button.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/asset/bloc/asset_view_bloc.dart';
import 'package:horizon/presentation/screens/asset/bloc/asset_view_event.dart';
import 'package:horizon/presentation/screens/dashboard/view/asset_icon.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser/view/create_dispenser_page.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser_on_new_address/view/create_dispenser_on_new_address_page.dart';
import 'package:horizon/presentation/screens/transactions/lock_quantity/view/lock_quantity_page.dart';
import 'package:horizon/presentation/screens/transactions/send/view/send_page.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

enum BalanceViewFilter { address, utxo }

enum DispenserOption { existingAddress, newAddress }

class DispenserOptionsDialog extends StatelessWidget {
  final Function(DispenserOption) onOptionSelected;

  const DispenserOptionsDialog({
    super.key,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StatefulBuilder(
      builder: (context, setState) {
        return HorizonDialogContainer(
          onCancel: () => Navigator.of(context).pop(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'How do you want to proceed?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      onOptionSelected(DispenserOption.existingAddress);
                      Navigator.of(context)
                          .pop(DispenserOption.existingAddress);
                    },
                    child:
                        const Text('Create dispenser on an existing address'),
                  ),
                  TextButton(
                    onPressed: () {
                      onOptionSelected(DispenserOption.newAddress);
                      Navigator.of(context).pop(DispenserOption.newAddress);
                    },
                    child: const Text('Create dispenser on a new address'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

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

  bool _isAssetOwner(MultiAddressBalance balance) {
    return balance.entries
        .any((entry) => entry.address == balance.assetInfo.owner);
  }

  @override
  void initState() {
    super.initState();
    context.read<AssetViewBloc>().add(PageLoaded());
    _tabController = TabController(length: 1, vsync: this);
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
  void _showTransactionPage({required TransactionType type}) async {
    final session = context.read<SessionStateCubit>().state;

    DispenserOption? selectedDispenserOption;
    if (type == TransactionType.dispenser) {
      selectedDispenserOption = await showDialog<DispenserOption?>(
        context: context,
        builder: (dialogContext) {
          return DispenserOptionsDialog(
            onOptionSelected: (option) {
              // Option is now handled within the dialog
            },
          );
        },
      );
    }

    // We need this mounted check because we're using the parent context to show the final dialog
    // after an async operation (the dispenser options dialog). This ensures the widget is still
    // in the tree before we try to show the next dialog. It's safe because we're only using
    // the context for showing a new dialog, not for any state updates.
    if (!mounted) return;

    final page = switch (type) {
      TransactionType.send => SendPage(
          assetName: widget.assetName,
          addresses: session.allAddresses,
        ),
      TransactionType.lockQuantity => LockQuantityPage(
          assetName: widget.assetName,
          addresses: session.allAddresses,
        ),
      TransactionType.dispenser =>
        selectedDispenserOption == DispenserOption.existingAddress
            ? CreateDispenserPage(
                assetName: widget.assetName,
                addresses: session.allAddresses,
              )
            : CreateDispenserOnNewAddressPage(
                assetName: widget.assetName,
                addresses: session.allAddresses,
              ),
    };
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog.fullscreen(
          child: page,
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
    return BlocBuilder<AssetViewBloc, RemoteDataState<AssetViewData>>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context)
                          .inputDecorationTheme
                          .outlineBorder
                          ?.color ??
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
                  ],
                ),
              ),
            ),
          ),
          error: (_) => const SizedBox.shrink(),
          success: (assetViewData) => Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context)
                          .inputDecorationTheme
                          .outlineBorder
                          ?.color ??
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
                    if (!_isBitcoin && _isAssetOwner(assetViewData.balances))
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
          ),
        );
      },
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
      child: BlocBuilder<AssetViewBloc, RemoteDataState<AssetViewData>>(
        builder: (context, state) {
          return TabBarView(
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
                            child: Column(
                              children: [
                                _buildLoadingActionButtons(context, 6),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : state.maybeWhen(
                      success: (assetViewData) {
                        final balances = assetViewData.balances;
                        return Column(
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
                                  disabledOptions: _isBitcoin
                                      ? [BalanceViewFilter.utxo]
                                      : [],
                                ),
                              ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
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
                                          _showTransactionPage(
                                              type: TransactionType.dispenser);
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
                                    _buildBalanceBreakdown(context, balances),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
              if (!_isBitcoin)
                state.maybeWhen(
                  success: (assetViewData) {
                    final balances = assetViewData.balances;
                    final fairminters = assetViewData.fairminters;
                    final isLocked = balances.assetInfo.locked ||
                        fairminters.any(
                            (fairminter) => fairminter.asset == balances.asset);
                    return SingleChildScrollView(
                      child: Column(
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
                            onTap: isLocked
                                ? null
                                : () {
                                    // Handle Reset Asset
                                  },
                          ),
                          IconItemButton(
                            title: 'Create Fairminter',
                            icon: AppIcons.mintIcon(
                              context: context,
                            ),
                            onTap: isLocked
                                ? null
                                : () {
                                    // Handle Create Fairminter
                                  },
                          ),
                          IconItemButton(
                            title: 'Issue More',
                            icon: AppIcons.plusIcon(
                              context: context,
                            ),
                            onTap: isLocked
                                ? null
                                : () {
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
                            onTap: isLocked
                                ? null
                                : () {
                                    // Handle Update Description
                                  },
                          ),
                          IconItemButton(
                            title: 'Lock Supply',
                            icon: AppIcons.lockIcon(
                              context: context,
                            ),
                            onTap: isLocked
                                ? null
                                : () {
                                    _showTransactionPage(
                                        type: TransactionType.lockQuantity);
                                  },
                          ),
                          IconItemButton(
                            title: 'Lock Description',
                            icon: AppIcons.lockIcon(
                              context: context,
                            ),
                            onTap: isLocked
                                ? null
                                : () {
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
                          _buildBalanceBreakdown(context, balances),
                        ],
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
            ],
          );
        },
      ),
    );
  }

  // Helper method to build the balance breakdown section
  Widget _buildBalanceBreakdown(
      BuildContext context, MultiAddressBalance balance) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title styled like a tab
          TabBar(
            controller: TabController(length: 1, vsync: this),
            indicatorWeight: 2,
            indicatorColor: transparentPurple33,
            labelColor: Theme.of(context).textTheme.bodyMedium?.color,
            indicatorSize: TabBarIndicatorSize.label,
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            tabs: const [
              Tab(
                child: Text(
                  'Balance Breakdown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Balance entries
          ...balance.entries.map((entry) {
            final displayId = entry.utxo ?? entry.address ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MiddleTruncatedText(
                      text: displayId,
                      width: 150,
                      charsToShow: 10,
                    ),
                  ),
                  SelectableText(
                    quantityRemoveTrailingZeros(entry.quantityNormalized),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssetViewBloc, RemoteDataState<AssetViewData>>(
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
          success: (assetViewData) {
            if (_tabController.length !=
                (_isBitcoin || !_isAssetOwner(assetViewData.balances)
                    ? 1
                    : 2)) {
              _tabController.dispose();
              _tabController = TabController(
                length: _isBitcoin || !_isAssetOwner(assetViewData.balances)
                    ? 1
                    : 2,
                vsync: this,
              );
            }
            return Column(
              children: [
                _buildHeader(
                    context: context,
                    isLoading: false,
                    balance: assetViewData.balances),
                _buildTabs(context),
                _buildTabContent(context: context, isLoading: false),
              ],
            );
          },
        );
      },
    );
  }
}
