import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_destroy.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_destroy/bloc/compose_destroy_bloc.dart';
import 'package:horizon/presentation/screens/compose_destroy/bloc/compose_destroy_state.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeDestroyPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  final String assetName;

  const ComposeDestroyPageWrapper({
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
        create: (context) => ComposeDestroyBloc(
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
        child: ComposeDestroyPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
          assetName: assetName,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeDestroyPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
  final String assetName;

  const ComposeDestroyPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
    required this.assetName,
  });

  @override
  ComposeDestroyPageState createState() => ComposeDestroyPageState();
}

class ComposeDestroyPageState extends State<ComposeDestroyPage> {
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
    return state.balancesState.maybeWhen(
      success: (balances) => [
        HorizonUI.HorizonTextFormField(
          label: 'Destroy',
          enabled: false,
          controller: TextEditingController(
              text: displayAssetName(
                  balances[0].asset, balances[0].assetInfo.assetLongname)),
        ),
        const SizedBox(height: 16),
        HorizonUI.HorizonTextFormField(
          controller:
              TextEditingController(text: balances[0].quantityNormalized),
          enabled: false,
          label: 'Available supply',
        ),
        const SizedBox(height: 16),
        HorizonUI.HorizonTextFormField(
          label: 'Quantity to destroy',
          controller: quantityController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a quantity';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        HorizonUI.HorizonTextFormField(
          label: 'Tag',
          controller: tagController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a tag';
            }
            return null;
          },
        )
      ],
      orElse: () => [
        const HorizonUI.HorizonTextFormField(
          label: 'Destroy',
          enabled: false,
        ),
        const SizedBox(height: 16),
        const HorizonUI.HorizonTextFormField(
          label: 'Quantity to destroy',
          enabled: false,
        ),
        const SizedBox(height: 16),
        const HorizonUI.HorizonTextFormField(
          enabled: false,
          label: 'Available supply',
        ),
        const SizedBox(height: 16),
        const HorizonUI.HorizonTextFormField(
          label: 'Tag',
          enabled: false,
        )
      ],
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
          context.read<ComposeDestroyBloc>().state.balancesState.maybeWhen(
                loading: () {},
                success: (balances) => balances,
                orElse: () => throw Exception('Balances not found'),
              );
      if (balances == null) {
        throw Exception('invariant:Balances not found');
      }
      final quantity = getQuantityForDivisibility(
          inputQuantity: quantityController.text,
          divisible: balances[0].assetInfo.divisible);
      context.read<ComposeDestroyBloc>().add(ComposeTransactionEvent(
            sourceAddress: widget.address,
            params: ComposeDestroyEventParams(
              assetName: widget.assetName,
              quantity: quantity,
              tag: tagController.text,
            ),
          ));
    }
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeDestroyResponse).params;
    return [
      HorizonUI.HorizonTextFormField(
        label: 'Source',
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        label: 'Asset',
        controller: TextEditingController(text: params.asset),
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        label: 'Quantity to destroy',
        controller: TextEditingController(text: params.quantityNormalized),
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        label: 'Tag',
        controller: TextEditingController(text: params.tag),
        keyboardType: TextInputType.text,
        enabled: false,
      ),
    ];
  }

  void _onConfirmationBack() {
    context.read<ComposeDestroyBloc>().add(FetchFormData(
        currentAddress: widget.address, assetName: widget.assetName));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDestroyBloc>().add(
            FinalizeTransactionEvent<ComposeDestroyResponse>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDestroyBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context.read<ComposeDestroyBloc>().add(FetchFormData(
        currentAddress: widget.address, assetName: widget.assetName));
  }
}
