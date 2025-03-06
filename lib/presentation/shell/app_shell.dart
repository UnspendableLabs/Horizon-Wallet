import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/common/fn.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/action.dart' as URLAction;
import 'package:horizon/domain/entities/extension_rpc.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/public_key_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/footer/view/footer.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_bloc.dart';
import 'package:horizon/presentation/forms/get_addresses/view/get_addresses_form.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/view/sign_psbt_form.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/version_cubit.dart';

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

class AppShell extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  // Method to navigate to tabs from outside
  static void navigateToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_AppShellState>();
    if (state != null) {
      state._bottomTabController.animateTo(index);
    }
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  late TabController _bottomTabController;
  final ActionRepository actionRepository = GetIt.instance<ActionRepository>();
  Timer? _actionCheckTimer;

  // Expose the bottom tab controller for external access
  TabController get bottomTabController => _bottomTabController;

  @override
  void initState() {
    super.initState();
    _bottomTabController = TabController(length: 2, vsync: this);
    _updateIndexFromRoute(widget.currentRoute);

    _bottomTabController.addListener(() {
      // Update URL when tab changes
      if (_bottomTabController.index == 1) {
        context.go('/settings');
      } else {
        context.go('/dashboard');
      }
    });

    // Initial check for pending actions
    _checkForPendingActions();

    // Set up periodic checks for actions
    _actionCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkForPendingActions();
    });
  }

  void _checkForPendingActions() {
    final action = actionRepository.dequeue();
    action.fold(noop, (action) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getHandler(action)();
      });
    });
  }

  void Function() _getHandler(URLAction.Action action) {
    // TODO: handle each PRC action as we add back transactions
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

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRoute != oldWidget.currentRoute) {
      _updateIndexFromRoute(widget.currentRoute);

      // Check for pending actions when route changes
      _checkForPendingActions();
    }
  }

  void _updateIndexFromRoute(String route) {
    if (route.startsWith('/settings')) {
      if (_bottomTabController.index != 1) {
        _bottomTabController.animateTo(1);
      }
    } else {
      if (_bottomTabController.index != 0) {
        _bottomTabController.animateTo(0);
      }
    }
  }

  @override
  void dispose() {
    _actionCheckTimer?.cancel();
    _bottomTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkTheme ? Colors.black : Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width > 500 ? 500 : double.infinity,
          ),
          child: VersionWarningSnackbar(
            child: Scaffold(
              backgroundColor: isDarkTheme ? offBlack : offWhite,
              body: widget.child,
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bottom Navigation Bar - Styled exactly like dashboard_page.dart
                  Container(
                    width: double.infinity,
                    height: 90,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkTheme ? Colors.black : Colors.white,
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
                            color:
                                _bottomTabController.index == 0 && !isDarkTheme
                                    ? offWhite
                                    : Colors.transparent,
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
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pie_chart_outline,
                                  size: 24,
                                  color: _bottomTabController.index == 0
                                      ? (isDarkTheme
                                          ? Colors.white
                                          : Colors.black)
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
                                        ? (isDarkTheme
                                            ? Colors.white
                                            : Colors.black)
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
                            color:
                                _bottomTabController.index == 1 && !isDarkTheme
                                    ? offWhite
                                    : Colors.transparent,
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
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.settings,
                                  size: 24,
                                  color: _bottomTabController.index == 1
                                      ? (isDarkTheme
                                          ? Colors.white
                                          : Colors.black)
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
                                        ? (isDarkTheme
                                            ? Colors.white
                                            : Colors.black)
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

                  // Footer
                  const Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VersionWarningSnackbar extends StatefulWidget {
  final Widget child;

  const VersionWarningSnackbar({required this.child, super.key});

  @override
  VersionWarningState createState() => VersionWarningState();
}

class VersionWarningState extends State<VersionWarningSnackbar> {
  bool _hasShownSnackbar = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final versionInfo = context
        .read<VersionCubit>()
        .state; // we should only ever get to this page if session is success

    if (!_hasShownSnackbar && versionInfo.warning != null) {
      switch (versionInfo.warning!) {
        case NewVersionAvailable():
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                'There is a new version of Horizon Wallet: ${versionInfo.latest}.  Your version is ${versionInfo.current} ',
              )),
            );
            _hasShownSnackbar = true;
          });
          break;
        case VersionServiceUnreachable():
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                'Version service unreachable.  Horizon Wallet may be out of date. Your version is ${versionInfo.current} ',
              )),
            );
            _hasShownSnackbar = true;
          });
          break;
      }
    }

    if (!_hasShownSnackbar && versionInfo.current < versionInfo.latest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'There is a new version of Horizon Wallet: ${versionInfo.latest}.  Your version is ${versionInfo.current} ',
          )),
        );
        _hasShownSnackbar = true;
      });
    }
  }

  @override
  Widget build(context) => widget.child;
}
