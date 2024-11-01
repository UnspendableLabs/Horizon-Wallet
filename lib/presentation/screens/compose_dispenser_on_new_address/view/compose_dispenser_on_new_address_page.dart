import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';

class ComposeDispenserOnNewAddressPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;

  const ComposeDispenserOnNewAddressPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ComposeDispenserOnNewAddressBloc(),
      child: const ComposeDispenserOnNewAddressPage(),
    );
  }
}

class ComposeDispenserOnNewAddressPage extends StatefulWidget {
  const ComposeDispenserOnNewAddressPage({super.key});

  @override
  State<ComposeDispenserOnNewAddressPage> createState() =>
      _ComposeDispenserOnNewAddressPageState();
}

class _ComposeDispenserOnNewAddressPageState
    extends State<ComposeDispenserOnNewAddressPage> {
  @override
  Widget build(BuildContext context) {
    return const SelectableText('ComposeDispenserOnNewAddressPage');
  }
}
