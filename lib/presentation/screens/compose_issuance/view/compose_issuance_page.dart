import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
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
                // TODO
                bool isNamedAssetEnabled = balances.isNotEmpty &&
                    balances.any((balance) =>
                        balance.asset == 'XCP' && balance.quantity >= 50000000);

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

                        const SizedBox(height: 16.0), // Spacing between inputs
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
                              return 'You must have at least 0.5 XCP to create a named asset';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0), // Spacing between inputs
                        Builder(builder: (context) {
                          return Row(
                            children: [
                              Checkbox(
                                mouseCursor: isNamedAssetEnabled
                                    ? SystemMouseCursors.basic
                                    : SystemMouseCursors.forbidden,
                                fillColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.disabled)) {
                                      return isNamedAssetEnabled
                                          ? Colors.transparent
                                          : Colors.grey;
                                    }
                                    return Colors.transparent;
                                  },
                                ),
                                value: isNamedAssetEnabled,
                                onChanged: isNamedAssetEnabled
                                    ? (bool? value) {
                                        setState(() {
                                          isNamedAssetEnabled = value ?? false;
                                        });
                                      }
                                    : null,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text('Named Asset'),
                              ),
                              !isNamedAssetEnabled
                                  ? Tooltip(
                                      message:
                                          'You must have at least 0.5 XCP to create a named asset. Your balance is: ${balances.isEmpty ? '0' : balances.where((balance) => balance.asset == 'XCP').first.quantity}', // TODO: format quantity
                                      child: const Icon(Icons.info),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          );
                        }),
                        const SizedBox(height: 16.0), // Spacing between inputs
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
                        const SizedBox(height: 16.0), // Spacing between inputs
                        TextFormField(
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
                                context
                                    .read<ComposeIssuanceBloc>()
                                    .add(CreateIssuanceEvent(
                                      sourceAddress: fromAddressController.text,
                                      password: passwordController.text,
                                      name: nameController.text,
                                      quantity:
                                          double.parse(quantityController.text),
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
