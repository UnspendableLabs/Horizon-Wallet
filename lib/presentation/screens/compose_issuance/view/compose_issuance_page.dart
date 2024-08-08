import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_bloc.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";
import 'package:horizon/presentation/screens/shared/view/horizon_dialog.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_dropdown_menu.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class ComposeIssuancePage extends StatelessWidget {
  final bool isDarkMode;
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;

  const ComposeIssuancePage({
    required this.isDarkMode,
    required this.dashboardActivityFeedBloc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => ComposeIssuanceBloc()
          ..add(FetchFormData(accountUuid: state.currentAccountUuid)),
        child: _ComposeIssuancePage_(
          isDarkMode: isDarkMode,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ComposeIssuancePage_ extends StatefulWidget {
  final bool isDarkMode;
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  const _ComposeIssuancePage_(
      {required this.isDarkMode, required this.dashboardActivityFeedBloc});

  @override
  _ComposeIssuancePageState createState() => _ComposeIssuancePageState();
}

class _ComposeIssuancePageState extends State<_ComposeIssuancePage_> {
  final balanceRepository = GetIt.I.get<BalanceRepository>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController assetController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String? asset;
  String? fromAddress;

  bool isDivisible = true;
  bool isLocked = false;
  bool isReset = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeIssuanceBloc, ComposeIssuanceState>(
        listener: (context, state) {
      state.submitState.when(
        success: (txHash) {
          // 0) reload activity feed
          widget.dashboardActivityFeedBloc
              .add(const Load()); // show "N more transactions".

          // 1) close modal
          Navigator.of(context).pop();
          // 2) show snackbar with copy tx action
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: txHash));
                },
              ),
              content: Text(txHash),
              behavior: SnackBarBehavior.floating));
          widget.dashboardActivityFeedBloc
              .add(const Load()); // show "N more transactions".
        },
        error: (msg) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg))),
        loading: () => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Loading"))),
        initial: () => const Text(''),
      );
    }, builder: (context, state) {
      return state.addressesState.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const SizedBox.shrink(),
        error: (e) => Text(e),
        success: (addresses) {
          return state.balancesState.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (e) => Text(e),
            success: (balances) {
              bool hasXCPBalance = balances.isNotEmpty &&
                  balances.any((balance) => balance.asset == 'XCP');
              Balance? xcpBalance = hasXCPBalance
                  ? balances.firstWhere((element) => element.asset == 'XCP')
                  : null;
              bool isNamedAssetEnabled =
                  xcpBalance != null && xcpBalance.quantity >= 50000000;
              String quantity =
                  xcpBalance != null ? xcpBalance.quantityNormalized : '0';

              return Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      HorizonDropdownMenu(
                        isDarkMode: widget.isDarkMode,
                        onChanged: (String? newValue) {
                          setState(() {
                            fromAddress = newValue;
                          });
                        },
                        items:
                            addresses.map<DropdownMenuEntry<String>>((address) {
                          return buildDropdownMenuItem(
                              address.address, address.address);
                        }).toList(),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Token name",
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name for your asset';
                          }
                          if (!isNamedAssetEnabled &&
                              !RegExp(r'^A\d+$').hasMatch(value)) {
                            return 'You must have at least 0.5 XCP to create a named asset. Your balance is: $quantity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Quantity',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a quantity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Description',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Password",
                            floatingLabelBehavior:
                                FloatingLabelBehavior.always),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isDivisible,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isDivisible = value ?? true;
                                  });
                                },
                              ),
                              const Text('Divisible',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Row(
                            children: [
                              SizedBox(
                                  width:
                                      30.0), // Width of the checkbox and some padding
                              Expanded(
                                child: Text(
                                  'Whether this asset is divisible or not. Defaults to true.',
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: isLocked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isLocked = value ?? false;
                                  });
                                },
                              ),
                              const Text('Lock',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Row(
                            children: [
                              SizedBox(
                                  width:
                                      30.0), // Width of the checkbox and some padding
                              Expanded(
                                child: Text(
                                  'Whether this issuance should lock supply of this asset forever. Defaults to false.',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16.0),
                          Row(
                            children: [
                              Checkbox(
                                value: isReset,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isReset = value ?? false;
                                  });
                                },
                              ),
                              const Text('Reset',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Row(
                            children: [
                              SizedBox(
                                  width:
                                      30.0), // Width of the checkbox and some padding
                              Expanded(
                                child: Text(
                                  'Wether this issuance should reset any existing supply. Defaults to false.',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      HorizonDialogSubmitButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            context
                                .read<ComposeIssuanceBloc>()
                                .add(CreateIssuanceEvent(
                                  sourceAddress: fromAddressController.text,
                                  password: passwordController.text,
                                  name: nameController.text,
                                  quantity:
                                      double.parse(quantityController.text),
                                  description: descriptionController.text,
                                  divisible: isDivisible,
                                  lock: isLocked,
                                  reset: isReset,
                                ));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }
}
