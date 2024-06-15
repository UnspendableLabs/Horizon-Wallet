import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import "package:horizon/data/sources/network/api/v2_api.dart" as v2_api;
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_bloc.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';

class ComposeSendPage extends StatelessWidget {
  final Address initialAddress;

  ComposeSendPage({Key? key, required this.initialAddress}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => ComposeSendBloc(),
        child: _ComposeSendPage_(
          initialAddress: initialAddress,
        ));
  }
}

class _ComposeSendPage_ extends StatefulWidget {
  final Address initialAddress;

  _ComposeSendPage_({Key? key, required this.initialAddress}) : super(key: key);

  @override
  _ComposeSendPageState createState() => _ComposeSendPageState();
}

class _ComposeSendPageState extends State<_ComposeSendPage_> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController destinationAddressController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  String? asset = null;

  Future<List<String>> _fetchAssets() async {
    final client = GetIt.I.get<v2_api.V2Api>();

    final xcpBalances = await client.getBalancesByAddress(widget.initialAddress.address, true);
    // final btcBalances = await blockCypher.fetchBalance(widget.initialAddress.address, NetworkEnum.mainnet);
    // final balances = xcpBalances.result! + btcBalances;
    final assets = xcpBalances.result!.map((e) => e.asset).toList();
    // return assets;
    return ['XCP', 'BTC'];
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
      body: BlocBuilder<ComposeSendBloc, ComposeSendState>(
        builder: (context, state) {
          if (state is ComposeSendInitial) {
            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SelectableText('From Address: ${widget.initialAddress.address}'),
                    TextFormField(
                      controller: destinationAddressController,
                      decoration: InputDecoration(labelText: 'Destination Address'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a destination address';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: quantityController,
                      decoration: InputDecoration(labelText: 'Quantity'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        return null;
                      },
                    ),
                    FutureBuilder<List<String>>(
                      future: _fetchAssets(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return SelectableText('Error: ${snapshot.error}');
                        } else {
                          return DropdownButtonFormField<String>(
                            value: asset,
                            hint: Text('Select Asset'),
                            onChanged: (value) {
                              setState(() {
                                asset = value!;
                              });
                            },
                            items: snapshot.data!.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            validator: (value) => value == null ? 'Please select an asset' : null,
                          );
                        }
                      },
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          context.read<ComposeSendBloc>().add(SendTransactionEvent(
                              sourceAddress: widget.initialAddress,
                              destinationAddress: destinationAddressController.text,
                              asset: asset!,
                              quantity: double.parse(quantityController.text),
                              network: 'testnet'));
                        }
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
      ),
    );
  }
}
