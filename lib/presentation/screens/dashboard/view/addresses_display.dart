import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    double screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<DashboardBloc, DashboardState>(builder: (context, state) {
      if (state.addressState is AddressStateSuccess) {
        return Flexible(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 80, 0, 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          state.addressState.currentAddress.address,
                          style: TextStyle(fontSize: screenWidth * 0.025), // Responsive font size
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: state.addressState.currentAddress.address)).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Address copied to clipboard!'),
                              ),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1.5, color: Colors.grey),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
                      child: BalanceDisplay(address: state.addressState.currentAddress.address)),
                  state.addressState.addresses.length > 1
                      ? Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: ElevatedButton(
                            child: Text('Switch Address'),
                            onPressed: () {
                              _showAddressDialog(
                                  context, state.addressState.addresses, BlocProvider.of<DashboardBloc>(context));
                            },
                          ),
                        )
                      : const Text(""),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: ElevatedButton(
                        onPressed: () {
                          GoRouter.of(context)
                              .push('/compose/send', extra: {'initialAddress': state.addressState.currentAddress});
                        },
                        child: Text('Compose Send')),
                  )
                ],
              ),
            ),
          ),
        );
      }
      if (state.addressState is AddressStateLoading) {
        return const Text('Loading...');
      }
      return const Text('');
    });
  }

  void _showAddressDialog(BuildContext context, List<Address> addresses, DashboardBloc bloc) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Select an Address"),
          content: SingleChildScrollView(
            child: ListBody(
              children: addresses.map((address) {
                return Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Container(
                    decoration: const BoxDecoration(
                        border: Border(
                      bottom: BorderSide(width: 1.5, color: Colors.grey),
                    )),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(address.address),
                          onTap: () {
                            bloc.add(ChangeAddress(address: address));
                            Navigator.of(context).pop();
                          },
                        ),
                        BalanceDisplay(address: address.address),
                      ],
                    ),
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
