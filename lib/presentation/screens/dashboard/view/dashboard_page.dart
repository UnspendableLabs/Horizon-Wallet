import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/fn.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/action.dart' as URLAction;
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/footer.dart';
import 'package:horizon/presentation/screens/close_dispenser/view/close_dispenser_page.dart';
import 'package:horizon/presentation/screens/compose_dispense/view/compose_dispense_modal.dart';
import 'package:horizon/presentation/screens/compose_dispenser/view/compose_dispenser_page.dart';
import 'package:horizon/presentation/screens/compose_fairmint/view/compose_fairmint_page.dart';
import 'package:horizon/presentation/screens/compose_fairminter/view/compose_fairminter_page.dart';
import 'package:horizon/presentation/screens/compose_issuance/view/compose_issuance_page.dart';
import 'package:horizon/presentation/screens/compose_send/view/compose_send_page.dart';
import "package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_bloc.dart";
import "package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_event.dart";
import "package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_state.dart";
import 'package:horizon/presentation/screens/dashboard/account_form/view/account_form.dart';
import 'package:horizon/presentation/screens/dashboard/address_form/view/address_form.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/view/activity_feed.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
import 'package:horizon/presentation/screens/dashboard/view/dashboard_contents.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

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
                topBarTitle: Text('Select an Account',
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
                            HorizonUI.HorizonDialog.show(
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

                                return HorizonUI.HorizonDialog(
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
  final HorizonUI.HorizonDialog dialog;
  final IconData icon;
  final String text;
  final double? iconSize;
  const AddressAction({
    super.key,
    required this.isDarkTheme,
    required this.dialog,
    required this.icon,
    required this.text,
    this.iconSize,
  });
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

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
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 12.0),
            ),
            onPressed: () {
              HorizonUI.HorizonDialog.show(context: context, body: dialog);
            },
            child: isMobile
                ? Icon(
                    icon,
                    size: iconSize ?? 24.0,
                    color: isDarkTheme
                        ? greyDashboardButtonTextDarkTheme
                        : greyDashboardButtonTextLightTheme,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: iconSize ?? 24.0,
                        color: isDarkTheme
                            ? greyDashboardButtonTextDarkTheme
                            : greyDashboardButtonTextLightTheme,
                      ),
                      const SizedBox(width: 4.0),
                      Flexible(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDarkTheme
                                ? greyDashboardButtonTextDarkTheme
                                : greyDashboardButtonTextLightTheme,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class DispenserButtonMenu extends StatelessWidget {
  final bool isDarkTheme;
  final IconData icon;
  final String text;
  final double? iconSize;
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;

  const DispenserButtonMenu({
    super.key,
    required this.isDarkTheme,
    required this.icon,
    required this.text,
    this.iconSize,
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: 65,
          child: PopupMenuButton(
            color: isDarkTheme ? lightNavyDarkTheme : lightBlueLightTheme,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                  child: const Text("Create Dispenser"),
                  onTap: () {
                    HorizonUI.HorizonDialog.show(
                        context: context,
                        body: HorizonUI.HorizonDialog(
                          title: "Create Dispenser",
                          includeBackButton: false,
                          includeCloseButton: true,
                          body: ComposeDispenserPageWrapper(
                            dashboardActivityFeedBloc:
                                dashboardActivityFeedBloc,
                            currentAddress: currentAddress,
                          ),
                        ));
                  }),
              PopupMenuItem(
                child: const Text("Close Dispenser"),
                onTap: () {
                  HorizonUI.HorizonDialog.show(
                      context: context,
                      body: HorizonUI.HorizonDialog(
                        title: "Close Dispenser",
                        body: CloseDispenserPageWrapper(
                          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                          currentAddress: currentAddress,
                        ),
                        includeBackButton: false,
                        includeCloseButton: true,
                      ));
                },
              ),
              PopupMenuItem(
                child: const Text("Trigger Dispense"),
                onTap: () {
                  HorizonUI.HorizonDialog.show(
                      context: context,
                      body: HorizonUI.HorizonDialog(
                        title: "Trigger Dispense",
                        body: ComposeDispensePageWrapper(
                          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                          currentAddress: currentAddress,
                        ),
                        includeBackButton: false,
                        includeCloseButton: true,
                      ));
                },
              ),
            ],
            child: Container(
              decoration: BoxDecoration(
                color: isDarkTheme ? lightNavyDarkTheme : lightBlueLightTheme,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: isMobile
                  ? Icon(
                      icon,
                      size: iconSize ?? 24.0,
                      color: isDarkTheme
                          ? greyDashboardButtonTextDarkTheme
                          : greyDashboardButtonTextLightTheme,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: iconSize ?? 24.0,
                          color: isDarkTheme
                              ? greyDashboardButtonTextDarkTheme
                              : greyDashboardButtonTextLightTheme,
                        ),
                        const SizedBox(width: 4.0),
                        Flexible(
                          child: Text(
                            text,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isDarkTheme
                                  ? greyDashboardButtonTextDarkTheme
                                  : greyDashboardButtonTextLightTheme,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class MintMenu extends StatelessWidget {
  final bool isDarkTheme;
  final IconData icon;
  final String text;
  final double? iconSize;
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;

  const MintMenu({
    super.key,
    required this.isDarkTheme,
    required this.icon,
    required this.text,
    this.iconSize,
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: 65,
          child: PopupMenuButton(
            color: isDarkTheme ? lightNavyDarkTheme : lightBlueLightTheme,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                  child: const Text("Compose Fairminter"),
                  onTap: () {
                    HorizonUI.HorizonDialog.show(
                        context: context,
                        body: HorizonUI.HorizonDialog(
                          title: "Compose Fairminter",
                          includeBackButton: false,
                          includeCloseButton: true,
                          body: ComposeFairminterPageWrapper(
                            currentAddress: currentAddress,
                            dashboardActivityFeedBloc:
                                dashboardActivityFeedBloc,
                          ),
                        ));
                  }),
              PopupMenuItem(
                child: const Text("Compose Fairmint"),
                onTap: () {
                  HorizonUI.HorizonDialog.show(
                      context: context,
                      body: HorizonUI.HorizonDialog(
                        title: "Compose Fairmint",
                        body: ComposeFairmintPageWrapper(
                          currentAddress: currentAddress,
                          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                        ),
                        includeBackButton: false,
                        includeCloseButton: true,
                      ));
                },
              ),
            ],
            child: Container(
              decoration: BoxDecoration(
                color: isDarkTheme ? lightNavyDarkTheme : lightBlueLightTheme,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: isMobile
                  ? Icon(
                      icon,
                      size: iconSize ?? 24.0,
                      color: isDarkTheme
                          ? greyDashboardButtonTextDarkTheme
                          : greyDashboardButtonTextLightTheme,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: iconSize ?? 24.0,
                          color: isDarkTheme
                              ? greyDashboardButtonTextDarkTheme
                              : greyDashboardButtonTextLightTheme,
                        ),
                        const SizedBox(width: 4.0),
                        Flexible(
                          child: Text(
                            text,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isDarkTheme
                                  ? greyDashboardButtonTextDarkTheme
                                  : greyDashboardButtonTextLightTheme,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
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
  final String currentAddress;
  final double screenWidth;
  const AddressActions(
      {super.key,
      required this.isDarkTheme,
      required this.dashboardActivityFeedBloc,
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
              dialog: HorizonUI.HorizonDialog(
                title: "Compose Send",
                body: ComposeSendPageWrapper(
                  currentAddress: currentAddress,
                  dashboardActivityFeedBloc: dashboardActivityFeedBloc,
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
              dialog: HorizonUI.HorizonDialog(
                title: "Compose Issuance",
                body: ComposeIssuancePageWrapper(
                  currentAddress: currentAddress,
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
                dialog: HorizonUI.HorizonDialog(
                  title: "Receive",
                  body: QRCodeDialog(
                    currentAddress: currentAddress,
                  ),
                  includeBackButton: false,
                  includeCloseButton: true,
                ),
                icon: Icons.qr_code,
                text: "RECEIVE",
                iconSize: 24.0),
            MintMenu(
              currentAddress: currentAddress,
              isDarkTheme: isDarkTheme,
              icon: Icons.print,
              text: "MINT",
              iconSize: 24.0,
              dashboardActivityFeedBloc: dashboardActivityFeedBloc,
            ),
            DispenserButtonMenu(
              currentAddress: currentAddress,
              isDarkTheme: isDarkTheme,
              icon: Icons.more_vert,
              text: "DISPENSER",
              iconSize: 24.0,
              dashboardActivityFeedBloc: dashboardActivityFeedBloc,
            ),
          ],
        ),
      ),
    ]);
  }
}

class DashboardPageWrapper extends StatelessWidget {
  const DashboardPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context
        .watch<ShellStateCubit>()
        .state; // we should only ever get to this page if shell is success
    return shell.maybeWhen(
        success: (data) => MultiBlocProvider(
              key: key,
              providers: [
                BlocProvider<BalancesBloc>(
                  create: (context) => BalancesBloc(
                    balanceRepository: GetIt.I.get<BalanceRepository>(),
                    accountRepository: GetIt.I.get<AccountRepository>(),
                    addressRepository: GetIt.I.get<AddressRepository>(),
                    addressTxRepository: GetIt.I.get<AddressTxRepository>(),
                    assetRepository: GetIt.I.get<AssetRepository>(),
                    currentAddress: data.currentAddress?.address ??
                        data.currentImportedAddress!.address,
                  )..add(Start(pollingInterval: const Duration(seconds: 60))),
                ),
                BlocProvider<DashboardActivityFeedBloc>(
                  create: (context) => DashboardActivityFeedBloc(
                    logger: GetIt.I.get<Logger>(),
                    currentAddress: data.currentAddress?.address ??
                        data.currentImportedAddress!.address,
                    eventsRepository: GetIt.I.get<EventsRepository>(),
                    addressRepository: GetIt.I.get<AddressRepository>(),
                    bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
                    transactionLocalRepository:
                        GetIt.I.get<TransactionLocalRepository>(),
                    pageSize: 1000,
                  ),
                ),
              ],
              child: DashboardPage(
                key: key,
                accountUuid: data.currentAccountUuid,
                currentAddress: data.currentAddress,
                currentImportedAddress: data.currentImportedAddress,
                actionRepository: GetIt.instance<ActionRepository>(),
              ),
            ),
        orElse: () => const SizedBox.shrink());
  }
}

class QRCodeDialog extends StatelessWidget {
  final String currentAddress;

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
          data: currentAddress,
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
                          currentAddress,
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
                                Clipboard.setData(
                                    ClipboardData(text: currentAddress));
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
                                    ClipboardData(text: currentAddress));
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
          final accountUuid = context.read<ShellStateCubit>().state.maybeWhen(
                success: (state) => state.currentAccountUuid,
                orElse: () => null,
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
                  HorizonUI.HorizonDialog.show(
                    context: context,
                    body: HorizonUI.HorizonDialog(
                      title: "Add a new address\nto ${account.name}",
                      titleAlign: Alignment.center,
                      body: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AddAddressForm(
                          accountUuid: accountUuid!,
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

class DashboardPage extends StatefulWidget {
  final String? accountUuid;
  final Address? currentAddress;
  final ImportedAddress? currentImportedAddress;
  final ActionRepository actionRepository;

  const DashboardPage({
    super.key,
    required this.accountUuid,
    required this.currentAddress,
    required this.currentImportedAddress,
    required this.actionRepository,
  });

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final accountSettingsRepository = GetIt.I.get<AccountSettingsRepository>();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    final action = widget.actionRepository.dequeue();
    action.fold(noop, (action) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getHandler(action)();
      });
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchTerm = _searchController.text;
    });
  }

  void Function() _getHandler(URLAction.Action action) {
    return switch (action) {
      URLAction.DispenseAction(address: var address) => () =>
          _handleDispenseAction(address),
      URLAction.FairmintAction(fairminterTxHash: var fairminterTxHash) => () =>
          _handleFairmintAction(fairminterTxHash),
      _ => noop
    };
  }

  void _handleDispenseAction(String address) {
    final dashboardActivityFeedBloc =
        BlocProvider.of<DashboardActivityFeedBloc>(context);

    HorizonUI.HorizonDialog.show(
        context: context,
        body: HorizonUI.HorizonDialog(
            title: "Trigger Dispense",
            body: ComposeDispensePageWrapper(
                initialDispenserAddress: address,
                currentAddress: widget.currentAddress?.address ??
                    widget.currentImportedAddress!.address,
                dashboardActivityFeedBloc: dashboardActivityFeedBloc)));
  }

  void _handleFairmintAction(String intitialFairminterTxHash) {
    final dashboardActivityFeedBloc =
        BlocProvider.of<DashboardActivityFeedBloc>(context);

    HorizonUI.HorizonDialog.show(
        context: context,
        body: HorizonUI.HorizonDialog(
          title: "Compose Fairmint",
          body: ComposeFairmintPageWrapper(
            initialFairminterTxHash: intitialFairminterTxHash,
            dashboardActivityFeedBloc: dashboardActivityFeedBloc,
            currentAddress: widget.currentAddress?.address ??
                widget.currentImportedAddress!.address,
          ),
          includeBackButton: false,
          includeCloseButton: true,
        ));
  }

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

    final isSmallScreen = screenWidth < 600;

    final Account? account = context.read<ShellStateCubit>().state.maybeWhen(
          success: (state) => state.accounts.firstWhereOrNull(
            (account) => account.uuid == state.currentAccountUuid,
          ),
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
                                            currentAddress: widget
                                                    .currentAddress?.address ??
                                                widget.currentImportedAddress!
                                                    .address,
                                            screenWidth: screenWidth,
                                          );
                                        }),
                                        SizedBox(
                                          height: isSmallScreen ? 352 : 258,
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
                                                      isDarkTheme: isDarkTheme,
                                                      currentAddress: widget
                                                              .currentAddress
                                                              ?.address ??
                                                          widget
                                                              .currentImportedAddress!
                                                              .address,
                                                      initialItemCount:
                                                          isSmallScreen
                                                              ? 5
                                                              : 3),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: isSmallScreen ? 248 : 352,
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
                                                          key: Key(
                                                            widget.currentAddress
                                                                    ?.address ??
                                                                widget
                                                                    .currentImportedAddress!
                                                                    .address,
                                                          ),
                                                          addresses: [
                                                            widget.currentAddress
                                                                    ?.address ??
                                                                widget
                                                                    .currentImportedAddress!
                                                                    .address
                                                          ],
                                                          initialItemCount:
                                                              isSmallScreen
                                                                  ? 3
                                                                  : 4),
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
                                    : SliverToBoxAdapter(
                                        child: AccountSelectionButton(
                                          isDarkTheme: isDarkTheme,
                                          onPressed: () => showAccountList(
                                              context, isDarkTheme),
                                        ),
                                      ),
                                if (account != null)
                                  isSmallScreen
                                      ? Builder(builder: (context) {
                                          return context
                                              .read<ShellStateCubit>()
                                              .state
                                              .maybeWhen(
                                                  success: (state) => state
                                                              .addresses
                                                              .length >
                                                          1
                                                      ? SliverToBoxAdapter(
                                                          child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  8.0,
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
                                                        ))
                                                      : const SliverToBoxAdapter(
                                                          child: SizedBox
                                                              .shrink()),
                                                  orElse: () =>
                                                      const SliverToBoxAdapter(
                                                          child: SizedBox
                                                              .shrink()));
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
                                    currentAddress: widget
                                            .currentAddress?.address ??
                                        widget.currentImportedAddress!.address,
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
                                        isDarkTheme: isDarkTheme,
                                        currentAddress:
                                            widget.currentAddress?.address ??
                                                widget.currentImportedAddress!
                                                    .address,
                                        initialItemCount:
                                            isSmallScreen ? 5 : 3),
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
                                      key: Key(widget.currentAddress?.address ??
                                          widget
                                              .currentImportedAddress!.address),
                                      addresses: [
                                        widget.currentAddress?.address ??
                                            widget
                                                .currentImportedAddress!.address
                                      ],
                                      initialItemCount: isSmallScreen ? 3 : 4,
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
}
