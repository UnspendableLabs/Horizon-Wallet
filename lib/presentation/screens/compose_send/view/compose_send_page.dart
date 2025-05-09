import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_bloc.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';
import 'package:horizon/presentation/screens/compose_send/view/asset_dropdown.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

import 'package:horizon/domain/repositories/settings_repository.dart';

class ComposeSendPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  final String? asset;

  const ComposeSendPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    this.asset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>();
    return session.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeSendBloc(
          passwordRequired:
              GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
          inMemoryKeyRepository: GetIt.I.get<InMemoryKeyRepository>(),
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
        )..add(AsyncFormDependenciesRequested(currentAddress: currentAddress)),
        child: ComposeSendPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
          asset: asset,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeSendPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
  final String? asset;
  const ComposeSendPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
    this.asset,
  });

  @override
  ComposeSendPageState createState() => ComposeSendPageState();
}

class ComposeSendPageState extends State<ComposeSendPage> {
  TextEditingController destinationAddressController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController assetController = TextEditingController();

  String? asset;
  Balance? balance_;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address;
    asset = widget.asset;
    if (asset != null) {
      context.read<ComposeSendBloc>().add(ChangeAsset(asset: asset!));
    }
  }

  String _formatMaxValue(ComposeSendState state, int maxValue, String? asset) {
    // You may need to adjust this based on your asset's divisibility
    final balance = _getBalanceForSelectedAsset(
        state.balancesState.maybeWhen(
          success: (balances) => balances,
          orElse: () => [],
        ),
        asset ?? '');
    if (balance == null) {
      throw Exception("invariant: No balance found for asset $asset");
    }

    String maxQuantityNormalized = quantityToQuantityNormalizedString(
        quantity: maxValue, divisible: balance.assetInfo.divisible);
    return maxQuantityNormalized;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeSendBloc, ComposeSendState>(
        listener: (context, state) {
      state.maxValue.maybeWhen(
        loading: () {
          if (state.sendMax) {
            quantityController.text = '';
          }
        },
        error: (_) {
          quantityController.text = '';
        },
        success: (maxValue) {
          if (state.sendMax) {
            if (state.submitState is FormStep) {
              // we only want to set the quantity to the max if we are in the initial state
              final formattedValue =
                  _formatMaxValue(state, maxValue, state.asset);

              if (formattedValue != quantityController.text) {
                quantityController.text = formattedValue;
              }
            }
          }
        },
        orElse: () {},
      );
    }, builder: (context, state) {
      return ComposeBasePage<ComposeSendBloc, ComposeSendState>(
        dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
        onFeeChange: (fee) =>
            context.read<ComposeSendBloc>().add(FeeOptionChanged(value: fee)),
        buildInitialFormFields: (state, loading, formKey) =>
            _buildInitialFormFields(state, loading, formKey),
        onInitialCancel: () => _handleInitialCancel(),
        onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
        buildConfirmationFormFields: (state, composeTransaction, formKey) =>
            _buildConfirmationDetails(composeTransaction),
        onConfirmationBack: () => context.read<ComposeSendBloc>().add(
            AsyncFormDependenciesRequested(currentAddress: widget.address)),
        onConfirmationContinue: (composeSend, fee, formKey) {
          if (formKey.currentState!.validate()) {
            context.read<ComposeSendBloc>().add(
                  ReviewSubmitted<ComposeSendResponse>(
                    composeTransaction: composeSend,
                    fee: fee,
                  ),
                );
          }
        },
        onFinalizeSubmit: (password, formKey) {
          if (formKey.currentState!.validate()) {
            context.read<ComposeSendBloc>().add(
                  SignAndBroadcastFormSubmitted(
                    password: password,
                  ),
                );
          }
        },
        onFinalizeCancel: () => context.read<ComposeSendBloc>().add(
            AsyncFormDependenciesRequested(currentAddress: widget.address)),
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
    if (formKey.currentState!.validate()) {
      Balance? balance = balance_;

      if (asset == null) {
        throw Exception("no asset selected");
      }

      if (balance == null) {
        throw Exception("invariant: No balance found for asset: $asset");
      }

      int quantity = getQuantityForDivisibility(
          divisible: balance.assetInfo.divisible,
          inputQuantity: quantityController.text);

      context.read<ComposeSendBloc>().add(FormSubmitted(
            sourceAddress: widget.address,
            params: ComposeSendEventParams(
              destinationAddress: destinationAddressController.text,
              asset: asset!,
              quantity: quantity,
            ),
          ));
    }
  }

  List<Widget> _buildInitialFormFields(
      ComposeSendState state, bool loading, GlobalKey<FormState> formKey) {
    final width = MediaQuery.of(context).size.width;
    return [
      HorizonUI.HorizonTextFormField(
        enabled: false,
        controller: fromAddressController,
        label: "Source",
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        enabled: !loading,
        controller: destinationAddressController,
        label: "Destination",
        onChanged: (value) {
          context.read<ComposeSendBloc>().add(ChangeDestination(value: value));
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a destination address';
          }
          return null;
        },
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
      ),
      const SizedBox(height: 16.0),
      if (width > 768)
        Row(
            children: _buildQuantityAndAssetInputsForRow(
                state, () => _handleInitialSubmit(formKey), loading)),
      if (width <= 768)
        Column(children: [
          _buildQuantityInput(
              state, () => _handleInitialSubmit(formKey), loading),
          const SizedBox(height: 16.0),
          _buildAssetInput(state, loading)
        ]),
    ];
  }

  List<Widget> _buildQuantityAndAssetInputsForRow(ComposeSendState state,
      void Function() handleInitialSubmit, bool loading) {
    return [
      Expanded(
          // TODO: make his type of input it's own component ( e.g. BalanceInput )
          child: Builder(builder: (context) {
        return _buildQuantityInput(state, handleInitialSubmit, loading);
      })),
      const SizedBox(width: 16.0),
      Expanded(
        child: Builder(builder: (context) {
          return _buildAssetInput(state, loading);
        }),
      )
    ];
  }

  Widget _buildQuantityInput(ComposeSendState state,
      void Function() handleInitialSubmit, bool loading) {
    return state.balancesState.maybeWhen(orElse: () {
      return _buildQuantityInputField(
          state, null, handleInitialSubmit, loading);
    }, success: (balances) {
      if (balances.isEmpty) {
        return const HorizonUI.HorizonTextFormField(
          enabled: false,
        );
      }

      Balance? balance = balance_ ??
          _getBalanceForSelectedAsset(balances, asset ?? balances[0].asset);

      if (balance == null) {
        return const HorizonUI.HorizonTextFormField(
          enabled: false,
        );
      }

      return _buildQuantityInputField(
          state, balance, handleInitialSubmit, loading);
    });
  }

  Widget _buildQuantityInputField(ComposeSendState state, Balance? balance,
      void Function() handleInitialSubmit, bool loading) {
    return Stack(
      children: [
        HorizonUI.HorizonTextFormField(
          controller: quantityController,
          enabled: !loading,
          onChanged: (value) {
            setState(() {
              balance_ = balance;
            });
            context.read<ComposeSendBloc>().add(ChangeQuantity(value: value));
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
            if (value != '.') {
              Decimal input = Decimal.parse(value);
              Decimal max = Decimal.parse(balance?.quantityNormalized ?? '0');
              if (input > max) {
                return "quantity exceeds max";
              }
            } else {
              return 'Please enter a quantity';
            }

            return null;
          },
          onFieldSubmitted: (value) {
            handleInitialSubmit();
          },
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
        ),
        state.sendMax
            ? state.maxValue.maybeWhen(
                loading: () => const Positioned(
                  left: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              )
            : const SizedBox.shrink(),
        state.balancesState.maybeWhen(orElse: () {
          return const SizedBox.shrink();
        }, success: (_) {
          return asset != "BTC" && asset != null
              ? Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2.0),
                        child: const Text('MAX',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          activeColor: Colors.blue,
                          value: state.sendMax,
                          onChanged: loading
                              ? null
                              : (value) {
                                  context
                                      .read<ComposeSendBloc>()
                                      .add(ToggleSendMaxEvent(value: value));
                                },
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildAssetInput(ComposeSendState state, bool loading) {
    return state.balancesState.maybeWhen(
        orElse: () => const AssetDropdownLoading(),
        success: (balances) {
          if (balances.isEmpty) {
            return const HorizonUI.HorizonTextFormField(
              enabled: false,
              label: "No assets",
            );
          }

          // Use a post-frame callback to set the asset state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (asset == null) {
              setState(() {
                asset = balances[0].asset;
              });
            }
          });
          return SizedBox(
            height: 48,
            child: AssetDropdown(
              loading: loading,
              asset: asset,
              balances: balances,
              controller: assetController,
              onSelected: (String? value) {
                Balance? balance =
                    _getBalanceForSelectedAsset(balances, value!);

                if (balance == null) {
                  throw Exception(
                      "invariant: No balance found for asset: $value");
                }

                setState(() {
                  asset = value;
                  balance_ = balance;
                  quantityController.text = '';
                });

                context.read<ComposeSendBloc>().add(ChangeAsset(asset: value));
              },
            ),
          );
        });
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeSendResponse).params;
    return [
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Destination Address",
        controller: TextEditingController(text: params.destination),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      Row(
        children: [
          Expanded(
            child: HorizonUI.HorizonTextFormField(
              label: "Quantity",
              controller:
                  TextEditingController(text: params.quantityNormalized),
              enabled: false,
            ),
          ),
          const SizedBox(width: 16.0), // Spacing between inputs
          Expanded(
            child: HorizonUI.HorizonTextFormField(
              label: "Asset",
              controller: TextEditingController(
                  text: displayAssetName(
                      params.asset, params.assetInfo.assetLongname)),
              enabled: false,
            ),
          ),
        ],
      ),
    ];
  }
}

Balance? _getBalanceForSelectedAsset(List<Balance> balances, String asset) {
  if (balances.isEmpty) {
    return null;
  }

  return balances.firstWhereOrNull((balance) => balance.asset == asset);
}
