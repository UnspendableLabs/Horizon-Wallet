import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/presentation/common/sats_to_usd_display.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/common/gradient_avatar.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PortfolioView extends StatefulWidget {
  final BitcoinRepository _bitcoinRepository;

  PortfolioView({
    super.key,
    BitcoinRepository? bitcoinRepository,
  }) : _bitcoinRepository =
            bitcoinRepository ?? GetIt.I.get<BitcoinRepository>();

  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView>
    with TickerProviderStateMixin {
  // late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final bool _isSearching = false;
  String _searchQuery = '';
  BalanceFilter _currentFilter = BalanceFilter.all;

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: 2, vsync: this);

    // _tabController.addListener(() {
    //   setState(() {
    //     // If switching to Activity tab, close search
    //     if (_tabController.index == 1 && _isSearching) {
    //       _isSearching = false;
    //       _searchController.clear();
    //       _searchQuery = '';
    //     }
    //   });
    // });
  }

  @override
  void dispose() {
    // _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 500;

    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    // final session = context.select<SessionStateCubit, SessionStateSuccess>(
    //   (cubit) => cubit.state.successOrThrow(),
    // );

    final List<String> addresses =
        session.addressIndexSet.list.map((a) => a.address).toList();

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
                          context.push('/send');
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
                        onPressed: () async {
                          await WoltModalSheet.show(
                              context: context,
                              modalTypeBuilder: (_) =>
                                  WoltModalType.bottomSheet(),
                              pageListBuilder: (bottomSheetContext) => [
                                    WoltModalSheetPage(
                                        trailingNavBarWidget: IconButton(
                                          icon: AppIcons.closeIcon(
                                            context: context,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(bottomSheetContext);
                                          },
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: session
                                              .addressIndexSet.list.length,
                                          itemBuilder: (context, index) {
                                            final addy = session
                                                .addressIndexSet.list[index];

                                            return ListTile(
                                                onTap: () {
                                                  WoltModalSheet.of(
                                                          bottomSheetContext)
                                                      .pushPage(
                                                    WoltModalSheetPage(
                                                      trailingNavBarWidget:
                                                          IconButton(
                                                        icon:
                                                            AppIcons.closeIcon(
                                                          context: context,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.color,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              bottomSheetContext);
                                                        },
                                                      ),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Center(
                                                              child:
                                                                  QrImageView(
                                                                      eyeStyle:
                                                                          QrEyeStyle(
                                                                        eyeShape:
                                                                            QrEyeShape.circle,
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium!
                                                                            .color,
                                                                      ),
                                                                      dataModuleStyle:
                                                                          QrDataModuleStyle(
                                                                        dataModuleShape:
                                                                            QrDataModuleShape.square,
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium!
                                                                            .color,
                                                                      ),
                                                                      data: addy
                                                                          .address,
                                                                      size:
                                                                          256),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      16,
                                                                      32,
                                                                      0,
                                                                      0),
                                                              child: Text(
                                                                addy.type
                                                                    .displayName,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .labelSmall,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      16,
                                                                      0,
                                                                      8,
                                                                      8),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        AutoSizeText(
                                                                      addy.address,
                                                                      maxLines:
                                                                          1,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyMedium,
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    visualDensity:
                                                                        VisualDensity
                                                                            .compact,
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .copy,
                                                                        size:
                                                                            18),
                                                                    tooltip:
                                                                        'Copy address',
                                                                    onPressed:
                                                                        () {
                                                                      Clipboard.setData(
                                                                          ClipboardData(
                                                                              text: addy.address));
                                                                      ScaffoldMessenger.of(
                                                                              bottomSheetContext)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                            content:
                                                                                Text("${addy.address} copied to clipboard")),
                                                                      );
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 32),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                leading: AppIcons.btcIcon(
                                                    width: 32, height: 32),
                                                title: Text(
                                                  addy.type.displayName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall, // smaller than default
                                                ),
                                                subtitle: Text(
                                                    addy.shortAddress(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium),
                                                trailing:
                                                    RemoteDataTaskEitherBuilder(
                                                        task: widget
                                                            ._bitcoinRepository
                                                            .getAddressInfoT(
                                                          address: addy.address,
                                                          httpConfig: session
                                                              .httpConfig,
                                                          onError: (err) =>
                                                              "Failed to fetch address info: $err",
                                                        ),
                                                        builder: (context,
                                                            state, refresh) {
                                                          return state.fold3(
                                                            onNone: () =>
                                                                const SizedBox
                                                                    .shrink(),
                                                            onFailure: (_) =>
                                                                const SizedBox
                                                                    .shrink(),
                                                            onReplete: (info) {
                                                              final total = info
                                                                      .chainStats
                                                                      .fundedTxoSum -
                                                                  info.chainStats
                                                                      .spentTxoSum;
                                                              return SatsToUsdDisplay(
                                                                key: ValueKey(
                                                                    "sats_display_${addy.address}"),
                                                                sats:
                                                                    BigInt.from(
                                                                        total),
                                                              );
                                                            },
                                                          );
                                                        }));
                                          },
                                        ))
                                  ]);

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
                  ],
                );
              },
            ),
          ),
          // Tab bar (Assets/Activity) with search
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context)
                          .inputDecorationTheme
                          .outlineBorder
                          ?.color ??
                      transparentBlack8,
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: HorizonTextField(
                      hintText: "Search assets",
                      height: 44,
                      borderRadius: 18,
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  HorizonIconSelect<BalanceFilter>(
                    options: BalanceFilter.values,
                    value: _currentFilter,
                    labelFor: (f) => f.label,
                    onChanged: (f) => setState(() {
                      _currentFilter = f;
                    }),
                    tooltip: 'Filter transactions',
                    icon: Icons.filter_list,
                    modalTitle: 'Filter by type',
                  ),
                ],
              ),
            ),
          ),

          // Tab content (Balances/Activity)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: BalancesDisplay(
                currentFilter: _currentFilter,
                key: const Key('balances_view'),
                searchQuery: _searchQuery,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
