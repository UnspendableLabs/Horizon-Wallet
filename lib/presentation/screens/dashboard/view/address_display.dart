import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/presentation/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:uniparty/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:uniparty/presentation/screens/dashboard/bloc/dashboard_state.dart';

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
      print('state.addressState: ${state.addressState}');
      //state.addressState.currentAddress.address
      return state.addressState is AddressStateSuccess
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        state.addressState.currentAddress.address,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: state.addressState.currentAddress.address));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Address copied to clipboard!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            )
          : const Text('');
    });
  }
}
