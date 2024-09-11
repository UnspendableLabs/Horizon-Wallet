import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/presentation/screens/compose_issuance/view/compose_issuance_page.dart';
import 'package:horizon/presentation/screens/compose_send/view/compose_send_page.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/view/activity_feed.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_dialog.dart';
import 'package:horizon/presentation/shell/account_form/view/account_form.dart';
import 'package:horizon/presentation/shell/address_form/view/address_form.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/shell/view/shell.dart';
import 'package:horizon/presentation/common/no_data.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:sliver_tools/sliver_tools.dart';



class AddressDropdown extends StatefulWidget {
  final bool isDarkTheme;
  final List<Address> addresses;
  final Address currentAddress;
  final Function(Address) onChange;

  const AddressDropdown({
    Key? key,
    required this.currentAddress,
    required this.isDarkTheme,
    required this.addresses,
    required this.onChange,
  }) : super(key: key);

  @override
  AddressDropdownState createState() => AddressDropdownState();
}

class AddressDropdownState extends State<AddressDropdown> {
  late Address _selectedAddress;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.currentAddress;
  }

  void _copyAddressToClipboard() {
    Clipboard.setData(ClipboardData(text: _selectedAddress.address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSingleAddress = widget.addresses.length == 1;
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 70),
            elevation: 0,
            backgroundColor:
                isDarkTheme ? lightNavyDarkTheme : lightBlueLightTheme,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
          ),

          // style: ElevatedButton.styleFrom(
          //   minimumSize: const Size(double.infinity, 70),
          //   elevation: 0,
          //   backgroundColor:
          //      Colors.red,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(24.0),
          //   ),
          // ),
          onPressed: isSingleAddress
              ? null
              : () {
                  // Show dropdown menu
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Select Address'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: widget.addresses.map((Address address) {
                              return ListTile(
                                title: Text(address.address),
                                onTap: () {
                                  setState(() {
                                    _selectedAddress = address;
                                  });
                                  widget.onChange(address);
                                  Navigator.of(context).pop();
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  );
                },
          child: Padding(
              padding: const EdgeInsets.all(12.0), child: Text("ta fuck")
              // child: Flex(
              //   direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Expanded(
              //       child: Text(
              //         _selectedAddress.address,
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           color: widget.isDarkTheme
              //               ? greyDashboardButtonTextDarkTheme
              //               : greyDashboardButtonTextLightTheme,
              //           overflow: TextOverflow.ellipsis,
              //         ),
              //       ),
              //     ),
              //     IconButton(
              //       icon: Icon(
              //         Icons.copy,
              //         color: widget.isDarkTheme
              //             ? greyDashboardButtonTextDarkTheme
              //             : greyDashboardButtonTextLightTheme,
              //       ),
              //       onPressed: _copyAddressToClipboard,
              //     ),
              //     if (!isSingleAddress)
              //       Icon(
              //         Icons.arrow_drop_down,
              //         color: widget.isDarkTheme
              //             ? greyDashboardButtonTextDarkTheme
              //             : greyDashboardButtonTextLightTheme,
              //       ),
              //   ],
              // ),
              ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context
        .watch<ShellStateCubit>()
        .state; // we should only ever get to this page if shell is success
    return shell.maybeWhen(
        success: (data) => MultiBlocProvider(
              key: Key(
                  "${data.currentAccountUuid}:${data.currentAddress.address}"),
              providers: [
                BlocProvider<BalancesBloc>(
                  create: (context) => BalancesBloc(
                    currentAddress: data.currentAddress,
                  )..add(Start(pollingInterval: const Duration(seconds: 60))),
                ),
                BlocProvider<DashboardActivityFeedBloc>(
                  create: (context) => DashboardActivityFeedBloc(
                    currentAddress: data.currentAddress,
                    eventsRepository: GetIt.I.get<EventsRepository>(),
                    addressRepository: GetIt.I.get<AddressRepository>(),
                    bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
                    transactionLocalRepository:
                        GetIt.I.get<TransactionLocalRepository>(),
                    pageSize: 10,
                  ),
                ),
              ],
              child: _DashboardPage(
                key: Key(
                    "${data.currentAccountUuid}:${data.currentAddress.address}"),
                accountUuid: data.currentAccountUuid,
                currentAddress: data.currentAddress,
              ),
            ),
        orElse: () => const SizedBox.shrink());
  }
}

class _DashboardPage extends StatefulWidget {
  final String accountUuid;
  final Address currentAddress;

  const _DashboardPage(
      {super.key, required this.accountUuid, required this.currentAddress});

  @override
  _DashboardPage_State createState() => _DashboardPage_State();
}

class _DashboardPage_State extends State<_DashboardPage> {
  final accountSettingsRepository = GetIt.I.get<AccountSettingsRepository>();

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = 926.0;

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    Color backgroundColor = isDarkTheme ? darkNavyDarkTheme : whiteLightTheme;
    final backgroundColorInner =
        isDarkTheme ? lightNavyDarkTheme : greyLightTheme;

    final isSmallScreen = screenWidth < 768;

    return Scaffold(
        body: Container(
      // padding: const EdgeInsets.fromLTRB(4, 8, 8, 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: isDarkTheme
            ? RadialGradient(
                center: Alignment.topRight,
                radius: 1.0,
                colors: [
                  blueDarkThemeGradiantColor,
                  backgroundColor,
                ],
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverCrossAxisConstrained(
                      maxCrossAxisExtent: maxWidth,
                      child: TransparentHorizonSliverAppBar(
                        expandedHeight: isSmallScreen ? kToolbarHeight : 150,
                      )),
                  SliverCrossAxisConstrained(
                      maxCrossAxisExtent: maxWidth,
                      child: SliverStack(children: [
                        SliverPositioned.fill(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ])),
                  SliverCrossAxisConstrained(
                    maxCrossAxisExtent: maxWidth,
                    child: SliverStack(
                      children: [
                        SliverPositioned.fill(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                          sliver: MultiSliver(children: [
                            !isSmallScreen
                                ? SliverToBoxAdapter(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: AccountSelectionButton(
                                            isDarkTheme: isDarkTheme,
                                            onPressed: () => showAccountList(
                                                context, isDarkTheme),
                                          ),
                                        ),
                                        // Expanded(
                                        //     child: AddressDropdown(
                                        //   isDarkTheme: isDarkTheme,
                                        //   currentAddress: widget.currentAddress,
                                        //   addresses: [widget.currentAddress],
                                        //   onChange: (address) {
                                        //     setState(() {
                                        //       // widget.currentAddress = address;
                                        //     });
                                        //   },
                                        // ))
                                      ],
                                    ),
                                  )
                                : SliverToBoxAdapter(child: SizedBox.shrink()),
                            isSmallScreen
                                ? SliverToBoxAdapter(
                                    child: AccountSelectionButton(
                                      isDarkTheme: isDarkTheme,
                                      onPressed: () =>
                                          showAccountList(context, isDarkTheme),
                                    ),
                                  )
                                : SliverToBoxAdapter(child: SizedBox.shrink()),
                            // isSmallScreen
                            //     ? SliverToBoxAdapter(
                            //         child: AddressDropdown(
                            //           isDarkTheme: isDarkTheme,
                            //           currentAddress: widget.currentAddress,
                            //           addresses: [widget.currentAddress],
                            //           onChange: (address) {
                            //             setState(() {
                            //               // widget.currentAddress = address;
                            //             });
                            //           },
                            //         ),
                            //       )
                            //     : SliverToBoxAdapter(child: SizedBox.shrink()),
                            SliverToBoxAdapter(
                                child: Builder(builder: (context) {
                              final dashboardActivityFeedBloc =
                                  BlocProvider.of<DashboardActivityFeedBloc>(
                                      context);
                              return AddressActions(
                                isDarkTheme: isDarkTheme,
                                dashboardActivityFeedBloc:
                                    dashboardActivityFeedBloc,
                                accountUuid: widget.accountUuid,
                                currentAddress: widget.currentAddress,
                                screenWidth: screenWidth,
                              );
                            })),
                            SliverStack(children: [
                              SliverPositioned.fill(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                                  decoration: BoxDecoration(
                                    color: backgroundColorInner,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.all(8.0),
                                sliver: BalancesDisplay(
                                    accountUuid: widget.accountUuid,
                                    isDarkTheme: isDarkTheme,
                                    addresses: [widget.currentAddress]),
                              ),
                            ]),
                            SliverStack(children: [
                              SliverPositioned.fill(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  decoration: BoxDecoration(
                                    color: backgroundColorInner,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.all(8.0),
                                sliver: DashboardActivityFeedScreen(
                                  addresses: [widget.currentAddress],
                                ),
                              ),
                            ])
                          ]),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));

    // return Builder(builder: (context) {
    //   final dashboardActivityFeedBloc =
    //       BlocProvider.of<DashboardActivityFeedBloc>(context);
    //
    //   return Padding(
    //     padding: const EdgeInsets.fromLTRB(4, 8, 8, 16),
    //     child: Container(
    //       decoration: BoxDecoration(
    //         color: Colors.red,
    //         borderRadius: BorderRadius.circular(30.0),
    //       ),
    //       child: Column(
    //         children: [
    //           if (screenWidth < 768)
    //             AccountSelectionButton(
    //               isDarkTheme: isDarkTheme,
    //               onPressed: () => showAccountList(context, isDarkTheme),
    //             ),
    //           AddressActions(
    //             isDarkTheme: isDarkTheme,
    //             dashboardActivityFeedBloc: dashboardActivityFeedBloc,
    //             addresses: [widget.currentAddress],
    //             accountUuid: widget.accountUuid,
    //             currentAddress: widget.currentAddress,
    //             screenWidth: screenWidth,
    //           ),
    //           ConstrainedBox(
    //             constraints: const BoxConstraints(maxHeight: 300),
    //             child: BalancesDisplay(
    //               key: Key(widget.currentAddress.address),
    //               isDarkTheme: isDarkTheme,
    //               addresses: [widget.currentAddress],
    //               accountUuid: widget.accountUuid,
    //             ),
    //           ),
    //           Expanded(
    //             child: Padding(
    //               padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
    //               child: ConstrainedBox(
    //                 constraints: const BoxConstraints(maxHeight: 700),
    //                 child: Container(
    //                   decoration: BoxDecoration(
    //                     color:
    //                         isDarkTheme ? lightNavyDarkTheme : greyLightTheme,
    //                     borderRadius: BorderRadius.circular(30.0),
    //                   ),
    //                   child: DashboardActivityFeedScreen(
    //                     addresses: [widget.currentAddress],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // });
  }
}

void showAccountList(BuildContext context, bool isDarkTheme) {
  const double pagePadding = 16.0;

  WoltModalSheet.show<void>(
    context: context,
    pageListBuilder: (modalSheetContext) {
      return [
        context.read<ShellStateCubit>().state.maybeWhen(
              success: (state) => WoltModalSheetPage(
                backgroundColor: isDarkTheme
                    ? dialogBackgroundColorDarkTheme
                    : dialogBackgroundColorLightTheme,
                isTopBarLayerAlwaysVisible: true,
                topBarTitle: Text('Select an account',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme ? mainTextWhite : mainTextBlack)),
                trailingNavBarWidget: IconButton(
                  padding: const EdgeInsets.all(pagePadding),
                  icon: const Icon(Icons.close),
                  onPressed: Navigator.of(modalSheetContext).pop,
                ),
                child: SizedBox(
                  height: 400,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.accounts.length,
                          itemBuilder: (context, index) {
                            final account = state.accounts[index];
                            final isSelected =
                                account.uuid == state.currentAccountUuid;
                            return ListTile(
                              title: Text(account.name),
                              selected: isSelected,
                              onTap: () {
                                context
                                    .read<ShellStateCubit>()
                                    .onAccountChanged(account);
                                Navigator.of(modalSheetContext).pop();
                                GoRouter.of(context).go('/dashboard');
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 25.0),
                            backgroundColor: isDarkTheme
                                ? darkNavyDarkTheme
                                : lightBlueLightTheme,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(modalSheetContext).pop();
                            HorizonDialog.show(
                              context: context,
                              body: const HorizonDialog(
                                title: "Add an account",
                                body: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: AddAccountForm(),
                                ),
                              ),
                            );
                          },
                          child: const Text("Add Account",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              orElse: () => SliverWoltModalSheetPage(),
            ),
      ];
    },
    onModalDismissedWithBarrierTap: () {
      print("dismissed with barrier tap");
    },
    modalTypeBuilder: (context) {
      final size = MediaQuery.of(context).size.width;
      if (size < 768.0) {
        return WoltModalType.bottomSheet;
      } else {
        return WoltModalType.dialog;
      }
    },
  );
}

class AccountSelectionButton extends StatelessWidget {
  final bool isDarkTheme;
  final VoidCallback onPressed;

  const AccountSelectionButton({
    super.key,
    required this.isDarkTheme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 70),
            elevation: 0,
            backgroundColor:
                isDarkTheme ? lightNavyDarkTheme : lightBlueLightTheme,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: isDarkTheme
                      ? greyDashboardButtonTextDarkTheme
                      : greyDashboardButtonTextLightTheme,
                ),
                const SizedBox(width: 16.0),
                Text(
                  context.read<ShellStateCubit>().state.maybeWhen(
                        success: (state) => state.accounts
                            .firstWhere((account) =>
                                account.uuid == state.currentAccountUuid)
                            .name,
                        orElse: () => "Select Account",
                      ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme
                        ? greyDashboardButtonTextDarkTheme
                        : greyDashboardButtonTextLightTheme,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: isDarkTheme
                      ? greyDashboardButtonTextDarkTheme
                      : greyDashboardButtonTextLightTheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddressAction extends StatelessWidget {
  final bool isDarkTheme;
  final HorizonDialog dialog;
  final IconData icon;
  final String text;
  final double? iconSize;

  const AddressAction(
      {super.key,
      required this.isDarkTheme,
      required this.dialog,
      required this.icon,
      required this.text,
      this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: 65,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDarkTheme ? lightNavyDarkTheme : lightBlueLightTheme,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
            onPressed: () {
              HorizonDialog.show(context: context, body: dialog);
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: iconSize ?? 28.0,
                      color: isDarkTheme
                          ? greyDashboardButtonTextDarkTheme
                          : greyDashboardButtonTextLightTheme),
                  const SizedBox(width: 8.0),
                  Text(text,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDarkTheme
                              ? greyDashboardButtonTextDarkTheme
                              : greyDashboardButtonTextLightTheme)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddressActions extends StatelessWidget {
  final bool isDarkTheme;
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String accountUuid;
  final Address currentAddress;
  final double screenWidth;

  const AddressActions(
      {super.key,
      required this.isDarkTheme,
      required this.dashboardActivityFeedBloc,
      required this.accountUuid,
      required this.currentAddress,
      required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AddressAction(
              isDarkTheme: isDarkTheme,
              dialog: HorizonDialog(
                title: "Compose Send",
                body: ComposeSendPage(
                  dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                  screenWidth: screenWidth,
                ),
                includeBackButton: false,
                includeCloseButton: true,
              ),
              icon: Icons.send,
              text: "SEND",
              iconSize: 22.0,
            ),
            AddressAction(
              isDarkTheme: isDarkTheme,
              dialog: HorizonDialog(
                title: "Compose Issuance",
                body: ComposeIssuancePage(
                  dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                ),
                includeBackButton: false,
                includeCloseButton: true,
              ),
              icon: Icons.add,
              text: "ISSUE",
            ),
            AddressAction(
                isDarkTheme: isDarkTheme,
                dialog: HorizonDialog(
                  title: "Receive",
                  body: QRCodeDialog(
                    currentAddress: currentAddress,
                  ),
                  includeBackButton: false,
                  includeCloseButton: true,
                ),
                icon: Icons.qr_code,
                text: "RECEIVE",
                iconSize: 24.0)
          ],
        ),
      ),
    ]);
  }
}

class BalancesDisplay extends StatefulWidget {
  final bool isDarkTheme;
  final List<Address> addresses;
  final String accountUuid;

  const BalancesDisplay(
      {super.key,
      required this.isDarkTheme,
      required this.addresses,
      required this.accountUuid});

  @override
  _BalancesDisplayState createState() => _BalancesDisplayState();
}

class _BalancesDisplayState extends State<BalancesDisplay> {
  late BalancesBloc _balancesBloc;

  @override
  void initState() {
    super.initState();
    _balancesBloc = context.read<BalancesBloc>();

    _balancesBloc.add(Start(pollingInterval: const Duration(seconds: 60)));
  }

  @override
  void dispose() {
    _balancesBloc.add(Stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BalancesSliver(
      isDarkTheme: widget.isDarkTheme,
      addresses: widget.addresses,
    );
  }
}

class Balances extends StatefulWidget {
  final bool isDarkTheme;
  final List<Address> addresses;
  final String accountUuid;

  const Balances(
      {super.key,
      required this.isDarkTheme,
      required this.addresses,
      required this.accountUuid});

  @override
  State<Balances> createState() => _BalancesState();
}

class _BalancesState extends State<Balances> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalancesBloc, BalancesState>(builder: (context, state) {
      return state.when(
        initial: () => const Text(""),
        loading: () => const CircularProgressIndicator(),
        complete: (result) => _resultToBalanceList(result, widget.isDarkTheme),
        reloading: (result) => _resultToBalanceList(result, widget.isDarkTheme),
      );
    });
  }

  Widget _resultToBalanceList(Result result, bool isDarkTheme) {
    Color backgroundColor = isDarkTheme ? lightNavyDarkTheme : greyLightTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 275,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: _balanceList(result, widget.isDarkTheme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _balanceList(Result result, bool isDarkMode) {
    return result.when(
      ok: (balances, aggregated) {
        if (balances.isEmpty) {
          return [
            const NoData(
              title: 'No Balances',
            )
          ];
        }

        // Use MapEntry<String, Balance>? to allow null values
        final MapEntry<String, Balance>? btcEntry =
            aggregated.entries.where((e) => e.key == 'BTC').firstOrNull;

        final MapEntry<String, Balance>? xcpEntry =
            aggregated.entries.where((e) => e.key == 'XCP').firstOrNull;

        final otherEntries = aggregated.entries
            .where((e) => e.key != 'BTC' && e.key != 'XCP')
            .toList();

        // Combine entries in the desired order
        final orderedEntries = [
          if (btcEntry != null) btcEntry,
          if (xcpEntry != null) xcpEntry,
          ...otherEntries,
        ];

        final balanceWidgets = orderedEntries.asMap().entries.map((mapEntry) {
          final index = mapEntry.key;
          final entry = mapEntry.value;
          final isLastEntry = index == orderedEntries.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SelectableText.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${entry.key} ',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? greyDashboardTextDarkTheme
                                    : greyDashboardTextLightTheme),
                          ),
                        ],
                      ),
                    ),
                    SelectableText(
                      entry.value.quantityNormalized,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (!isLastEntry)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Divider(),
                ),
            ],
          );
        }).toList();
        return balanceWidgets;
      },
      error: (error) => [SelectableText('Error: $error')],
    );
  }
}

class QRCodeDialog extends StatelessWidget {
  final Address currentAddress;

  const QRCodeDialog({super.key, required this.currentAddress});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8.0),
        QrImageView(
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: isDarkTheme ? mainTextWhite : royalBlueLightTheme,
          ),
          eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: isDarkTheme ? mainTextWhite : royalBlueLightTheme),
          data: currentAddress.address,
          version: QrVersions.auto,
          size: 230.0,
        ),
        const SizedBox(height: 16.0),
        const Divider(
          thickness: 1.0,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                  color: isDarkTheme ? darkNavyDarkTheme : noBackgroundColor,
                  borderRadius: BorderRadius.circular(10.0),
                  border: isDarkTheme
                      ? Border.all(color: noBackgroundColor)
                      : Border.all(color: greyLightThemeUnderlineColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SelectableText(
                          currentAddress.address,
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: screenWidth < 768.0
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: currentAddress.address));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Address copied to clipboard')),
                                );
                              },
                              child: const Icon(Icons.copy),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: currentAddress.address));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Address copied to clipboard')),
                                );
                              },
                              child: SizedBox(
                                height: 32.0,
                                child: Row(
                                  children: [
                                    Icon(Icons.copy,
                                        size: 14.0,
                                        color: isDarkTheme
                                            ? darkThemeInputLabelColor
                                            : lightThemeInputLabelColor),
                                    const SizedBox(width: 4.0, height: 16.0),
                                    Text("COPY",
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: isDarkTheme
                                                ? darkThemeInputLabelColor
                                                : lightThemeInputLabelColor)),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Builder(builder: (context) {
          // TODO: this is a bit smelly
          final accountUuid = context.read<ShellStateCubit>().state.maybeWhen(
                success: (state) => state.currentAccountUuid,
                orElse: () => throw Exception("invariant: no account"),
              );

          // look up account
          Account account = context.read<ShellStateCubit>().state.maybeWhen(
                success: (state) => state.accounts
                    .firstWhere((account) => account.uuid == accountUuid),
                orElse: () => throw Exception("invariant: no account"),
              );

          // don't support address creation for horizon accounts
          return switch (account.importFormat) {
            ImportFormat.horizon => const SizedBox.shrink(),
            _ => TextButton(
                child: const Text("Add a new address"),
                onPressed: () {
                  // 1) close receive modal
                  Navigator.of(context).pop();

                  // 2) open add address modal
                  HorizonDialog.show(
                      context: context,
                      body: HorizonDialog(
                        title: "Add an address",
                        body: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: AddAddressForm(
                            accountUuid: accountUuid,
                          ),
                        ),
                      ));
                })
          };
        })
      ],
    );
  }
}

class BalancesSliver extends StatefulWidget {
  final bool isDarkTheme;
  final List<Address> addresses;
  final int initialItemCount;

  const BalancesSliver(
      {Key? key,
      required this.isDarkTheme,
      required this.addresses,
      this.initialItemCount = 3})
      : super(key: key);

  @override
  _BalancesSliverState createState() => _BalancesSliverState();
}

class _BalancesSliverState extends State<BalancesSliver> {
  bool _viewAll = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalancesBloc, BalancesState>(
      builder: (context, state) {
        return SliverList(
          delegate: SliverChildListDelegate(_buildContent(state)),
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
      ok: (balances, aggregated) {
        if (balances.isEmpty) {
          return [
            const NoData(
              title: 'No Balances',
            )
          ];
        }

        final entries = aggregated.entries.toList();
        final displayedEntries =
            _viewAll ? entries : entries.take(widget.initialItemCount).toList();

        List<Widget> widgets = displayedEntries.expand((entry) {
          final isLastEntry = entry.key == aggregated.entries.last.key;
          return [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SelectableText.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${entry.key} ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: widget.isDarkTheme
                                ? greyDashboardTextDarkTheme
                                : greyDashboardTextLightTheme,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SelectableText(
                    entry.value.quantityNormalized,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            if (!isLastEntry) const Divider(height: 1),
          ];
        }).toList();

        if (!_viewAll && entries.length > widget.initialItemCount) {
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
          child: Center(child: Text('Error: $error')),
        )
      ],
    );
  }
}
