// https://medium.com/@antonio.tioypedro1234/flutter-go-router-the-essential-guide-349ef39ec5b3
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/shell/account_form/view/account_form.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/shell/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/shell/theme/bloc/theme_event.dart';
import 'package:horizon/presentation/shell/view/address_dropdown.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'package:horizon/presentation/screens/settings/bloc/logout_bloc.dart';
import 'package:horizon/presentation/screens/settings/bloc/logout_event.dart';
import 'package:horizon/presentation/screens/settings/bloc/logout_state.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class AccountListView extends StatelessWidget {
  const AccountListView({super.key});
  @override
  Widget build(BuildContext context) {
    final shell = context.read<ShellStateCubit>();

    return shell.state.maybeWhen(
        success: (state) => ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: state.accounts.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Center(child: Text(state.accounts[index].name)),
                  onTap: () => print(index),
                );
              },
            ),
        orElse: () => const Text(""));
  }
}

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
    final backgroundColor =
        isDarkTheme ? const Color.fromRGBO(25, 25, 39, 1) : Colors.white;

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
                                                fontWeight: FontWeight.w500,
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
                          child: const Text("Add Account"),
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
    final unselectedColor = isDarkTheme ? mainTextGrey : Colors.grey;

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
          padding: const EdgeInsets.only(top: 20.0, bottom: 40.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 926),
            child: Scaffold(
              backgroundColor: noBackgroundColor,
              appBar: AppBar(
                backgroundColor: noBackgroundColor,
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        isDarkTheme
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
                        const SizedBox(width: 8),
                        const Text('Horizon',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(width: 8),
                        const Text('Wallet',
                            style: TextStyle(
                              color: neonBlueDarkTheme,
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(width: 12),
                        const Text('ALPHA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    );
                  },
                ),
                actions: [
                  shell.state.maybeWhen(
                    success: (state) => state.addresses.length > 1
                        ? AddressDropdown(
                            key: Key(state.currentAddress.address),
                            isDarkTheme: isDarkTheme,
                            addresses: state.addresses,
                            currentAddress: state.currentAddress,
                            onChange: shell.onAddressChanged,
                          )
                        : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  ),
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
                      builder: (context, state) => SizedBox(
                        height: 40,
                        child: FilledButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return BlocProvider.value(
                                  value: BlocProvider.of<LogoutBloc>(context),
                                  child: AlertDialog(
                                    title: const Text('Confirm Logout'),
                                    content: Text(
                                      'This will result in deletion of all wallet data. To log back in, you will need to use your seed phrase.',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          GoRouter.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<LogoutBloc>()
                                              .add(LogoutEvent());
                                        },
                                        child: const Text('Logout'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text('Logout'),
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
