import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/presentation/common/footer.dart';
import 'package:horizon/presentation/common/no_data.dart';
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
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:flutter/gestures.dart';
import "package:horizon/presentation/shell/account_form/bloc/account_form_bloc.dart";
import "package:horizon/presentation/shell/account_form/bloc/account_form_state.dart";
import "package:horizon/presentation/shell/account_form/bloc/account_form_event.dart";

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
                              body: Builder(builder: (context) {
                                final bloc = context.watch<AccountFormBloc>();

                                final cb = switch (bloc.state) {
                                  AccountFormStep2() => () {
                                      bloc.add(Reset());
                                    },
                                  _ => () {
                                      Navigator.of(context).pop();
                                    },
                                };

                                return HorizonDialog(
                                  onBackButtonPressed: cb,
                                  title: "Add an account",
                                  body: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: AddAccountForm(),
                                  ),
                                );
                              }),
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

class BalancesSliver extends StatefulWidget {
  final bool isDarkTheme;
  final List<Address> addresses;
  final int initialItemCount;

  const BalancesSliver(
      {super.key,
      required this.isDarkTheme,
      required this.addresses,
      this.initialItemCount = 3});

  @override
  _BalancesSliverState createState() => _BalancesSliverState();
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
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis, fontSize: 16),
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
                  HorizonDialog.show(
                    context: context,
                    body: HorizonDialog(
                      title: "Add a new address\nto ${account.name}",
                      titleAlign: Alignment.center,
                      body: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AddAddressForm(
                          accountUuid: accountUuid,
                        ),
                      ),
                      onBackButtonPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                })
          };
        })
      ],
    );
  }
}

class _BalancesDisplayState extends State<BalancesDisplay> {
  late BalancesBloc _balancesBloc;

  @override
  Widget build(BuildContext context) {
    return BalancesSliver(
      isDarkTheme: widget.isDarkTheme,
      addresses: widget.addresses,
    );
  }

  @override
  void dispose() {
    _balancesBloc.add(Stop());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _balancesBloc = context.read<BalancesBloc>();

    _balancesBloc.add(Start(pollingInterval: const Duration(seconds: 60)));
  }
}

class _BalancesSliverState extends State<BalancesSliver> {
  bool _viewAll = false;
  final Config _config = GetIt.I<Config>();

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

        final displayedEntries = _viewAll
            ? orderedEntries
            : orderedEntries.take(widget.initialItemCount).toList();

        List<Widget> widgets = displayedEntries.expand((entry) {
          final isLastEntry = entry == orderedEntries.last;

          final isClickable = entry.key != 'BTC';

          final Color textColor = isClickable
              ? (widget.isDarkTheme ? Colors.blue[300]! : Colors.blue[700]!)
              : (widget.isDarkTheme
                  ? greyDashboardTextDarkTheme
                  : greyDashboardTextLightTheme);

          return [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SelectableText.rich(
                    TextSpan(
                      text: '${entry.key} ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      recognizer: isClickable
                          ? (TapGestureRecognizer()
                            ..onTap = () => _launchAssetUrl(entry.key))
                          : null,
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

        if (!_viewAll && orderedEntries.length > widget.initialItemCount) {
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

  Future<void> _launchAssetUrl(String asset) async {
    final url = "${_config.horizonExplorerBase}/assets/$asset";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
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
  Widget build(BuildContext context) {
    const maxWidth = 926.0;

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    Color backgroundColor = isDarkTheme ? darkNavyDarkTheme : greyLightTheme;
    final backgroundColorInner =
        isDarkTheme ? lightNavyDarkTheme : greyLightTheme;

    final backgroundColorWrapper =
        isDarkTheme ? darkNavyDarkTheme : Colors.white;

    final isSmallScreen = screenWidth < 768;

    final account = context.read<ShellStateCubit>().state.maybeWhen(
          success: (state) => state.accounts
              .firstWhere((account) => account.uuid == widget.accountUuid),
          orElse: () => null,
        );

    if (!isSmallScreen) {
      return Scaffold(
          bottomNavigationBar: const Footer(),
          body: Container(
            // padding: const EdgeInsets.fromLTRB(4, 8, 8, 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              gradient: isDarkTheme
                  ? RadialGradient(
                      center: Alignment.topRight,
                      radius: 2.0,
                      colors: [
                        blueDarkThemeGradiantColor,
                        backgroundColor,
                      ],
                    )
                  : null,
            ),
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: max(0, ((height / 2 - 560)))),
                  ),
                  const SliverCrossAxisConstrained(
                      maxCrossAxisExtent: maxWidth,
                      child: TransparentHorizonSliverAppBar(
                        expandedHeight: kToolbarHeight,
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
                        SliverPadding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                            sliver: SliverToBoxAdapter(
                                child: Row(children: [
                              Expanded(
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: backgroundColorWrapper,
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      child: const AccountSidebar())),
                              const SizedBox(width: 8),
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: backgroundColorWrapper,
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Column(
                                      children: [
                                        Builder(builder: (context) {
                                          final dashboardActivityFeedBloc =
                                              BlocProvider.of<
                                                      DashboardActivityFeedBloc>(
                                                  context);
                                          return AddressActions(
                                            isDarkTheme: isDarkTheme,
                                            dashboardActivityFeedBloc:
                                                dashboardActivityFeedBloc,
                                            accountUuid: widget.accountUuid,
                                            currentAddress:
                                                widget.currentAddress,
                                            screenWidth: screenWidth,
                                          );
                                        }),
                                        SizedBox(
                                          height: 248,
                                          child: Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                8, 4, 8, 8),
                                            decoration: BoxDecoration(
                                              color: backgroundColorInner,
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                            child: CustomScrollView(
                                              slivers: [
                                                SliverPadding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  sliver: BalancesDisplay(
                                                      accountUuid:
                                                          widget.accountUuid,
                                                      isDarkTheme: isDarkTheme,
                                                      addresses: [
                                                        widget.currentAddress
                                                      ]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 352,
                                          child: Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                8, 4, 8, 8),
                                            decoration: BoxDecoration(
                                              color: backgroundColorInner,
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                            child: CustomScrollView(
                                              slivers: [
                                                SliverPadding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  sliver:
                                                      DashboardActivityFeedScreen(
                                                    key: Key(widget
                                                        .currentAddress
                                                        .address),
                                                    addresses: [
                                                      widget.currentAddress
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ])))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ));
    }

    return Scaffold(
        bottomNavigationBar: const Footer(),
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
                            expandedHeight:
                                isSmallScreen ? kToolbarHeight : 150,
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
                                  color: backgroundColorWrapper,
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
                                                onPressed: () =>
                                                    showAccountList(
                                                        context, isDarkTheme),
                                              ),
                                            ),
                                            Builder(builder: (context) {
                                              return context
                                                  .read<ShellStateCubit>()
                                                  .state
                                                  .maybeWhen(
                                                      success: (state) => state
                                                                  .addresses
                                                                  .length >
                                                              1
                                                          ? Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        0.0,
                                                                        8.0,
                                                                        8.0,
                                                                        0.0),
                                                                child:
                                                                    AddressSelectionButton(
                                                                  isDarkTheme:
                                                                      isDarkTheme,
                                                                  onPressed: () =>
                                                                      showAddressList(
                                                                          context,
                                                                          isDarkTheme,
                                                                          account),
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox
                                                              .shrink(),
                                                      orElse: () =>
                                                          const SizedBox
                                                              .shrink());
                                            }),
                                          ],
                                        ),
                                      )
                                    : const SliverToBoxAdapter(
                                        child: SizedBox.shrink()),
                                isSmallScreen
                                    ? SliverToBoxAdapter(
                                        child: AccountSelectionButton(
                                          isDarkTheme: isDarkTheme,
                                          onPressed: () => showAccountList(
                                              context, isDarkTheme),
                                        ),
                                      )
                                    : const SliverToBoxAdapter(
                                        child: SizedBox.shrink()),
                                isSmallScreen
                                    ? Builder(builder: (context) {
                                        return context
                                            .read<ShellStateCubit>()
                                            .state
                                            .maybeWhen(
                                                success: (state) => state
                                                            .addresses.length >
                                                        1
                                                    ? SliverToBoxAdapter(
                                                        child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(8.0,
                                                                8.0, 8.0, 0.0),
                                                        child:
                                                            AddressSelectionButton(
                                                          isDarkTheme:
                                                              isDarkTheme,
                                                          onPressed: () =>
                                                              showAddressList(
                                                                  context,
                                                                  isDarkTheme,
                                                                  account),
                                                        ),
                                                      ))
                                                    : const SliverToBoxAdapter(
                                                        child:
                                                            SizedBox.shrink()),
                                                orElse: () =>
                                                    const SliverToBoxAdapter(
                                                        child:
                                                            SizedBox.shrink()));
                                      })
                                    : const SliverToBoxAdapter(
                                        child: SizedBox.shrink()),
                                SliverToBoxAdapter(
                                    child: Builder(builder: (context) {
                                  final dashboardActivityFeedBloc = BlocProvider
                                      .of<DashboardActivityFeedBloc>(context);
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
                                      margin:
                                          const EdgeInsets.fromLTRB(8, 4, 8, 0),
                                      decoration: BoxDecoration(
                                        color: backgroundColorInner,
                                        borderRadius:
                                            BorderRadius.circular(30.0),
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
                                      margin:
                                          const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                      decoration: BoxDecoration(
                                        color: backgroundColorInner,
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                    ),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.all(8.0),
                                    sliver: DashboardActivityFeedScreen(
                                      key: Key(widget.currentAddress.address),
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
  }

  @override
  void initState() {
    super.initState();
  }
}
