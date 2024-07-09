import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';
import 'package:horizon/presentation/screens/compose_issuance/view/compose_issuance_page.dart';
import 'package:horizon/presentation/screens/compose_send/view/compose_send_page.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

import '../../../../domain/entities/balance.dart';

String balancesStateToString(BalancesState state) {
  return state.when(
    initial: () => 'Initial',
    loading: () => 'Loading',
    complete: (result) => 'Complete: ${resultToString(result)}',
    reloading: (result) => 'Reloading: ${resultToString(result)}',
  );
}

String resultToString(Result result) {
  return result.when(
    ok: (balances, aggregated) {
      var assetSummaries = aggregated.entries.map((entry) => '${entry.key}: ${entry.value.toStringAsFixed(2)}').join(', ');

      return 'OK (${balances.length} balances, $assetSummaries)';
    },
    error: (error) => 'Error: $error',
  );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>().state;

    // we should only ever get to this page if shell is success

    return shell.when(
        initial: () => const Text("initial"),
        onboarding: (_) => const Text("onboarding"),
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
                BalancesDisplay(
                  isDarkTheme: isDarkTheme,
                ),
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
                    elevation: 0,
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
                                padding: const EdgeInsets.all(16.0),
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
                    elevation: 0,
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
                                padding: const EdgeInsets.all(16.0),
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

class BalancesDisplay extends StatelessWidget {
  final bool isDarkTheme;
  BalancesDisplay({
    Key? key,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) =>
            BalancesBloc(accountUuid: state.currentAccountUuid)..add(Start(pollingInterval: const Duration(seconds: 60))),
        child: Balances(isDarkTheme: isDarkTheme),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class Balances extends StatefulWidget {
  final bool isDarkTheme;
  const Balances({super.key, required this.isDarkTheme});

  @override
  State<Balances> createState() => _BalancesState();
}

class _BalancesState extends State<Balances> {
  bool _isExpanded = false;

  // TODO: handle dispose, send Stop to balances bloc

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalancesBloc, BalancesState>(builder: (context, state) {
      // final dummyBalances = [
      //   Balance(address: 'address1', quantity: 100.0, asset: 'Asset1'),
      //   Balance(address: 'address2', quantity: 200.0, asset: 'Asset2'),
      //   Balance(address: 'address3', quantity: 300.0, asset: 'Asset3'),
      //   Balance(address: 'address3', quantity: 300.0, asset: 'Asset3'),
      //   Balance(address: 'address3', quantity: 300.0, asset: 'Asset4'),
      //   Balance(address: 'address3', quantity: 500.0, asset: 'Asset5'),
      //   Balance(address: 'address3', quantity: 300.0, asset: 'Asset6'),
      //   Balance(address: 'address3', quantity: 300.0, asset: 'Asset7'),
      //   Balance(address: 'address3', quantity: 300.0, asset: 'Asset8'),
      //   Balance(address: 'address3', quantity: 300.0, asset: 'Asset9'),
      //   Balance(address: 'address3', quantity: 300.0, asset: 'Asset10'),
      // ];

      // final dummyAggregated = {
      //   'Asset1': 100.0,
      //   'Asset2': 200.0,
      //   'Asset3': 300.0,
      //   'Asset4': 300.0,
      //   'Asset5': 500.0,
      //   'Asset6': 300.0,
      //   'Asset7': 300.0,
      //   'Asset8': 300.0,
      //   'Asset9': 300.0,
      //   'Asset10': 300.0,
      // };

      // final dummyResult = Result.ok(dummyBalances, dummyAggregated);

      double height = MediaQuery.of(context).size.height * 0.75;
      return state.when(
        initial: () => const Text(""),
        loading: () => const CircularProgressIndicator(),
        complete: (result) => _resultToBalanceList(result, height, widget.isDarkTheme),
        reloading: (result) => _resultToBalanceList(result, height, widget.isDarkTheme),
      );
    });
  }

  Widget _resultToBalanceList(Result result, double height, bool isDarkTheme) {
    Color backgroundColor = isDarkTheme ? const Color.fromRGBO(35, 35, 58, 1) : const Color.fromRGBO(246, 247, 250, 1);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Account Balances',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: _balanceList(result)),
            if (_isExpanded)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = false;
                        });
                      },
                      child: const Text("Collapse"),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _balanceList(Result result) {
    return result.when(
      ok: (balances, aggregated) {
        final balanceWidgets = aggregated.entries.map((entry) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${entry.key}: ${entry.value.toStringAsFixed(2)}'),
                    const Text("\$ dollar placeholder"),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Divider(),
              ),
            ],
          );
        }).toList();

        if (balanceWidgets.length > 6 && !_isExpanded) {
          return Column(
            children: [
              ...balanceWidgets.take(6),
              FractionallySizedBox(
                widthFactor: 0.5,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = true;
                    });
                  },
                  child: const Text("View All"),
                ),
              ),
            ],
          );
        } else {
          return ListView(
            children: balanceWidgets,
          );
        }
      },
      error: (error) => Text('Error: $error'),
    );
  }
}
