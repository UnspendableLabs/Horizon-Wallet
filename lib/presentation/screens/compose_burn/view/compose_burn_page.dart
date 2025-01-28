import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_burn.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_burn/bloc/compose_burn_bloc.dart';
import 'package:horizon/presentation/screens/compose_burn/bloc/compose_burn_state.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeBurnPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  const ComposeBurnPageWrapper({
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
        create: (context) => ComposeBurnBloc(
          logger: GetIt.I.get<Logger>(),
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          blockRepository: GetIt.I.get<BlockRepository>(),
          balanceRepository: GetIt.I.get<BalanceRepository>(),
        )..add(AsyncFormDependenciesRequested(currentAddress: currentAddress)),
        child: ComposeBurnPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeBurnPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
  const ComposeBurnPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  ComposeBurnPageState createState() => ComposeBurnPageState();
}

class ComposeBurnPageState extends State<ComposeBurnPage> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();

  bool _submitted = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeBurnBloc, ComposeBurnState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ComposeBasePage<ComposeBurnBloc, ComposeBurnState>(
          dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
          onFeeChange: (fee) =>
              context.read<ComposeBurnBloc>().add(FeeOptionChanged(value: fee)),
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
    setState(() {
      _submitted = true;
    });
    if (formKey.currentState!.validate()) {
      final quantity = getQuantityForDivisibility(
          inputQuantity: quantityController.text, divisible: true);

      context.read<ComposeBurnBloc>().add(FormSubmitted(
            sourceAddress: widget.address,
            params: ComposeBurnEventParams(
              quantity: quantity,
            ),
          ));
    }
  }

  List<Widget> _buildInitialFormFields(
      ComposeBurnState state, bool loading, GlobalKey<FormState> formKey) {
    return state.balancesState.maybeWhen(
      success: (balances) => [
        HorizonUI.HorizonTextFormField(
          label: "Source Address",
          controller: fromAddressController,
          enabled: false,
        ),
        const SizedBox(height: 16.0),
        HorizonUI.HorizonTextFormField(
          label: "Burn Quantity",
          controller: quantityController,
          inputFormatters: [
            DecimalTextInputFormatter(decimalRange: 8),
          ],
        ),
        const SizedBox(height: 16.0),
        HorizonUI.HorizonTextFormField(
          label: "BTC Balance",
          controller:
              TextEditingController(text: balances.first.quantityNormalized),
          enabled: false,
        ),
      ],
      loading: () => [
        HorizonUI.HorizonTextFormField(
          label: "Source Address",
          controller: fromAddressController,
          enabled: false,
        ),
        const SizedBox(height: 16.0),
        const HorizonUI.HorizonTextFormField(
          label: "Burn Quantity",
          enabled: false,
        ),
        const SizedBox(height: 16.0),
        const HorizonUI.HorizonTextFormField(
          label: "BTC Balance",
          enabled: false,
        ),
      ],
      error: (error) => [
        SelectableText(error),
      ],
      orElse: () => [],
    );
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeBurnResponse).params;
    return [
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Burn Quantity",
        controller: TextEditingController(
            text: quantityToQuantityNormalizedString(
                quantity: params.quantity, divisible: true)),
        enabled: false,
      ),
    ];
  }

  void _onConfirmationBack() {
    context
        .read<ComposeBurnBloc>()
        .add(AsyncFormDependenciesRequested(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    context.read<ComposeBurnBloc>().add(ReviewSubmitted<ComposeBurnResponse>(
          composeTransaction: composeTransaction,
          fee: fee,
        ));
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeBurnBloc>().add(
            SignAndBroadcastFormSubmitted(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeBurnBloc>()
        .add(AsyncFormDependenciesRequested(currentAddress: widget.address));
  }
}
