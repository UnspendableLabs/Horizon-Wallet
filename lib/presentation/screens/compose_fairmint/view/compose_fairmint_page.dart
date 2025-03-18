import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart';
import 'package:horizon/common/format.dart';
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
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController nameController = UpperCaseTextEditingController();
  TextEditingController quantityController = TextEditingController();
  String? error;
  // Add a key for the dropdown
  Key _dropdownKey = UniqueKey();
  bool showLockedOnly = false;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address;
    quantityController.addListener(() {
      setState(() {}); // Trigger rebuild when quantity changes
    });
  }

  @override
  void dispose() {
    quantityController.dispose();
    fromAddressController.dispose();
    nameController.dispose();
    super.dispose();
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
    if (formKey.currentState!.validate()) {
      if (state.selectedFairminter == null) {
        setState(() {
          error = 'Please select a fairminter';
        });
        return;
      }

      if (state.selectedFairminter!.price != null &&
          state.selectedFairminter!.price! > 0 &&
          quantityController.text.isEmpty) {
        setState(() {
          error = 'Please enter a quantity';
        });
        return;
      }

      try {
        int? quantity;
        if (state.selectedFairminter!.price != null &&
            state.selectedFairminter!.price! > 0) {
          quantity = getQuantityForDivisibility(
            inputQuantity: quantityController.text,
            divisible: state.selectedFairminter!.divisible ?? false,
          );
        } else {
          quantity = null;
        }

        context.read<ComposeFairmintBloc>().add(FormSubmitted(
              sourceAddress: widget.address,
              params: ComposeFairmintEventParams(
                asset: state.selectedFairminter!.asset!,
                quantity: quantity,
              ),
            ));
      } catch (e) {
        setState(() {
          error = 'Invalid quantity format';
        });
      }
    } else {
      setState(() {
        error = 'Please fix the validation errors';
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
      return fairminter.status != null && fairminter.status == 'open';
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
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showLockedOnly)
            TextButton.icon(
              onPressed: () {
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
                foregroundColor: Colors.grey,
              ),
            ),
          PopupMenuButton<bool>(
            icon: const Icon(
              Icons.filter_list,
              color: Colors.grey,
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
          Expanded(
            child: HorizonUI.HorizonSearchableDropdownMenu(
              key: _dropdownKey, // Add the key here
              displayStringForOption: (fairminter) =>
                  displayAssetName(fairminter.asset!, fairminter.assetLongname),
              label: "Select a fairminter",
              selectedValue: state.selectedFairminter,
              items: filteredFairminters
                  .map((fairminter) => DropdownMenuItem(
                      value: fairminter,
                      child: Text(displayAssetName(
                          fairminter.asset!, fairminter.assetLongname))))
                  .toList(),
              onChanged: (Fairminter? value) {
                context
                    .read<ComposeFairmintBloc>()
                    .add(FairminterChanged(value: value));
                setState(() {
                  quantityController.text = '';
                });
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 16.0),
      if (state.selectedFairminter != null)
        Column(
          children: [
            const SizedBox(height: 16.0),
            SelectableText(
                'Quantity Locked After Fairminter Closes: ${state.selectedFairminter!.lockQuantity}'),
            if (state.selectedFairminter!.price != null &&
                state.selectedFairminter!.price! > 0) ...[
              SelectableText(
                  'XCP price by token: ${_getXCPPricePerToken(state.selectedFairminter!.price!, state.selectedFairminter!.quantityByPrice!, state.selectedFairminter!.divisible)}'),
              SelectableText(
                  'Max mint per tx: ${state.selectedFairminter!.maxMintPerTxNormalized}'),
              HorizonUI.HorizonTextFormField(
                label: 'Quantity',
                controller: quantityController,
                enabled: true,
                autovalidateMode: AutovalidateMode.always,
                inputFormatters: [
                  state.selectedFairminter!.divisible == true
                      ? DecimalTextInputFormatter(decimalRange: 8)
                      : FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (value == '.') {
                    // Don't validate if the user is typing a decimal point
                    return null;
                  }
                  if (Decimal.parse(value) >
                      Decimal.parse(
                          state.selectedFairminter!.maxMintPerTxNormalized!)) {
                    return 'Quantity must be <= ${state.selectedFairminter!.maxMintPerTxNormalized}';
                  }
                  return null;
                },
              ),
              if (quantityController.text.isNotEmpty) ...[
                Builder(
                  builder: (context) {
                    try {
                      return Column(
                        children: [
                          SelectableText(
                              'Total XCP price: ${_getTotalXCPPriceForQuantity(quantityController.text, state.selectedFairminter!.price!, state.selectedFairminter!.quantityByPrice!, state.selectedFairminter!.divisible)}'),
                        ],
                      );
                    } catch (e) {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ]
          ],
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
        label: "Mint Quantity",
        controller: TextEditingController(text: _formatMintQuantity(params)),
        enabled: false,
      ),
    ];
  }

  String _formatMintQuantity(ComposeFairmintParams params) {
    final fairminter =
        context.read<ComposeFairmintBloc>().state.selectedFairminter;

    if (fairminter == null || fairminter.maxMintPerTxNormalized == null) {
      return '';
    }
    if (params.quantity != 0) {
      return params.quantityNormalized!;
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

  num _getXCPPricePerToken(num price, num quantityByPrice, bool? divisible) {
    // XCP price by token calculation:
    // If price = XCP cost per price unit
    // quantityByPrice = tokens received per price unit
    // Then: pricePerToken = price / quantityByPrice
    // This gives the XCP cost for a single token

    final pricePerToken = price / quantityByPrice;
    if (divisible == true) {
      return pricePerToken;
    }
    return double.parse((pricePerToken).toStringAsFixed(8));
  }

  Decimal _getTotalXCPPriceForQuantity(
      // Total XCP price calculation:
      // If quantity = tokens to mint
      // quantityByPrice = tokens received per price unit
      // price = XCP cost per price unit
      // Then: totalXCP = (quantity / quantityByPrice) * price
      // This gives the total XCP needed to mint the requested quantity of tokens
      String quantityInput,
      num price,
      num quantityByPrice,
      bool? divisible) {
    final quantity = Decimal.parse(quantityInput);
    final pricePerToken = Decimal.parse((price / quantityByPrice).toString());
    if (divisible == true) {
      return quantity * pricePerToken;
    }

    return ((quantity * pricePerToken).ceil() / Decimal.fromInt(SATOSHI_RATE))
        .toDecimal(scaleOnInfinitePrecision: 8);
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
