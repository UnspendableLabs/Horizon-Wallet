// https://medium.com/@antonio.tioypedro1234/flutter-go-router-the-essential-guide-349ef39ec5b3
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

import 'package:horizon/presentation/shell/account_form/view/account_form.dart';
import 'package:horizon/presentation/shell/account_form/bloc/account_form_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_event.dart';

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
        orElse: () => Text(""));
  }
}

class AccountDropdownButton extends StatefulWidget {
  const AccountDropdownButton({super.key});
  @override
  State<AccountDropdownButton> createState() => AccountDropdownButtonState();
}

class AccountDropdownButtonState extends State<AccountDropdownButton> {
  final TextEditingController accountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();

    Account? selectedAccount;

    return shell.state.maybeWhen(
        success: (state) {
          return DropdownMenu(
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
              }).toList());
        },
        orElse: () => Text(""));
  }
}

class Shell extends StatelessWidget {
  const Shell(this.navigationShell, {super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();

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

    return Scaffold(
      body: SafeArea(
        child: Row(children: <Widget>[
          NavigationRail(
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
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
              child: Scaffold(
                  appBar: AppBar(
                    title: Row(children: [
                      const AccountDropdownButton(),
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
                                final size = MediaQuery.sizeOf(context).width;
                                if (size < 768.0) {
                                  return WoltModalType.bottomSheet;
                                } else {
                                  return WoltModalType.dialog;
                                }
                              },
                            );
                          })
                    ]),
                  ),
                  // don't render any route children until

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
                              )..add(GetAll(
                                  accountUuid: shell.currentAccountUuid)));
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
