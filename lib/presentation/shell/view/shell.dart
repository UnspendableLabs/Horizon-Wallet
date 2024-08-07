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
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/colors.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_event.dart';
import 'package:horizon/presentation/shell/account_form/view/account_form.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/shell/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/shell/theme/bloc/theme_event.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

const double _bottomPaddingForButton = 150.0;
const double _buttonHeight = 56.0;
const double _pagePadding = 16.0;

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

    SliverWoltModalSheetPage page1(
      BuildContext modalSheetContext,
      TextTheme textTheme,
    ) {
      return WoltModalSheetPage(
        isTopBarLayerAlwaysVisible: true,
        topBarTitle: Text('Add an account', style: textTheme.titleSmall),
        trailingNavBarWidget: IconButton(
          padding: const EdgeInsets.all(_pagePadding),
          icon: const Icon(Icons.close),
          onPressed: Navigator.of(modalSheetContext).pop,
        ),
        child: const Padding(
            padding: EdgeInsets.fromLTRB(
              _pagePadding,
              _pagePadding,
              _pagePadding,
              _bottomPaddingForButton,
            ),
            child: AddAccountForm()),
      );
    }

    if (screenWidth >= 768.0) {
      // Sidebar for wider screens
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 4, 16),
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
                                              style: TextStyle(
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
                                return [page1(modalSheetContext, textTheme)];
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

  SliverWoltModalSheetPage page1(
    BuildContext modalSheetContext,
    TextTheme textTheme,
  ) {
    return WoltModalSheetPage(
      isTopBarLayerAlwaysVisible: true,
      topBarTitle: Text('Add an account', style: textTheme.titleSmall),
      trailingNavBarWidget: IconButton(
        padding: const EdgeInsets.all(_pagePadding),
        icon: const Icon(Icons.close),
        onPressed: Navigator.of(modalSheetContext).pop,
      ),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(
            _pagePadding,
            _pagePadding,
            _pagePadding,
            _bottomPaddingForButton,
          ),
          child: AddAccountForm(modalSheetContext: modalSheetContext)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final shell = context.read<ShellStateCubit>();
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    void showAccountList(BuildContext context) {
      final textTheme = Theme.of(context).textTheme;

      WoltModalSheet.show<void>(
        context: context,
        pageListBuilder: (modalSheetContext) {
          return [
            shell.state.maybeWhen(
              success: (state) => WoltModalSheetPage(
                isTopBarLayerAlwaysVisible: true,
                topBarTitle:
                    Text('Select an account', style: textTheme.titleSmall),
                trailingNavBarWidget: IconButton(
                  padding: const EdgeInsets.all(_pagePadding),
                  icon: const Icon(Icons.close),
                  onPressed: Navigator.of(modalSheetContext).pop,
                ),
                child: SizedBox(
                  height: 400, // Set a fixed height for the ListView
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
                                return [page1(modalSheetContext, textTheme)];
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
                          },
                          child: const Text("Add Account"),
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

    final backgroundColor = isDarkTheme ? lightNavyDarkTheme : greyLightTheme;
    final selectedColor =
        isDarkTheme ? blueDarkThemeGradiantColor : royalBlueLightTheme;
    final unselectedColor = isDarkTheme ? greyDarkTheme : Colors.grey;

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
      child: Scaffold(
        backgroundColor: noBackgroundColor,
        appBar: AppBar(
          backgroundColor: noBackgroundColor,
          title: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: screenWidth > 768
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
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
                ],
              );
            },
          ),
          leading: screenWidth < 768.0
              ? IconButton(
                  icon: Icon(Icons.account_balance_wallet_rounded,
                      color: isDarkTheme
                          ? neonBlueDarkTheme
                          : royalBlueLightTheme),
                  onPressed: () => showAccountList(context),
                )
              : null,
          actions: [
            Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(
                    color: isDarkTheme ? darkNavyDarkTheme : Colors.grey[300]!),
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
                          context.read<ThemeBloc>().add(ThemeEvent.toggle);
                        }
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkTheme ? backgroundColor : selectedColor,
                        ),
                        child: Icon(
                          Icons.wb_sunny,
                          size: 20,
                          color: isDarkTheme ? unselectedColor : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        if (!isDarkTheme) {
                          context.read<ThemeBloc>().add(ThemeEvent.toggle);
                        }
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkTheme ? selectedColor : backgroundColor,
                        ),
                        child: Icon(
                          Icons.dark_mode,
                          size: 20,
                          color:
                              isDarkTheme ? neonBlueDarkTheme : unselectedColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkTheme ? darkNavyDarkTheme : lightBlueLightTheme,
              ),
              child: IconButton(
                icon: Icon(Icons.settings,
                    size: 15,
                    color: isDarkTheme ? Colors.grey : royalBlueLightTheme),
                onPressed: () {
                  context.go('/settings');
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Row(children: <Widget>[
            const ResponsiveAccountSidebar(),
            Expanded(
                child: Scaffold(
                    backgroundColor: noBackgroundColor,
                    body: shell.state.when(
                      initial: () => const Text(
                          "Loading..."), // TODO: all of this is smell.  should only handle success branch
                      onboarding: (_) => const Text("onboarding"),
                      loading: () => const Text("Loading..."),
                      error: (e) => const Text("error"),
                      success: (shell) {
                        return BlocProvider<AddressesBloc>(
                            key: Key(shell.currentAccountUuid),
                            child: navigationShell,
                            create: (_) => AddressesBloc(
                                  walletRepository: GetIt.I<WalletRepository>(),
                                  accountRepository:
                                      GetIt.I<AccountRepository>(),
                                  addressService: GetIt.I<AddressService>(),
                                  addressRepository:
                                      GetIt.I<AddressRepository>(),
                                  encryptionService:
                                      GetIt.I<EncryptionService>(),
                                )..add(GetAll(
                                    accountUuid: shell.currentAccountUuid)));
                      },
                    )))
          ]),
        ),
      ),
    );
  }

  void _onDestinationSelected(index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
