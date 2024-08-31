// https://medium.com/@antonio.tioypedro1234/flutter-go-router-the-essential-guide-349ef39ec5b3
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/presentation/screens/onboarding/view/back_continue_buttons.dart';
import 'package:horizon/presentation/screens/settings/bloc/logout_bloc.dart';
import 'package:horizon/presentation/screens/settings/bloc/logout_event.dart';
import 'package:horizon/presentation/screens/settings/bloc/logout_state.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_dialog.dart';
import 'package:horizon/presentation/shell/account_form/view/account_form.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/shell/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/shell/theme/bloc/theme_event.dart';
import 'package:horizon/presentation/shell/view/address_dropdown.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class ResponsiveAccountSidebar extends StatefulWidget {
  const ResponsiveAccountSidebar({super.key});
  @override
  State<ResponsiveAccountSidebar> createState() =>
      _ResponsiveAccountSidebarState();
}

class _ResponsiveAccountSidebarState extends State<ResponsiveAccountSidebar> {
  final TextEditingController accountController = TextEditingController();
  Account? selectedAccount;

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkTheme ? darkNavyDarkTheme : whiteLightTheme;

    if (screenWidth >= 768.0) {
      // Sidebar for wider screens
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 16),
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: shell.state.maybeWhen(
                success: (state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: state.accounts.length,
                            itemBuilder: (context, index) {
                              final account = state.accounts[index];
                              return Column(
                                children: [
                                  ListTile(
                                    title: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                              width:
                                                  16.0), // Add some left padding
                                          const Icon(Icons
                                              .account_balance_wallet_rounded),
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
                                    selected: account.uuid ==
                                        state.currentAccountUuid,
                                    onTap: () {
                                      setState(() => selectedAccount = account);
                                      context
                                          .read<ShellStateCubit>()
                                          .onAccountChanged(account);
                                      GoRouter.of(context).go('/dashboard');
                                    },
                                  ),
                                  if (index !=
                                      state.accounts.length -
                                          1) // Avoid underline for the last element
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Divider(
                                        color: isDarkTheme
                                            ? greyDarkThemeUnderlineColor
                                            : greyLightThemeUnderlineColor,
                                        thickness: 1.0,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            elevation: 0, // No shadow
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
                                return WoltModalType.dialog;
                              },
                            );
                          },
                          child: const Text("Add Account",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
                        child: Text(
                          "POWERED BY\nUNSPENDABLE LABS",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
                orElse: () => const Text(""),
              ),
            ),
          ),
        ],
      );
    } else {
      // Return blank text for narrower screens
      return const Text("");
    }
  }
}

class Shell extends StatelessWidget {
  const Shell(this.navigationShell, {super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    final backgroundColor = isDarkTheme ? lightNavyDarkTheme : greyLightTheme;
    final selectedColor =
        isDarkTheme ? blueDarkThemeGradiantColor : royalBlueLightTheme;
    final unselectedColor = isDarkTheme ? mainTextGrey : mainTextGrey;

    return Container(
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 0.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 926, maxHeight: 845),
            child: Scaffold(
              backgroundColor: noBackgroundColor,
              appBar: AppBar(
                backgroundColor: noBackgroundColor,
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            if (!isSmallScreen) const SizedBox(width: 12),
                            if (!isSmallScreen)
                              const Text('ALPHA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  )),
                            if (!isSmallScreen) const SizedBox(width: 12),
                            if (!isSmallScreen)
                              shell.state.maybeWhen(
                                success: (state) => state.addresses.length > 1
                                    ? Flexible(
                                        child: AddressDropdown(
                                          key:
                                              Key(state.currentAddress.address),
                                          isDarkTheme: isDarkTheme,
                                          addresses: state.addresses,
                                          currentAddress: state.currentAddress,
                                          onChange: shell.onAddressChanged,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                orElse: () => const SizedBox.shrink(),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                actions: [
                  const SizedBox(width: 8),
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
                                context
                                    .read<ThemeBloc>()
                                    .add(ThemeEvent.toggle);
                              }
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDarkTheme
                                    ? backgroundColor
                                    : selectedColor,
                              ),
                              child: Icon(
                                Icons.wb_sunny,
                                size: 20,
                                color: isDarkTheme
                                    ? unselectedColor
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              if (!isDarkTheme) {
                                context
                                    .read<ThemeBloc>()
                                    .add(ThemeEvent.toggle);
                              }
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDarkTheme
                                    ? selectedColor
                                    : backgroundColor,
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
                    create: (context) => LogoutBloc(
                      walletRepository: GetIt.I.get<WalletRepository>(),
                      accountRepository: GetIt.I.get<AccountRepository>(),
                      addressRepository: GetIt.I.get<AddressRepository>(),
                      cacheProvider: GetIt.I.get<CacheProvider>(),
                    ),
                    child: BlocConsumer<LogoutBloc, LogoutState>(
                      listener: (context, state) {
                        if (state.logoutState is LoggedOut) {
                          final shell = context.read<ShellStateCubit>();
                          shell.onOnboarding();
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
                            if (value == 'reset') {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return BlocProvider.value(
                                    value: BlocProvider.of<LogoutBloc>(context),
                                    child: HorizonDialog(
                                      title: 'Reset wallet',
                                      body: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              'This will result in deletion of all wallet data. To log back in, you will need to use your seed phrase.',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isDarkTheme
                                                    ? mainTextGrey
                                                    : mainTextBlack,
                                              ),
                                            ),
                                          ),
                                          BackContinueButtons(
                                            isDarkMode: isDarkTheme,
                                            isSmallScreenWidth: isSmallScreen,
                                            onPressedContinue: () {
                                              GoRouter.of(context).pop();
                                            },
                                            backButtonText: 'RESET WALLET',
                                            continueButtonText:
                                                'CANCEL', // The BackContinueButtons widget is the style/responiveness we want here, however we want the CANCEL button to be more prominent so that the user doesn't accidentally reset their wallet. In BackContinueButtons, the continue button is the one that is more prominent.
                                            onPressedBack: () {
                                              context
                                                  .read<LogoutBloc>()
                                                  .add(LogoutEvent());
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'reset',
                              child: Text('Reset wallet'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    if (isSmallScreen)
                      shell.state.maybeWhen(
                        success: (state) => state.addresses.length > 1
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: AddressDropdown(
                                  key: Key(state.currentAddress.address),
                                  isDarkTheme: isDarkTheme,
                                  addresses: state.addresses,
                                  currentAddress: state.currentAddress,
                                  onChange: shell.onAddressChanged,
                                ),
                              )
                            : const SizedBox.shrink(),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    Expanded(
                      child: Row(
                        children: [
                          const ResponsiveAccountSidebar(),
                          Expanded(
                            child: Scaffold(
                              backgroundColor: noBackgroundColor,
                              body: shell.state.when(
                                initial: () => const Text("Loading..."),
                                onboarding: (state) => const Text("onboarding"),
                                loading: () => const Text("Loading..."),
                                error: (state) => const Text("error"),
                                success: (state) {
                                  return Builder(
                                    builder: (context) => navigationShell,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (MediaQuery.of(context).size.width < 768.0)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
                        child: Text(
                          "POWERED BY\nUNSPENDABLE LABS",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
