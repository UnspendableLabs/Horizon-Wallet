import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart';
import 'package:horizon/presentation/screens/dashboard/view/activity_feed.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/common/gradient_avatar.dart';

class PortfolioView extends StatefulWidget {
  const PortfolioView({super.key});

  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      setState(() {
        // If switching to Activity tab, close search
        if (_tabController.index == 1 && _isSearching) {
          _isSearching = false;
          _searchController.clear();
          _searchQuery = '';
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 500;
    final session = context.select<SessionStateCubit, SessionStateSuccess>(
      (cubit) => cubit.state.successOrThrow(),
    );
    final List<String> addresses =
        context.watch<SessionStateCubit>().state.allAddresses;
    final addressesKey = addresses.join(",");

    return MultiBlocProvider(
      providers: [
        BlocProvider<BalancesBloc>(
          // Key based on addresses - if addresses change, a new bloc will be created
          key: ValueKey('balances-bloc-$addressesKey'),
          create: (context) => BalancesBloc(
            httpConfig: session.httpConfig,
            balanceRepository: GetIt.I.get<BalanceRepository>(),
            addresses: addresses,
            cacheProvider: GetIt.I.get<CacheProvider>(),
          )..add(Start(pollingInterval: const Duration(seconds: 30))),
        ),
        BlocProvider<DashboardActivityFeedBloc>(
          create: (context) => DashboardActivityFeedBloc(
            httpConfig: session.httpConfig,
            logger: GetIt.I.get<Logger>(),
            addresses: addresses,
            eventsRepository: GetIt.I.get<EventsRepository>(),
            bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
            transactionLocalRepository:
                GetIt.I.get<TransactionLocalRepository>(),
            pageSize: 1000,
          )..add(const Load()),
        ),
      ],
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 16.0),
                child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 18, 8, 18),
                    ),
                    onPressed: () {
                      context.go("/accounts");
                    },
                    child: Row(
                      children: [
                        GradientAvatar(
                          input: session.currentAccount!.hash,
                          radius: 12,
                        ),
                        const SizedBox(width: 12),
                        Text(session.currentAccount!.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            )),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ],
                    )),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 11.0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: HorizonButton(
                        child: TextButtonContent(
                            value: 'Send',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                        height: 44,
                        borderRadius: 18,
                        variant: ButtonVariant.green,
                        icon: AppIcons.sendIcon(
                          context: context,
                          color: black,
                        ),
                        onPressed: () {
                          context.go("/accounts");
                          // TODO: Implement send functionality
                        },
                      ),
                    ),
                    const SizedBox(width: spacing),
                    Expanded(
                      child: HorizonButton(
                        child: TextButtonContent(
                            value: 'Receive',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                        height: 44,
                        borderRadius: 18,
                        variant: ButtonVariant.black,
                        icon: AppIcons.receiveIcon(
                          context: context,
                        ),
                        onPressed: () {
                          // TODO: Implement receive functionality
                        },
                      ),
                    ),
                    const SizedBox(width: spacing),
                    Expanded(
                      child: HorizonButton(
                        child: TextButtonContent(
                            value: 'Swap',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                        height: 44,
                        borderRadius: 18,
                        variant: ButtonVariant.black,
                        icon: AppIcons.swapIcon(
                          context: context,
                        ),
                        onPressed: () {
                          context.push('/atomic-swap');
                        },
                      ),
                    ),
                    const SizedBox(width: spacing),
                    Expanded(
                      child: HorizonButton(
                        child: TextButtonContent(
                            value: 'Mint',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                        height: 44,
                        borderRadius: 18,
                        variant: ButtonVariant.black,
                        icon: AppIcons.mintIcon(
                          context: context,
                        ),
                        onPressed: () {
                          // TODO: Implement mint functionality
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Tab bar (Assets/Activity) with search
          Container(
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
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TabBar(
                    controller: _tabController,
                    indicatorWeight: 2,
                    dividerHeight: 0,
                    indicatorColor: transparentPurple33,
                    labelColor: Theme.of(context).textTheme.bodyMedium?.color,
                    unselectedLabelColor: Theme.of(context)
                            .textButtonTheme
                            .style
                            ?.foregroundColor
                            ?.resolve({}) ??
                        Colors.grey,
                    isScrollable: true,
                    padding: EdgeInsets.zero,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(
                        height: 62,
                        child: Text(
                          'Assets',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Tab(
                        height: 62,
                        child: Text(
                          'Activity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSearching && _tabController.index == 0)
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: transparentPurple8,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            hintText: 'Search assets...',
                            hintStyle: TextStyle(
                              color: Theme.of(context)
                                      .textButtonTheme
                                      .style
                                      ?.foregroundColor
                                      ?.resolve({}) ??
                                  Colors.grey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _tabController.index == 0 ? _toggleSearch : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      key: const Key('search_button'),
                      width: 44,
                      height: 32,
                      decoration: BoxDecoration(
                        color: transparentPurple8,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: _isSearching
                            ? AppIcons.closeIcon(
                                context: context,
                                color: _tabController.index == 0
                                    ? (Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color)
                                    : (Theme.of(context)
                                            .textButtonTheme
                                            .style
                                            ?.foregroundColor
                                            ?.resolve({}) ??
                                        Colors.grey),
                              )
                            : AppIcons.searchIcon(
                                context: context,
                                color: _tabController.index == 0
                                    ? (Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color)
                                    : (Theme.of(context)
                                            .textButtonTheme
                                            .style
                                            ?.foregroundColor
                                            ?.resolve({}) ??
                                        Colors.grey),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),

          // Tab content (Balances/Activity)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Balances tab
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 35),
                  child: BalancesDisplay(
                    key: const Key('balances_view'),
                    searchQuery: _searchQuery,
                  ),
                ),

                // Activity tab
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DashboardActivityFeedScreen(
                    key: const Key('activity_feed_view'),
                    addresses: addresses,
                    initialItemCount: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
