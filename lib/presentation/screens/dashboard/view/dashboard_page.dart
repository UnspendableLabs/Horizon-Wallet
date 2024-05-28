import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/view/main_address_display.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_state.dart';
import 'package:horizon/presentation/screens/dashboard/view/main_address_display.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => DashboardBloc(), child: _DashboardPage_());
  }
}

class _DashboardPage_ extends StatefulWidget {
  @override
  _DashboardPage_State createState() => _DashboardPage_State();
}

class _DashboardPage_State extends State<_DashboardPage_> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(SetAccountAndWallet());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(builder: (context, state) {
      return Scaffold(
        body: Row(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey, // Color of the border
                    width: 1.0, // Width of the border
                  ),
                ),
              ),
              width: 300, // Fixed width for the sidebar
              child: ListView(
                children: <Widget>[
                  const ListTile(
                    title: Text('Horizon',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  ),
                  state.walletState is WalletStateSuccess
                      ? Column(
                          children: state.walletState.wallets
                              .map<Widget>((wallet) => ListTile(
                                  title: Text(wallet.name!),
                                  selected: wallet.uuid == state.walletState.currentWallet.uuid,
                                  autofocus: wallet.uuid == state.walletState.currentWallet.uuid,
                                  onTap: () {}))
                              .toList())
                      : const Text(""),
                  state.walletState is WalletStateLoading ? const CircularProgressIndicator() : const Text(""),
                  state.walletState is WalletStateError
                      ?
                            Text("Error: ${state.walletState.error}")
                      : const Text(""),
                ],
              ),
            ),
            state.walletState is WalletStateSuccess ? AddressDisplay() : const Text(''),
            state.walletState is WalletStateLoading ? const CircularProgressIndicator() : const Text(''),
            state.walletState is WalletStateError ? Text("Error: ${state.walletState.error}") : const Text(""),
            state.walletState is WalletStateInitial ? const Text("CENTER IT") : const Text(""),
          ],
        ),
      );
    });
  }
}
