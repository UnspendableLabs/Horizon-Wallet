import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/deprecated/bloc/transaction_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/deprecated/models/send_transaction.dart';
import 'package:horizon/deprecated/widgets/common/common_dialog_shape.dart';
import 'package:horizon/deprecated/widgets/common/object_properties.dart' as object_properties;

class SendDialog extends StatefulWidget {
  final NetworkEnum network;
  const SendDialog({required this.network, super.key});

  @override
  State<SendDialog> createState() => _SendDialogState();
}

List<AssetEnum> assetList = <AssetEnum>[
  AssetEnum.BTC,
  AssetEnum.XCP,
];

class _SendDialogState extends State<SendDialog> {
  _SendDialogState();

  final _destinationAddressTextController = TextEditingController();
  final _quantityTextController = TextEditingController();

  // Variables to hold the values of the inputs
  String _destinationAddress = 'n2HcDKczzjsY4SfJ6tUtuBrkDfqjYVCoDw';
  double _quantity = 10.0;
  AssetEnum _asset = AssetEnum.XCP;
  String _sourceAddress = '';

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _destinationAddressTextController.dispose();
    _quantityTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<TransactionBloc>(context).add(InitializeTransactionEvent(network: widget.network));
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    // (BlocProvider.of<WalletBloc>(context).state as WalletSuccess).data.map((e) => sourceAddresses.add(e.address));

    return Dialog(
        shape: getDialogShape(),
        child: BlocBuilder<TransactionBloc, TransactionState>(builder: (context, transactionState) {
          return switch (transactionState) {
            InitializeTransactionLoading() => const Text('loading...'),
            TransactionInitial() => Padding(
                padding: const EdgeInsets.all(15),
                child: Form(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Wrap(
                      children: [
                        DropdownButtonFormField<String>(
                            value: transactionState.sourceAddressOptions[0],
                            decoration: const InputDecoration(labelText: "Source address"),
                            onChanged: (String? value) {
                              setState(() {
                                _sourceAddress = value!;
                              });
                            },
                            items: transactionState.sourceAddressOptions.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                ),
                              );
                            }).toList())
                      ],
                    ),
                    SizedBox(
                      width: screenSize.width / 2,
                      child: TextFormField(
                        controller: _destinationAddressTextController,
                        decoration: const InputDecoration(labelText: "Destination address"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _destinationAddress = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                        width: screenSize.width / 2,
                        child: TextField(
                            decoration: const InputDecoration(labelText: "Quantity"),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            controller: _quantityTextController,
                            onChanged: (value) {
                              setState(() {
                                _quantity = double.parse(value);
                              });
                            })),
                    DropdownButtonFormField<AssetEnum>(
                      value: _asset,
                      decoration: const InputDecoration(labelText: "Asset"),
                      onChanged: (AssetEnum? value) {
                        setState(() {
                          _asset = value!;
                        });
                      },
                      items: assetList.map<DropdownMenuItem<AssetEnum>>((var value) {
                        return DropdownMenuItem<AssetEnum>(
                          value: value,
                          child: Center(
                            child: Text(
                              value.name,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    Wrap(
                      children: <Widget>[
                        CupertinoButton(
                            child: const Text('Send'),
                            onPressed: () {
                              BlocProvider.of<TransactionBloc>(context).add(SendTransactionEvent(
                                  sendTransaction: SendTransaction(
                                      sourceAddress: _sourceAddress,
                                      destinationAddress: _destinationAddress,
                                      asset: _asset,
                                      quantity: _quantity),
                                  network: widget.network));
                            }),
                        CupertinoButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                )),
              ),
            SendTransactionLoading() => const Text('sending transaction...'),
            TransactionSuccess() => Column(children: [
                Text(transactionState.transactionHex),
                object_properties.renderObjectProperties(transactionState.info.toJson()),
                CupertinoButton(
                    child: const Text('Sign'),
                    onPressed: () {
                      BlocProvider.of<TransactionBloc>(context).add(SignTransactionEvent(
                          unsignedTransaction: transactionState.transactionHex, network: widget.network));
                    }),
              ]),
            TransactionSignSuccess() => Text(transactionState.signedTransaction),
            TransactionError() => Text('transaction error: ${transactionState.message}'),
          };
        }));
  }
}
