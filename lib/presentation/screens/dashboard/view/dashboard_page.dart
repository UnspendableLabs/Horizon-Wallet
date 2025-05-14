import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/fn.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/account_v2.dart';
import 'package:horizon/domain/entities/action.dart' as URLAction;
import 'package:horizon/domain/entities/extension_rpc.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/public_key_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_bloc.dart';
import 'package:horizon/presentation/forms/get_addresses/view/get_addresses_form.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/view/sign_psbt_form.dart';

import 'package:horizon/presentation/forms/sign_message/bloc/sign_message_bloc.dart';
import 'package:horizon/presentation/forms/sign_message/view/sign_message_form.dart';

import 'package:horizon/presentation/screens/close_dispenser/view/close_dispenser_page.dart';
import 'package:horizon/presentation/screens/compose_cancel/view/compose_cancel_view.dart';
import 'package:horizon/presentation/screens/compose_destroy/view/compose_destroy_page.dart';
import 'package:horizon/presentation/screens/compose_dispense/view/compose_dispense_modal.dart';
import 'package:horizon/presentation/screens/compose_dispenser/view/compose_dispenser_page.dart';
import 'package:horizon/presentation/screens/compose_fairmint/view/compose_fairmint_page.dart';
import 'package:horizon/presentation/screens/compose_fairminter/view/compose_fairminter_page.dart';
import 'package:horizon/presentation/screens/compose_mpma/view/compose_mpma_page.dart';
import 'package:horizon/presentation/screens/compose_order/view/compose_order_view.dart';
import 'package:horizon/presentation/screens/compose_sweep/view/compose_sweep_page.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';

class SignMessageModal extends StatelessWidget {
  final int tabId;
  final String requestId;
  final String message;
  final String address;
  final TransactionService transactionService;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final BitcoindService bitcoindService;
  final BalanceRepository balanceRepository;
  final RPCSignMessageSuccessCallback onSuccess;
  final ImportedAddressService importedAddressService;
  final UnifiedAddressRepository addressRepository;
  final BitcoinRepository bitcoinRepository;

  const SignMessageModal(
      {super.key,
      required this.message,
      required this.address,
      required this.transactionService,
      required this.walletRepository,
      required this.encryptionService,
      required this.addressService,
      required this.bitcoindService,
      required this.balanceRepository,
      required this.tabId,
      required this.requestId,
      required this.onSuccess,
      required this.importedAddressService,
      required this.addressRepository,
      required this.bitcoinRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignMessageBloc(
        address: address,
        passwordRequired:
            GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
        inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
        addressRepository: addressRepository,
        importedAddressService: importedAddressService,
        message: message,
        transactionService: transactionService,
        balanceRepository: balanceRepository,
        walletRepository: walletRepository,
        encryptionService: encryptionService,
        addressService: addressService,
        accountRepository: accountRepository,
      ),
      child: SignMessageForm(
        key: Key(message),
        passwordRequired:
            GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
        onSuccess: (signature) {
          onSuccess(RPCSignMessageSuccessCallbackArgs(
              tabId: tabId,
              requestId: requestId,
              signature: signature,
              messageHash: message, // TODO: This is just a placeholder
              address: address));
        },
      ),
    );
  }
}

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
  final ImportedAddressService importedAddressService;
  final UnifiedAddressRepository addressRepository;
  final BitcoinRepository bitcoinRepository;
  final List<int>? sighashTypes;
  final SessionStateSuccess session;

  const SignPsbtModal(
      {super.key,
      required this.session,
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
      required this.bitcoinRepository});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionStateCubit>().state.successOrThrow();
    return BlocProvider(
      create: (_) => SignPsbtBloc(
        httpConfig: session.httpConfig,
        session: session,
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
      ),
      child: SignPsbtForm(
        key: Key(unsignedPsbt),
        balanceRepository: balanceRepository,
        bitcoinRepository: bitcoinRepository,
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
  final List<AccountV2> accounts;
  final AddressRepository addressRepository;
  final ImportedAddressRepository importedAddressRepository;
  final RPCGetAddressesSuccessCallback onSuccess;
  final AddressService addressService;
  final ImportedAddressService importedAddressService;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final PublicKeyService publicKeyService;

  const GetAddressesModal(
      {super.key,
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
    final session = context.read<SessionStateCubit>().state.successOrThrow();
    return BlocProvider(

      create: (_) => GetAddressesBloc(
        httpConfig: session.httpConfig,
        passwordRequired:
            GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
        inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
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

// void showAccountList(BuildContext context, bool isDarkTheme) {
//   const double pagePadding = 16.0;

//   WoltModalSheet.show<void>(
//     context: context,
//     pageListBuilder: (modalSheetContext) {
//       return [
//         context.read<SessionStateCubit>().state.maybeWhen(
//               success: (state) {
//                 final hasImportedAddresses =
//                     state.importedAddresses?.isNotEmpty ?? false;

//                 return WoltModalSheetPage(
//                   backgroundColor: isDarkTheme
//                       ? dialogBackgroundColorDarkTheme
//                       : dialogBackgroundColorLightTheme,
//                   isTopBarLayerAlwaysVisible: true,
//                   topBarTitle: Text(
//                     'Select item to view balance',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold,
//                       color: isDarkTheme ? mainTextWhite : mainTextBlack,
//                     ),
//                   ),
//                   trailingNavBarWidget: IconButton(
//                     padding: const EdgeInsets.all(pagePadding),
//                     icon: const Icon(Icons.close),
//                     onPressed: Navigator.of(modalSheetContext).pop,
//                   ),
//                   child: SizedBox(
//                     height: 400,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (hasImportedAddresses)
//                           const Padding(
//                             padding: EdgeInsets.fromLTRB(32, 16, 0, 8),
//                             child: Text(
//                               "Accounts",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 12,
//                                 color: mainTextGrey,
//                               ),
//                             ),
//                           ),
//                         Expanded(
//                           child: ListView(
//                             children: [
//                               // Regular accounts
//                               ...state.accounts.asMap().entries.map((entry) {
//                                 final index = entry.key;
//                                 final account = entry.value;
//                                 return Column(
//                                   children: [
//                                     ListTile(
//                                       leading: const Icon(
//                                           Icons.account_balance_wallet_rounded),
//                                       title: Text(
//                                         account.name,
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                       selected: state.accounts.first,
//                                       onTap: () {
//                                         context
//                                             .read<SessionStateCubit>()
//                                             .onAccountChanged(account);
//                                         Navigator.of(modalSheetContext).pop();
//                                         GoRouter.of(context).go('/dashboard');
//                                       },
//                                     ),
//                                     if (index != state.accounts.length - 1)
//                                       const Padding(
//                                         padding: EdgeInsets.symmetric(
//                                             horizontal: 4.0),
//                                         child: Divider(thickness: 1.0),
//                                       ),
//                                   ],
//                                 );
//                               }),

//                               // Add Account button
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 25.0),
//                                   backgroundColor: isDarkTheme
//                                       ? darkNavyDarkTheme
//                                       : lightBlueLightTheme,
//                                   shape: const RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.zero,
//                                   ),
//                                   elevation: 0,
//                                 ),
//                                 onPressed: () {
//                                   Navigator.of(modalSheetContext).pop();
//                                   HorizonUI.HorizonDialog.show(
//                                     context: context,
//                                     body: Builder(builder: (context) {
//                                       final bloc =
//                                           context.watch<AccountFormBloc>();
//                                       final cb = switch (bloc.state) {
//                                         AccountFormStep2() => () {
//                                             bloc.add(Reset());
//                                           },
//                                         _ => () {
//                                             Navigator.of(context).pop();
//                                           },
//                                       };
//                                       return HorizonUI.HorizonDialog(
//                                         onBackButtonPressed: cb,
//                                         title: "Add an account",
//                                         body: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 16.0),
//                                           child: AddAccountForm(
//                                             passwordRequired: GetIt.I<
//                                                     SettingsRepository>()
//                                                 .requirePasswordForCryptoOperations,
//                                           ),
//                                         ),
//                                       );
//                                     }),
//                                   );
//                                 },
//                                 child: const Text("Add Account",
//                                     style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600)),
//                               ),

//                               // Imported addresses section
//                               if (hasImportedAddresses) ...[
//                                 const Padding(
//                                   padding: EdgeInsets.fromLTRB(32, 16, 0, 8),
//                                   child: Text(
//                                     "Imported Addresses",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 12,
//                                       color: mainTextGrey,
//                                     ),
//                                   ),
//                                 ),
//                                 ...?state.importedAddresses
//                                     ?.asMap()
//                                     .entries
//                                     .map((entry) {
//                                   final index = entry.key;
//                                   final importedAddress = entry.value;
//                                   return Column(
//                                     children: [
//                                       ListTile(
//                                         leading: const Icon(Icons.key),
//                                         title: Text(
//                                           importedAddress.name,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.w700,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                         selected: importedAddress.address ==
//                                             state.currentImportedAddress
//                                                 ?.address,
//                                         onTap: () {
//                                           context
//                                               .read<SessionStateCubit>()
//                                               .onImportedAddressChanged(
//                                                   importedAddress);
//                                           Navigator.of(modalSheetContext).pop();
//                                           GoRouter.of(context).go('/dashboard');
//                                         },
//                                       ),
//                                       if (index !=
//                                           (state.importedAddresses?.length ??
//                                                   0) -
//                                               1)
//                                         const Padding(
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 4.0),
//                                           child: Divider(thickness: 1.0),
//                                         ),
//                                     ],
//                                   );
//                                 }),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//               orElse: () => SliverWoltModalSheetPage(),
//             ),
//       ];
//     },
//     modalTypeBuilder: (context) {
//       final size = MediaQuery.of(context).size.width;
//       return size < 768.0 ? WoltModalType.bottomSheet : WoltModalType.dialog;
//     },
//   );
// }

// class WalletItemSelectionButton extends StatelessWidget {
//   final bool isDarkTheme;
//   final VoidCallback onPressed;

//   const WalletItemSelectionButton({
//     super.key,
//     required this.isDarkTheme,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final selectedItem = context.read<SessionStateCubit>().state.maybeWhen(
//           success: (state) {
//             final account = state.accounts.firstWhereOrNull(
//                 (account) => account.uuid == state.currentAccountUuid);
//             if (account != null) {
//               return account.name;
//             }
//             final importedAddress = state.importedAddresses?.firstWhereOrNull(
//                 (importedAddress) =>
//                     importedAddress.address ==
//                     state.currentImportedAddress?.address);
//             return importedAddress?.name ?? "Select Item ";
//           },
//           orElse: () => "Select Item",
//         );
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
//       child: SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             minimumSize: const Size(double.infinity, 70),
//             elevation: 0,
//             backgroundColor:
//                 isDarkTheme ? lightNavyDarkTheme : lightBlueLightTheme,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(24.0),
//             ),
//           ),
//           onPressed: onPressed,
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Icon(
//                   Icons.account_balance_wallet_rounded,
//                   color: isDarkTheme
//                       ? greyDashboardButtonTextDarkTheme
//                       : greyDashboardButtonTextLightTheme,
//                 ),
//                 const SizedBox(width: 16.0),
//                 Text(
//                   selectedItem,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: isDarkTheme
//                         ? greyDashboardButtonTextDarkTheme
//                         : greyDashboardButtonTextLightTheme,
//                   ),
//                 ),
//                 const Spacer(),
//                 Icon(
//                   Icons.arrow_drop_down,
//                   color: isDarkTheme
//                       ? greyDashboardButtonTextDarkTheme
//                       : greyDashboardButtonTextLightTheme,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

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

// class AddressActions extends StatelessWidget {
//   final bool isDarkTheme;
//   final DashboardActivityFeedBloc dashboardActivityFeedBloc;
//   final String currentAddress;
//   final String? currentAccountUuid;
//   final double screenWidth;
//   const AddressActions(
//       {super.key,
//       required this.isDarkTheme,
//       required this.dashboardActivityFeedBloc,
//       required this.currentAddress,
//       required this.screenWidth,
//       this.currentAccountUuid});
//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//       Padding(
//         padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 4.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             SendMenu(
//               currentAddress: currentAddress,
//               isDarkTheme: isDarkTheme,
//               icon: Icons.send,
//               text: "SEND",
//               iconSize: 18.0,
//               dashboardActivityFeedBloc: dashboardActivityFeedBloc,
//             ),
//             AddressAction(
//               tooltip: "Issue Asset",
//               isDarkTheme: isDarkTheme,
//               dialog: HorizonUI.HorizonDialog(
//                 title: "Compose Issuance",
//                 body: ComposeIssuancePageWrapper(
//                   currentAddress: currentAddress,
//                   dashboardActivityFeedBloc: dashboardActivityFeedBloc,
//                 ),
//                 includeBackButton: false,
//                 includeCloseButton: true,
//               ),
//               icon: Icons.add,
//               text: "ISSUE",
//               iconSize: 18.0,
//             ),
//             AddressAction(
//               tooltip: "Receive Asset",
//               isDarkTheme: isDarkTheme,
//               dialog: HorizonUI.HorizonDialog(
//                 title: "Receive",
//                 body: QRCodeDialog(
//                   currentAddress: currentAddress,
//                   currentAccountUuid: currentAccountUuid,
//                 ),
//                 includeBackButton: false,
//                 includeCloseButton: true,
//               ),
//               icon: Icons.qr_code,
//               text: "RECEIVE",
//               iconSize: 18.0,
//             ),
//             MintMenu(
//               currentAddress: currentAddress,
//               isDarkTheme: isDarkTheme,
//               icon: Icons.print,
//               text: "MINT",
//               iconSize: 18.0,
//               dashboardActivityFeedBloc: dashboardActivityFeedBloc,
//             ),
//             DispenserButtonMenu(
//               currentAddress: currentAddress,
//               isDarkTheme: isDarkTheme,
//               icon: Icons.more_vert,
//               text: "DISPENSER",
//               iconSize: 18.0,
//               dashboardActivityFeedBloc: dashboardActivityFeedBloc,
//             ),
//             OrderButtonMenu(
//               currentAddress: currentAddress,
//               isDarkTheme: isDarkTheme,
//               icon: Icons.toc,
//               text: "ORDER",
//               iconSize: 18.0,
//               dashboardActivityFeedBloc: dashboardActivityFeedBloc,
//             ),
//           ],
//         ),
//       ),
//     ]);
//   }
// }

class DashboardPageWrapper extends StatelessWidget {
  const DashboardPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context
        .watch<SessionStateCubit>()
        .state; // we should only ever get to this page if session is success

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
                // BlocProvider<DashboardActivityFeedBloc>(
                //   create: (context) => DashboardActivityFeedBloc(
                //     logger: GetIt.I.get<Logger>(),
                //     addresses: data.addresses,
                //     eventsRepository: GetIt.I.get<EventsRepository>(),
                //     addressRepository: GetIt.I.get<AddressRepository>(),
                //     bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
                //     transactionLocalRepository:
                //         GetIt.I.get<TransactionLocalRepository>(),
                //     pageSize: 1000,
                //   ),
                // ),
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

// class QRCodeDialog extends StatelessWidget {
//   final String currentAddress;
//   final String? currentAccountUuid;

//   const QRCodeDialog(
//       {super.key, required this.currentAddress, this.currentAccountUuid});

//   @override
//   Widget build(BuildContext context) {
//     final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const SizedBox(height: 8.0),
//         QrImageView(
//           dataModuleStyle: QrDataModuleStyle(
//             dataModuleShape: QrDataModuleShape.square,
//             color: isDarkTheme ? mainTextWhite : royalBlueLightTheme,
//           ),
//           eyeStyle: QrEyeStyle(
//               eyeShape: QrEyeShape.square,
//               color: isDarkTheme ? mainTextWhite : royalBlueLightTheme),
//           data: currentAddress,
//           version: QrVersions.auto,
//           size: 230.0,
//         ),
//         const SizedBox(height: 16.0),
//         const Divider(
//           thickness: 1.0,
//         ),
//         LayoutBuilder(
//           builder: (context, constraints) {
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Container(
//                 width: 500,
//                 decoration: BoxDecoration(
//                   color: isDarkTheme ? darkNavyDarkTheme : noBackgroundColor,
//                   borderRadius: BorderRadius.circular(10.0),
//                   border: isDarkTheme
//                       ? Border.all(color: noBackgroundColor)
//                       : Border.all(color: greyLightThemeUnderlineColor),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: SelectableText(
//                           currentAddress,
//                           style: const TextStyle(
//                               overflow: TextOverflow.ellipsis, fontSize: 16),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(2.0),
//                       child: screenWidth < 768.0
//                           ? ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 elevation: 0,
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 20.0, vertical: 20.0),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                               ),
//                               onPressed: () {
//                                 Clipboard.setData(
//                                     ClipboardData(text: currentAddress));
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                       content:
//                                           Text('Address copied to clipboard')),
//                                 );
//                               },
//                               child: const Icon(Icons.copy),
//                             )
//                           : ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 elevation: 0,
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 20.0, vertical: 20.0),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                               ),
//                               onPressed: () {
//                                 Clipboard.setData(
//                                     ClipboardData(text: currentAddress));
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                       content:
//                                           Text('Address copied to clipboard')),
//                                 );
//                               },
//                               child: SizedBox(
//                                 height: 32.0,
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.copy,
//                                         size: 14.0,
//                                         color: isDarkTheme
//                                             ? darkThemeInputLabelColor
//                                             : lightThemeInputLabelColor),
//                                     const SizedBox(width: 4.0, height: 16.0),
//                                     Text("COPY",
//                                         style: TextStyle(
//                                             fontSize: 14.0,
//                                             color: isDarkTheme
//                                                 ? darkThemeInputLabelColor
//                                                 : lightThemeInputLabelColor)),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//         if (currentAccountUuid != null)
//           Builder(builder: (context) {
//             final accountUuid =
//                 context.read<SessionStateCubit>().state.maybeWhen(
//                       success: (state) => state.currentAccountUuid,
//                       orElse: () => null,
//                     );

//             // look up account
//             Account account = context.read<SessionStateCubit>().state.maybeWhen(
//                   success: (state) => state.accounts
//                       .firstWhere((account) => account.uuid == accountUuid),
//                   orElse: () => throw Exception("invariant: no account"),
//                 );

//             // don't support address creation for horizon accounts
//             return switch (account.importFormat) {
//               ImportFormat.horizon => const SizedBox.shrink(),
//               _ => TextButton(
//                   child: const Text("Add a new address"),
//                   onPressed: () {
//                     HorizonUI.HorizonDialog.show(
//                       context: context,
//                       body: HorizonUI.HorizonDialog(
//                         title: "Add a new address\nto ${account.name}",
//                         titleAlign: Alignment.center,
//                         body: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                           child: AddAddressForm(
//                             passwordRequired: GetIt.I
//                                 .get<SettingsRepository>()
//                                 .requirePasswordForCryptoOperations,
//                             accountUuid: accountUuid!,
//                           ),
//                         ),
//                         onBackButtonPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     );
//                   })
//             };
//           })
//       ],
//     );
//   }
// }

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

class DashboardPageState extends State<DashboardPage> {
  final accountSettingsRepository = GetIt.I.get<AccountSettingsRepository>();
  final _scrollController = ScrollController();
  bool shown = false;

  @override
  void initState() {
    super.initState();
    final action = widget.actionRepository.dequeue();
    action.fold(noop, (action) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getHandler(action)();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void Function() _getHandler(URLAction.Action action) {
    return switch (action) {
      URLAction.DispenseAction(address: var address) => () =>
          _handleDispenseAction(address),
      URLAction.FairmintAction(
        fairminterTxHash: var fairminterTxHash,
        numLots: var numLots
      ) =>
        () => _handleFairmintAction(fairminterTxHash, numLots),
      URLAction.OpenOrderAction(
        giveQuantity: var giveQuantity,
        giveAsset: var giveAsset,
        getQuantity: var getQuantity,
        getAsset: var getAsset
      ) =>
        _handleOrderAction(giveQuantity, giveAsset, getQuantity, getAsset),
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
      URLAction.RPCSignMessageAction(
        tabId: var tabId,
        requestId: var requestId,
        message: var message,
        address: var address
      ) =>
        () => _handleRPCSignMessageAction(tabId, requestId, message, address),
      _ => noop
    };
  }

  void _handleOrderAction(
      int giveQuantity, String giveAsset, int getQuantity, String getAsset) {
    throw UnimplementedError();
    //
    // final dashboardActivityFeedBloc =
    //     BlocProvider.of<DashboardActivityFeedBloc>(context);
    //
    // HorizonUI.HorizonDialog.show(
    //   context: context,
    //   body: HorizonUI.HorizonDialog(
    //     includeBackButton: false,
    //     includeCloseButton: true,
    //     title: "Open Order",
    //     body: ComposeOrderPageWrapper(
    //       currentAddress: widget.currentAddress?.address ??
    //           widget.currentImportedAddress!.address,
    //       dashboardActivityFeedBloc: dashboardActivityFeedBloc,
    //       getFeeEstimatesUseCase: GetIt.I<GetFeeEstimatesUseCase>(),
    //       composeTransactionUseCase: GetIt.I<ComposeTransactionUseCase>(),
    //
    //       // balanceRepository: GetIt.I<BalanceRepository>(),
    //       assetRepository: GetIt.I<AssetRepository>(),
    //       initialGiveAsset: giveAsset,
    //       initialGiveQuantity: giveQuantity,
    //       initialGetAsset: getAsset,
    //       initialGetQuantity: getQuantity,
    //     ),
    //   ),
    // );
  }

  void _handleDispenseAction(String address) {
    throw UnimplementedError();
    // final dashboardActivityFeedBloc =
    //     BlocProvider.of<DashboardActivityFeedBloc>(context);
    //
    // HorizonUI.HorizonDialog.show(
    //     context: context,
    //     body: HorizonUI.HorizonDialog(
    //         includeBackButton: false,
    //         includeCloseButton: true,
    //         title: "Trigger Dispense",
    //         body: ComposeDispensePageWrapper(
    //             initialDispenserAddress: address,
    //             currentAddress: widget.currentAddress?.address ??
    //                 widget.currentImportedAddress!.address,
    //             dashboardActivityFeedBloc: dashboardActivityFeedBloc)));
  }

  void _handleFairmintAction(String intitialFairminterTxHash, int? numLots) {
    throw UnimplementedError();

    // final dashboardActivityFeedBloc =
    //     BlocProvider.of<DashboardActivityFeedBloc>(context);
    //
    // HorizonUI.HorizonDialog.show(
    //     context: context,
    //     body: HorizonUI.HorizonDialog(
    //       title: "Compose Fairmint",
    //       body: ComposeFairmintPageWrapper(
    //         initialFairminterTxHash: intitialFairminterTxHash,
    //         initialNumLots: numLots,
    //         dashboardActivityFeedBloc: dashboardActivityFeedBloc,
    //         currentAddress: widget.currentAddress?.address ??
    //             widget.currentImportedAddress!.address,
    //       ),
    //       includeBackButton: false,
    //       includeCloseButton: true,
    //     ));
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
                      // accountRepository: GetIt.I<AccountRepository>(),
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
          body: Builder(builder: (context) {
            final session =
                context.watch<SessionStateCubit>().state.successOrThrow();

            return SignPsbtModal(
                session: session,
                tabId: tabId,
                requestId: requestId,
                unsignedPsbt: psbt,
                signInputs: signInputs,
                sighashTypes: sighashTypes,
                // accountRepository: GetIt.I<AccountRepository>(),
                addressRepository: GetIt.I<UnifiedAddressRepository>(),
                importedAddressService: GetIt.I.get<ImportedAddressService>(),
                transactionService: GetIt.I.get<TransactionService>(),
                bitcoindService: GetIt.I.get<BitcoindService>(),
                balanceRepository: GetIt.I.get<BalanceRepository>(),
                bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
                walletRepository: GetIt.I.get<WalletRepository>(),
                encryptionService: GetIt.I.get<EncryptionService>(),
                addressService: GetIt.I.get<AddressService>(),
                onSuccess: GetIt.I<RPCSignPsbtSuccessCallback>());
          }),
          includeBackButton: false,
          includeCloseButton: true,
        ));
  }

  void _handleRPCSignMessageAction(
    int tabId,
    String requestId,
    String message,
    String address,
  ) {
    HorizonUI.HorizonDialog.show(
        context: context,
        body: HorizonUI.HorizonDialog(
          title: "Sign Message",
          body: SignMessageModal(
              tabId: tabId,
              requestId: requestId,
              message: message,
              address: address,
              addressRepository: GetIt.I<UnifiedAddressRepository>(),
              importedAddressService: GetIt.I.get<ImportedAddressService>(),
              transactionService: GetIt.I.get<TransactionService>(),
              bitcoindService: GetIt.I.get<BitcoindService>(),
              balanceRepository: GetIt.I.get<BalanceRepository>(),
              bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
              walletRepository: GetIt.I.get<WalletRepository>(),
              encryptionService: GetIt.I.get<EncryptionService>(),
              addressService: GetIt.I.get<AddressService>(),
              onSuccess: GetIt.I<RPCSignMessageSuccessCallback>()),
          includeBackButton: false,
          includeCloseButton: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 926.0;

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    Color backgroundColor = isDarkTheme ? darkNavyDarkTheme : greyLightTheme;
    final backgroundColorInner =
        isDarkTheme ? lightNavyDarkTheme : greyLightTheme;

    final backgroundColorWrapper =
        isDarkTheme ? darkNavyDarkTheme : Colors.white;

    final isSmallScreen = screenWidth < 600;

    // final state = context.watch<SessionStateCubit>().state;

    // final Account? account = state.maybeWhen(
    //   success: (state) => state.accounts.firstWhereOrNull(
    //     (account) => account.uuid == state.currentAccountUuid,
    //   ),
    //   orElse: () => null,
    // );

    if (!isSmallScreen) {
      // Scaffold for desktop
      return Container(
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
        child: Builder(builder: (context) {
          return Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
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
                            // Expanded(
                            //     child: Container(
                            //         decoration: BoxDecoration(
                            //           color: backgroundColorWrapper,
                            //           borderRadius: BorderRadius.circular(30.0),
                            //         ),
                            //         child: const WalletItemSidebar())),
                            // const SizedBox(width: 8),
                            Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: backgroundColorWrapper,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: Column(
                                    children: [
                                      // Builder(builder: (context) {
                                      //   final dashboardActivityFeedBloc =
                                      //       BlocProvider.of<
                                      //               DashboardActivityFeedBloc>(
                                      //           context);
                                      //   return AddressActions(
                                      //     isDarkTheme: isDarkTheme,
                                      //     dashboardActivityFeedBloc:
                                      //         dashboardActivityFeedBloc,
                                      //     currentAddress:
                                      //         widget.currentAddress?.address ??
                                      //             widget.currentImportedAddress!
                                      //                 .address,
                                      //     screenWidth: screenWidth,
                                      //     currentAccountUuid:
                                      //         widget.accountUuid,
                                      //   );
                                      // }),
                                      SizedBox(
                                        height: 258,
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
                                                    isDarkTheme: isDarkTheme),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   height: 352,
                                      //   child: Container(
                                      //     margin: const EdgeInsets.fromLTRB(
                                      //         8, 4, 8, 8),
                                      //     decoration: BoxDecoration(
                                      //       color: backgroundColorInner,
                                      //       borderRadius:
                                      //           BorderRadius.circular(30.0),
                                      //     ),
                                      //     child: CustomScrollView(
                                      //       slivers: [
                                      //         SliverPadding(
                                      //           padding:
                                      //               const EdgeInsets.all(8.0),
                                      //           sliver:
                                      //               DashboardActivityFeedScreen(
                                      //                   key: Key(
                                      //                     widget.currentAddress
                                      //                             ?.address ??
                                      //                         widget
                                      //                             .currentImportedAddress!
                                      //                             .address,
                                      //                   ),
                                      //                   addresses: [
                                      //                     widget.currentAddress
                                      //                             ?.address ??
                                      //                         widget
                                      //                             .currentImportedAddress!
                                      //                             .address
                                      //                   ],
                                      //                   initialItemCount: 4),
                                      //         )
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                )),
                          ])))
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      );
    }

    // Scaffold for mobile
    return Container(
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
                            // SliverToBoxAdapter(
                            //   child: WalletItemSelectionButton(
                            //     isDarkTheme: isDarkTheme,
                            //     onPressed: () =>
                            //         showAccountList(context, isDarkTheme),
                            //   ),
                            // ),
                            // if (account != null)
                            //   Builder(builder: (context) {
                            //     return context
                            //         .read<SessionStateCubit>()
                            //         .state
                            //         .maybeWhen(
                            //             success: (state) => state
                            //                         .addresses.length >
                            //                     1
                            //                 ? SliverToBoxAdapter(
                            //                     child: Padding(
                            //                     padding:
                            //                         const EdgeInsets.fromLTRB(
                            //                             8.0, 8.0, 8.0, 0.0),
                            //                     child: AddressSelectionButton(
                            //                       isDarkTheme: isDarkTheme,
                            //                       onPressed: () =>
                            //                           showAddressList(context,
                            //                               isDarkTheme, account),
                            //                     ),
                            //                   ))
                            //                 : const SliverToBoxAdapter(
                            //                     child: SizedBox.shrink()),
                            //             orElse: () => const SliverToBoxAdapter(
                            //                 child: SizedBox.shrink()));
                            //   }),
                            // SliverToBoxAdapter(
                            //     child: Builder(builder: (context) {
                            //   final dashboardActivityFeedBloc =
                            //       BlocProvider.of<DashboardActivityFeedBloc>(
                            //           context);
                            //   return AddressActions(
                            //     isDarkTheme: isDarkTheme,
                            //     dashboardActivityFeedBloc:
                            //         dashboardActivityFeedBloc,
                            //     currentAddress:
                            //         widget.currentAddress?.address ??
                            //             widget.currentImportedAddress!.address,
                            //     screenWidth: screenWidth,
                            //   );
                            // })),
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
                                sliver:
                                    BalancesDisplay(isDarkTheme: isDarkTheme),
                              ),
                            ]),
                            // SliverStack(children: [
                            //   SliverPositioned.fill(
                            //     child: Container(
                            //       margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            //       decoration: BoxDecoration(
                            //         color: backgroundColorInner,
                            //         borderRadius: BorderRadius.circular(30.0),
                            //       ),
                            //     ),
                            //   ),
                            //   SliverPadding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     sliver: DashboardActivityFeedScreen(
                            //       key: Key(widget.currentAddress?.address ??
                            //           widget.currentImportedAddress!.address),
                            //       addresses: [
                            //         widget.currentAddress?.address ??
                            //             widget.currentImportedAddress!.address
                            //       ],
                            //       initialItemCount: 3,
                            //     ),
                            //   ),
                            // ])
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
    );
  }
}
