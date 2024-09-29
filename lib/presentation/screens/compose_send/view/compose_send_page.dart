import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/fee_estimation_v2.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/screens/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_bloc.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";
import 'package:horizon/presentation/screens/shared/view/horizon_dropdown_menu.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_text_field.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class ComposeSendPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;

  const ComposeSendPageWrapper({
    required this.dashboardActivityFeedBloc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => ComposeSendBloc(
          analyticsService: GetIt.I.get<AnalyticsService>(),
          addressRepository: GetIt.I.get<AddressRepository>(),
          balanceRepository: GetIt.I.get<BalanceRepository>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          utxoRepository: GetIt.I.get<UtxoRepository>(),
          transactionService: GetIt.I.get<TransactionService>(),
          bitcoindService: GetIt.I.get<BitcoindService>(),
          accountRepository: GetIt.I.get<AccountRepository>(),
          walletRepository: GetIt.I.get<WalletRepository>(),
          encryptionService: GetIt.I.get<EncryptionService>(),
          addressService: GetIt.I.get<AddressService>(),
          transactionRepository: GetIt.I.get<TransactionRepository>(),
          transactionLocalRepository: GetIt.I.get<TransactionLocalRepository>(),
          bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
        )..add(FetchFormData(currentAddress: state.currentAddress)),
        child: ComposeSendPage(
          address: state.currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeSendPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;
  const ComposeSendPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  ComposeSendPageState createState() => ComposeSendPageState();
}

class ComposeSendPageState extends State<ComposeSendPage> {
  final passwordFormKey = GlobalKey<FormState>();
  TextEditingController destinationAddressController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController assetController = TextEditingController();

  String? asset;
  Balance? balance_;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address.address;
  }

    String _formatMaxValue(ComposeSendState state, int maxValue, String? asset) {
    // You may need to adjust this based on your asset's divisibility
    final balance = _getBalanceForSelectedAsset(
        state.balancesState.maybeWhen(
          success: (balances) => balances,
          orElse: () => [],
        ),
        asset ?? '');

    if (balance?.assetInfo.divisible == true) {
      final maxDecimal = Decimal.fromInt(maxValue);
      final maxDecimalNormalized = maxDecimal / Decimal.fromInt(100000000);

      return (Decimal.fromInt(maxValue) / Decimal.fromInt(100000000)).toDecimal().round(scale: 8).toString();
    } else {
      return maxValue.toString();
    }
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
            final formattedValue =
                _formatMaxValue(state, maxValue, state.asset);

            if (formattedValue != quantityController.text) {
              quantityController.text = formattedValue;
            }
          }
        },
        orElse: () {},
      );
    }, builder: (context, state) {
      return ComposeBasePage<ComposeSendBloc, ComposeSendState>(
        address: widget.address,
        dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
        buildInitialFormFields: (context, state, loading, error) =>
            _buildInitialFormFields(context, state, loading, error),
        onInitialCancel: (context) => _handleInitialSubmit(),
        onInitialSubmit: (context, state) => _handleInitialSubmit(),
        buildConfirmationFormFields: _buildConfirmationDetails,
        onConfirmationBack: (context) => {
          context
              .read<ComposeSendBloc>()
              .add(FetchFormData(currentAddress: widget.address))
        },
        onConfirmationContinue: (context, composeSend, fee) => {
          context.read<ComposeSendBloc>().add(
                FinalizeTransactionEvent<ComposeSend>(
                  composeTransaction: composeSend,
                  fee: fee,
                ),
              )
        },
        onFinalizeSubmit: (context, password) => {
          context.read<ComposeSendBloc>().add(
                SignAndBroadcastTransactionEvent(
                  password: password,
                ),
              )
        },
        onFinalizeCancel: (context) {
          context
              .read<ComposeSendBloc>()
              .add(FetchFormData(currentAddress: widget.address));
        },
      );
    });
  }

  void _handleInitialSubmit() {
    // form key is validated by parent
    Decimal input = Decimal.parse(quantityController.text);
    Balance? balance = balance_;
    int quantity;

    if (balance == null) {
      throw Exception("invariant: No balance found for asset");
    }

    if (balance.assetInfo.divisible) {
      quantity = (input * Decimal.fromInt(100000000)).toBigInt().toInt();
    } else {
      quantity = input.toBigInt().toInt();
    }

    if (asset == null) {
      throw Exception("no asset");
    }

    context.read<ComposeSendBloc>().add(ComposeTransactionEvent(
          sourceAddress: widget.address.address,
          params: ComposeSendEventParams(
            destinationAddress: destinationAddressController.text,
            asset: asset!,
            quantity: quantity,
          ),
        ));
  }

  List<Widget> _buildInitialFormFields(
      BuildContext context,
      ComposeSendState state,
      bool loading,
      String? error) {
    final width = MediaQuery.of(context).size.width;
    return [
      HorizonTextFormField(
        enabled: false,
        controller: fromAddressController,
        label: "Source",
        onFieldSubmitted: (value) {
          _handleInitialSubmit();
        },
      ),
      const SizedBox(height: 16.0),
      HorizonTextFormField(
        enabled: loading ? false : true,
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
        onFieldSubmitted: (value) {
          _handleInitialSubmit();
        },
      ),
      const SizedBox(height: 16.0),
      if (width > 768)
        Row(
            children: _buildQuantityAndAssetInputsForRow(
                state, _handleInitialSubmit, loading)),
      if (width <= 768)
        Column(children: [
          _buildQuantityInput(state, _handleInitialSubmit, loading),
          const SizedBox(height: 16.0),
          _buildAssetInput(state, loading)
        ]),
      const SizedBox(height: 16.0),
      FeeSelectionV2(
        value: state.feeOption,
        feeEstimates: state.feeState.maybeWhen(
          success: (feeEstimates) =>
              FeeEstimateSuccess(feeEstimates: feeEstimates),
          orElse: () => FeeEstimateLoading(),
        ),
        onSelected: (fee) {
          context.read<ComposeSendBloc>().add(ChangeFeeOption(value: fee));
        },
        layout:
            width > 768 ? FeeSelectionLayout.row : FeeSelectionLayout.column,
        onFieldSubmitted: () => _handleInitialSubmit(),
      ),
      const SizedBox(height: 16.0),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(error, style: const TextStyle(color: Colors.red)),
        ),
    ];
  }

    List<Widget> _buildQuantityAndAssetInputsForRow(
      ComposeSendState state, void Function() handleInitialSubmit, bool loading) {
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


  Widget _buildQuantityInput(ComposeSendState state, void Function() handleInitialSubmit, bool loading) {
    return state.balancesState.maybeWhen(orElse: () {
      return _buildQuantityInputField(state, null, handleInitialSubmit, loading);
    }, success: (balances) {
      if (balances.isEmpty) {
        return const HorizonTextFormField(
          enabled: false,
        );
      }

      Balance? balance = balance_ ?? _getBalanceForSelectedAsset(balances, asset ?? balances[0].asset);

      if (balance == null) {
        return const HorizonTextFormField(
          enabled: false,
        );
      }

      return _buildQuantityInputField(state, balance, handleInitialSubmit, loading);
    });
  }


  Widget _buildQuantityInputField(
      ComposeSendState state, Balance? balance, void Function() handleInitialSubmit, bool loading) {
    return Stack(
      children: [
        HorizonTextFormField(
          controller: quantityController,
          enabled: loading ? false : true,
          onChanged: (value) {
            context.read<ComposeSendBloc>().add(ChangeQuantity(value: value));
          },
          label: 'Quantity',
          inputFormatters: [
            balance?.assetInfo.divisible == true
                ? DecimalTextInputFormatter(decimalRange: 8)
                : FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a quantity';
            }
            Decimal input = Decimal.parse(value);
            Decimal max = Decimal.parse(balance?.quantityNormalized ?? '0');
            if (input > max) {
              return "quantity exceeds max";
            }
            setState(() {
              balance_ = balance;
            });
            return null;
          },
          onFieldSubmitted: (value) {
            handleInitialSubmit();
          },
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
                                  context.read<ComposeSendBloc>().add(ToggleSendMaxEvent(value: value));
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
            return const HorizonTextFormField(
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
                Balance? balance = _getBalanceForSelectedAsset(balances, value!);

                if (balance == null) {
                  throw Exception("invariant: No balance found for asset");
                }

                setState(() {
                  asset = value;
                  balance_ = balance;
                  quantityController.text = '';
                });

                context.read<ComposeSendBloc>().add(ChangeAsset(asset: value, balance: balance));
              },
            ),
          );
        });
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeSend).params;
    return [
      HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonTextFormField(
        label: "Destination Address",
        controller: TextEditingController(text: params.destination),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      Row(
        children: [
          Expanded(
            child: HorizonTextFormField(
              label: "Quantity",
              controller:
                  TextEditingController(text: params.quantityNormalized),
              enabled: false,
            ),
          ),
          const SizedBox(width: 16.0), // Spacing between inputs
          Expanded(
            child: HorizonTextFormField(
              label: "Asset",
              controller: TextEditingController(text: params.asset),
              enabled: false,
            ),
          ),
        ],
      ),
    ];
  }
}

class AssetDropdownLoading extends StatelessWidget {
  const AssetDropdownLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      DropdownMenu(
        expandedInsets: const EdgeInsets.all(0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        initialSelection: "",
        // enabled: false,
        label: const Text('Asset'),
        dropdownMenuEntries:
            [const DropdownMenuEntry<String>(value: "", label: "")].toList(),
        menuStyle: MenuStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(vertical: 8.0),
          ),
        ),
      ),
      const Positioned(
        left: 12,
        top: 0,
        bottom: 0,
        child: Center(
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ]);
  }
}

class AssetDropdown extends StatefulWidget {
  final String? asset;
  final List<Balance> balances;
  final TextEditingController controller;
  final void Function(String?) onSelected;
  final bool loading;

  const AssetDropdown(
      {super.key,
      this.asset,
      required this.balances,
      required this.controller,
      required this.onSelected,
      required this.loading});

  @override
  State<AssetDropdown> createState() => _AssetDropdownState();
}

class _AssetDropdownState extends State<AssetDropdown> {
  late List<Balance> orderedBalances;

  @override
  void initState() {
    super.initState();
    orderedBalances = _orderBalances(widget.balances);
    widget.controller.text = widget.asset ?? orderedBalances[0].asset;
  }

  List<Balance> _orderBalances(List<Balance> balances) {
    final Balance? btcBalance =
        balances.where((b) => b.asset == 'BTC').firstOrNull;

    final Balance? xcpBalance =
        balances.where((b) => b.asset == 'XCP').firstOrNull;

    final otherBalances =
        balances.where((b) => b.asset != 'BTC' && b.asset != 'XCP').toList();

    return [
      if (btcBalance != null) btcBalance,
      if (xcpBalance != null) xcpBalance,
      ...otherBalances,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HorizonDropdownMenu(
      enabled: widget.loading ? false : true,
      controller: widget.controller,
      label: 'Asset',
      onChanged: widget.onSelected,
      selectedValue: widget.asset ?? orderedBalances[0].asset,
      items: orderedBalances.map<DropdownMenuItem<String>>((balance) {
        return buildDropdownMenuItem(balance.asset, balance.asset);
      }).toList(),
    );
  }
}

_getBalanceForSelectedAsset(List<Balance> balances, String asset) {
  if (balances.isEmpty) {
    return null;
  }

  return balances.firstWhereOrNull((balance) => balance.asset == asset) ??
      balances[0];
}
