import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_event.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';
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
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

String balancesStateToString(BalancesState state) {
  return state.when(
    initial: () => 'Initial',
    loading: () => 'Loading',
    complete: (result) => 'Complete: ${resultToString(result)}',
    reloading: (result) => 'Reloading: ${resultToString(result)}',
  );
}

String resultToString(Result result) {
  return result.when(
    ok: (balances, aggregated) {
      var assetSummaries = aggregated.entries
          .map((entry) =>
              '${entry.key}: ${entry.value.quantity.toStringAsFixed(2)}')
          .join(', ');

      return 'OK (${balances.length} balances, $assetSummaries)';
    },
    error: (error) => 'Error: $error',
  );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>().state;

    // we should only ever get to this page if shell is success

    return shell.when(
        initial: () => const Text("initial"),
        onboarding: (_) => const Text("onboarding"),
        loading: () => const CircularProgressIndicator(),
        error: (error) => Text("Error: $error"),
        success: (data) => _DashboardPage(
            key: Key(data.currentAccountUuid),
            accountUuid: data.currentAccountUuid));
  }
}

class _DashboardPage extends StatefulWidget {
  final String accountUuid;

  const _DashboardPage({super.key, required this.accountUuid});

  @override
  _DashboardPage_State createState() => _DashboardPage_State();
}

class _DashboardPage_State extends State<_DashboardPage> {
  final accountSettingsRepository = GetIt.I.get<AccountSettingsRepository>();

  @override
  void initState() {
    super.initState();

    context.read<AddressesBloc>().add(GetAll(
          accountUuid: widget.accountUuid,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define background colors based on theme
    Color backgroundColor =
        isDarkTheme ? const Color.fromRGBO(25, 25, 39, 1) : Colors.white;

    return BlocBuilder<AddressesBloc, AddressesState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Text("initial"),
          loading: () => const CircularProgressIndicator(),
          error: (error) => Text("Error: $error"),
          success: (addresses) => BlocProvider(
              key: widget.key,
              create: (context) => DashboardActivityFeedBloc(
                    accountUuid: widget.accountUuid,
                    eventsRepository: GetIt.I.get<EventsRepository>(),
                    addressRepository: GetIt.I.get<AddressRepository>(),
                    bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
                    transactionLocalRepository:
                        GetIt.I.get<TransactionLocalRepository>(),
                    pageSize: 10,
                  ),
              child: Builder(builder: (context) {
                final dashboardActivityFeedBloc =
                    BlocProvider.of<DashboardActivityFeedBloc>(context);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 8, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (screenWidth < 768)
                            AccountSelectionButton(
                              isDarkTheme: isDarkTheme,
                              onPressed: () =>
                                  showAccountList(context, isDarkTheme),
                            ),
                          AddressActions(
                            isDarkTheme: isDarkTheme,
                            dashboardActivityFeedBloc:
                                dashboardActivityFeedBloc,
                            addresses: addresses,
                            accountUuid: widget.accountUuid,
                          ),
                          BlocProvider(
                            create: (context) =>
                                BalancesBloc(accountUuid: widget.accountUuid),
                            child: BalancesDisplay(
                              isDarkTheme: isDarkTheme,
                              addresses: addresses,
                              accountUuid: widget.accountUuid,
                            ),
                          ),
                          DashboardActivityFeedScreen(
                              key: Key(widget.accountUuid),
                              addresses: addresses),
                        ],
                      ),
                    ),
                  ),
                );
              })),
        );
      },
    );
  }
}

void showAccountList(BuildContext context, bool isDarkTheme) {
  const double pagePadding = 16.0;

  final textTheme = Theme.of(context).textTheme;

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
                            WoltModalSheet.show<void>(
                              context: context,
                              pageListBuilder: (modalSheetContext) {
                                final textTheme = Theme.of(context).textTheme;
                                return [
                                  addAccountModal(
                                      modalSheetContext, textTheme, isDarkTheme)
                                ];
                              },
                              onModalDismissedWithBarrierTap: () {
                                print("dismissed with barrier tap");
                              },
                              modalTypeBuilder: (context) {
                                return WoltModalType.bottomSheet;
                              },
                            );
                          },
                          child: const Text("Add Account",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
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
                const Icon(
                  Icons.account_balance_wallet_rounded,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_drop_down,
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
  final HorizonDialog dialog;
  final IconData icon;
  final String text;

  const AddressAction(
      {super.key,
      required this.dialog,
      required this.icon,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: 65,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return dialog;
                  });
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20.0, color: mainTextGrey),
                  const SizedBox(width: 8.0),
                  Text(text,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: mainTextGrey)),
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
  final List<Address> addresses;
  final String accountUuid;

  const AddressActions({
    super.key,
    required this.isDarkTheme,
    required this.dashboardActivityFeedBloc,
    required this.addresses,
    required this.accountUuid,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AddressAction(
              dialog: HorizonDialog(
                title: "Compose Issuance",
                body: ComposeIssuancePage(
                  isDarkMode: isDarkTheme,
                  dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                ),
                includeBackButton: false,
                includeCloseButton: true,
              ),
              icon: Icons.add,
              text: "ISSUE",
            ),
            AddressAction(
              dialog: HorizonDialog(
                title: "Compose Send",
                body: ComposeSendPage(
                  isDarkMode: isDarkTheme,
                  dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                ),
                includeBackButton: false,
                includeCloseButton: true,
              ),
              icon: Icons.send,
              text: "SEND",
            ),
            AddressAction(
                dialog: HorizonDialog(
                  title: "Receive",
                  body: QRCodeDialog(
                    isDarkTheme: isDarkTheme,
                    key: Key(accountUuid),
                    addresses: addresses,
                  ),
                  includeBackButton: false,
                  includeCloseButton: true,
                ),
                icon: Icons.qr_code,
                text: "RECEIVE")
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
    return Balances(
        key: Key(widget.accountUuid),
        isDarkTheme: widget.isDarkTheme,
        addresses: widget.addresses,
        accountUuid: widget.accountUuid);
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
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalancesBloc, BalancesState>(builder: (context, state) {
      double height = MediaQuery.of(context).size.height * 0.75;
      return state.when(
        initial: () => const Text(""),
        loading: () => const CircularProgressIndicator(),
        complete: (result) => _resultToBalanceList(
            result, height, widget.isDarkTheme, widget.addresses),
        reloading: (result) => _resultToBalanceList(
            result, height, widget.isDarkTheme, widget.addresses),
      );
    });
  }

  Widget _resultToBalanceList(
      Result result, double height, bool isDarkTheme, List<Address> addresses) {
    Color backgroundColor = isDarkTheme
        ? const Color.fromRGBO(35, 35, 58, 1)
        : const Color.fromRGBO(246, 247, 250, 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 16.0),
      child: Container(
        // height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Column(
          children: [
            const Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Account Balances',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                child:
                    Container(child: _balanceList(result, widget.isDarkTheme))),
            if (_isExpanded)
              Builder(builder: (context) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                        child: const Text("Collapse"),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _balanceList(Result result, bool isDarkMode) {
    return result.when(
      ok: (balances, aggregated) {
        if (balances.isEmpty) {
          return const Center(child: Text("No balance"));
        }

        final balanceWidgets = aggregated.entries.map((entry) {
          final isLastEntry = entry.key == aggregated.entries.last.key;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${entry.key} ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? greyDashboardTextDarkTheme
                                    : greyDashboardTextLightTheme),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      entry.value.quantityNormalized,
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

        if (balanceWidgets.length > 6 && !_isExpanded) {
          return Column(
            children: [
              ListView(
                shrinkWrap: true,
                children: balanceWidgets.take(6).toList(),
              ),
              FractionallySizedBox(
                widthFactor: 0.5,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = true;
                    });
                  },
                  child: const Text("View All"),
                ),
              ),
            ],
          );
        } else {
          return ListView(
            shrinkWrap: true,
            children: balanceWidgets,
          );
        }
      },
      error: (error) => Text('Error: $error'),
    );
  }
}

class QRCodeDialog extends StatefulWidget {
  final bool isDarkTheme;
  final List<Address> addresses;

  const QRCodeDialog(
      {super.key, required this.isDarkTheme, required this.addresses});

  @override
  _QRCodeDialogState createState() => _QRCodeDialogState();
}

class _QRCodeDialogState extends State<QRCodeDialog> {
  late String _selectedAddress;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.addresses.first.address;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8.0),
        QrImageView(
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: widget.isDarkTheme ? mainTextWhite : royalBlueLightTheme,
          ),
          eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: widget.isDarkTheme ? mainTextWhite : royalBlueLightTheme),
          data: _selectedAddress,
          version: QrVersions.auto,
          size: 230.0,
        ),
        const SizedBox(height: 16.0),
        Divider(
          color: widget.isDarkTheme
              ? greyDarkThemeUnderlineColor
              : greyLightThemeUnderlineColor,
          thickness: 1.0,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                  color: widget.isDarkTheme
                      ? darkNavyDarkTheme
                      : noBackgroundColor,
                  borderRadius: BorderRadius.circular(10.0),
                  border: widget.isDarkTheme
                      ? Border.all(color: noBackgroundColor)
                      : Border.all(color: greyLightThemeUnderlineColor),
                ),
                child: Row(
                  children: [
                    if (widget.addresses.length > 1)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: widget.isDarkTheme
                                  ? darkNavyDarkTheme
                                  : whiteLightTheme,
                              style: TextStyle(
                                  color: widget.isDarkTheme
                                      ? darkThemeInputLabelColor
                                      : lightThemeInputLabelColor),
                              isExpanded: true,
                              value: _selectedAddress,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedAddress = newValue!;
                                });
                              },
                              items: widget.addresses
                                  .map<DropdownMenuItem<String>>(
                                      (Address address) {
                                return DropdownMenuItem<String>(
                                  value: address.address,
                                  child: Text(
                                    address.address,
                                    style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 16.0),
                                  ),
                                );
                              }).toList(),
                              icon: const Icon(Icons.keyboard_arrow_down),
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SelectableText(
                            _selectedAddress,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
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
                                Clipboard.setData(
                                    ClipboardData(text: _selectedAddress));
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
                                Clipboard.setData(
                                    ClipboardData(text: _selectedAddress));
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
                                        color: widget.isDarkTheme
                                            ? darkThemeInputLabelColor
                                            : lightThemeInputLabelColor),
                                    const SizedBox(width: 4.0, height: 16.0),
                                    Text("COPY",
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: widget.isDarkTheme
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
      ],
    );
  }
}
