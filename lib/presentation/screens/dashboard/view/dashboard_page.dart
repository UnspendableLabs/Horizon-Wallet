import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/common/fn.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/action.dart' as URLAction;
import 'package:horizon/domain/entities/extension_rpc.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/public_key_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_bloc.dart';
import 'package:horizon/presentation/forms/get_addresses/view/get_addresses_form.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/view/sign_psbt_form.dart';
import 'package:horizon/presentation/screens/close_dispenser/view/close_dispenser_page.dart';
import 'package:horizon/presentation/screens/compose_cancel/view/compose_cancel_view.dart';
import 'package:horizon/presentation/screens/compose_destroy/view/compose_destroy_page.dart';
import 'package:horizon/presentation/screens/compose_dispense/view/compose_dispense_modal.dart';
import 'package:horizon/presentation/screens/compose_dispenser/view/compose_dispenser_page.dart';
import 'package:horizon/presentation/screens/compose_fairmint/view/compose_fairmint_page.dart';
import 'package:horizon/presentation/screens/compose_fairminter/view/compose_fairminter_page.dart';
import 'package:horizon/presentation/screens/compose_mpma/view/compose_mpma_page.dart';
import 'package:horizon/presentation/screens/compose_order/view/compose_order_view.dart';
import 'package:horizon/presentation/screens/compose_send/view/compose_send_page.dart';
import 'package:horizon/presentation/screens/compose_sweep/view/compose_sweep_page.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/view/reset_dialog.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_event.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_state.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/view/import_address_pk_form.dart';
import 'package:horizon/presentation/screens/dashboard/view/activity_feed.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/view/view_seed_phrase_form.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_event.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SignPsbtModal extends StatelessWidget {
  final int tabId;
  final String requestId;
  final String unsignedPsbt;
  final TransactionService transactionService;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final BitcoindService bitcoindService;
  final BalanceRepository balanceRepository;
  final RPCSignPsbtSuccessCallback onSuccess;
  final Map<String, List<int>> signInputs;
  final List<int>? sighashTypes;
  final ImportedAddressService importedAddressService;
  final UnifiedAddressRepository addressRepository;
  final AccountRepository accountRepository;
  final BitcoinRepository bitcoinRepository;

  const SignPsbtModal(
      {super.key,
      required this.unsignedPsbt,
      required this.transactionService,
      required this.walletRepository,
      required this.encryptionService,
      required this.addressService,
      required this.bitcoindService,
      required this.balanceRepository,
      required this.tabId,
      required this.requestId,
      required this.onSuccess,
      required this.signInputs,
      required this.sighashTypes,
      required this.importedAddressService,
      required this.addressRepository,
      required this.accountRepository,
      required this.bitcoinRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignPsbtBloc(
        passwordRequired:
            GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
        inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
        addressRepository: addressRepository,
        importedAddressService: importedAddressService,
        signInputs: signInputs,
        sighashTypes: sighashTypes,
        unsignedPsbt: unsignedPsbt,
        transactionService: transactionService,
        bitcoindService: bitcoindService,
        balanceRepository: balanceRepository,
        bitcoinRepository: bitcoinRepository,
        walletRepository: walletRepository,
        encryptionService: encryptionService,
        addressService: addressService,
        accountRepository: accountRepository,
      ),
      child: SignPsbtForm(
        key: Key(unsignedPsbt),
        passwordRequired:
            GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
        onSuccess: (signedPsbtHex) {
          onSuccess(RPCSignPsbtSuccessCallbackArgs(
              tabId: tabId, requestId: requestId, signedPsbt: signedPsbtHex));
        },
      ),
    );
  }
}

class GetAddressesModal extends StatelessWidget {
  final int tabId;
  final String requestId;
  final List<Account> accounts;
  final AddressRepository addressRepository;
  final ImportedAddressRepository importedAddressRepository;
  final RPCGetAddressesSuccessCallback onSuccess;
  final AddressService addressService;
  final ImportedAddressService importedAddressService;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final PublicKeyService publicKeyService;
  final AccountRepository accountRepository;

  const GetAddressesModal(
      {super.key,
      required this.accountRepository,
      required this.publicKeyService,
      required this.encryptionService,
      required this.addressService,
      required this.importedAddressService,
      required this.walletRepository,
      required this.tabId,
      required this.requestId,
      required this.accounts,
      required this.addressRepository,
      required this.importedAddressRepository,
      required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetAddressesBloc(
        passwordRequired:
            GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
        inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
        accountRepository: accountRepository,
        publicKeyService: publicKeyService,
        encryptionService: encryptionService,
        walletRepository: walletRepository,
        importedAddressService: importedAddressService,
        addressService: addressService,
        accounts: accounts,
        addressRepository: addressRepository,
        importedAddressRepository: importedAddressRepository,
      ),
      child: GetAddressesForm(
        passwordRequired:
            GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
        accounts: accounts,
        onSuccess: (addresses) {
          onSuccess(RPCGetAddressesSuccessCallbackArgs(
              tabId: tabId, requestId: requestId, addresses: addresses));
        },
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
  final String? tooltip;
  const AddressAction({
    super.key,
    required this.isDarkTheme,
    required this.dialog,
    required this.icon,
    required this.text,
    this.iconSize,
    this.tooltip,
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
          child: Tooltip(
            message: tooltip ?? text,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDarkTheme ? lightNavyDarkTheme : lightBlueLightTheme,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: isMobile ? 6.0 : 10.0),
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
      ),
    );
  }
}

class OrderButtonMenu extends StatelessWidget {
  final bool isDarkTheme;
  final IconData icon;
  final String text;
  final double? iconSize;
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final currentAddress;

  const OrderButtonMenu(
      {super.key,
      required this.isDarkTheme,
      required this.icon,
      required this.text,
      this.iconSize,
      required this.dashboardActivityFeedBloc,
      required this.currentAddress});

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
            tooltip: "Order Actions",
            color: isDarkTheme ? lightNavyDarkTheme : lightBlueLightTheme,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                  child: const Text("Open Order"),
                  onTap: () {
                    HorizonUI.HorizonDialog.show(
                      context: context,
                      body: HorizonUI.HorizonDialog(
                        includeBackButton: false,
                        includeCloseButton: true,
                        title: "Open Order",
                        body: ComposeOrderPageWrapper(
                          composeTransactionUseCase:
                              GetIt.I<ComposeTransactionUseCase>(),
                          currentAddress: currentAddress,
                          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                          getFeeEstimatesUseCase:
                              GetIt.I<GetFeeEstimatesUseCase>(),

                          // balanceRepository: GetIt.I<BalanceRepository>(),
                          assetRepository: GetIt.I<AssetRepository>(),
                        ),
                      ),
                    );
                  }),
              PopupMenuItem(
                  child: const Text("Cancel Order"),
                  onTap: () {
                    HorizonUI.HorizonDialog.show(
                      context: context,
                      body: HorizonUI.HorizonDialog(
                        includeBackButton: false,
                        includeCloseButton: true,
                        title: "Cancel Order",
                        body: ComposeCancelPageWrapper(
                          composeTransactionUseCase:
                              GetIt.I<ComposeTransactionUseCase>(),
                          currentAddress: currentAddress,
                          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                          getFeeEstimatesUseCase:
                              GetIt.I<GetFeeEstimatesUseCase>(),

                          // balanceRepository: GetIt.I<BalanceRepository>(),
                          assetRepository: GetIt.I<AssetRepository>(),
                        ),
                      ),
                    );
                  }),
              // PopupMenuItem(
              //   child: const Text("Cancel Order"),
              //   onTap: () {
              //     HorizonUI.HorizonDialog.show(
              //         context: context,
              //         body: HorizonUI.HorizonDialog(
              //           title: "Close Dispenser",
              //           body: CloseDispenserPageWrapper(
              //             currentAddress: currentAddress,
              //             dashboardActivityFeedBloc: dashboardActivityFeedBloc,
              //           ),
              //           includeBackButton: false,
              //           includeCloseButton: true,
              //         ));
              //   },
              // ),
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
            tooltip: "Dispenser Actions",
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
            tooltip: "Fairminter Actions",
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

class SendMenu extends StatelessWidget {
  final bool isDarkTheme;
  final IconData icon;
  final String text;
  final double? iconSize;
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;

  const SendMenu({
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
          child: PopupMenuButton<String>(
            tooltip: "Send Options",
            color: isDarkTheme ? lightNavyDarkTheme : lightBlueLightTheme,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
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
            onSelected: (String result) {
              if (result == 'send') {
                HorizonUI.HorizonDialog.show(
                  context: context,
                  body: HorizonUI.HorizonDialog(
                    title: "Compose Send",
                    body: ComposeSendPageWrapper(
                      currentAddress: currentAddress,
                      dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                    ),
                    includeBackButton: false,
                    includeCloseButton: true,
                  ),
                );
              } else if (result == 'mpma') {
                HorizonUI.HorizonDialog.show(
                  context: context,
                  body: HorizonUI.HorizonDialog(
                    title: "Compose MPMA",
                    body: ComposeMpmaPageWrapper(
                      dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                      currentAddress: currentAddress,
                    ),
                    includeBackButton: false,
                    includeCloseButton: true,
                  ),
                );
              } else if (result == 'sweep') {
                HorizonUI.HorizonDialog.show(
                  context: context,
                  body: HorizonUI.HorizonDialog(
                    title: "Compose Sweep",
                    body: ComposeSweepPageWrapper(
                      currentAddress: currentAddress,
                      dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                    ),
                    includeBackButton: false,
                    includeCloseButton: true,
                  ),
                );
              } else if (result == 'destroy') {
                HorizonUI.HorizonDialog.show(
                  context: context,
                  body: HorizonUI.HorizonDialog(
                    title: "Compose Destroy",
                    body: ComposeDestroyPageWrapper(
                      dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                      currentAddress: currentAddress,
                    ),
                    includeBackButton: false,
                    includeCloseButton: true,
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'send',
                child: Text('Compose Send'),
              ),
              const PopupMenuItem<String>(
                value: 'mpma',
                child: Text('Compose MPMA Send'),
              ),
              const PopupMenuItem<String>(
                value: 'sweep',
                child: Text('Compose Sweep'),
              ),
              const PopupMenuItem<String>(
                value: 'destroy',
                child: Text('Compose Destroy'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  final List<String> addresses;
  final ActionRepository actionRepository;

  const DashboardPage({
    super.key,
    required this.addresses,
    required this.actionRepository,
  });

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  final accountSettingsRepository = GetIt.I.get<AccountSettingsRepository>();
  final _scrollController = ScrollController();
  bool shown = false;
  late TabController _tabController;
  late TabController _bottomTabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bottomTabController = TabController(length: 2, vsync: this);
    _bottomTabController.addListener(() {
      setState(() {}); // Rebuild to update the selected tab styling
    });
    final action = widget.actionRepository.dequeue();
    action.fold(noop, (action) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getHandler(action)();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bottomTabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void Function() _getHandler(URLAction.Action action) {
    return switch (action) {
      URLAction.RPCGetAddressesAction(
        tabId: var tabId,
        requestId: var requestId
      ) =>
        () => _handleRPCGetAddressesAction(tabId, requestId),
      URLAction.RPCSignPsbtAction(
        tabId: var tabId,
        requestId: var requestId,
        psbt: var psbt,
        signInputs: var signInputs,
        sighashTypes: var sighashTypes
      ) =>
        () => _handleRPCSignPsbtAction(
            tabId, requestId, psbt, signInputs, sighashTypes),
      _ => noop
    };
  }

  void _handleRPCGetAddressesAction(int tabId, String requestId) {
    HorizonUI.HorizonDialog.show(
        context: context,
        body: HorizonUI.HorizonDialog(
          title: "Get Addresses",
          body: Builder(builder: (context) {
            final session = context.watch<SessionStateCubit>();
            return session.state.maybeWhen(
                orElse: () => const SizedBox.shrink(),
                success: (state) {
                  return GetAddressesModal(
                      tabId: tabId,
                      requestId: requestId,
                      accounts: state.accounts,
                      addressRepository: GetIt.I<AddressRepository>(),
                      accountRepository: GetIt.I<AccountRepository>(),
                      publicKeyService: GetIt.I<PublicKeyService>(),
                      encryptionService: GetIt.I<EncryptionService>(),
                      addressService: GetIt.I<AddressService>(),
                      importedAddressService: GetIt.I<ImportedAddressService>(),
                      walletRepository: GetIt.I<WalletRepository>(),
                      importedAddressRepository:
                          GetIt.I<ImportedAddressRepository>(),
                      onSuccess: GetIt.I<RPCGetAddressesSuccessCallback>());
                });
          }),
          includeBackButton: false,
          includeCloseButton: true,
        ));
  }

  void _handleRPCSignPsbtAction(int tabId, String requestId, String psbt,
      Map<String, List<int>> signInputs, List<int>? sighashTypes) {
    HorizonUI.HorizonDialog.show(
        context: context,
        body: HorizonUI.HorizonDialog(
          title: "Sign Psbt",
          body: SignPsbtModal(
              tabId: tabId,
              requestId: requestId,
              unsignedPsbt: psbt,
              signInputs: signInputs,
              sighashTypes: sighashTypes,
              accountRepository: GetIt.I<AccountRepository>(),
              addressRepository: GetIt.I<UnifiedAddressRepository>(),
              importedAddressService: GetIt.I.get<ImportedAddressService>(),
              transactionService: GetIt.I.get<TransactionService>(),
              bitcoindService: GetIt.I.get<BitcoindService>(),
              balanceRepository: GetIt.I.get<BalanceRepository>(),
              bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
              walletRepository: GetIt.I.get<WalletRepository>(),
              encryptionService: GetIt.I.get<EncryptionService>(),
              addressService: GetIt.I.get<AddressService>(),
              onSuccess: GetIt.I<RPCSignPsbtSuccessCallback>()),
          includeBackButton: false,
          includeCloseButton: true,
        ));
  }

  Widget buildSettingsTab() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text("Theme"),
              const Spacer(),
              Switch(
                value: isDarkTheme,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(ThemeToggled());
                },
              ),
            ],
          ),
        ),
        ListTile(
          title: const Text('Settings'),
          onTap: () => context.go("/settings"),
        ),
        ListTile(
          title: const Text('View wallet seed phrase'),
          onTap: () {
            HorizonUI.HorizonDialog.show(
              context: context,
              body: const HorizonUI.HorizonDialog(
                includeBackButton: false,
                includeCloseButton: true,
                title: "View wallet seed phrase",
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ViewSeedPhraseFormWrapper(),
                ),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Import new address private key'),
          onTap: () {
            HorizonUI.HorizonDialog.show(
              context: context,
              body: Builder(builder: (context) {
                final bloc = context.watch<ImportAddressPkBloc>();
                final cb = switch (bloc.state) {
                  ImportAddressPkStep2() => () {
                      bloc.add(ResetForm());
                    },
                  _ => () {
                      Navigator.of(context).pop();
                    },
                };
                return HorizonUI.HorizonDialog(
                  onBackButtonPressed: cb,
                  title: "Import address private key",
                  body: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: ImportAddressPkForm(),
                  ),
                );
              }),
            );
          },
        ),
        ListTile(
          title: const Text('Reset wallet'),
          onTap: () {
            HorizonUI.HorizonDialog.show(
              context: context,
              body: BlocProvider(
                create: (context) => ResetBloc(
                  kvService: GetIt.I.get<SecureKVService>(),
                  inMemoryKeyRepository: GetIt.I.get<InMemoryKeyRepository>(),
                  walletRepository: GetIt.I.get<WalletRepository>(),
                  accountRepository: GetIt.I.get<AccountRepository>(),
                  addressRepository: GetIt.I.get<AddressRepository>(),
                  importedAddressRepository:
                      GetIt.I.get<ImportedAddressRepository>(),
                  cacheProvider: GetIt.I.get<CacheProvider>(),
                  analyticsService: GetIt.I.get<AnalyticsService>(),
                ),
                child: const ResetDialog(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Lock Screen'),
          onTap: () => context.read<SessionStateCubit>().onLogout(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 926.0;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    Widget buildTabContent() {
      return Column(
        children: [
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
            child: TabBar(
              controller: _tabController,
              indicatorWeight: 2,
              indicatorColor: transparentPurple33,
              labelColor: Theme.of(context).textTheme.bodyMedium?.color,
              unselectedLabelColor:
                  isDarkTheme ? transparentWhite33 : transparentBlack33,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 14),
              tabs: const [
                SizedBox(
                  width: 81,
                  height: 64,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Assets',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  width: 81,
                  height: 64,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Activity',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(8.0),
                        sliver: BalancesDisplay(isDarkTheme: isDarkTheme),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(8.0),
                        sliver: DashboardActivityFeedScreen(
                          key: Key(widget.addresses.first),
                          addresses: widget.addresses,
                          initialItemCount: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final mainContent = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverCrossAxisConstrained(
              maxCrossAxisExtent: maxWidth,
              child: SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  height: MediaQuery.of(context).size.height -
                      100, // Take up most of the screen height
                  child: buildTabContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: TabBarView(
        controller: _bottomTabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          mainContent,
          buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        width: 375,
        height: 90,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDarkTheme
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: TabBar(
          controller: _bottomTabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          labelColor: isDarkTheme ? Colors.white : Colors.black,
          unselectedLabelColor:
              isDarkTheme ? transparentWhite33 : transparentBlack33,
          tabs: [
            Container(
              width: 75,
              height: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _bottomTabController.index == 0
                      ? (isDarkTheme
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1))
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 24,
                      color: _bottomTabController.index == 0
                          ? (isDarkTheme ? Colors.white : Colors.black)
                          : (isDarkTheme
                              ? transparentWhite33
                              : transparentBlack33),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Portfolio',
                      style: TextStyle(
                        fontSize: 12,
                        color: _bottomTabController.index == 0
                            ? (isDarkTheme ? Colors.white : Colors.black)
                            : (isDarkTheme
                                ? transparentWhite33
                                : transparentBlack33),
                      ),
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 75,
              height: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _bottomTabController.index == 1
                      ? (isDarkTheme
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1))
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings,
                      size: 24,
                      color: _bottomTabController.index == 1
                          ? (isDarkTheme ? Colors.white : Colors.black)
                          : (isDarkTheme
                              ? transparentWhite33
                              : transparentBlack33),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 12,
                        color: _bottomTabController.index == 1
                            ? (isDarkTheme ? Colors.white : Colors.black)
                            : (isDarkTheme
                                ? transparentWhite33
                                : transparentBlack33),
                      ),
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPageWrapper extends StatelessWidget {
  const DashboardPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state;

    return session.maybeWhen(
        success: (data) => MultiBlocProvider(
              key: key,
              providers: [
                BlocProvider<BalancesBloc>(
                  create: (context) => BalancesBloc(
                    balanceRepository: GetIt.I.get<BalanceRepository>(),
                    addresses: [
                      ...data.addresses.map((e) => e.address),
                      ...(data.importedAddresses?.map((e) => e.address) ?? [])
                    ],
                  )..add(Start(pollingInterval: const Duration(seconds: 60))),
                ),
                BlocProvider<DashboardActivityFeedBloc>(
                  create: (context) => DashboardActivityFeedBloc(
                    logger: GetIt.I.get<Logger>(),
                    addresses: [
                      ...data.addresses.map((e) => e.address),
                      ...(data.importedAddresses?.map((e) => e.address) ?? [])
                    ],
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
                addresses: [
                  ...data.addresses.map((e) => e.address),
                  ...(data.importedAddresses?.map((e) => e.address) ?? [])
                ],
                actionRepository: GetIt.instance<ActionRepository>(),
              ),
            ),
        orElse: () => const SizedBox.shrink());
  }
}
