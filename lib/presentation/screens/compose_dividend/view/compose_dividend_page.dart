import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_dividend.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dividend/bloc/compose_dividend_bloc.dart';
import 'package:horizon/presentation/screens/compose_dividend/bloc/compose_dividend_state.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class ComposeDividendPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  final String assetName;

  const ComposeDividendPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    required this.assetName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeDividendBloc(
          balanceRepository: GetIt.I.get<BalanceRepository>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          logger: GetIt.I.get<Logger>(),
        )..add(FetchFormData(
            currentAddress: currentAddress, assetName: assetName)),
        child: ComposeDividendPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
          assetName: assetName,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeDividendPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
  final String assetName;

  const ComposeDividendPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
    required this.assetName,
  });

  @override
  ComposeDividendPageState createState() => ComposeDividendPageState();
}

class ComposeDividendPageState extends State<ComposeDividendPage> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    quantityController.dispose();
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeDividendBloc, ComposeDividendState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ComposeBasePage<ComposeDividendBloc, ComposeDividendState>(
          dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
          onFeeChange: (fee) => context
              .read<ComposeDividendBloc>()
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
      ComposeDividendState state, bool loading, GlobalKey<FormState> formKey) {
    return state.balancesState.maybeWhen(
      success: (balances) => [],
      orElse: () => [],
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
      final balances =
          context.read<ComposeDividendBloc>().state.balancesState.maybeWhen(
                loading: () {},
                success: (balances) => balances,
                orElse: () => throw Exception('Balances not found'),
              );
      if (balances == null) {
        throw Exception('invariant: Balances not found');
      }
      final quantity = getQuantityForDivisibility(
          inputQuantity: quantityController.text,
          divisible: balances[0].assetInfo.divisible);
      // context.read<ComposeDividendBloc>().add(ComposeTransactionEvent(
      //       sourceAddress: widget.address,
      //       params: ComposeDividendEventParams(
      //         assetName: widget.assetName,
      //         quantity: quantity,
      //         tag: tagController.text,
      //       ),
      // ));
    }
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeDividendResponse).params;
    return [];
//
  }

  void _onConfirmationBack() {
    context.read<ComposeDividendBloc>().add(FetchFormData(
        currentAddress: widget.address, assetName: widget.assetName));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDividendBloc>().add(
            FinalizeTransactionEvent<ComposeDividendResponse>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDividendBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context.read<ComposeDividendBloc>().add(FetchFormData(
        currentAddress: widget.address, assetName: widget.assetName));
  }
}
