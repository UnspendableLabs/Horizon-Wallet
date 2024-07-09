import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Define background colors based on theme
    Color backgroundColor =
        isDarkTheme ? const Color.fromRGBO(25, 25, 39, 1) : Colors.white;

    return BlocBuilder<AddressesBloc, AddressesState>(
        builder: (context, state) {
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
                // BlocProvider(
                //   create: (context) => DashboardBloc(),
                //   child: BlocBuilder<DashboardBloc, DashboardState>(
                //     builder: (context, state) {
                //       return FilledButton(
                //           onPressed: () {
                //             context.read<DashboardBloc>().add(DeleteWallet());
                //           },
                //           child: const Text("Delete DB"));
                //     },
                //   ),
                // )
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
    Color backgroundColor = isDarkTheme
        ? const Color.fromRGBO(35, 35, 58, 1)
        : const Color.fromRGBO(246, 247, 250, 1);

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
                              borderRadius: BorderRadius.circular(
                                  30.0), // Updated border radius
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width *
                                  0.75, // 75% of the page width
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
                              borderRadius: BorderRadius.circular(
                                  30.0), // Updated border radius
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width *
                                  0.75, // 75% of the page width
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
        create: (context) => BalancesBloc()
          ..add(FetchBalances(accountUuid: state.currentAccountUuid)),
        child: Balances(isDarkTheme: isDarkTheme),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class Balances extends StatelessWidget {
  final bool isDarkTheme;
  const Balances({super.key, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = isDarkTheme
        ? const Color.fromRGBO(35, 35, 58, 1)
        : const Color.fromRGBO(246, 247, 250, 1);

    return BlocBuilder<BalancesBloc, BalancesState>(builder: (context, state) {
      return state.when(
        initial: () => const Text(""),
        loading: () => const CircularProgressIndicator(),
        error: (error) => Text("Error: $error"),
        success: (addressInfo, currentAddressBalances) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SelectableText(
                          currentAddressBalances.address.address,
                          style: const TextStyle(
                              fontSize: 25), // Responsive font size
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text:
                                        currentAddressBalances.address.address))
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Address copied to clipboard!'),
                                ),
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.list),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: ListView.builder(
                                        itemCount: addressInfo.length,
                                        itemBuilder: (context, index) {
                                          final info = addressInfo[index];
                                          return TextButton(
                                            onPressed: () => {},
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size(50, 30),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  info.address.address,
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                if (info.balances.isEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0),
                                                    child: Container(
                                                      child: const Text(
                                                        "No balance",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  ...info.balances
                                                      .map((balance) => Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        8.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    '${balance.asset} ${balance.quantity.toString()}',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16)),
                                                                const Text(
                                                                    "\$ dollar value placeholder",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16)),
                                                              ],
                                                            ),
                                                          )),
                                                const Divider(),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: currentAddressBalances.balances.length,
                        itemBuilder: (context, index) {
                          final balance =
                              currentAddressBalances.balances[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.black, // Underline color
                                    width: 1.0, // Underline width
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        balance.asset,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16, // Responsive font size
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Text(
                                        balance.quantity.toString(),
                                        style: const TextStyle(
                                          fontSize: 16, // Responsive font size
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  const Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "\$ dollar value placeholder",
                                      style: TextStyle(
                                        fontSize: 16, // Responsive font size
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
