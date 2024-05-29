import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_state.dart';
import 'package:horizon/presentation/screens/dashboard/view/addresses_display.dart';

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
      final width = MediaQuery.of(context).size.width;
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
              width: width / 4,
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
                  state.walletState is WalletStateError ? Text("Error: ${state.walletState.error}") : const Text(""),
                ],
              ),
            ),
            state.walletState is WalletStateSuccess ? const AddressDisplay() : const Text(''),
            state.walletState is WalletStateLoading ? const CircularProgressIndicator() : const Text(''),
            state.walletState is WalletStateError ? Text("Error: ${state.walletState.error}") : const Text(""),
            FilledButton(
                onPressed: () {
                  context.read<DashboardBloc>().add(DeleteWallet());
                  GoRouter.of(context).go('/onboarding');
                },
                child: Text("delete db"))
          ],
        ),
      );
    });
  }
}
