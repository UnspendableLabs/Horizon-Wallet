import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/update_issuance/bloc/update_issuance_bloc.dart';
import 'package:horizon/presentation/screens/update_issuance/bloc/update_issuance_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class UpdateIssuancePageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;

  const UpdateIssuancePageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.address,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => UpdateIssuanceBloc(),
        child: UpdateIssuancePage(
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
          address: address,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class UpdateIssuancePage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;
  const UpdateIssuancePage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  UpdateIssuancePageState createState() => UpdateIssuancePageState();
}

class UpdateIssuancePageState extends State<UpdateIssuancePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ComposeBasePage<UpdateIssuanceBloc, UpdateIssuanceState>(
      address: widget.address,
      dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
      onFeeChange: (fee) =>
          context.read<UpdateIssuanceBloc>().add(ChangeFeeOption(value: fee)),
      buildInitialFormFields: (state, loading, formKey) =>
          _buildInitialFormFields(state, loading, formKey),
      onInitialCancel: () => _handleInitialCancel(),
      onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
      buildConfirmationFormFields: (composeTransaction, formKey) =>
          _buildConfirmationDetails(composeTransaction),
      onConfirmationBack: () => _onConfirmationBack(),
      onConfirmationContinue: (composeTransaction, fee, formKey) {
        _onConfirmationContinue(composeTransaction, fee, formKey);
      },
      onFinalizeSubmit: (password, formKey) {
        _onFinalizeSubmit(password, formKey);
      },
      onFinalizeCancel: () => _onFinalizeCancel(),
    );
  }

  List<Widget> _buildInitialFormFields(
      UpdateIssuanceState state, bool loading, GlobalKey<FormState> formKey) {
    return const [];
  }

  void _handleInitialCancel() {}

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {}

  List<Widget> _buildConfirmationDetails(composeTransaction) {
    return const [];
  }

  void _onConfirmationBack() {}

  void _onConfirmationContinue(
      composeTransaction, int fee, GlobalKey<FormState> formKey) {}

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {}

  void _onFinalizeCancel() {}
}
