import 'package:flutter/material.dart';
import 'package:uniparty/components/wallet_pages/wallet_container.dart';
import 'package:uniparty/models/constants.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

const List<String> networkList = <String>[MAINNET, TESTNET];

class _WalletState extends State<Wallet> {
  String dropdownNetwork = networkList.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'UNIPARTY',
            style: TextStyle(color: Colors.white, fontSize: 40, overflow: TextOverflow.visible),
          ),
          backgroundColor: Colors.black,
          actions: [
            DropdownButton<String>(
              value: dropdownNetwork,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Color.fromRGBO(159, 194, 244, 1.0)),
              underline: Container(
                height: 2,
                color: const Color.fromRGBO(159, 194, 244, 1.0),
              ),
              onChanged: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  dropdownNetwork = value!;
                });
              },
              items: networkList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            )
          ],
        ),
        body: WalletContainer(network: dropdownNetwork));
  }
}
