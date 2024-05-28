import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_state.dart';
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';

class AddressDisplay extends StatefulWidget {
  const AddressDisplay({super.key});

  @override
  _AddressDisplayState createState() => _AddressDisplayState();
}

class _AddressDisplayState extends State<AddressDisplay> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<DashboardBloc>(context).add(GetAddresses());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(builder: (context, state) {
      double screenWidth = MediaQuery.of(context).size.width;

      return state.addressState is AddressStateSuccess
          ? Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 80),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.addressState.currentAddress.address,
                              style: const TextStyle(fontSize: 20), textAlign: TextAlign.center),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: state.addressState.currentAddress.address));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Address copied to clipboard!'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Container(
                          padding: const EdgeInsets.fromLTRB(50, 100, 50, 0),
                          child: BalanceDisplay(address: state.addressState.currentAddress.address)),
                      state.addressState.addresses.length > 1
                          ? Container(
                              padding: const EdgeInsets.only(top: 100.0),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FilledButton(
                                  child: Text('Change Address'),
                                  onPressed: () {
                                    _showAddressDialog(context, state.addressState.addresses);
                                  },
                                ),
                              ),
                            )
                          : const Text(""),
                    ],
                  ),
                ),
              ),
            )
          : const Text('');
    });
  }

  void _showAddressDialog(BuildContext context, List<Address> addresses) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select an Address"),
          content: SingleChildScrollView(
            child: ListBody(
              children: addresses.map((address) {
                return Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(width: 1.5, color: Colors.grey))),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(address.address),
                        onTap: () {
                          context.read<DashboardBloc>().add(ChangeAddress(address: address));
                        },
                      ),
                      BalanceDisplay(address: address.address),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
