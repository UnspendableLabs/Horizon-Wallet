import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/bloc/compose_attach_utxo_bloc.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/bloc/compose_attach_utxo_state.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/usecase/fetch_form_data.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeAttachUtxoPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  final String assetName;
  const ComposeAttachUtxoPageWrapper({
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
        create: (context) => ComposeAttachUtxoBloc(
          logger: GetIt.I.get<Logger>(),
          fetchComposeAttachUtxoFormDataUseCase:
              GetIt.I.get<FetchComposeAttachUtxoFormDataUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          blockRepository: GetIt.I.get<BlockRepository>(),
        )..add(FetchFormData(currentAddress: currentAddress)),
        child: ComposeAttachUtxoPage(
          address: currentAddress,
          assetName: assetName,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeAttachUtxoPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
  final String assetName;
  const ComposeAttachUtxoPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
    required this.assetName,
  });

  @override
  ComposeAttachUtxoPageState createState() => ComposeAttachUtxoPageState();
}

class ComposeAttachUtxoPageState extends State<ComposeAttachUtxoPage> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController assetController = TextEditingController();

  bool _submitted = false;
  String? error;
  // Add a key for the dropdown
  bool showLockedOnly = false;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address;
    assetController.text = widget.assetName;
  }

  @override
  Widget build(BuildContext context) {
    print('BUILDING');
    return BlocConsumer<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      listener: (context, state) {},
      builder: (context, state) {
        print('STATE: ${state.assetState}');
        return state.assetState.maybeWhen(
          loading: () =>
              ComposeBasePage<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
            dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
            onFeeChange: (fee) => () {},
            buildInitialFormFields: (state, loading, formKey) => [
              HorizonUI.HorizonTextFormField(
                controller: fromAddressController,
                label: 'From Address',
                enabled: false,
              ),
              HorizonUI.HorizonTextFormField(
                controller: quantityController,
                label: 'Quantity',
                enabled: false,
              ),
            ],
            onInitialCancel: () => _handleInitialCancel(),
            onInitialSubmit: (formKey) => () {},
            buildConfirmationFormFields: (state, composeTransaction, formKey) =>
                [],
            onConfirmationBack: () => () {},
            onConfirmationContinue: (composeTransaction, fee, formKey) {
              () {};
            },
            onFinalizeSubmit: (password, formKey) {
              () {};
            },
            onFinalizeCancel: () => () {},
          ),
          success: (asset) =>
              ComposeBasePage<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
            dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
            onFeeChange: (fee) => context
                .read<ComposeAttachUtxoBloc>()
                .add(ChangeFeeOption(value: fee)),
            buildInitialFormFields: (state, loading, formKey) =>
                _buildInitialFormFields(state, loading, formKey, asset),
            onInitialCancel: () => _handleInitialCancel(),
            onInitialSubmit: (formKey) => _handleInitialSubmit(formKey, asset),
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

  void _handleInitialSubmit(GlobalKey<FormState> formKey, Asset asset) {
    setState(() {
      _submitted = true;
    });
    if (formKey.currentState!.validate()) {
      Decimal input = Decimal.parse(quantityController.text);
      int quantity;

      if (asset.divisible!) {
        quantity = (input * Decimal.fromInt(100000000)).toBigInt().toInt();
      } else {
        quantity = input.toBigInt().toInt();
      }

      context.read<ComposeAttachUtxoBloc>().add(ComposeTransactionEvent(
            sourceAddress: fromAddressController.text,
            params: ComposeAttachUtxoEventParams(
              asset: asset,
              quantity: quantity,
            ),
          ));
    }
  }

  List<Widget> _buildInitialFormFields(ComposeAttachUtxoState state,
      bool loading, GlobalKey<FormState> formKey, Asset asset) {
    print('BUILDING INITIAL FORM FIELDS');

    return [
      HorizonUI.HorizonTextFormField(
        controller: fromAddressController,
        label: 'From Address',
        enabled: false,
      ),
      HorizonUI.HorizonTextFormField(
        controller: quantityController,
        label: 'Quantity',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Quantity is required';
          }
          return null;
        },
        onFieldSubmitted: (value) {
          _handleInitialSubmit(formKey, asset);
        },
      ),
    ];
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    // final params = (composeTransaction as ComposeFairmintResponse).params;
    return [];
  }

  void _onConfirmationBack() {
    context
        .read<ComposeAttachUtxoBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    // context.read<ComposeAttachUtxoBloc>().add(FinalizeTransactionEvent<ComposeFairmintResponse>(
    //       composeTransaction: composeTransaction,
    //       fee: fee,
    //     ));
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      // context.read<ComposeAttachUtxoBloc>().add(
      //       SignAndBroadcastTransactionEvent(
      //         password: password,
      //       ),
      //     );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeAttachUtxoBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }
}

// class UpperCaseTextEditingController extends TextEditingController {
//   @override
//   set value(TextEditingValue newValue) {
//     super.value = newValue.copyWith(
//       text: newValue.text.toUpperCase(),
//       selection: newValue.selection,
//       composing: newValue.composing,
//     );
//   }
// }
