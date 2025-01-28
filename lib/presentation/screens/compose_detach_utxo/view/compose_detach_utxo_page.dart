import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_detach_utxo.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_detach_utxo/bloc/compose_detach_utxo_bloc.dart';
import 'package:horizon/presentation/screens/compose_detach_utxo/bloc/compose_detach_utxo_state.dart';

import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeDetachUtxoPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  final String assetName;
  final String utxo;
  const ComposeDetachUtxoPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    required this.assetName,
    required this.utxo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>();
    return session.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeDetachUtxoBloc(
          logger: GetIt.I.get<Logger>(),
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
        )..add(AsyncFormDependenciesRequested()),
        child: ComposeDetachUtxoPage(
          address: currentAddress,
          assetName: assetName,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
          utxo: utxo,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeDetachUtxoPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
  final String assetName;
  final String utxo;
  const ComposeDetachUtxoPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
    required this.assetName,
    required this.utxo,
  });

  @override
  ComposeDetachUtxoPageState createState() => ComposeDetachUtxoPageState();
}

class ComposeDetachUtxoPageState extends State<ComposeDetachUtxoPage> {
  TextEditingController utxoController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  String? error;
  // Add a key for the dropdown
  bool showLockedOnly = false;

  @override
  void initState() {
    super.initState();
    utxoController.text = widget.utxo;
    destinationController.text = widget.address;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeDetachUtxoBloc, ComposeDetachUtxoState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ComposeBasePage<ComposeDetachUtxoBloc, ComposeDetachUtxoState>(
          dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
          onFeeChange: (fee) => context
              .read<ComposeDetachUtxoBloc>()
              .add(FeeOptionChanged(value: fee)),
          buildInitialFormFields: (state, loading, formKey) =>
              _buildInitialFormFields(state, loading, formKey),
          onInitialCancel: () => _handleInitialCancel(),
          onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
          buildConfirmationFormFields: (state, composeTransaction, formKey) =>
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

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDetachUtxoBloc>().add(FormSubmitted(
            sourceAddress: destinationController.text,
            params: ComposeDetachUtxoEventParams(
              utxo: utxoController.text,
            ),
          ));
    }
  }

  List<Widget> _buildInitialFormFields(ComposeDetachUtxoState state,
      bool loading, GlobalKey<FormState> formKey) {
    return [
      HorizonUI.HorizonTextFormField(
        controller: utxoController,
        label: 'Utxo',
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        controller: destinationController,
        label: 'Destination',
        enabled: false,
      ),
    ];
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeDetachUtxoResponse).params;
    return [
      HorizonUI.HorizonTextFormField(
        controller: TextEditingController(text: params.source),
        label: 'Utxo',
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        controller: TextEditingController(text: params.destination),
        label: 'Destination',
        enabled: false,
      ),
    ];
  }

  void _onConfirmationBack() {
    context.read<ComposeDetachUtxoBloc>().add(AsyncFormDependenciesRequested());
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    context
        .read<ComposeDetachUtxoBloc>()
        .add(ReviewSubmitted<ComposeDetachUtxoResponse>(
          composeTransaction: composeTransaction,
          fee: fee,
        ));
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDetachUtxoBloc>().add(
            SignAndBroadcastFormSubmitted(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context.read<ComposeDetachUtxoBloc>().add(AsyncFormDependenciesRequested());
  }
}
