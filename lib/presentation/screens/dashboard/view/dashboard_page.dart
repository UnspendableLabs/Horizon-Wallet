import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';

import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_event.dart';

import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';

import 'package:horizon/domain/entities/address.dart';

import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>().state;

    return shell.when(
        initial: () => const Text("initial"),
        loading: () => const CircularProgressIndicator(),
        error: (error) => Text("Error: $error"),
        success: (data) => _DashboardPage(
            key: Key(data.currentAccountUuid),
            accountUuid: data.currentAccountUuid));
  }
}

class _DashboardPage extends StatefulWidget {
  final String accountUuid;

  const _DashboardPage({super.key, required this.accountUuid});

  @override
  _DashboardPage_State createState() => _DashboardPage_State();
}

class _DashboardPage_State extends State<_DashboardPage> {
  final accountSettingsRepository = GetIt.I.get<AccountSettingsRepository>();

  @override
  void initState() {
    super.initState();

    // context.read<AddressesBloc>().add(Generate(
    //       accountUuid: widget.accountUuid,
    //       gapLimit: accountSettingsRepository.getGapLimit(widget.accountUuid),
    //     ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressesBloc, AddressesState>(
        builder: (context, state) {
      return state.when(
        initial: () => const Text("initial"),
        loading: () => const CircularProgressIndicator(),
        error: (error) => Text("Error: $error"),
        success: (addresses) => Balances(
          key: Key(widget.accountUuid),
          addresses: addresses,
        ),
      );
    });
  }
}

class Balances extends StatefulWidget {
  final List<Address> addresses;

  const Balances({super.key, required this.addresses});

  @override
  _Balances_State createState() => _Balances_State();
}

class _Balances_State extends State<Balances> {
  final accountSettingsRepository = GetIt.I.get<AccountSettingsRepository>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalancesBloc, BalancesState>(
        bloc: BalancesBloc(
          balanceRepository: GetIt.I.get<BalanceRepository>(),
          ),
        // )..add(Fetch(addresses: widget.addresses)),
        builder: (context, state) {
          return state.when(
            initial: () => const Text("initial"),
            loading: () => const CircularProgressIndicator(),
            error: (error) => Text("Error: $error"),
            success: (balances) => ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: balances.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Text(balances[index].asset),
                    title: Center(
                        child: Text(balances[index].quantity.toString())),
                    onTap: () => print(index),
                  );
                }),
          );
        });
  }
}
