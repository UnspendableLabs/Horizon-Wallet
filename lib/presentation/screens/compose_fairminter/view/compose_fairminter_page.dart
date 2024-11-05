import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/compose_fairminter.dart';
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_fairminter/bloc/compose_fairminter_bloc.dart';
import 'package:horizon/presentation/screens/compose_fairminter/bloc/compose_fairminter_state.dart';
import 'package:horizon/presentation/screens/compose_fairminter/usecase/fetch_form_data.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeFairminterPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;

  const ComposeFairminterPageWrapper({
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
        )..add(FetchFormData(currentAddress: currentAddress)),
        child: ComposeFairminterPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeFairminterPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
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
  bool isLocked = false;

  String? error;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeFairminterBloc, ComposeFairminterState>(
      listener: (context, state) {},
      builder: (context, state) {
        return state.assetState.maybeWhen(
          loading: () =>
              ComposeBasePage<ComposeFairminterBloc, ComposeFairminterState>(
                  dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
                  onFeeChange: (fee) => context
                      .read<ComposeFairminterBloc>()
                      .add(ChangeFeeOption(value: fee)),
                  buildInitialFormFields: (state, loading, formKey) => [
                        HorizonUI.HorizonTextFormField(
                          label: "Address that will be minting the asset",
                          controller: fromAddressController,
                          enabled: false,
                        ),
                        const SizedBox(height: 16.0),
                        const HorizonUI.HorizonTextFormField(
                          label: "Select an asset",
                          enabled: false,
                        ),
                        const SizedBox(height: 16.0),
                        const HorizonUI.HorizonTextFormField(
                          label: "Max mint per transaction",
                          enabled: false,
                        ),
                        const SizedBox(height: 16.0),
                        const HorizonUI.HorizonTextFormField(
                          label: "Hard cap",
                          enabled: false,
                        ),
                        const SizedBox(height: 16.0),
                        const HorizonUI.HorizonTextFormField(
                          label: "Start block (optional)",
                          enabled: false,
                        )
                      ],
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

      Decimal maxMintPerTxInput = Decimal.parse(maxMintPerTxController.text);
      Decimal hardcapInput = Decimal.parse(hardcapController.text);

      if (hardcapInput % maxMintPerTxInput != Decimal.zero) {
        setState(() {
          error = 'Hardcap must be divisible by max mint per transaction';
        });
        return;
      }

      int maxMintPerTxDivisible =
          (maxMintPerTxInput * Decimal.fromInt(100000000)).toBigInt().toInt();
      int hardcapDivisible =
          (hardcapInput * Decimal.fromInt(100000000)).toBigInt().toInt();
      String? parent;
      String? subAsset;
      final fullAssetName =
          displayAssetName(asset!.asset, asset!.assetLongname);
      if (fullAssetName.contains('.')) {
        parent = fullAssetName.split('.')[0];
        subAsset = fullAssetName.split('.')[1];
      }

      print('parent: $parent');
      print('subAsset: $subAsset');
      context.read<ComposeFairminterBloc>().add(ComposeTransactionEvent(
            sourceAddress: widget.address,
            params: ComposeFairminterEventParams(
              parent: parent,
              asset: subAsset ?? asset!.asset,
              maxMintPerTx: asset!.divisible!
                  ? maxMintPerTxDivisible
                  : int.parse(maxMintPerTxController.text),
              hardCap: asset!.divisible!
                  ? hardcapDivisible
                  : int.parse(hardcapController.text),
              divisible: asset!.divisible!,
              startBlock: startBlockController.text.isEmpty
                  ? null
                  : int.parse(startBlockController.text),
              isLocked: isLocked,
            ),
          ));
    }
  }

  List<Widget> _buildInitialFormFields(ComposeFairminterState state,
      bool loading, GlobalKey<FormState> formKey, List<Asset> assets) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return [
      HorizonUI.HorizonTextFormField(
        label: "Address that will be minting the asset",
        controller: fromAddressController,
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonSearchableDropdownMenu<Asset>(
        label: "Select an asset",
        items: assets
            .where((asset) => asset.locked == false)
            .map((asset) => DropdownMenuItem(
                value: asset,
                child:
                    Text(displayAssetName(asset.asset, asset.assetLongname))))
            .toList(),
        onChanged: (Asset? value) => setState(() {
          asset = value;
          error = null;
        }),
        selectedValue: asset,
        displayStringForOption: (Asset asset) =>
            displayAssetName(asset.asset, asset.assetLongname),
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Max mint per transaction",
        controller: maxMintPerTxController,
        onChanged: (value) {
          setState(() {
            error = null;
          });
        },
        inputFormatters: [
          asset?.divisible == true
              ? DecimalTextInputFormatter(decimalRange: 20)
              : FilteringTextInputFormatter.digitsOnly,
        ],
        autovalidateMode:
            _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
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
        onChanged: (value) {
          setState(() {
            error = null;
          });
        },
        inputFormatters: [
          asset?.divisible == true
              ? DecimalTextInputFormatter(decimalRange: 20)
              : FilteringTextInputFormatter.digitsOnly,
        ],
        autovalidateMode:
            _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
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
      Column(children: [
        Row(
          children: [
            Checkbox(
              value: isLocked,
              onChanged: (value) {
                setState(() {
                  isLocked = value ?? false;
                  error = null;
                });
              },
            ),
            Text('Lock Quantity',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? mainTextWhite : mainTextBlack)),
          ],
        ),
        const Row(
          children: [
            SizedBox(width: 30.0),
            Expanded(
              child: Text(
                'If quantity is locked, additional issuances cannot be done after hard cap is reached. Defaults to false.',
              ),
            ),
          ],
        ),
      ]),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Start block (optional)",
        controller: startBlockController,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
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
    final params = (composeTransaction as ComposeFairminterResponse).params;
    final Decimal maxMintPerTxNormalized =
        quantityToQuantityNormalized(params.maxMintPerTx!, params.divisible!);
    final Decimal hardcapNormalized =
        quantityToQuantityNormalized(params.hardCap!, params.divisible!);
    final String assetName = params.assetParent == null
        ? params.asset
        : "${params.assetParent}.${params.asset}";
    return [
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Asset",
        controller: TextEditingController(text: assetName),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Max mint per transaction",
        controller: TextEditingController(
            text: params.divisible!
                ? maxMintPerTxNormalized.toStringAsFixed(8)
                : maxMintPerTxNormalized.toString()),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Hard cap",
        controller: TextEditingController(
            text: params.divisible!
                ? hardcapNormalized.toStringAsFixed(8)
                : hardcapNormalized.toString()),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Quantity Locked",
        controller: TextEditingController(text: params.lockQuantity.toString()),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Start block",
        controller: TextEditingController(text: params.startBlock.toString()),
        enabled: false,
      ),
    ];
  }

  void _onConfirmationBack() {
    context
        .read<ComposeFairminterBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    context
        .read<ComposeFairminterBloc>()
        .add(FinalizeTransactionEvent<ComposeFairminterResponse>(
          composeTransaction: composeTransaction,
          fee: fee,
        ));
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeFairminterBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeFairminterBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }
}
