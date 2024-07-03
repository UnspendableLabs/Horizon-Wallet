// https://medium.com/@antonio.tioypedro1234/flutter-go-router-the-essential-guide-349ef39ec5b3
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_event.dart';
import 'package:horizon/presentation/shell/account_form/view/account_form.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
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
  State<ResponsiveAccountSidebar> createState() => _ResponsiveAccountSidebarState();
}

class _ResponsiveAccountSidebarState extends State<ResponsiveAccountSidebar> {
  final TextEditingController accountController = TextEditingController();
  Account? selectedAccount;

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Define background colors based on theme
    final backgroundColor = isDarkTheme ? const Color.fromRGBO(25, 25, 39, 1) : Colors.white;

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
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: shell.state.maybeWhen(
                success: (state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start, // Adjusted alignment
                    children: [
                      ListView.builder(
                        shrinkWrap: true, // Ensures the ListView takes only the necessary space
                        itemCount: state.accounts.length,
                        itemBuilder: (context, index) {
                          final account = state.accounts[index];
                          return Column(
                            children: [
                              ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.account_balance_wallet_rounded), // Added icon
                                      const SizedBox(width: 8.0), // Space between icon and text
                                      Text(account.name),
                                    ],
                                  ),
                                ),
                                hoverColor: Colors.transparent, // No hover effect
                                selected: account.uuid == state.currentAccountUuid,
                                onTap: () {
                                  setState(() => selectedAccount = account);
                                  context.read<ShellStateCubit>().onAccountChanged(account);
                                },
                              ),
                              if (index != state.accounts.length - 1) // Avoid underline for the last element
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Divider(
                                    color: Colors.grey.shade300, // Faint underline color
                                    thickness: 1.0,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero, // No rounded corners
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
                      const Spacer(), // Pushes the text to the bottom
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "POWERED BY UNSPENDABLE LABS",
                          style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
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
      // Dropdown menu for narrower screens
      return shell.state.maybeWhen(
          success: (state) {
            return Column(
              children: [
                Row(
                  children: [
                    DropdownMenu(
                        initialSelection: state.accounts.where((account) {
                          return account.uuid == state.currentAccountUuid;
                        }).first,
                        enableSearch: false,
                        controller: accountController,
                        requestFocusOnTap: true,
                        onSelected: (account) {
                          setState(() => selectedAccount = account);
                          context.read<ShellStateCubit>().onAccountChanged(account!);
                        },
                        dropdownMenuEntries: state.accounts.map((account) {
                          return DropdownMenuEntry(
                            value: account,
                            label: account.name,
                          );
                        }).toList()),
                    IconButton(
                        icon: const Icon(Icons.add),
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
                        })
                  ],
                ),
              ],
            );
          },
          orElse: () => const Text(""));
    }
  }
}

class Shell extends StatelessWidget {
  const Shell(this.navigationShell, {super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();

    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 768.0) {
              return const Align(
                alignment: Alignment.centerLeft,
                child: Text('Horizon', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              );
            } else {
              return const Center(child: Text('Horizon', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)));
            }
          },
        ),
      ),
      body: SafeArea(
        child: Row(children: <Widget>[
          /**
           *           NavigationRail(
            onDestinationSelected: _onDestinationSelected,
            selectedIndex: navigationShell.currentIndex,
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.send),
                selectedIcon: Icon(Icons.send),
                label: Text('Send'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.toll),
                selectedIcon: Icon(Icons.toll),
                label: Text('Issuance'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),

           */
          const ResponsiveAccountSidebar(),
          // const VerticalDivider(thickness: 1, width: 1),
          Expanded(
              child: Scaffold(
                  body: shell.state.when(
            initial: () => const Text("loading..."),
            loading: () => const Text("loading..."),
            error: (e) => const Text("error"),
            success: (shell) {
              return BlocProvider<AddressesBloc>(
                  key: Key(shell.currentAccountUuid),
                  child: navigationShell,
                  create: (_) => AddressesBloc(
                        walletRepository: GetIt.I<WalletRepository>(),
                        accountRepository: GetIt.I<AccountRepository>(),
                        addressService: GetIt.I<AddressService>(),
                        addressRepository: GetIt.I<AddressRepository>(),
                        encryptionService: GetIt.I<EncryptionService>(),
                      )..add(GetAll(accountUuid: shell.currentAccountUuid)));
            },
          )))
        ]),
      ),
    );
  }

  void _onDestinationSelected(index) {
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
