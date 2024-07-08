import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_bloc.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class ComposeSendPage extends StatelessWidget {
  ComposeSendPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => ComposeSendBloc()..add(FetchFormData(accountUuid: state.currentAccountUuid)),
        child: _ComposeSendPage_(),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ComposeSendPage_ extends StatefulWidget {
  _ComposeSendPage_({
    Key? key,
  }) : super(key: key);

  @override
  _ComposeSendPageState createState() => _ComposeSendPageState();
}

class _ComposeSendPageState extends State<_ComposeSendPage_> {
  final balanceRepository = GetIt.I.get<BalanceRepository>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController destinationAddressController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController assetController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? asset = null;
  String? fromAddress = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text('Compose Send', style: TextStyle(fontSize: 20.0)),
      ),
      body: BlocConsumer<ComposeSendBloc, ComposeSendState>(listener: (context, state) {
        state.submitState.when(
          success: (transactionHex, sourceAddress) =>
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(transactionHex))),
          error: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
          loading: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Loading"))),
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
                return Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        DropdownMenu<String>(
                            expandedInsets: const EdgeInsets.all(0),
                            initialSelection: fromAddress ?? addresses[0].address,
                            controller: fromAddressController,
                            requestFocusOnTap: true,
                            label: const Text('Address'),
                            onSelected: (String? a) {
                              setState(() {
                                fromAddress = a!;
                              });
                              // fromAddressController.text = a!;
                              context.read<ComposeSendBloc>().add(FetchBalances(address: a!));
                            },
                            dropdownMenuEntries: addresses.map<DropdownMenuEntry<String>>((address) {
                              return DropdownMenuEntry<String>(
                                value: address.address,
                                label: address.address,
                              );
                            }).toList()),

                        const SizedBox(height: 16.0), // Spacing between inputs
                        TextFormField(
                          controller: destinationAddressController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Destination",
                              floatingLabelBehavior: FloatingLabelBehavior.always),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a destination address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0), // Spacing between inputs
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: quantityController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Quantity',
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a quantity';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16.0), // Spacing between inputs
                            Expanded(
                              child: Builder(builder: (context) {
                                if (balances.isEmpty) {
                                  return DropdownMenu(
                                      expandedInsets: const EdgeInsets.all(0),
                                      inputDecorationTheme: const InputDecorationTheme(
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      initialSelection: "None",
                                      enabled: false,
                                      label: const Text('Asset'),
                                      dropdownMenuEntries:
                                          [const DropdownMenuEntry<String>(value: "None", label: "None")].toList());
                                }

                                return DropdownMenu<String>(
                                    expandedInsets: const EdgeInsets.all(0),
                                    controller: assetController,
                                    inputDecorationTheme: const InputDecorationTheme(
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    initialSelection: balances[0].asset,
                                    requestFocusOnTap: true,
                                    label: const Text('Asset'),
                                    onSelected: (String? value) {
                                      setState(() {
                                        asset = value;
                                      });
                                    },
                                    dropdownMenuEntries: balances.map<DropdownMenuEntry<String>>((balance) {
                                      return DropdownMenuEntry<String>(
                                        value: balance.asset,
                                        label: balance.asset,
                                        trailingIcon: Text(balance.quantity.toString()),
                                      );
                                    }).toList());
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0), // Spacing between inputs
                        TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Password",
                              floatingLabelBehavior: FloatingLabelBehavior.always),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length != 32) {
                              return 'Password must be 32 chars';
                            }
                            return null;
                          },
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                context.read<ComposeSendBloc>().add(SendTransactionEvent(
                                      sourceAddress: fromAddressController.text,
                                      password: passwordController.text,
                                      destinationAddress: destinationAddressController.text,
                                      asset: assetController.text,
                                      quantity: double.parse(quantityController.text),
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
