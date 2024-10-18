import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/compose_fairmint.dart';
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_fairmint/bloc/compose_fairmint_bloc.dart';
import 'package:horizon/presentation/screens/compose_fairminter/bloc/compose_fairminter_bloc.dart';
import 'package:horizon/presentation/screens/compose_fairminter/bloc/compose_fairminter_state.dart';
import 'package:horizon/presentation/screens/compose_fairminter/usecase/fetch_form_data.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeFairminterPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;

  const ComposeFairminterPageWrapper({
    required this.dashboardActivityFeedBloc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => ComposeFairminterBloc(
          logger: GetIt.I.get<Logger>(),
          fetchFairminterFormDataUseCase:
              GetIt.I.get<FetchFairminterFormDataUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          blockRepository: GetIt.I.get<BlockRepository>(),
        )..add(FetchFormData(currentAddress: state.currentAddress)),
        child: ComposeFairminterPage(
          address: state.currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeFairminterPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;
  const ComposeFairminterPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  ComposeFairminterPageState createState() => ComposeFairminterPageState();
}

class ComposeFairminterPageState extends State<ComposeFairminterPage> {
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController maxMintPerTxController = TextEditingController();
  TextEditingController hardcapController = TextEditingController();
  TextEditingController startBlockController = TextEditingController();

  Asset? asset;

  bool _submitted = false;

  String? error;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address.address;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeFairminterBloc, ComposeFairminterState>(
      listener: (context, state) {},
      builder: (context, state) {
        return state.assetState.maybeWhen(
          loading: () =>
              ComposeBasePage<ComposeFairminterBloc, ComposeFairminterState>(
                  address: widget.address,
                  dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
                  onFeeChange: (fee) => context
                      .read<ComposeFairminterBloc>()
                      .add(ChangeFeeOption(value: fee)),
                  buildInitialFormFields: (state, loading, formKey) => [],
                  onInitialCancel: () => _handleInitialCancel(),
                  onInitialSubmit: (formKey) {},
                  buildConfirmationFormFields:
                      (state, composeTransaction, formKey) => [],
                  onConfirmationBack: () {},
                  onConfirmationContinue: (composeTransaction, fee, formKey) {},
                  onFinalizeSubmit: (password, formKey) {},
                  onFinalizeCancel: () {}),
          success: (assets) =>
              ComposeBasePage<ComposeFairminterBloc, ComposeFairminterState>(
            address: widget.address,
            dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
            onFeeChange: (fee) => context
                .read<ComposeFairminterBloc>()
                .add(ChangeFeeOption(value: fee)),
            buildInitialFormFields: (state, loading, formKey) =>
                _buildInitialFormFields(state, loading, formKey, assets),
            onInitialCancel: () => _handleInitialCancel(),
            onInitialSubmit: (formKey) => _handleInitialSubmit(formKey, assets),
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
          error: (error) => SelectableText(error),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey, List<Asset> assets) {
    setState(() {
      _submitted = true;
    });
    if (formKey.currentState!.validate()) {
      if (asset == null) {
        setState(() {
          error = 'Please select an asset';
        });
        return;
      }
      // if (asset == null && nameController.text.isEmpty) {
      //   setState(() {
      //     error = 'Please select a fairminter or enter a fairminter name';
      //   });
      //   return;
      // } else if (asset == null && nameController.text.isNotEmpty) {
      //   if (!assets.any((asset) => asset.asset == nameController.text)) {
      //     setState(() {
      //       error = 'Fairminter with name ${nameController.text} not found';
      //     });
      //     return;
      //   }
      // } else if (fairminter != null && nameController.text.isNotEmpty) {
      //   setState(() {
      //     error = 'Please specify either a fairminter name or a select from the dropdown, not both';
      //   });
      //   return;
      // }

      // context.read<ComposeFairmintBloc>().add(ComposeTransactionEvent(
      //       sourceAddress: widget.address.address,
      //       params: ComposeFairmintEventParams(
      //         asset: nameController.text,
      //       ),
      //     ));
    }
  }

  List<Widget> _buildInitialFormFields(ComposeFairminterState state,
      bool loading, GlobalKey<FormState> formKey, List<Asset> assets) {
    return [
      HorizonUI.HorizonTextFormField(
        label: "Address that will be minting the asset",
        controller: fromAddressController,
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonDropdownMenu<Asset>(
        label: "Select an asset",
        items: assets
            .map((asset) =>
                DropdownMenuItem(value: asset, child: Text(asset.asset)))
            .toList(),
        onChanged: (Asset? value) => setState(() {
          asset = value;
        }),
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Max mint per transaction",
        controller: maxMintPerTxController,
        inputFormatters: [DecimalTextInputFormatter(decimalRange: 8)],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a max mint per transaction';
          }
          return null;
        },
        onFieldSubmitted: (value) {
          _handleInitialSubmit(formKey, assets);
        },
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Hard cap",
        controller: hardcapController,
        inputFormatters: [
          asset?.divisible == true
              ? DecimalTextInputFormatter(decimalRange: 8)
              : FilteringTextInputFormatter.digitsOnly,
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a hardcap';
          }
          return null;
        },
        onFieldSubmitted: (value) {
          _handleInitialSubmit(formKey, assets);
        },
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Start block (optional)",
        controller: startBlockController,
        inputFormatters: [
          asset?.divisible == true
              ? DecimalTextInputFormatter(decimalRange: 8)
              : FilteringTextInputFormatter.digitsOnly,
        ],
        onFieldSubmitted: (value) {
          _handleInitialSubmit(formKey, assets);
        },
      ),
      if (error != null)
        SelectableText(
          error!,
          style: const TextStyle(color: redErrorText),
        ),
    ];
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeFairmintResponse).params;
    return [
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Asset",
        controller: TextEditingController(text: params.asset),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Quantity",
        controller: TextEditingController(text: params.quantityNormalized),
        enabled: false,
      ),
    ];
  }

  void _onConfirmationBack() {
    context
        .read<ComposeFairmintBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    context
        .read<ComposeFairmintBloc>()
        .add(FinalizeTransactionEvent<ComposeFairmintResponse>(
          composeTransaction: composeTransaction,
          fee: fee,
        ));
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeFairmintBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeFairmintBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }
}

class UpperCaseTextEditingController extends TextEditingController {
  @override
  set value(TextEditingValue newValue) {
    super.value = newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: newValue.composing,
    );
  }
}
