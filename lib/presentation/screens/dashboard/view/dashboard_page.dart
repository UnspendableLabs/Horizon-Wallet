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
    context.read<DashboardBloc>().add(GetAddresses());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(title: const Text('Uniparty')),
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                state.addressState is AddressStateSuccess ? Text("Dashboard") : Text(""),
                state.addressState is AddressStateLoading ? CircularProgressIndicator() : Text(""),
                state.addressState is AddressStateError ? Text("Error: ${state.addressState.error}") : Text(""),
              ],
            )));
      },
    );
  }
}
