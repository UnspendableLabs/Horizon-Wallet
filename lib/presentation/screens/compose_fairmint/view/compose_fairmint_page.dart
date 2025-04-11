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
  final int? initialNumLots;
  const ComposeFairmintPageWrapper({
    required this.dashboardActivityFeedBloc,
    this.initialFairminterTxHash,
    required this.currentAddress,
    this.initialNumLots,
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
          initialNumLots: initialNumLots,
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
  String? error;
  // Add a key for the dropdown
  Key _dropdownKey = UniqueKey();
  bool showLockedOnly = false;
  int numLots = 1;
  double? maxLots;
  double? maxMintPerTx;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address;
    numLots = context.read<ComposeFairmintBloc>().state.initialNumLots ?? 1;
  }

  @override
  void dispose() {
    fromAddressController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _updateMaxLots(Fairminter? fairminter) {
    if (fairminter != null &&
        fairminter.maxMintPerTx != null &&
        fairminter.quantityByPrice != null) {
      if (fairminter.maxMintPerTx! % fairminter.quantityByPrice! == 0) {
        maxMintPerTx = fairminter.maxMintPerTx! as double?;
      } else {
        maxMintPerTx = (fairminter.maxMintPerTx! -
                (fairminter.maxMintPerTx! % fairminter.quantityByPrice!))
            as double?;
      }
      maxLots =
          (maxMintPerTx! / fairminter.quantityByPrice!).floor().toDouble();
    } else {
      maxLots = null;
      maxMintPerTx = null;
    }
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

      try {
        int? quantity;
        if (state.selectedFairminter!.price != null &&
            state.selectedFairminter!.price! > 0) {
          quantity = getQuantityForDivisibility(
            inputQuantity: (numLots *
                    double.parse(
                        state.selectedFairminter!.quantityByPriceNormalized!))
                .toString(),
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

    _updateMaxLots(state.selectedFairminter);

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
              label: "a fairminter",
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
                  numLots = 1;
                  _updateMaxLots(value);
                });
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 16.0),
      if (state.selectedFairminter != null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            if (state.selectedFairminter!.price != null &&
                state.selectedFairminter!.price! > 0)
              FairminterProperty(
                label: 'Lot Price (XCP)',
                property:
                    satoshisToBtc(state.selectedFairminter!.price!).toString(),
              ),
            SizedBox(height: 8.0),
            FairminterProperty(
              label: 'Lot Size',
              property: numberWithCommas.format(double.parse(
                  state.selectedFairminter!.quantityByPriceNormalized!)),
            ),
            SizedBox(height: 8.0),
            if (state.selectedFairminter!.price != null &&
                state.selectedFairminter!.price! > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "No. of Lots",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  if (maxLots != null && maxLots! <= 1000)
                    Slider(
                      label: numLots.toString(),
                      value: numLots.toDouble().clamp(1.0, maxLots!),
                      min: 1,
                      max: maxLots!,
                      divisions: (maxLots! - 1).toInt(),
                      onChanged: (value) {
                        setState(() {
                          numLots = value.round();
                        });
                      },
                    )
                  else ...[
                    TextFormField(
                      initialValue: numLots.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed >= 1) {
                          setState(() {
                            numLots = maxLots != null && parsed > maxLots!
                                ? maxLots!.toInt()
                                : parsed;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Enter a value between 1 and ${numberWithCommas.format(maxLots ?? 1)}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 64,
                    children: [
                      FairminterProperty(
                        label: 'No. Lots',
                        property: numberWithCommas.format(numLots),
                      ),
                    ],
                  ),
                ],
              ),
            if (state.selectedFairminter!.price != null &&
                state.selectedFairminter!.price! > 0) ...[
              const SizedBox(height: 8.0),
              FairminterProperty(
                label: 'Lot Price (XCP)',
                property:
                    satoshisToBtc(state.selectedFairminter!.price!).toString(),
              ),
              const SizedBox(height: 8.0),
              FairminterProperty(
                label: 'Lot Size',
                property: numberWithCommas.format(double.parse(
                    state.selectedFairminter!.quantityByPriceNormalized!)),
              ),
              // FairminterProperty(
              //   label: 'Total XCP Price',
              //   property:
              //       "${_getTotalXCPPrice(state.selectedFairminter!)}",
              // ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  "Total Price ( XCP )",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Row(children: [
                  Text(
                    "${_getTotalXCPPrice(state.selectedFairminter!)}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text.rich(
                    TextSpan(
                      text: '',
                      children: [
                        TextSpan(
                          text:
                              '( $numLots lots X ${satoshisToBtc(state.selectedFairminter!.price!)} XCP )',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ])
              ])
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

  String _getTotalXCPPrice(Fairminter fairminter) {
    final price = numLots * satoshisToBtc(fairminter.price!).toDouble();
    return numberWithCommas.format(price);
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

class FairminterProperty extends StatelessWidget {
  final String label;
  final String property;

  const FairminterProperty({
    super.key,
    required this.label,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          property,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
