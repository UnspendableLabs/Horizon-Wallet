import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_bloc.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';

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
        create: (context) => ComposeSendBloc()
          ..add(FetchFormData(accountUuid: state.currentAccountUuid)),
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

class AssetDropdown extends StatefulWidget {
  final List<Balance> balances;
  final TextEditingController controller;
  final void Function(String?) onSelected;

  const AssetDropdown(
      {super.key,
      required this.balances,
      required this.controller,
      required this.onSelected});

  @override
  State<AssetDropdown> createState() => _AssetDropdownState();
}

class _AssetDropdownState extends State<AssetDropdown> {
  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.balances[0].asset;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
        expandedInsets: const EdgeInsets.all(0),
        controller: widget.controller,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        initialSelection: widget.balances[0].asset,
        requestFocusOnTap: true,
        label: const Text('Asset'),
        onSelected: widget.onSelected,
        dropdownMenuEntries:
            widget.balances.map<DropdownMenuEntry<String>>((balance) {
          return DropdownMenuEntry<String>(
              value: balance.asset,
              label: balance.asset,
              trailingIcon: Text(balance.quantityNormalized));
        }).toList());
  }
}

_getBalanceForSelectedAsset(List<Balance> balances, String asset) {
  if (balances.isEmpty) {
    return null;
  }

  return balances.firstWhereOrNull((balance) => balance.asset == asset) ??
      balances[0];
}

class _ComposeSendPageState extends State<_ComposeSendPage_> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController destinationAddressController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController assetController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? asset;
  String? fromAddress;

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
      body: BlocConsumer<ComposeSendBloc, ComposeSendState>(
          listener: (context, state) {
        state.submitState.when(
          success: (transactionHex, sourceAddress) =>
              ScaffoldMessenger.of(context)
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
              success: (balances_) {
                List<Balance> balances = balances_;
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
                              // fromAddressController.text = a!;
                              context
                                  .read<ComposeSendBloc>()
                                  .add(FetchBalances(address: a!));
                            },
                            dropdownMenuEntries: addresses
                                .map<DropdownMenuEntry<String>>((address) {
                              return DropdownMenuEntry<String>(
                                value: address.address,
                                label: address.address,
                              );
                            }).toList()),

                        const SizedBox(height: 16.0), // Spacing between inputs
                        TextFormField(
                          controller: destinationAddressController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Destination",
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always),
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
                              // TODO: make his type of input it's own component ( e.g. BalanceInput )
                              child: TextFormField(
                                controller: quantityController,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Quantity',
                                  suffix: Builder(
                                    builder: (context) {
                                      Balance? balance =
                                          _getBalanceForSelectedAsset(
                                              balances, assetController.text);

                                      if (balance == null) {
                                        return const SizedBox.shrink();
                                      }

                                      return Text(
                                          "${balance.quantityNormalized} max");
                                    },
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),

                                inputFormatters: <TextInputFormatter>[
                                  TextInputFormatter.withFunction(
                                      (oldValue, newValue) {
                                    if (newValue.text.isEmpty) {
                                      return newValue;
                                    }
                                    if (double.tryParse(newValue.text) !=
                                        null) {
                                      return newValue;
                                    }
                                    return oldValue;
                                  }),
                                  _getBalanceForSelectedAsset(balances,
                                                  assetController.text)
                                              ?.assetInfo
                                              .divisible ??
                                          false
                                      ? FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*$'))
                                      : FilteringTextInputFormatter.digitsOnly
                                ], // Only
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (value) {
                                  Balance? balance =
                                      _getBalanceForSelectedAsset(
                                          balances, assetController.text);

                                  if (balance == null) {
                                    throw Exception(
                                        "invariant: No balance found for asset");
                                  }

                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a quantity';
                                  }

                                  // this works because we still get normalised values
                                  // for non divisible assets
                                  Decimal input = Decimal.parse(value);
                                  Decimal max =
                                      Decimal.parse(balance.quantityNormalized);

                                  if (input > max) {
                                    return "quantity exceeds max";
                                  }

                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                                width: 16.0), // Spacing between inputs
                            Expanded(
                              child: Builder(builder: (context) {
                                if (balances.isEmpty) {
                                  return DropdownMenu(
                                      expandedInsets: const EdgeInsets.all(0),
                                      inputDecorationTheme:
                                          const InputDecorationTheme(
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                      ),
                                      initialSelection: "None",
                                      enabled: false,
                                      label: const Text('Asset'),
                                      dropdownMenuEntries: [
                                        const DropdownMenuEntry<String>(
                                            value: "None", label: "None")
                                      ].toList());
                                }

                                return AssetDropdown(
                                  balances: balances,
                                  controller: assetController,
                                  onSelected: (String? value) {
                                    setState(() {
                                      asset = value;
                                    });
                                  },
                                );

                                // return DropdownMenu<String>(
                                //     expandedInsets: const EdgeInsets.all(0),
                                //     controller: assetController,
                                //     inputDecorationTheme:
                                //         const InputDecorationTheme(
                                //       border: OutlineInputBorder(),
                                //       floatingLabelBehavior:
                                //           FloatingLabelBehavior.always,
                                //     ),
                                //     initialSelection: balances[0].asset,
                                //     requestFocusOnTap: true,
                                //     label: const Text('Asset'),
                                //     onSelected: (String? value) {
                                //       setState(() {
                                //         asset = value;
                                //       });
                                //     },
                                //     dropdownMenuEntries: balances
                                //         .map<DropdownMenuEntry<String>>(
                                //             (balance) {
                                //       return DropdownMenuEntry<String>(
                                //           value: balance.asset,
                                //           label: balance.asset,
                                //           trailingIcon:
                                //               Text(balance.quantityNormalized));
                                //     }).toList());
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0), // Spacing between inputs
                        TextFormField(
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          controller: passwordController,
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
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // TODO: wrap this in function and write some tests
                                Decimal input =
                                    Decimal.parse(quantityController.text);
                                Balance? balance = _getBalanceForSelectedAsset(
                                    balances, assetController.text);
                                int quantity;

                                if (balance == null) {
                                  throw Exception(
                                      "invariant: No balance found for asset");
                                }

                                if (balance.assetInfo.divisible) {
                                  quantity =
                                      (input * Decimal.fromInt(100000000))
                                          .toBigInt()
                                          .toInt();
                                } else {
                                  quantity = (input).toBigInt().toInt();
                                }

                                context.read<ComposeSendBloc>().add(
                                    SendTransactionEvent(
                                        sourceAddress:
                                            fromAddressController.text,
                                        password: passwordController.text,
                                        destinationAddress:
                                            destinationAddressController.text,
                                        asset: assetController.text,
                                        quantity: quantity));
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
