import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/screens/compose_destroy/bloc/compose_destroy_bloc.dart';
import 'package:horizon/presentation/screens/compose_destroy/bloc/compose_destroy_state.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class ComposeDestroyPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;

  const ComposeDestroyPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeDestroyBloc()
          ..add(FetchFormData(currentAddress: currentAddress)),
        child: ComposeDestroyPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeDestroyPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;

  const ComposeDestroyPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  ComposeDestroyPageState createState() => ComposeDestroyPageState();
}

class ComposeDestroyPageState extends State<ComposeDestroyPage> {
  TextEditingController dispenserController = TextEditingController();

  Dispenser? selectedDispenser;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeDestroyBloc, ComposeDestroyState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ComposeBasePage<ComposeDestroyBloc, ComposeDestroyState>(
          dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
          onFeeChange: (fee) => context
              .read<ComposeDestroyBloc>()
              .add(ChangeFeeOption(value: fee)),
          buildInitialFormFields: (state, loading, formKey) =>
              _buildInitialFormFields(state, loading, formKey),
          onInitialCancel: () => _handleInitialCancel(),
          onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
          buildConfirmationFormFields: (_, composeTransaction, formKey) =>
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
      },
    );
  }

  List<Widget> _buildInitialFormFields(
      ComposeDestroyState state, bool loading, GlobalKey<FormState> formKey) {
    return [];
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    setState(() {
      _submitted = true;
    });
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    // final params = (composeTransaction as ComposeDispenserResponseVerbose).params;
    return [];
  }

  void _onConfirmationBack() {}

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      // context.read<ComposeDestroyBloc>().add(
      //       FinalizeTransactionEvent<ComposeDispenserResponseVerbose>(
      //         composeTransaction: composeTransaction,
      //         fee: fee,
      //       ),
      // );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    // if (formKey.currentState!.validate()) {
    //   context.read<CloseDispenserBloc>().add(
    //         SignAndBroadcastTransactionEvent(
    //           password: password,
    // ),
    // );
    // }
  }

  void _onFinalizeCancel() {
    //   setState(() {
    //     selectedDispenser = null;
    //     dispenserController.clear();
    //   });
    //   context.read<CloseDispenserBloc>().add(FetchFormData(currentAddress: widget.address));
  }
}
