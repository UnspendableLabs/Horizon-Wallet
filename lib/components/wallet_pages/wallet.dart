import 'package:flutter/material.dart';
import 'package:uniparty/components/wallet_pages/wallet_container.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';

class Wallet extends StatefulWidget {
  final WalletRetrieveInfo payload;

  const Wallet({required this.payload, super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

const List<String> networkList = <String>[MAINNET, TESTNET];

class _WalletState extends State<Wallet> {
  String dropdownNetwork = networkList.first;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'UNIPARTY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              overflow: TextOverflow.visible,
            ),
          ),
          backgroundColor: Colors.black,
          leadingWidth: screenSize.width / 4,
          leading: DropdownButton(
            isExpanded: true,
            value: dropdownNetwork,
            underline: Container(),
            iconSize: 0.0,
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownNetwork = value!;
              });
            },
            items: networkList.map<DropdownMenuItem<String>>((var value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Center(
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        body: WalletContainer(payload: widget.payload, network: dropdownNetwork));
  }
}
