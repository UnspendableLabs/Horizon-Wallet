import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_state.dart';

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
                  padding: const EdgeInsets.only(top: 40.0),
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
                              // Clipboard.setData(ClipboardData(text: state.addressState.currentAddress.address));
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
                        padding: const EdgeInsets.fromLTRB(50, 80, 50, 10),
                        child: Container(
                          width: screenWidth - 300,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1.5, color: Colors.grey),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween, // This spreads out the children across the main axis

                            children: [
                              Text('ASSET'),
                              Text('BALANCE'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const Text('');
    });
  }
}
