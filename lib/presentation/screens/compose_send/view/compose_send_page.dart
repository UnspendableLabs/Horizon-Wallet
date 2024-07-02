import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import "package:horizon/data/sources/network/api/v2_api.dart" as v2_api;
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';

import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_bloc.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';

class ComposeSendPage extends StatelessWidget {
  ComposeSendPage({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => ComposeSendBloc(), child: _ComposeSendPage_());
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

  String? asset = null;
  String? fromAddress = null;

  Future<List<Balance>> _fetchAssets() async {
    if (fromAddress == null) {
      return [];
    }

    return await balanceRepository.getBalance(fromAddress!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: Text('Compose Send'),
      ),
      body:
          BlocBuilder<AddressesBloc, AddressesState>(builder: (context, state) {
        return state.when(
            initial: () => SizedBox.shrink(),
            loading: () => SizedBox.shrink(),
            error: (e) => Text(e),
            success: (addresses) {
              return BlocBuilder<ComposeSendBloc, ComposeSendState>(
                builder: (context, state) {
                  if (state is ComposeSendInitial) {
                    return Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // SelectableText(
                            //     'From Address: ${widget.initialAddress.address}'),

                            DropdownMenu(
                                initialSelection: addresses[0],
                                controller: fromAddressController,
                                requestFocusOnTap: true,
                                label: const Text('Address'),
                                onSelected: (Address? a) {
                                  setState(() {
                                    fromAddress = a!.address;
                                  });
                                },
                                dropdownMenuEntries: addresses.map((address) {
                                  return DropdownMenuEntry<Address>(
                                    value: address,
                                    label: address.address,
                                  );
                                }).toList()),

                            const SizedBox(
                                height: 16.0), // Spacing between inputs
                            TextFormField(
                              controller: destinationAddressController,
                              decoration: const InputDecoration(
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
                            const SizedBox(
                                height: 16.0), // Spacing between inputs
                            TextFormField(
                              controller: quantityController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Quantity',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a quantity';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(
                                height: 16.0), // Spacing between inputs
                            FutureBuilder<List<Balance>>(
                              future: _fetchAssets(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return SelectableText(
                                      'Error: ${snapshot.error}');
                                } else {
                                  if (snapshot.data!.isEmpty) {
                                    return const DropdownMenu(
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                          border: OutlineInputBorder(),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                        ),
                                        initialSelection: "None",
                                        enabled: false,
                                        label: Text('Asset'),
                                        dropdownMenuEntries: [
                                          DropdownMenuEntry<String>(
                                              value: "None", label: "None")
                                        ]);
                                  }

                                  return DropdownMenu(
                                      inputDecorationTheme:
                                          InputDecorationTheme(
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                      ),
                                      initialSelection: snapshot.data![0],
                                      controller: fromAddressController,
                                      requestFocusOnTap: true,
                                      label: const Text('Asset'),
                                      onSelected: (Balance? a) {
                                        setState(() {
                                          asset = a!.asset;
                                        });
                                      },
                                      dropdownMenuEntries:
                                          snapshot.data!.map((balance) {
                                        return DropdownMenuEntry<Balance>(
                                          value: balance,
                                          label: balance.quantity.toString(),
                                          trailingIcon: Text(balance.asset),
                                        );
                                      }).toList());
                                  //
                                  // return DropdownButtonFormField<String>(
                                  //   value: asset,
                                  //   hint: Text('Select Asset'),
                                  //   onChanged: (value) {
                                  //     setState(() {
                                  //       asset = value!;
                                  //     });
                                  //   },
                                  //   items: snapshot.data!
                                  //       .map<DropdownMenuItem<String>>(
                                  //           (String value) {
                                  //     return DropdownMenuItem<String>(
                                  //       value: value,
                                  //       child: Text(value),
                                  //     );
                                  //   }).toList(),
                                  //   validator: (value) => value == null
                                  //       ? 'Please select an asset'
                                  //       : null,
                                  // );
                                }
                              },
                            ),
                            Spacer(),
                            ElevatedButton(
                              onPressed: () async {
                                // if (_formKey.currentState!.validate()) {
                                //   context.read<ComposeSendBloc>().add(
                                //       SendTransactionEvent(
                                //           sourceAddress: widget.initialAddress,
                                //           password: '', // TODO!
                                //           destinationAddress:
                                //               destinationAddressController.text,
                                //           asset: asset!,
                                //           quantity:
                                //               double.parse(quantityController.text),
                                //           network: 'testnet'));
                                // }
                              },
                              child: Text('Submit'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (state is ComposeSendLoading) {
                    return const CircularProgressIndicator();
                  }
                  if (state is ComposeSendError) {
                    return SelectableText(state.message);
                  }
                  if (state is ComposeSendSuccess) {
                    return Text(state.transactionHex);
                  }
                  if (state is ComposeSendSignSuccess) {
                    return Text(state.signedTransaction);
                  }
                  return Text("");
                },
              );
            });
      }),
    );
  }
}
