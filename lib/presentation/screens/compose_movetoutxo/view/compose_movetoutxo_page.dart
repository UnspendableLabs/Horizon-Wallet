import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_movetoutxo.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_movetoutxo/bloc/compose_movetoutxo_bloc.dart';
import 'package:horizon/presentation/screens/compose_movetoutxo/bloc/compose_movetoutxo_state.dart';
import 'package:horizon/presentation/screens/compose_movetoutxo/usecase/fetch_form_data.dart';

import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeMoveToUtxoPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  final String assetName;
  final String utxo;
  const ComposeMoveToUtxoPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    required this.assetName,
    required this.utxo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeMoveToUtxoBloc(
          logger: GetIt.I.get<Logger>(),
          fetchComposeMoveToUtxoFormDataUseCase:
              GetIt.I.get<FetchComposeMoveToUtxoFormDataUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
        )..add(FetchFormData(
            utxo: utxo,
            currentAddress:
                currentAddress)), // we need to fetch the utxo balance here rather than the address balance
        child: ComposeMoveToUtxoPage(
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

class ComposeMoveToUtxoPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
  final String assetName;
  final String utxo;
  const ComposeMoveToUtxoPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
    required this.assetName,
    required this.utxo,
  });

  @override
  ComposeMoveToUtxoPageState createState() => ComposeMoveToUtxoPageState();
}

class ComposeMoveToUtxoPageState extends State<ComposeMoveToUtxoPage> {
  TextEditingController utxoController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  bool _submitted = false;
  String? error;
  // Add a key for the dropdown
  bool showLockedOnly = false;

  @override
  void initState() {
    super.initState();
    utxoController.text = widget.utxo;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeMoveToUtxoBloc, ComposeMoveToUtxoState>(
      listener: (context, state) {},
      builder: (context, state) {
        return state.balancesState.maybeWhen(
          loading: () =>
              ComposeBasePage<ComposeMoveToUtxoBloc, ComposeMoveToUtxoState>(
            dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
            onFeeChange: (fee) {},
            buildInitialFormFields: (state, loading, formKey) => [
              HorizonUI.HorizonTextFormField(
                controller: utxoController,
                label: 'Utxo',
                enabled: false,
              ),
              const SizedBox(height: 16),
              HorizonUI.HorizonTextFormField(
                controller: destinationController,
                label: 'Destination Address',
                enabled: false,
              ),
            ],
            onInitialCancel: () => _handleInitialCancel(),
            onInitialSubmit: (formKey) {},
            buildConfirmationFormFields: (state, composeTransaction, formKey) =>
                [],
            onConfirmationBack: () {},
            onConfirmationContinue: (composeTransaction, fee, formKey) {},
            onFinalizeSubmit: (password, formKey) {},
            onFinalizeCancel: () => {},
          ),
          success: (balances) =>
              ComposeBasePage<ComposeMoveToUtxoBloc, ComposeMoveToUtxoState>(
            dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
            onFeeChange: (fee) => context
                .read<ComposeMoveToUtxoBloc>()
                .add(ChangeFeeOption(value: fee)),
            buildInitialFormFields: (state, loading, formKey) =>
                _buildInitialFormFields(state, loading, formKey),
            onInitialCancel: () => _handleInitialCancel(),
            onInitialSubmit: (formKey) =>
                _handleInitialSubmit(formKey, balances),
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
          ),
          error: (message) => SelectableText(message),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(
      GlobalKey<FormState> formKey, List<Balance> balances) {
    setState(() {
      _submitted = true;
    });
    if (formKey.currentState!.validate()) {
      context.read<ComposeMoveToUtxoBloc>().add(ComposeTransactionEvent(
            sourceAddress: destinationController.text,
            params: ComposeMoveToUtxoEventParams(
              utxo: utxoController.text,
              destination: destinationController.text,
            ),
          ));
    }
  }

  List<Widget> _buildInitialFormFields(ComposeMoveToUtxoState state,
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
        label: 'Destination Address',
        enabled: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Destination address is required';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeMoveToUtxoResponse).params;
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
    context.read<ComposeMoveToUtxoBloc>().add(FetchFormData(
        currentAddress: widget
            .utxo)); // we need to fetch the utxo balance here rather than the address balance
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    context
        .read<ComposeMoveToUtxoBloc>()
        .add(FinalizeTransactionEvent<ComposeMoveToUtxoResponse>(
          composeTransaction: composeTransaction,
          fee: fee,
        ));
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeMoveToUtxoBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeMoveToUtxoBloc>()
        .add(FetchFormData(currentAddress: widget.utxo));
  }
}
