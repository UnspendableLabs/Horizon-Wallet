import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
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
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/fee_estimation.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_bloc.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_cancel_button.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_continue_button.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_dialog.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_dropdown_menu.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_text_field.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class ComposeSendPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final double screenWidth;

  const ComposeSendPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.screenWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => ComposeSendBloc(
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
          screenWidth: screenWidth,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeSendPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;
  final double screenWidth;
  const ComposeSendPage(
      {super.key,
      required this.dashboardActivityFeedBloc,
      required this.address,
      required this.screenWidth});

  @override
  ComposeSendPageState createState() => ComposeSendPageState();
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

  const AssetDropdown(
      {super.key,
      this.asset,
      required this.balances,
      required this.controller,
      required this.onSelected});

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

class ComposeSendPageState extends State<ComposeSendPage> {
  final _formKey = GlobalKey<FormState>();
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeSendBloc, ComposeSendState>(
        listener: (context, state) {
      state.submitState.maybeWhen(
          success: (txHash, sourceAddress) {
            // close modal
            Navigator.of(context).pop();
            // reload activity feed
            widget.dashboardActivityFeedBloc
                .add(const Load()); // show "N more transactions".
          },
          orElse: () => null);
    }, builder: (context, state) {
      return state.submitState.maybeWhen(
        loading: () => const Center(
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(),
          ),
        ),
        error: (msg) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText('An error occurred: $msg')),
        initial: () {
          void handleInitialSubmit() {
            if (_formKey.currentState!.validate()) {
              // TODO: wrap this in function and write some tests
              Decimal input = Decimal.parse(quantityController.text);

              Balance? balance = balance_;

              int quantity;

              if (balance == null) {
                throw Exception("invariant: No balance found for asset");
              }

              if (balance.assetInfo.divisible) {
                quantity =
                    (input * Decimal.fromInt(100000000)).toBigInt().toInt();
              } else {
                quantity = (input).toBigInt().toInt();
              }

              if (asset == null) {
                throw Exception("no asset");
              }

              context.read<ComposeSendBloc>().add(ComposeTransactionEvent(
                    sourceAddress: widget.address.address,
                    destinationAddress: destinationAddressController.text,
                    asset: asset!,
                    quantity: quantity,
                  ));
            }
          }

          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  HorizonTextFormField(
                    enabled: false,
                    controller: fromAddressController,
                    label: "Source",
                    onFieldSubmitted: (value) {
                      handleInitialSubmit();
                    },
                  ),
                  const SizedBox(height: 16.0),
                  HorizonTextFormField(
                      controller: destinationAddressController,
                      label: "Destination",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a destination address';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) {
                        handleInitialSubmit();
                      }),
                  const SizedBox(height: 16.0),
                  if (widget.screenWidth > 768)
                    Row(
                        children: _buildQuantityAndAssetInputsForRow(
                            state, handleInitialSubmit)),
                  if (widget.screenWidth <= 768)
                    Column(children: [
                      _buildQuantityInput(state, handleInitialSubmit),
                      const SizedBox(height: 16.0),
                      _buildAssetInput(state)
                    ]),
                  HorizonDialogSubmitButton(
                    onPressed: handleInitialSubmit,
                  ),
                ],
              ),
            ),
          );
        },
        composing: (composeSendState) {
          return ConfirmationPage(
            composeSendState: composeSendState,
            address: widget.address,
          );
        },
        finalizing: (finalizingState) {
          TextEditingController passwordController = TextEditingController();
          void handlePasswordSubmit() {
            if (passwordFormKey.currentState!.validate()) {
              try {
                final password = passwordController.text;
                if (password.isEmpty) {
                  throw Exception('Password cannot be empty');
                }

                context.read<ComposeSendBloc>().add(
                      SignAndBroadcastTransactionEvent(
                        password: password,
                      ),
                    );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            }
          }

          return Form(
              key: passwordFormKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  HorizonTextFormField(
                    onFieldSubmitted: (_) => handlePasswordSubmit(),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: passwordController,
                    label: "Password",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(
                      thickness: 1.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HorizonCancelButton(
                        onPressed: () {
                          context.read<ComposeSendBloc>().add(
                              FetchFormData(currentAddress: widget.address));
                        },
                        buttonText: 'BACK',
                      ),
                      HorizonContinueButton(
                        onPressed: handlePasswordSubmit,
                        buttonText: 'SIGN AND BROADCAST',
                      ),
                    ],
                  ),
                ]),
              ));
        },
        orElse: () => const SizedBox.shrink(),
      );
    });
  }

  Widget _buildQuantityInput(
      ComposeSendState state, void Function() handleInitialSubmit) {
    return state.balancesState.maybeWhen(orElse: () {
      return _buildQuantityInputField(null, handleInitialSubmit);
    }, success: (balances) {
      if (balances.isEmpty) {
        return const HorizonTextFormField(
          enabled: false,
        );
      }

      Balance? balance = balance_ ??
          _getBalanceForSelectedAsset(balances, asset ?? balances[0].asset);

      if (balance == null) {
        return const HorizonTextFormField(
          enabled: false,
        );
      }

      return _buildQuantityInputField(balance, handleInitialSubmit);
    });
  }

  Widget _buildQuantityInputField(
      Balance? balance, void Function() handleInitialSubmit) {
    return Stack(
      children: [
        HorizonTextFormField(
          controller: quantityController,
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
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: TextButton(
            onPressed: balance != null
                ? () {
                    setState(() {
                      quantityController.text = balance.quantityNormalized;
                    });
                  }
                : null,
            child: const Text('MAX',
                style: TextStyle(
                  fontSize: 14.0,
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetInput(ComposeSendState state) {
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
            height: 48.0,
            child: AssetDropdown(
              asset: asset,
              balances: balances,
              controller: assetController,
              onSelected: (String? value) {
                Balance? balance =
                    _getBalanceForSelectedAsset(balances, value!);

                if (balance == null) {
                  throw Exception("invariant: No balance found for asset");
                }

                setState(() {
                  asset = value;
                  balance_ = balance;
                  quantityController.text = '';
                });
              },
            ),
          );
        });
  }

  List<Widget> _buildQuantityAndAssetInputsForRow(
      ComposeSendState state, void Function() handleInitialSubmit) {
    return [
      Expanded(
          // TODO: make his type of input it's own component ( e.g. BalanceInput )
          child: Builder(builder: (context) {
        return _buildQuantityInput(state, handleInitialSubmit);
      })),
      const SizedBox(width: 16.0),
      Expanded(
        child: Builder(builder: (context) {
          return _buildAssetInput(state);
        }),
      )
    ];
  }
}

class ConfirmationPage extends StatefulWidget {
  final SubmitStateComposingSend composeSendState;
  final Address address;

  const ConfirmationPage(
      {super.key, required this.composeSendState, required this.address});

  @override
  ConfirmationPageState createState() => ConfirmationPageState();
}

class ConfirmationPageState extends State<ConfirmationPage> {
  late int fee;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // initialize fee
    fee = (widget.composeSendState.virtualSize *
            widget.composeSendState
                .feeEstimates[widget.composeSendState.feeEstimates.keys.first]!)
        .ceil();
  }

  @override
  Widget build(BuildContext context) {
    final sendParams = widget.composeSendState.composeSend.params;
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Please review your transaction details.',
              style: TextStyle(
                  fontSize: 16.0,
                  color: mainTextWhite,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              label: "Source Address",
              controller: TextEditingController(text: sendParams.source),
              enabled: false,
            ),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              label: "Destination Address",
              controller: TextEditingController(text: sendParams.destination),
              enabled: false,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: HorizonTextFormField(
                    label: "Quantity",
                    controller: TextEditingController(
                        text: sendParams.quantityNormalized),
                    enabled: false,
                  ),
                ),
                const SizedBox(width: 16.0), // Spacing between inputs
                Expanded(
                  child: HorizonTextFormField(
                    label: "Asset",
                    controller: TextEditingController(text: sendParams.asset),
                    enabled: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            FeeEstimation(
                feeMap: widget.composeSendState.feeEstimates,
                virtualSize: widget.composeSendState.virtualSize,
                onChanged: (v) {
                  setState(() {
                    fee = v.toInt();
                  });
                }),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(
                thickness: 1.0,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HorizonCancelButton(
                  onPressed: () {
                    context
                        .read<ComposeSendBloc>()
                        .add(FetchFormData(currentAddress: widget.address));
                  },
                  buttonText: 'BACK',
                ),
                HorizonContinueButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<ComposeSendBloc>().add(
                            FinalizeTransactionEvent(
                              composeSend: widget.composeSendState.composeSend,
                              fee: fee,
                            ),
                          );
                    }
                  },
                  buttonText: 'CONTINUE',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
