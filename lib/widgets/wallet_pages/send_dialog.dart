import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/transaction_bloc.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/widgets/common/common_dialog_shape.dart';

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
  String _destinationAddress = '';
  double _quantity = 0.0;
  AssetEnum _asset = AssetEnum.BTC;
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
            TransactionInitial() => Padding(
                padding: const EdgeInsets.all(15),
                child: Form(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: screenSize.width / 2,
                      child: TextFormField(
                        controller: _destinationAddressTextController,
                        decoration: const InputDecoration(hintText: "address"),
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
                            decoration: const InputDecoration(labelText: "Enter your number"),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            // inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                            controller: _quantityTextController,
                            onChanged: (value) {
                              setState(() {
                                _quantity = double.parse(value);
                              });
                            })),
                    DropdownButton<String>(
                        value: transactionState.sourceAddressOptions[0],
                        onChanged: (String? value) {
                          setState(() {
                            _sourceAddress = value!;
                          });
                        },
                        items: transactionState.sourceAddressOptions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                              child: Text(
                                value,
                              ),
                            ),
                          );
                        }).toList()),
                    DropdownButton<AssetEnum>(
                      value: _asset,
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
                        CupertinoButton(child: const Text('Send'), onPressed: () {}),
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
            TransactionLoading() => const Text('transaction loading...'),
            TransactionSuccess() => const Text('transaction success'),
            TransactionError() => Text('transaction error: ${transactionState.message}'),
          };
        }));

    // return BlocBuilder<TransactionBloc, TransactionState>(builder: (context, transactionState) {
    //   return switch (transactionState) {
    //     TransactionInitial() => Dialog(
    //         shape: getDialogShape(),
    //         child: Padding(
    //           padding: const EdgeInsets.all(15),
    //           child: Form(
    //               child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: <Widget>[
    //               const CommonBackButton(),
    //               SizedBox(
    //                 width: screenSize.width / 2,
    //                 child: TextFormField(
    //                   controller: _destinationAddressTextController,
    //                   decoration: const InputDecoration(hintText: "address"),
    //                   validator: (value) {
    //                     if (value == null || value.isEmpty) {
    //                       return 'Please enter some text';
    //                     }
    //                     return null;
    //                   },
    //                   onChanged: (value) {
    //                     setState(() {
    //                       _destinationAddress = value;
    //                     });
    //                   },
    //                 ),
    //               ),
    //               SizedBox(
    //                   width: screenSize.width / 2,
    //                   child: TextField(
    //                       decoration: const InputDecoration(labelText: "Enter your number"),
    //                       keyboardType: const TextInputType.numberWithOptions(decimal: true),
    //                       // inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
    //                       controller: _quantityTextController,
    //                       onChanged: (value) {
    //                         setState(() {
    //                           _quantity = double.parse(value);
    //                         });
    //                       })),
    //               DropdownButton<String>(
    //                   value: transactionState.sourceAddressOptions[0],
    //                   onChanged: (String? value) {
    //                     setState(() {
    //                       _sourceAddress = value!;
    //                     });
    //                   },
    //                   items: transactionState.sourceAddressOptions.map<DropdownMenuItem<String>>((String value) {
    //                     return DropdownMenuItem<String>(
    //                       value: value,
    //                       child: Center(
    //                         child: Text(
    //                           value,
    //                         ),
    //                       ),
    //                     );
    //                   }).toList()),
    //               DropdownButton<AssetEnum>(
    //                 value: _asset,
    //                 onChanged: (AssetEnum? value) {
    //                   setState(() {
    //                     _asset = value!;
    //                   });
    //                 },
    //                 items: assetList.map<DropdownMenuItem<AssetEnum>>((var value) {
    //                   return DropdownMenuItem<AssetEnum>(
    //                     value: value,
    //                     child: Center(
    //                       child: Text(
    //                         value.name,
    //                       ),
    //                     ),
    //                   );
    //                 }).toList(),
    //               ),
    //               Wrap(
    //                 children: <Widget>[
    //                   CupertinoButton(child: const Text('Send'), onPressed: () {}),
    //                   CupertinoButton(
    //                     child: const Text('Cancel'),
    //                     onPressed: () {
    //                       Navigator.pop(context);
    //                     },
    //                   ),
    //                 ],
    //               ),
    //             ],
    //           )),
    //         )),
    //     TransactionLoading() => const Text('transaction loading...'),
    //     TransactionSuccess() => const Text('transaction success'),
    //     TransactionError() => Text('transaction error: ${transactionState.message}'),
    //   };
    // });
    // });
  }
}
