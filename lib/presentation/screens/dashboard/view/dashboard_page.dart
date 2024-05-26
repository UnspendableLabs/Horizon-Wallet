import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/presentation/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:uniparty/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:uniparty/presentation/screens/dashboard/bloc/dashboard_state.dart';

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
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // TODO: remove. this allows us to set the state on hot reload since initState is not called on hot reload
    //   context.read<DashboardBloc>().add(SetAccountAndWallet());
    // });
    return BlocBuilder<DashboardBloc, DashboardState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Uniparty')),
        body: Row(
          children: <Widget>[
            Container(
              width: 200, // Fixed width for the sidebar
              child: ListView(
                children: <Widget>[
                  DrawerHeader(
                    child: Text('Accounts'),
                    margin: const EdgeInsets.only(bottom: 0),
                    padding: const EdgeInsets.all(0.0),
                    // decoration: BoxDecoration(),
                  ),
                  // state.walletState is WalletStateSuccess ? Text('Dashboard') : Text(''),

                  state.walletState is WalletStateSuccess
                      ? Column(
                          children: state.walletState.wallets
                              .map<Widget>((wallet) => ListTile(
                                  title: Text(wallet.name!),
                                  selected: wallet.uuid == state.walletState.currentWallet.uuid,
                                  autofocus: wallet.uuid == state.walletState.currentWallet.uuid,
                                  onTap: () {}))
                              .toList())
                      : Text(""),
                  state.walletState is WalletStateLoading ? CircularProgressIndicator() : Text(""),
                  state.walletState is WalletStateError ? Text("Error: ${state.walletState.error}") : Text(""),
                ],
              ),
            ),
            Expanded(
              child: Center(child: Text('DASHBOARD')), // Main content area
            ),
          ],
        ),
      );
    }

        //  Center(
        //     child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [

        //     state.walletState is WalletStateSuccess ? Text("Wallet: ${state.walletState.wallet.uuid}") : Text(""),
        //     state.walletState is WalletStateLoading ? CircularProgressIndicator() : Text(""),
        //     state.walletState is WalletStateError ? Text("Error: ${state.walletState.error}") : Text(""),
        //     //   state.addressState is AddressStateSuccess ? Text("Dashboard") : Text(""),
        //     //   state.addressState is AddressStateLoading ? CircularProgressIndicator() : Text(""),
        //     //   state.addressState is AddressStateError ? Text("Error: ${state.addressState.error}") : Text(""),
        //   ],
        // ))
        );
  }
}
