import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_sweep.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/estimate_xcp_fee_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_sweep/bloc/compose_sweep_bloc.dart';
import 'package:horizon/presentation/screens/compose_sweep/bloc/compose_sweep_state.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/session/bloc/session_cubit.dart';

class ComposeSweepPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;

  const ComposeSweepPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>();
    return session.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeSweepBloc(
          composeRepository: GetIt.I.get<ComposeRepository>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          estimateXcpFeeRepository: GetIt.I.get<EstimateXcpFeeRepository>(),
          logger: GetIt.I.get<Logger>(),
        )..add(FetchFormData(currentAddress: currentAddress)),
        child: ComposeSweepPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeSweepPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;

  const ComposeSweepPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  ComposeSweepPageState createState() => ComposeSweepPageState();
}

class ComposeSweepPageState extends State<ComposeSweepPage> {
  TextEditingController destinationController = TextEditingController();
  TextEditingController memoController = TextEditingController();
  bool _submitted = false;
  bool warningAccepted = false;
  bool errorWarningAccepted = false;
  int flags = 1;

  @override
  void initState() {
    super.initState();
    warningAccepted = false;
  }

  @override
  void dispose() {
    destinationController.dispose();
    memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeSweepBloc, ComposeSweepState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ComposeBasePage<ComposeSweepBloc, ComposeSweepState>(
          dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
          onFeeChange: (fee) =>
              context.read<ComposeSweepBloc>().add(ChangeFeeOption(value: fee)),
          buildInitialFormFields: (state, loading, formKey) =>
              _buildInitialFormFields(state, loading, formKey),
          onInitialCancel: () => _handleInitialCancel(),
          onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
          buildConfirmationFormFields: (_, composeTransaction, formKey) =>
              _buildConfirmationDetails(composeTransaction, state),
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
      ComposeSweepState state, bool loading, GlobalKey<FormState> formKey) {
    return [
      HorizonUI.HorizonTextFormField(
        controller: TextEditingController(text: widget.address),
        label: 'Source',
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        controller: destinationController,
        label: 'Destination',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a destination';
          }
          return null;
        },
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonDropdownMenu<int>(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        label: 'Flags',
        selectedValue: flags,
        items: [
          HorizonUI.buildDropdownMenuItem('1', '1: Sweep balance'),
          HorizonUI.buildDropdownMenuItem('2', '2: Sweep ownership'),
          HorizonUI.buildDropdownMenuItem(
              '3', '3: Sweep ownership and balance'),
        ]
            .map((item) => DropdownMenuItem<int>(
                  value: int.parse(item.value!),
                  child: item.child,
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            flags = value ?? 1;
          });
        },
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        controller: memoController,
        label: 'Memo',
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a memo';
          }
          return null;
        },
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
      ),
      const SizedBox(height: 16),
      state.sweepXcpFeeState.maybeWhen(
        success: (sweepXcpFee) => HorizonUI.HorizonTextFormField(
          enabled: false,
          label: 'XCP Fee',
          controller: TextEditingController(
              text:
                  '${quantityToQuantityNormalizedString(quantity: sweepXcpFee, divisible: true)} XCP'),
        ),
        error: (error) =>
            SelectableText('Error fetching sweep XCP fee: $error'),
        orElse: () => const SizedBox.shrink(),
      ),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: warningAccepted,
            onChanged: (value) {
              setState(() {
                warningAccepted = value ?? false;
                errorWarningAccepted = false;
              });
            },
          ),
          Expanded(
            child: SelectableText(
              'Escrowed and UTXO-attached assets will not be included in the sweep. Please confirm that you understand.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      if (errorWarningAccepted)
        const SelectableText(
          'You must accept the warning to continue',
          style: TextStyle(color: Colors.red),
        ),
    ];
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    setState(() {
      _submitted = true;
    });

    if (!warningAccepted) {
      setState(() {
        errorWarningAccepted = true;
      });
      return;
    }

    if (formKey.currentState!.validate()) {
      context.read<ComposeSweepBloc>().add(
            ComposeTransactionEvent(
              sourceAddress: widget.address,
              params: ComposeSweepEventParams(
                destination: destinationController.text,
                flags: flags,
                memo: memoController.text,
              ),
            ),
          );
    }
  }

  List<Widget> _buildConfirmationDetails(
      dynamic composeTransaction, ComposeSweepState state) {
    final sweepXcpFee = state.sweepXcpFeeState.maybeWhen(
      success: (sweepXcpFee) => sweepXcpFee,
      error: (error) => 0,
      orElse: () => 0,
    );
    final params = (composeTransaction as ComposeSweepResponse).params;
    return [
      HorizonUI.HorizonTextFormField(
        controller: TextEditingController(text: params.source),
        label: 'Source',
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        controller: TextEditingController(text: params.destination),
        label: 'Destination',
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        controller: TextEditingController(
            text:
                "${params.flags.toString()} - Sweep ${flagMapper[params.flags]}"),
        label: 'Flags',
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        controller: TextEditingController(text: params.memo),
        label: 'Memo',
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        enabled: false,
        label: 'XCP Fee',
        controller: TextEditingController(
            text:
                '${quantityToQuantityNormalizedString(quantity: sweepXcpFee, divisible: true)} XCP'),
      ),
    ];
  }

  void _onConfirmationBack() {
    context
        .read<ComposeSweepBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeSweepBloc>().add(
            FinalizeTransactionEvent<ComposeSweepResponse>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeSweepBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeSweepBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }
}
