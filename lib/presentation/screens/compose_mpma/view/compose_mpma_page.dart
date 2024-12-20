import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_mpma/bloc/compose_mpma_bloc.dart';
import 'package:horizon/presentation/screens/compose_mpma/bloc/compose_mpma_event.dart';
import 'package:horizon/presentation/screens/compose_mpma/bloc/compose_mpma_state.dart';
import 'package:horizon/presentation/screens/compose_send/view/asset_dropdown.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class ComposeMpmaPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;

  const ComposeMpmaPageWrapper({
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
        create: (context) => ComposeMpmaBloc(
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          balanceRepository: GetIt.I.get<BalanceRepository>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          transactionService: GetIt.I.get<TransactionService>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          logger: GetIt.I.get<Logger>(),
        )..add(FetchFormData(currentAddress: currentAddress)),
        child: ComposeMpmaPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeMpmaPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;

  const ComposeMpmaPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  ComposeMpmaPageState createState() => ComposeMpmaPageState();
}

class ComposeMpmaPageState extends State<ComposeMpmaPage> {
  final TextEditingController fromAddressController = TextEditingController();
  final Map<int, TextEditingController> destinationControllers = {};
  final Map<int, TextEditingController> quantityControllers = {};
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address;
  }

  @override
  void dispose() {
    fromAddressController.dispose();
    for (var controller in destinationControllers.values) {
      controller.dispose();
    }
    for (var controller in quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getDestinationController(int index, String? text) {
    if (!destinationControllers.containsKey(index)) {
      destinationControllers[index] = TextEditingController(text: text);
    } else if (text != null && destinationControllers[index]?.text != text) {
      destinationControllers[index]?.text = text;
    }
    return destinationControllers[index]!;
  }

  TextEditingController _getQuantityController(int index, String? text) {
    if (!quantityControllers.containsKey(index)) {
      quantityControllers[index] = TextEditingController(text: text);
    } else if (text != null && quantityControllers[index]?.text != text) {
      quantityControllers[index]?.text = text;
    }
    return quantityControllers[index]!;
  }

  Widget _buildQuantityInput(ComposeMpmaState state,
      void Function() handleInitialSubmit, bool loading, int entryIndex) {
    return state.balancesState.maybeWhen(orElse: () {
      return _buildQuantityInputField(
          state, null, handleInitialSubmit, loading, entryIndex);
    }, success: (balances) {
      if (balances.isEmpty) {
        return const HorizonUI.HorizonTextFormField(enabled: false);
      }

      final entry = state.entries[entryIndex];
      Balance? balance = _getBalanceForSelectedAsset(
          balances, entry.asset ?? balances[0].asset);

      if (balance == null) {
        return const HorizonUI.HorizonTextFormField(enabled: false);
      }

      return _buildQuantityInputField(
          state, balance, handleInitialSubmit, loading, entryIndex);
    });
  }

  Widget _buildQuantityInputField(ComposeMpmaState state, Balance? balance,
      void Function() handleInitialSubmit, bool loading, int entryIndex) {
    final entry = state.entries[entryIndex];
    final controller = _getQuantityController(entryIndex, entry.quantity);

    return Stack(
      children: [
        HorizonUI.HorizonTextFormField(
          controller: controller,
          enabled: !loading,
          onChanged: (value) {
            context.read<ComposeMpmaBloc>().add(
                  UpdateEntryQuantity(
                    quantity: value,
                    entryIndex: entryIndex,
                  ),
                );
          },
          label: 'Quantity',
          inputFormatters: [
            balance?.assetInfo.divisible == true
                ? DecimalTextInputFormatter(decimalRange: 8)
                : FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: false),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a quantity';
            }
            try {
              Decimal input = Decimal.parse(value);
              Decimal max = Decimal.parse(balance?.quantityNormalized ?? '0');
              if (input > max) {
                return "quantity is greater than asset balance";
              }
            } catch (e) {
              return "Invalid number format";
            }
            return null;
          },
          onFieldSubmitted: (value) {
            handleInitialSubmit();
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        state.balancesState.maybeWhen(
          orElse: () {
            return const SizedBox.shrink();
          },
          success: (_) {
            return entry.asset != "BTC" && entry.asset != null
                ? Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2.0),
                          child: const Text(
                            'MAX',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            activeColor: Colors.blue,
                            value: entry.sendMax,
                            onChanged: loading
                                ? null
                                : (value) {
                                    if (value) {
                                      controller.text =
                                          balance?.quantityNormalized ?? '0';
                                      context.read<ComposeMpmaBloc>().add(
                                            UpdateEntryQuantity(
                                              quantity:
                                                  balance?.quantityNormalized ??
                                                      '0',
                                              entryIndex: entryIndex,
                                            ),
                                          );
                                    }
                                    context.read<ComposeMpmaBloc>().add(
                                          ToggleEntrySendMax(
                                            value: value,
                                            entryIndex: entryIndex,
                                          ),
                                        );
                                  },
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildAssetInput(
      ComposeMpmaState state, bool loading, int entryIndex) {
    return state.balancesState.maybeWhen(
        orElse: () => const AssetDropdownLoading(),
        success: (balances) {
          if (balances.isEmpty) {
            return const HorizonUI.HorizonTextFormField(
              enabled: false,
              label: "No assets",
            );
          }

          final entry = state.entries[entryIndex];
          final controller = TextEditingController(text: entry.asset);

          return SizedBox(
            height: 48,
            child: AssetDropdown(
              loading: loading,
              asset: entry.asset ?? balances[0].asset,
              balances: balances,
              controller: controller,
              onSelected: (String? value) {
                if (value == null) return;

                context.read<ComposeMpmaBloc>().add(
                      UpdateEntryAsset(
                        asset: value,
                        entryIndex: entryIndex,
                      ),
                    );
              },
            ),
          );
        });
  }

  List<Widget> _buildInitialFormFields(
      ComposeMpmaState state, bool loading, GlobalKey<FormState> formKey) {
    final width = MediaQuery.of(context).size.width;
    return [
      HorizonUI.HorizonTextFormField(
        enabled: false,
        controller: fromAddressController,
        label: "Source",
        onFieldSubmitted: (value) {
          _handleInitialSubmit(formKey);
        },
      ),
      const SizedBox(height: 16.0),
      ...state.entries.asMap().entries.map((mapEntry) {
        final entryIndex = mapEntry.key;
        final entry = mapEntry.value;

        return Column(
          children: [
            if (entryIndex > 0) const Divider(height: 32),
            HorizonUI.HorizonTextFormField(
              enabled: !loading,
              controller:
                  _getDestinationController(entryIndex, entry.destination),
              label: "Destination",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a destination address';
                }
                return null;
              },
              onChanged: (value) {
                context.read<ComposeMpmaBloc>().add(
                      UpdateEntryDestination(
                        destination: value,
                        entryIndex: entryIndex,
                      ),
                    );
              },
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
            ),
            const SizedBox(height: 16.0),
            if (width > 768)
              Row(children: [
                Expanded(
                    child: _buildQuantityInput(
                        state,
                        () => _handleInitialSubmit(formKey),
                        loading,
                        entryIndex)),
                const SizedBox(width: 16.0),
                Expanded(child: _buildAssetInput(state, loading, entryIndex)),
              ]),
            if (width <= 768)
              Column(children: [
                _buildQuantityInput(state, () => _handleInitialSubmit(formKey),
                    loading, entryIndex),
                const SizedBox(height: 16.0),
                _buildAssetInput(state, loading, entryIndex),
              ]),
          ],
        );
      }),
      const SizedBox(height: 16.0),
      Center(
        child: TextButton.icon(
          onPressed: loading
              ? null
              : () => context.read<ComposeMpmaBloc>().add(AddNewEntry()),
          icon: const Icon(Icons.add),
          label: const Text('Add another entry'),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeMpmaBloc, ComposeMpmaState>(
        listener: (context, state) {},
        builder: (context, state) {
          return ComposeBasePage<ComposeMpmaBloc, ComposeMpmaState>(
            dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
            onFeeChange: (fee) => context
                .read<ComposeMpmaBloc>()
                .add(ChangeFeeOption(value: fee)),
            buildInitialFormFields: (state, loading, formKey) =>
                _buildInitialFormFields(state, loading, formKey),
            onInitialCancel: () => _handleInitialCancel(),
            onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
            buildConfirmationFormFields: (state, composeTransaction, formKey) =>
                _buildConfirmationDetails(composeTransaction),
            onConfirmationBack: () => context
                .read<ComposeMpmaBloc>()
                .add(FetchFormData(currentAddress: widget.address)),
            onConfirmationContinue: (composeSend, fee, formKey) {
              // if (formKey.currentState!.validate()) {
              //   context.read<ComposeSendBloc>().add(
              //         FinalizeTransactionEvent<ComposeSendResponse>(
              //           composeTransaction: composeSend,
              //           fee: fee,
              //         ),
              //       );
              // }
            },
            onFinalizeSubmit: (password, formKey) {
              // if (formKey.currentState!.validate()) {
              //   context.read<ComposeSendBloc>().add(
              //         SignAndBroadcastTransactionEvent(
              //           password: password,
              //         ),
              //       );
              // }
            },
            onFinalizeCancel: () => context
                .read<ComposeMpmaBloc>()
                .add(FetchFormData(currentAddress: widget.address)),
          );
        });
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    setState(() {
      _submitted = true;
    });
    // if (formKey.currentState!.validate()) {
    //   Decimal input = Decimal.parse(quantityController.text);
    //   Balance? balance = balance_;
    //   int quantity;

    //   if (balance == null) {
    //     throw Exception("invariant: No balance found for asset");
    //   }

    //   if (balance.assetInfo.divisible) {
    //     quantity = (input * Decimal.fromInt(100000000)).toBigInt().toInt();
    //   } else {
    //     quantity = input.toBigInt().toInt();
    //   }

    //   context.read<ComposeSendBloc>().add(ComposeTransactionEvent(
    //         sourceAddress: widget.address,
    //         params: ComposeSendEventParams(
    //           destinationAddress: destinationAddressController.text,
    //           asset: asset!,
    //           quantity: quantity,
    //         ),
    //       ));
    // }
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    return [];
    // final params = (composeTransaction as ComposeSendResponse).params;
    // return [
    //   HorizonUI.HorizonTextFormField(
    //     label: "Source Address",
    //     controller: TextEditingController(text: params.source),
    //     enabled: false,
    //   ),
    //   const SizedBox(height: 16.0),
    //   HorizonUI.HorizonTextFormField(
    //     label: "Destination Address",
    //     controller: TextEditingController(text: params.destination),
    //     enabled: false,
    //   ),
    //   const SizedBox(height: 16.0),
    //   Row(
    //     children: [
    //       Expanded(
    //         child: HorizonUI.HorizonTextFormField(
    //           label: "Quantity",
    //           controller: TextEditingController(text: params.quantityNormalized),
    //           enabled: false,
    //         ),
    //       ),
    //       const SizedBox(width: 16.0), // Spacing between inputs
    //       Expanded(
    //         child: HorizonUI.HorizonTextFormField(
    //           label: "Asset",
    //           controller: TextEditingController(text: params.asset),
    //           enabled: false,
    //         ),
    //       ),
    //     ],
    //   ),
    // ];
  }

  @override
  void didUpdateWidget(ComposeMpmaPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final state = context.read<ComposeMpmaBloc>().state;
    final validIndices = state.entries.asMap().keys.toSet();

    destinationControllers.keys.toList().forEach((index) {
      if (!validIndices.contains(index)) {
        destinationControllers[index]?.dispose();
        destinationControllers.remove(index);
      }
    });

    quantityControllers.keys.toList().forEach((index) {
      if (!validIndices.contains(index)) {
        quantityControllers[index]?.dispose();
        quantityControllers.remove(index);
      }
    });
  }
}

Balance? _getBalanceForSelectedAsset(List<Balance> balances, String asset) {
  if (balances.isEmpty) {
    return null;
  }

  return balances.firstWhereOrNull((balance) => balance.asset == asset) ??
      balances[0];
}
