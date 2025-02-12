import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_fairmint.dart';
import 'package:horizon/domain/entities/fairminter.dart';
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_fairmint/bloc/compose_fairmint_bloc.dart';
import 'package:horizon/presentation/screens/compose_fairmint/bloc/compose_fairmint_state.dart';
import 'package:horizon/presentation/screens/compose_fairmint/bloc/compose_fairmint_event.dart';
import 'package:horizon/presentation/screens/compose_fairmint/usecase/fetch_form_data.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';

class ComposeFairmintPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String? initialFairminterTxHash;
  final String currentAddress;
  const ComposeFairmintPageWrapper({
    required this.dashboardActivityFeedBloc,
    this.initialFairminterTxHash,
    required this.currentAddress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>();
    return session.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeFairmintBloc(
          passwordRequired:
              GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
          inMemoryKeyRepository: GetIt.I.get<InMemoryKeyRepository>(),
          initialFairminterTxHash: initialFairminterTxHash,
          logger: GetIt.I.get<Logger>(),
          fetchComposeFairmintFormDataUseCase:
              GetIt.I.get<FetchComposeFairmintFormDataUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          blockRepository: GetIt.I.get<BlockRepository>(),
        )..add(AsyncFormDependenciesRequested(currentAddress: currentAddress)),
        child: ComposeFairmintPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeFairmintPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
  const ComposeFairmintPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  ComposeFairmintPageState createState() => ComposeFairmintPageState();
}

class ComposeFairmintPageState extends State<ComposeFairmintPage> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController nameController = UpperCaseTextEditingController();

  bool _submitted = false;
  String? error;
  bool _isAssetNameSelected = false;
  // Add a key for the dropdown
  Key _dropdownKey = UniqueKey();
  bool showLockedOnly = false;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeFairmintBloc, ComposeFairmintState>(
      listener: (context, state) {},
      builder: (context, state) {
        return state.fairmintersState.maybeWhen(
          loading: () =>
              ComposeBasePage<ComposeFairmintBloc, ComposeFairmintState>(
                  dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
                  onFeeChange: (fee) => context
                      .read<ComposeFairmintBloc>()
                      .add(FeeOptionChanged(value: fee)),
                  buildInitialFormFields: (state, loading, formKey) => [
                        HorizonUI.HorizonTextFormField(
                          label: "Address that will be minting the asset",
                          controller: fromAddressController,
                          enabled: false,
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PopupMenuButton<bool>(
                              enabled: false,
                              icon: const Icon(
                                Icons.filter_list,
                              ),
                              itemBuilder: (context) => [],
                              onSelected: (bool value) {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        const HorizonUI.HorizonTextFormField(
                          label: "Select a fairminter",
                          enabled: false,
                        ),
                        const SizedBox(height: 16.0),
                        HorizonUI.HorizonTextFormField(
                            label: "Name of the asset to mint",
                            controller: nameController,
                            enabled: false),
                      ],
                  onInitialCancel: () => _handleInitialCancel(),
                  onInitialSubmit: (formKey) {},
                  buildConfirmationFormFields:
                      (state, composeTransaction, formKey) => [],
                  onConfirmationBack: () {},
                  onConfirmationContinue: (composeTransaction, fee, formKey) {},
                  onFinalizeSubmit: (password, formKey) {},
                  onFinalizeCancel: () {}),
          success: (fairminters) =>
              ComposeBasePage<ComposeFairmintBloc, ComposeFairmintState>(
            dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
            onFeeChange: (fee) => context
                .read<ComposeFairmintBloc>()
                .add(FeeOptionChanged(value: fee)),
            buildInitialFormFields: (state, loading, formKey) =>
                _buildInitialFormFields(state, loading, formKey, fairminters),
            onInitialCancel: () => _handleInitialCancel(),
            onInitialSubmit: (formKey) =>
                _handleInitialSubmit(formKey, fairminters, state),
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

  void _handleInitialSubmit(GlobalKey<FormState> formKey,
      List<Fairminter> fairminters, ComposeFairmintState state) {
    setState(() {
      _submitted = true;
    });
    if (formKey.currentState!.validate()) {
      if (!_isAssetNameSelected && state.selectedFairminter == null) {
        setState(() {
          error = 'Please select a fairminter';
        });
        return;
      } else if (_isAssetNameSelected && nameController.text.isEmpty) {
        setState(() {
          error = 'Please enter a fairminter name';
        });
        return;
      }

      if (_isAssetNameSelected &&
          !fairminters
              .any((fairminter) => fairminter.asset == nameController.text)) {
        setState(() {
          error = 'Fairminter with name ${nameController.text} not found';
        });
        return;
      }

      context.read<ComposeFairmintBloc>().add(FormSubmitted(
            sourceAddress: widget.address,
            params: ComposeFairmintEventParams(
              asset: _isAssetNameSelected
                  ? state.selectedFairminter!.asset ?? nameController.text
                  : state.selectedFairminter!.asset!,
            ),
          ));
    } else {
      setState(() {
        error = 'unknown error: invalid form';
      });
    }
  }

  List<Widget> _buildInitialFormFields(ComposeFairmintState state, bool loading,
      GlobalKey<FormState> formKey, List<Fairminter> fairminters) {
    if (fairminters.isEmpty) {
      return [
        const SelectableText('No fairminters found'),
      ];
    }

    final validFairminters = fairminters.where((fairminter) {
      return fairminter.status != null &&
          fairminter.status == 'open' &&
          fairminter.price != null &&
          fairminter.price! == 0;
    }).toList();

    final filteredFairminters = showLockedOnly
        ? validFairminters.where((f) => f.lockQuantity == true).toList()
        : validFairminters;

    return [
      HorizonUI.HorizonTextFormField(
        label: "Address that will be minting the asset",
        controller: fromAddressController,
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showLockedOnly)
            TextButton.icon(
              onPressed: _isAssetNameSelected
                  ? null
                  : () {
                      setState(() {
                        showLockedOnly = false;
                        context
                            .read<ComposeFairmintBloc>()
                            .add(FairminterChanged(value: null));
                        _dropdownKey = UniqueKey();
                      });
                    },
              icon: const Icon(Icons.clear),
              label: const Text('Clear filter'),
              style: TextButton.styleFrom(
                foregroundColor: _isAssetNameSelected ? Colors.grey : null,
              ),
            ),
          PopupMenuButton<bool>(
            enabled: !_isAssetNameSelected,
            icon: Icon(
              Icons.filter_list,
              color: _isAssetNameSelected ? Colors.grey : null,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      showLockedOnly
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Show only locked quantity fairminters',
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (bool value) {
              setState(() {
                showLockedOnly = value;
                context
                    .read<ComposeFairmintBloc>()
                    .add(FairminterChanged(value: null));
                _dropdownKey = UniqueKey();
              });
            },
          ),
        ],
      ),
      const SizedBox(height: 16.0),
      Row(
        children: [
          Radio<bool>(
            value: false,
            groupValue: _isAssetNameSelected,
            onChanged: (value) {
              setState(() {
                error = null;
                _isAssetNameSelected = value!;
                if (!_isAssetNameSelected) {
                  // Clear the asset name input when switching to dropdown
                  nameController.clear();
                }
              });
            },
          ),
          Expanded(
            child: _isAssetNameSelected
                ? const HorizonUI.HorizonTextFormField(
                    label: "Select a fairminter",
                    enabled: false,
                  )
                : HorizonUI.HorizonSearchableDropdownMenu(
                    key: _dropdownKey, // Add the key here
                    displayStringForOption: (fairminter) => displayAssetName(
                        fairminter.asset!, fairminter.assetLongname),
                    label: "Select a fairminter",
                    selectedValue:
                        _isAssetNameSelected ? null : state.selectedFairminter,
                    items: filteredFairminters
                        .map((fairminter) => DropdownMenuItem(
                            value: fairminter,
                            child: Text(displayAssetName(
                                fairminter.asset!, fairminter.assetLongname))))
                        .toList(),
                    onChanged: _isAssetNameSelected
                        ? null
                        : (Fairminter? value) {
                            if (!_isAssetNameSelected) {
                              context
                                  .read<ComposeFairmintBloc>()
                                  .add(FairminterChanged(value: value));
                            }
                          },
                    enabled: !_isAssetNameSelected,
                  ),
          ),
        ],
      ),
      const SizedBox(height: 16.0),
      Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: _isAssetNameSelected,
            onChanged: (value) {
              setState(() {
                error = null;
                _isAssetNameSelected = value!;
                if (_isAssetNameSelected) {
                  // Clear the dropdown value when switching to asset name input
                  context
                      .read<ComposeFairmintBloc>()
                      .add(FairminterChanged(value: null));
                  // Reset the dropdown key to force a re-render
                  _dropdownKey = UniqueKey();
                  showLockedOnly = false;
                }
              });
            },
          ),
          Expanded(
            child: HorizonUI.HorizonTextFormField(
              label: "Name of the asset to mint",
              controller: nameController,
              enabled: _isAssetNameSelected,
              onChanged: (value) {
                if (_isAssetNameSelected) {
                  final Fairminter? fairminter = fairminters.firstWhereOrNull(
                      (fairminter) => fairminter.asset == value);
                  context
                      .read<ComposeFairmintBloc>()
                      .add(FairminterChanged(value: fairminter));
                }
              },
              onFieldSubmitted: (value) {
                if (_isAssetNameSelected) {
                  _handleInitialSubmit(formKey, fairminters, state);
                }
              },
            ),
          ),
        ],
      ),
      state.selectedFairminter != null
          ? Column(
              children: [
                const SizedBox(height: 16.0),
                SelectableText(
                    'Quantity Locked After Fairminter Closes: ${state.selectedFairminter!.lockQuantity}'),
              ],
            )
          : const SizedBox.shrink(),
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
        label: "Mint Quantity",
        controller: TextEditingController(text: _formatMintQuantity()),
        enabled: false,
      ),
    ];
  }

  String _formatMintQuantity() {
    final fairminter =
        context.read<ComposeFairmintBloc>().state.selectedFairminter;

    if (fairminter == null || fairminter.maxMintPerTxNormalized == null) {
      return '';
    }

    return fairminter.maxMintPerTxNormalized!;
  }

  void _onConfirmationBack() {
    context
        .read<ComposeFairmintBloc>()
        .add(AsyncFormDependenciesRequested(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    context
        .read<ComposeFairmintBloc>()
        .add(ReviewSubmitted<ComposeFairmintResponse>(
          composeTransaction: composeTransaction,
          fee: fee,
        ));
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeFairmintBloc>().add(
            SignAndBroadcastFormSubmitted(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeFairmintBloc>()
        .add(AsyncFormDependenciesRequested(currentAddress: widget.address));
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
