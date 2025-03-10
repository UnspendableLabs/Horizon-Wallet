import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
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
import 'package:horizon/presentation/session/bloc/session_cubit.dart';

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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 500;

    return context.watch<SessionStateCubit>().state.maybeWhen(
          orElse: () => const CircularProgressIndicator(),
          success: (session) {
            // Collect all addresses with explicit List<String> type
            final List<String> addresses = [
              ...session.addresses.map((e) => e.address),
              ...(session.importedAddresses?.map((e) => e.address) ?? [])
            ];

            return MultiBlocProvider(
              providers: [
                BlocProvider<BalancesBloc>(
                  create: (context) => BalancesBloc.getInstance(
                    addresses: addresses,
                    repository: GetIt.I.get<BalanceRepository>(),
                  )..add(Start(pollingInterval: const Duration(seconds: 30))),
                ),
                BlocProvider<DashboardActivityFeedBloc>(
                  create: (context) => DashboardActivityFeedBloc(
                    logger: GetIt.I.get<Logger>(),
                    addresses: addresses,
                    eventsRepository: GetIt.I.get<EventsRepository>(),
                    addressRepository: GetIt.I.get<AddressRepository>(),
                    bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
                    transactionLocalRepository:
                        GetIt.I.get<TransactionLocalRepository>(),
                    pageSize: 1000,
                  )..add(const Load()),
                ),
              ],
              child: Column(
                children: [
                  // Tab bar (Assets/Activity) with search
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
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TabBar(
                            controller: _tabController,
                            indicatorWeight: 2,
                            indicatorColor: transparentPurple33,
                            labelColor:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            unselectedLabelColor: isDarkTheme
                                ? transparentWhite33
                                : transparentBlack33,
                            isScrollable: true,
                            padding: EdgeInsets.zero,
                            indicatorSize: TabBarIndicatorSize.label,
                            tabAlignment: TabAlignment.start,
                            tabs: const [
                              Tab(
                                child: Text(
                                  'Assets',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Tab(
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
                                    color: isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14,
                                  ),
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    isCollapsed: true,
                                    hintText: 'Search assets...',
                                    hintStyle: TextStyle(
                                      color: isDarkTheme
                                          ? transparentWhite33
                                          : transparentBlack33,
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
                            onTap: _tabController.index == 0
                                ? _toggleSearch
                                : null,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 44,
                              height: 32,
                              decoration: BoxDecoration(
                                color: transparentPurple8,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  _isSearching
                                      ? Icons.close
                                      : Icons.search_outlined,
                                  size: 25,
                                  color: _tabController.index == 0
                                      ? (isDarkTheme
                                          ? Colors.white
                                          : Colors.black)
                                      : (isDarkTheme
                                          ? transparentWhite33
                                          : transparentBlack33),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 35),
                          child: BalancesDisplay(
                            isDarkTheme: isDarkTheme,
                            searchQuery: _searchQuery,
                          ),
                        ),

                        // Activity tab
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DashboardActivityFeedScreen(
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
          },
        );
  }
}
