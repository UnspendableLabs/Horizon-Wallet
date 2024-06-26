// https://medium.com/@antonio.tioypedro1234/flutter-go-router-the-essential-guide-349ef39ec5b3

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

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

    return const Text('Account List View');
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
        success: (state) => DropdownMenu(
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
        orElse: () => Text(""));
  }
}

class Shell extends StatelessWidget {
  const Shell(this.navigationShell, {super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Row(
        children: <Widget>[
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
            ],
          ),

          const VerticalDivider(thickness: 1, width: 1),
          // SizedBox(
          //     width: 300,
          //     child: Column(children: <Widget>[
          //       const Expanded(child: AccountListView()),
          //       Padding(
          //         padding: const EdgeInsets.all(12),
          //         child: FilledButton(
          //           child: const Text('Add Account'),
          //           onPressed: () => print('Add Account'),
          //         ),
          //       )
          //     ])),
          // const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.

          Expanded(
              child: Scaffold(
            appBar: AppBar(
              title: const AccountDropdownButton(),
            ),
            body: navigationShell,
          ))
        ],
      )),
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
