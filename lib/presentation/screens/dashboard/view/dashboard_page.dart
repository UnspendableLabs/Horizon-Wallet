import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_event.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';
import 'package:horizon/presentation/screens/compose_issuance/view/compose_issuance_page.dart';
import 'package:horizon/presentation/screens/compose_send/view/compose_send_page.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

    context.read<AddressesBloc>().add(GetAll(
          accountUuid: widget.accountUuid,
        ));
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
                BlocProvider(
                  create: (context) => BalancesBloc(accountUuid: widget.accountUuid),
                  child: BalancesDisplay(
                    isDarkTheme: isDarkTheme,
                    addresses: addresses,
                    accountUuid: widget.accountUuid,
                  ),
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

class BalancesDisplay extends StatefulWidget {
  final bool isDarkTheme;
  final List<Address> addresses;
  final String accountUuid;

  BalancesDisplay({Key? key, required this.isDarkTheme, required this.addresses, required this.accountUuid})
      : super(key: key);

  @override
  _BalancesDisplayState createState() => _BalancesDisplayState();
}

class _BalancesDisplayState extends State<BalancesDisplay> {
  late BalancesBloc _balancesBloc;

  @override
  void initState() {
    super.initState();
    _balancesBloc = context.read<BalancesBloc>();

    _balancesBloc.add(Start(pollingInterval: const Duration(seconds: 60)));
  }

  @override
  Widget build(BuildContext context) {
    return Balances(
        key: Key(widget.accountUuid),
        isDarkTheme: widget.isDarkTheme,
        addresses: widget.addresses,
        accountUuid: widget.accountUuid);
  }
}

class Balances extends StatefulWidget {
  final bool isDarkTheme;
  final List<Address> addresses;
  final String accountUuid;

  const Balances({super.key, required this.isDarkTheme, required this.addresses, required this.accountUuid});

  @override
  State<Balances> createState() => _BalancesState();
}

class _BalancesState extends State<Balances> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalancesBloc, BalancesState>(builder: (context, state) {
      double height = MediaQuery.of(context).size.height * 0.75;
      return state.when(
        initial: () => const Text(""),
        loading: () => const CircularProgressIndicator(),
        complete: (result) => _resultToBalanceList(result, height, widget.isDarkTheme, widget.addresses),
        reloading: (result) => _resultToBalanceList(result, height, widget.isDarkTheme, widget.addresses),
      );
    });
  }

  Widget _resultToBalanceList(Result result, double height, bool isDarkTheme, List<Address> addresses) {
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Account Balances',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: QRCodeDialog(key: Key(widget.accountUuid), addresses: addresses),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
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
        if (balances.isEmpty) {
          return const Center(child: Text("No balance"));
        }

        final balanceWidgets = aggregated.entries.map((entry) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${entry.key} ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: entry.value.toStringAsFixed(8),
                          ),
                        ],
                      ),
                    ),
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

class QRCodeDialog extends StatefulWidget {
  final List<Address> addresses;

  const QRCodeDialog({super.key, required this.addresses});

  @override
  _QRCodeDialogState createState() => _QRCodeDialogState();
}

class _QRCodeDialogState extends State<QRCodeDialog> {
  late String _selectedAddress;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.addresses.first.address;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Receive',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        QrImageView(
          data: _selectedAddress,
          version: QrVersions.auto,
          size: 200.0,
        ),
        const SizedBox(height: 16.0),
        LayoutBuilder(
          builder: (context, constraints) {
            double fontSize = constraints.maxWidth * 0.04;

            return Row(
              children: [
                if (widget.addresses.length > 1)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedAddress,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedAddress = newValue!;
                          });
                        },
                        items: widget.addresses.map<DropdownMenuItem<String>>((Address address) {
                          return DropdownMenuItem<String>(
                            value: address.address,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                address.address,
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SelectableText(
                        _selectedAddress,
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _selectedAddress));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address copied to clipboard')),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
