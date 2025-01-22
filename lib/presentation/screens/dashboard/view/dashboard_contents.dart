import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_event.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_state.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/view/import_address_pk_form.dart';
import 'package:horizon/presentation/screens/dashboard/view_address_pk_form/view/view_address_pk_form.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/view/view_seed_phrase_form.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/screens/dashboard/bloc/reset/view/reset_dialog.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_state.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/link.dart';
import 'package:horizon/presentation/screens/dashboard/account_form/view/account_form.dart';
import 'package:horizon/presentation/screens/dashboard/address_form/view/address_form.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_event.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import "package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_bloc.dart";
import "package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_state.dart";
import "package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_event.dart";

class WalletItemSidebar extends StatefulWidget {
  const WalletItemSidebar({super.key});
  @override
  State<WalletItemSidebar> createState() => _WalletItemSidebarState();
}

class _WalletItemSidebarState extends State<WalletItemSidebar> {
  Account? selectedAccount;
  ImportedAddress? selectedImportedAddress;
  bool isImportedAddressesExpanded = true;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>();
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkTheme ? darkNavyDarkTheme : whiteLightTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 4, 16),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: session.state.maybeWhen(
          success: (state) {
            final hasImportedAddresses =
                state.importedAddresses?.isNotEmpty ?? false;

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 554,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        if (hasImportedAddresses)
                          const Padding(
                            padding: EdgeInsets.fromLTRB(32, 8, 0, 8),
                            child: Text(
                              "Accounts",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: mainTextGrey,
                              ),
                            ),
                          ),
                        // Regular accounts list
                        ...state.accounts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final account = entry.value;
                          return Column(
                            children: [
                              ListTile(
                                title: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                          width: 16.0), // Add some left padding
                                      const Icon(
                                          Icons.account_balance_wallet_rounded),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Text(
                                          account.name,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                hoverColor:
                                    Colors.transparent, // No hover effect
                                selected:
                                    account.uuid == state.currentAccountUuid,
                                onTap: () {
                                  setState(() => selectedAccount = account);
                                  context
                                      .read<SessionStateCubit>()
                                      .onAccountChanged(account);
                                  GoRouter.of(context).go('/dashboard');
                                },
                              ),
                              if (index !=
                                  state.accounts.length -
                                      1) // Avoid underline for the last element
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Divider(
                                    thickness: 1.0,
                                  ),
                                ),
                            ],
                          );
                        }),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
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

                        if (hasImportedAddresses)
                          Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors
                                  .transparent, // Removes the default divider
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: isImportedAddressesExpanded,
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  isImportedAddressesExpanded = expanded;
                                });
                              },
                              title: const Text(
                                "Imported Addresses",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: mainTextGrey,
                                ),
                              ),
                              tilePadding:
                                  const EdgeInsets.fromLTRB(32, 0, 16, 0),
                              children: [
                                ...state.importedAddresses
                                        ?.asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final importedAddress = entry.value;
                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 8, 0, 8),
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 16.0),
                                                  const Icon(Icons.key),
                                                  const SizedBox(width: 16.0),
                                                  Expanded(
                                                    child: Text(
                                                      importedAddress.name,
                                                      textAlign: TextAlign.left,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            hoverColor: Colors.transparent,
                                            selected: importedAddress.address ==
                                                state.currentImportedAddress
                                                    ?.address,
                                            onTap: () {
                                              setState(() =>
                                                  selectedImportedAddress =
                                                      importedAddress);
                                              context
                                                  .read<SessionStateCubit>()
                                                  .onImportedAddressChanged(
                                                      importedAddress);
                                              GoRouter.of(context)
                                                  .go('/dashboard');
                                            },
                                          ),
                                          if (index !=
                                              (state.importedAddresses
                                                          ?.length ??
                                                      0) -
                                                  1)
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4.0),
                                              child: Divider(thickness: 1.0),
                                            ),
                                        ],
                                      );
                                    }).toList() ??
                                    [],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
                  child: Text(
                    "POWERED BY\nUNSPENDABLE LABS",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
          orElse: () => const Text(""),
        ),
      ),
    );
  }
}

class TransparentHorizonSliverAppBar extends StatelessWidget {
  final double expandedHeight;

  const TransparentHorizonSliverAppBar({
    super.key,
    this.expandedHeight = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      // floating: true,
      // snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: const FlexibleSpaceBar(
        background: HorizonAppBarContent(),
      ),
    );
  }
}

class HorizonAppBarContent extends StatelessWidget {
  const HorizonAppBarContent({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>();
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 700;

    final backgroundColor = isDarkTheme ? lightNavyDarkTheme : greyLightTheme;
    final selectedColor =
        isDarkTheme ? blueDarkThemeGradiantColor : royalBlueLightTheme;
    final unselectedColor = isDarkTheme ? mainTextGrey : mainTextGrey;

    final Account? account = session.state.maybeWhen(
      success: (state) => state.accounts.firstWhereOrNull(
        (account) => account.uuid == state.currentAccountUuid,
      ),
      orElse: () => null,
    );

    final String? address = session.state.maybeWhen(
      success: (state) =>
          state.currentAddress?.address ??
          state.currentImportedAddress?.address,
      orElse: () => null,
    );

    final addressURL =
        '${GetIt.I<Config>().horizonExplorerBase}/addresses/$address';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: isDarkTheme
                        ? SvgPicture.asset(
                            'assets/logo-white.svg',
                            width: 35,
                            height: 35,
                          )
                        : SvgPicture.asset(
                            'assets/logo-black.svg',
                            width: 35,
                            height: 35,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Text('Horizon',
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black,
                        fontSize: isSmallScreen ? 25 : 30,
                        fontWeight: FontWeight.w700,
                      )),
                  if (!isSmallScreen) const SizedBox(width: 8),
                  if (!isSmallScreen)
                    const Text('Wallet',
                        style: TextStyle(
                          color: neonBlueDarkTheme,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        )),
                  const SizedBox(width: 12),
                  if (!isSmallScreen && account != null)
                    session.state.maybeWhen(
                      success: (state) => state.addresses.length > 1
                          ? Flexible(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
                                child: AddressSelectionButton(
                                  isDarkTheme: isDarkTheme,
                                  onPressed: () {
                                    showAddressList(
                                        context, isDarkTheme, account);
                                  },
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      orElse: () => const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(
                        color: isDarkTheme
                            ? darkNavyDarkTheme
                            : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (isDarkTheme) {
                              context.read<ThemeBloc>().add(ThemeToggled());
                            }
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isDarkTheme ? backgroundColor : selectedColor,
                            ),
                            child: Icon(
                              Icons.wb_sunny,
                              size: 20,
                              color:
                                  isDarkTheme ? unselectedColor : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (!isDarkTheme) {
                              context.read<ThemeBloc>().add(ThemeToggled());
                            }
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isDarkTheme ? selectedColor : backgroundColor,
                            ),
                            child: Icon(
                              Icons.dark_mode,
                              size: 20,
                              color: isDarkTheme
                                  ? neonBlueDarkTheme
                                  : unselectedColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                BlocProvider(
                  create: (context) => ResetBloc(
                    walletRepository: GetIt.I.get<WalletRepository>(),
                    accountRepository: GetIt.I.get<AccountRepository>(),
                    addressRepository: GetIt.I.get<AddressRepository>(),
                    importedAddressRepository:
                        GetIt.I.get<ImportedAddressRepository>(),
                    cacheProvider: GetIt.I.get<CacheProvider>(),
                    analyticsService: GetIt.I.get<AnalyticsService>(),
                  ),
                  child: BlocConsumer<ResetBloc, ResetState>(
                    listener: (context, state) {
                      if (state.resetState is Out) {
                        final session = context.read<SessionStateCubit>();
                        session.onOnboarding();
                      }
                    },
                    builder: (context, state) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDarkTheme
                              ? darkNavyDarkTheme
                              : lightBlueLightTheme,
                          shape: BoxShape.circle,
                          border: Border.all(color: noBackgroundColor),
                        ),
                        child: PopupMenuButton<String>(
                          position: PopupMenuPosition.under,
                          icon: Icon(
                            Icons.settings,
                            size: 20,
                            color: isDarkTheme
                                ? mainTextGrey
                                : royalBlueLightTheme,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'lock_screen':
                                context.read<SessionStateCubit>().onLogout();
                                return;
                              case 'reset':
                                HorizonUI.HorizonDialog.show(
                                    context: context,
                                    body: BlocProvider.value(
                                      value:
                                          BlocProvider.of<ResetBloc>(context),
                                      child: const ResetDialog(),
                                    ));
                              case 'import_address_pk':
                                HorizonUI.HorizonDialog.show(
                                  context: context,
                                  body: Builder(builder: (context) {
                                    final bloc =
                                        context.watch<ImportAddressPkBloc>();

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
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: ImportAddressPkForm(),
                                      ),
                                    );
                                  }),
                                );
                              case 'view_address_pk':
                                HorizonUI.HorizonDialog.show(
                                    context: context,
                                    body: HorizonUI.HorizonDialog(
                                      includeBackButton: false,
                                      includeCloseButton: true,
                                      title: "View address private key",
                                      body: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: ViewAddressPkFormWrapper(
                                            address: address!),
                                      ),
                                    ));
                              case 'view_seed_phrase':
                                HorizonUI.HorizonDialog.show(
                                    context: context,
                                    body: const HorizonUI.HorizonDialog(
                                      includeBackButton: false,
                                      includeCloseButton: true,
                                      title: "View wallet seed phrase",
                                      body: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: ViewSeedPhraseFormWrapper(),
                                      ),
                                    ));
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'view_current_address_in_explorer',
                              child: Link(
                                  display: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('View address in explorer'),
                                        Icon(Icons.open_in_new, size: 16)
                                      ]),
                                  href: addressURL),
                            ),
                            const PopupMenuItem<String>(
                              value: 'view_seed_phrase',
                              child: Text('View wallet seed phrase'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'import_address_pk',
                              child: Text('Import new address private key'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'view_address_pk',
                              child: Text('View current address private key'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'reset',
                              child: Text('Reset wallet'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'lock_screen',
                              child: Text('Lock Screen'),
                            ),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddressSelectionButton extends StatelessWidget {
  final bool isDarkTheme;
  final VoidCallback onPressed;
  final EdgeInsets padding;

  const AddressSelectionButton({
    super.key,
    this.padding = const EdgeInsets.all(12.0),
    required this.isDarkTheme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  context.read<SessionStateCubit>().state.maybeWhen(
                        success: (state) => state.addresses
                            .firstWhere((address) =>
                                address.address ==
                                state.currentAddress!.address)
                            .address,
                        orElse: () => "Select Address",
                      ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme
                        ? greyDashboardButtonTextDarkTheme
                        : greyDashboardButtonTextLightTheme,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
    );
  }
}

void showAddressList(BuildContext context, bool isDarkTheme, Account? account) {
  const double pagePadding = 16.0;

  WoltModalSheet.show<void>(
    context: context,
    pageListBuilder: (modalSheetContext) {
      return [
        context.read<SessionStateCubit>().state.maybeWhen(
              success: (state) => WoltModalSheetPage(
                backgroundColor: isDarkTheme
                    ? dialogBackgroundColorDarkTheme
                    : dialogBackgroundColorLightTheme,
                isTopBarLayerAlwaysVisible: true,
                topBarTitle: Text('Select Address',
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
                          itemCount: state.addresses.length,
                          itemBuilder: (context, index) {
                            final address = state.addresses[index];
                            final isSelected = address.address ==
                                state.currentAddress!.address;
                            return ListTile(
                              title: Text(address.address),
                              selected: isSelected,
                              onTap: () {
                                context
                                    .read<SessionStateCubit>()
                                    .onAddressChanged(address);
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
                            HorizonUI.HorizonDialog.show(
                              context: context,
                              body: HorizonUI.HorizonDialog(
                                title:
                                    "Add a new address\nto ${account?.name} ",
                                titleAlign: Alignment.center,
                                body: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: AddAddressForm(
                                      accountUuid: state.currentAccountUuid!,
                                      modalContext: modalSheetContext),
                                ),
                                onBackButtonPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                          child: const Text("Add a new address",
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
