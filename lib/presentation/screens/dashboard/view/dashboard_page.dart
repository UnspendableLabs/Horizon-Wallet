import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';
import 'package:horizon/presentation/screens/compose_issuance/view/compose_issuance_page.dart';
import 'package:horizon/presentation/screens/compose_send/view/compose_send_page.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_state.dart';
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
        success: (data) => _DashboardPage(key: Key(data.currentAccountUuid), accountUuid: data.currentAccountUuid));
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Define background colors based on theme
    Color backgroundColor = isDarkTheme ? const Color.fromRGBO(25, 25, 39, 1) : Colors.white;

    return BlocBuilder<AddressesBloc, AddressesState>(builder: (context, state) {
      return state.when(
        initial: () => const Text("initial"),
        loading: () => const CircularProgressIndicator(),
        error: (error) => Text("Error: $error"),
        success: (addresses) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 16),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Column(
              children: [
                AddressActions(
                  isDarkTheme: isDarkTheme,
                ),
                Balances(
                  key: Key(widget.accountUuid),
                  addresses: addresses,
                ),
                BlocProvider(
                  create: (context) => DashboardBloc(),
                  child: BlocBuilder<DashboardBloc, DashboardState>(
                    builder: (context, state) {
                      return FilledButton(
                          onPressed: () {
                            context.read<DashboardBloc>().add(DeleteWallet());
                          },
                          child: const Text("Delete DB"));
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}

class AddressActions extends StatelessWidget {
  final bool isDarkTheme;
  const AddressActions({super.key, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = isDarkTheme ? const Color.fromRGBO(35, 35, 58, 1) : const Color.fromRGBO(246, 247, 250, 1);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 4.0, 8.0),
              child: SizedBox(
                height: 75,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0), // Updated border radius
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.75, // 75% of the page width
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: ComposeIssuancePage(),
                              ),
                            ),
                          );
                        });
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8.0),
                      Text(
                        "ISSUE",
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 8.0, 8.0, 8.0),
              child: SizedBox(
                height: 75,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0), // Updated border radius
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.75, // 75% of the page width
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: ComposeSendPage(),
                              ),
                            ),
                          );
                        });
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send),
                      SizedBox(width: 8.0), // Space between icon and text
                      Text(
                        "SEND",
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ]);
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
            initial: () => const Text("Balances UI.  Blocked on weird API bug"),
            loading: () => const CircularProgressIndicator(),
            error: (error) => Text("Error: $error"),
            success: (balances) => ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: balances.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Text(balances[index].asset),
                    title: Center(child: Text(balances[index].quantity.toString())),
                    onTap: () => print(index),
                  );
                }),
          );
        });
  }
}
