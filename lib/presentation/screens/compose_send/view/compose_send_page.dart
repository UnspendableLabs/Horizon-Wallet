import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:horizon/api/v2_api.dart" as v2_api;
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

  final client = v2_api.V2Api(Dio());
  Future<List<String>> _fetchAssets() async {
    final xcpBalances = await client.getBalancesByAddress(widget.initialAddress.address, true);
    final assets = xcpBalances.result!.map((e) => e.asset).toList();
    return assets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
                    Text('From Address: ${widget.initialAddress}'),
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
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return DropdownButtonFormField<String>(
                            hint: Text('Select Asset'),
                            onChanged: (value) {
                              setState(() {
                                asset = value;
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
                        // if (_formKey.currentState!.validate()) {
                        context.read<ComposeSendBloc>().add(SendTransactionEvent(
                            sourceAddress: widget.initialAddress.address,
                            destinationAddress: destinationAddressController.text,
                            asset: 'XCP',
                            quantity: 10.0,
                            network: 'testnet'));
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
            return Text(state.message);
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