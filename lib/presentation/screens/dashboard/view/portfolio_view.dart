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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return context.watch<SessionStateCubit>().state.maybeWhen(
          orElse: () => const CircularProgressIndicator(),
          success: (session) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<BalancesBloc>(
                  create: (context) => BalancesBloc(
                    balanceRepository: GetIt.I.get<BalanceRepository>(),
                    addresses: [
                      ...session.addresses.map((e) => e.address),
                      ...(session.importedAddresses?.map((e) => e.address) ??
                          [])
                    ],
                  )..add(Start(pollingInterval: const Duration(seconds: 60))),
                ),
                BlocProvider<DashboardActivityFeedBloc>(
                  create: (context) => DashboardActivityFeedBloc(
                    logger: GetIt.I.get<Logger>(),
                    addresses: [
                      ...session.addresses.map((e) => e.address),
                      ...(session.importedAddresses?.map((e) => e.address) ??
                          [])
                    ],
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
                  // Tabs (Balances/Activity)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Container(
                      height: 44,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDarkTheme
                            ? white.withOpacity(0.05)
                            : black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDarkTheme
                              ? white.withOpacity(0.08)
                              : black.withOpacity(0.08),
                        ),
                        dividerColor: Colors.transparent,
                        labelColor: isDarkTheme ? Colors.white : Colors.black,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        unselectedLabelColor: isDarkTheme
                            ? transparentWhite66
                            : transparentBlack66,
                        tabs: const [
                          Tab(text: 'Balances'),
                          Tab(text: 'Activity'),
                        ],
                      ),
                    ),
                  ),

                  // Tab content (Balances/Activity)
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Balances tab
                        BalancesDisplay(isDarkTheme: isDarkTheme),

                        // Activity tab - use the existing DashboardActivityFeedScreen
                        DashboardActivityFeedScreen(
                          addresses: [
                            ...session.addresses.map((e) => e.address),
                            ...(session.importedAddresses
                                    ?.map((e) => e.address) ??
                                [])
                          ],
                          initialItemCount: 20,
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
