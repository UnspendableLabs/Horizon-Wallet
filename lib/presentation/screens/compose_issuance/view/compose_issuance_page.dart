import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_bloc.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class ComposeIssuancePage extends StatelessWidget {
  ComposeIssuancePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => ComposeIssuanceBloc()
          ..add(FetchFormData(accountUuid: state.currentAccountUuid)),
        child: _ComposeIssuancePage_(),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ComposeIssuancePage_ extends StatefulWidget {
  _ComposeIssuancePage_({
    Key? key,
  }) : super(key: key);

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

  bool isDivisible = false;
  bool isLocked = false;
  bool isReset = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text('Compose Issuance', style: TextStyle(fontSize: 20.0)),
      ),
      body: BlocConsumer<ComposeIssuanceBloc, ComposeIssuanceState>(
          listener: (context, state) {
        state.submitState.when(
          success: (transactionHex) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(transactionHex))),
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
                        DropdownMenu<String>(
                            expandedInsets: const EdgeInsets.all(0),
                            initialSelection:
                                fromAddress ?? addresses[0].address,
                            controller: fromAddressController,
                            requestFocusOnTap: true,
                            label: const Text('Address'),
                            onSelected: (String? a) {
                              setState(() {
                                fromAddress = a!;
                              });
                              context
                                  .read<ComposeIssuanceBloc>()
                                  .add(FetchBalances(address: a!));
                            },
                            dropdownMenuEntries: addresses
                                .map<DropdownMenuEntry<String>>((address) {
                              return DropdownMenuEntry<String>(
                                value: address.address,
                                label: address.address,
                              );
                            }).toList()),
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
                                      isDivisible = value ?? false;
                                    });
                                  },
                                ),
                                const Text('Divisible',
                                    style: TextStyle(color: Colors.black87)),
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
                                    style: TextStyle(color: Colors.black54),
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
                                    style: TextStyle(color: Colors.black87)),
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
                                    style: TextStyle(color: Colors.black54),
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
                                    style: TextStyle(color: Colors.black87)),
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
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
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
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
