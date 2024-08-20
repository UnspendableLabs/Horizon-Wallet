import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
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

class DiscreteSlider extends StatefulWidget {
  final Map<String, double> valueMap;
  final Function(String) onChanged;

  const DiscreteSlider(
      {super.key, required this.valueMap, required this.onChanged});

  @override
  _DiscreteSliderState createState() => _DiscreteSliderState();
}

class _DiscreteSliderState extends State<DiscreteSlider> {
  late List<String> _keys;
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _keys = widget.valueMap.keys.toList();
    _currentValue = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          min: 0,
          max: (_keys.length - 1).toDouble(),
          divisions: _keys.length - 1,
          value: _currentValue,
          onChanged: (value) {
            setState(() {
              _currentValue = value;
            });
            int index = value.round();
            if (index >= 0 && index < _keys.length) {
              widget.onChanged(_keys[index]);
            }
          },
        ),
      ],
    );
  }
}

class ComposeSendPage extends StatelessWidget {
  final bool isDarkMode;
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;

  const ComposeSendPage({
    required this.isDarkMode,
    required this.dashboardActivityFeedBloc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => ComposeSendBloc()
          ..add(FetchFormData(currentAddress: state.currentAddress)),
        child: _ComposeSendPage_(
          address: state.currentAddress,
          isDarkMode: isDarkMode,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ComposeSendPage_ extends StatefulWidget {
  final bool isDarkMode;
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;
  const _ComposeSendPage_(
      {required this.isDarkMode,
      required this.dashboardActivityFeedBloc,
      required this.address});

  @override
  _ComposeSendPageState createState() => _ComposeSendPageState();
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
              [const DropdownMenuEntry<String>(value: "", label: "")].toList()),
      const Positioned(
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
    ]);
  }
}

class AssetDropdown extends StatefulWidget {
  final String? asset;
  final List<Balance> balances;
  final TextEditingController controller;
  final void Function(String?) onSelected;
  final bool isDarkMode;

  const AssetDropdown(
      {super.key,
      this.asset,
      required this.balances,
      required this.controller,
      required this.onSelected,
      required this.isDarkMode});

  @override
  State<AssetDropdown> createState() => _AssetDropdownState();
}

class _AssetDropdownState extends State<AssetDropdown> {
  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.asset ?? widget.balances[0].asset;
  }

  @override
  Widget build(BuildContext context) {
    return HorizonDropdownMenu(
        isDarkMode: widget.isDarkMode,
        controller: widget.controller,
        label: 'Asset',
        onChanged: widget.onSelected,
        selectedValue: widget.asset ?? widget.balances[0].asset,
        items: widget.balances.map<DropdownMenuItem<String>>((balance) {
          return buildDropdownMenuItem(balance.asset, balance.asset);
        }).toList());
  }
}

_getBalanceForSelectedAsset(List<Balance> balances, String asset) {
  if (balances.isEmpty) {
    return null;
  }

  return balances.firstWhereOrNull((balance) => balance.asset == asset) ??
      balances[0];
}

class _ComposeSendPageState extends State<_ComposeSendPage_> {
  final _formKey = GlobalKey<FormState>();
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

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
        loading: () => const CircularProgressIndicator(),
        error: (msg) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('An error occurred: $msg')),
        initial: () => Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                HorizonTextFormField(
                  enabled: false,
                  isDarkMode: widget.isDarkMode,
                  controller: fromAddressController,
                  label: "Source",
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  fillColor: isDarkTheme
                      ? dialogBackgroundColorDarkTheme
                      : dialogBackgroundColorLightTheme,
                  textColor: isDarkTheme ? mainTextWhite : mainTextBlack,
                ),
                const SizedBox(height: 16.0),
                HorizonTextFormField(
                    isDarkMode: widget.isDarkMode,
                    controller: destinationAddressController,
                    label: "Destination",
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a destination address';
                      }
                      return null;
                    }),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                        // TODO: make his type of input it's own component ( e.g. BalanceInput )
                        child: Builder(builder: (context) {
                      return state.balancesState.maybeWhen(orElse: () {
                        return HorizonTextFormField(
                          isDarkMode: widget.isDarkMode,
                          controller: quantityController,
                          label: 'Quantity',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        );
                      }, success: (balances) {
                        if (balances.isEmpty) {
                          return HorizonTextFormField(
                            isDarkMode: widget.isDarkMode,
                            enabled: false,
                          );
                        }

                        Balance? balance = balance_ ??
                            _getBalanceForSelectedAsset(
                                balances, asset ?? balances[0].asset);

                        if (balance == null) {
                          return HorizonTextFormField(
                            isDarkMode: widget.isDarkMode,
                            enabled: false,
                          );
                        }

                        return HorizonTextFormField(
                          isDarkMode: widget.isDarkMode,
                          controller: quantityController,
                          label: 'Quantity',
                          suffix: Builder(builder: (context) {
                            return Text("${balance.quantityNormalized} max");
                          }),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,

                          inputFormatters: <TextInputFormatter>[
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              if (newValue.text.isEmpty) {
                                return newValue;
                              }
                              if (double.tryParse(newValue.text) != null) {
                                return newValue;
                              }
                              return oldValue;
                            }),
                            balance.assetInfo.divisible
                                ? FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*$'))
                                : FilteringTextInputFormatter.digitsOnly,
                          ], // Only
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a quantity';
                            }
                            Decimal input = Decimal.parse(value);
                            Decimal max =
                                Decimal.parse(balance.quantityNormalized);

                            if (input > max) {
                              return "quantity exceeds max";
                            }

                            setState(() {
                              balance_ = balance;
                            });

                            return null;
                          },
                        );
                      });
                    })),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Builder(builder: (context) {
                        return state.balancesState.maybeWhen(
                            orElse: () => const AssetDropdownLoading(),
                            success: (balances) {
                              if (balances.isEmpty) {
                                return HorizonTextFormField(
                                  isDarkMode: widget.isDarkMode,
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
                                  isDarkMode: widget.isDarkMode,
                                  asset: asset,
                                  balances: balances,
                                  controller: assetController,
                                  onSelected: (String? value) {
                                    Balance? balance =
                                        _getBalanceForSelectedAsset(
                                            balances, value!);

                                    if (balance == null) {
                                      throw Exception(
                                          "invariant: No balance found for asset");
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
                      }),
                    ),
                  ],
                ),
                HorizonDialogSubmitButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // TODO: wrap this in function and write some tests
                      Decimal input = Decimal.parse(quantityController.text);

                      Balance? balance = balance_;

                      int quantity;

                      if (balance == null) {
                        throw Exception(
                            "invariant: No balance found for asset");
                      }

                      if (balance.assetInfo.divisible) {
                        quantity = (input * Decimal.fromInt(100000000))
                            .toBigInt()
                            .toInt();
                      } else {
                        quantity = (input).toBigInt().toInt();
                      }

                      if (asset == null) {
                        throw Exception("no asset");
                      }

                      context.read<ComposeSendBloc>().add(
                          ComposeTransactionEvent(
                              sourceAddress: widget.address.address,
                              destinationAddress:
                                  destinationAddressController.text,
                              asset: asset!,
                              quantity: quantity,
                              quantityDisplay: input.toString()));
                    }
                  },
                ),
              ],
            ),
          ),

          // },
        ),
        composing: (composeSendState) {
          return ConfirmationPage(
            composeSendState: composeSendState,
            isDarkMode: isDarkTheme,
            address: widget.address,
          );
          // return _buildConfirmationPage(context, composeSendState, isDarkTheme);
        },
        orElse: () => const SizedBox.shrink(),
      );
    });
  }

  // Widget _buildConfirmationPage(BuildContext context,
  //     SubmitStateComposingSend composeSendState, bool isDarkTheme) {
  //   final inputFillColor = isDarkTheme
  //       ? dialogBackgroundColorDarkTheme
  //       : dialogBackgroundColorLightTheme;
  //   final sendParams = composeSendState.composeSend.params;
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: <Widget>[
  //         const Text(
  //           'Please review your transaction details.',
  //           style: TextStyle(
  //               fontSize: 16.0,
  //               color: mainTextWhite,
  //               fontWeight: FontWeight.bold),
  //           textAlign: TextAlign.center,
  //         ),
  //         const SizedBox(height: 16.0),
  //         HorizonTextFormField(
  //           isDarkMode: widget.isDarkMode,
  //           label: "Source Address",
  //           floatingLabelBehavior: FloatingLabelBehavior.always,
  //           controller: TextEditingController(text: sendParams.source),
  //           enabled: false,
  //           fillColor: inputFillColor,
  //           textColor: isDarkTheme ? mainTextWhite : mainTextBlack,
  //         ),
  //         const SizedBox(height: 16.0),
  //         HorizonTextFormField(
  //           isDarkMode: widget.isDarkMode,
  //           label: "Destination Address",
  //           floatingLabelBehavior: FloatingLabelBehavior.always,
  //           controller: TextEditingController(text: sendParams.destination),
  //           enabled: false,
  //           fillColor: inputFillColor,
  //           textColor: isDarkTheme ? mainTextWhite : mainTextBlack,
  //         ),
  //         const SizedBox(height: 16.0),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: HorizonTextFormField(
  //                 isDarkMode: widget.isDarkMode,
  //                 label: "Quantity",
  //                 floatingLabelBehavior: FloatingLabelBehavior.always,
  //                 controller: TextEditingController(
  //                     text: sendParams.quantityNormalized),
  //                 enabled: false,
  //                 fillColor: inputFillColor,
  //                 textColor: isDarkTheme ? mainTextWhite : mainTextBlack,
  //               ),
  //             ),
  //             const SizedBox(width: 16.0), // Spacing between inputs
  //             Expanded(
  //               child: HorizonTextFormField(
  //                 isDarkMode: widget.isDarkMode,
  //                 label: "Asset",
  //                 floatingLabelBehavior: FloatingLabelBehavior.always,
  //                 controller: TextEditingController(text: sendParams.asset),
  //                 enabled: false,
  //                 fillColor: inputFillColor,
  //                 textColor: isDarkTheme ? mainTextWhite : mainTextBlack,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16.0),
  //         FeeEstimation(
  //             feeMap: composeSendState.feeEstimates,
  //             virtualSize: composeSendState.virtualSize,
  //             onChanged: (v) {
  //               setState(() {
  //                 fee = v.toInt();
  //               });
  //             }),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 16.0),
  //           child: Divider(
  //             color: isDarkTheme
  //                 ? greyDarkThemeUnderlineColor
  //                 : greyLightThemeUnderlineColor,
  //             thickness: 1.0,
  //           ),
  //         ),
  //         HorizonTextFormField(
  //           isDarkMode: widget.isDarkMode,
  //           obscureText: true,
  //           enableSuggestions: false,
  //           autocorrect: false,
  //           controller: passwordController,
  //           label: "Password",
  //           floatingLabelBehavior: FloatingLabelBehavior.auto,
  //           validator: (value) {
  //             if (value == null || value.isEmpty) {
  //               return 'Please enter your password';
  //             }
  //             return null;
  //           },
  //         ),
  //         const SizedBox(height: 16.0),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             HorizonCancelButton(
  //               isDarkMode: widget.isDarkMode,
  //               onPressed: () {
  //                 context
  //                     .read<ComposeSendBloc>()
  //                     .add(FetchFormData(currentAddress: widget.address));
  //               },
  //               buttonText: 'BACK',
  //             ),
  //             HorizonContinueButton(
  //               isDarkMode: widget.isDarkMode,
  //               onPressed: () {
  //                 context.read<ComposeSendBloc>().add(
  //                     SignAndBroadcastTransactionEvent(
  //                         composeSend: composeSendState.composeSend,
  //                         password: passwordController.text));
  //               },
  //               buttonText: 'SIGN AND BROADCAST',
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class FeeEstimation extends StatefulWidget {
  final Map<String, double> feeMap;
  final Function(double) onChanged;
  final int virtualSize;

  const FeeEstimation(
      {super.key,
      required this.feeMap,
      required this.onChanged,
      required this.virtualSize});

  @override
  FeeEstimationState createState() => FeeEstimationState();
}

class FeeEstimationState extends State<FeeEstimation> {
  late String _confirmationTarget;

  @override
  void initState() {
    super.initState();
    _confirmationTarget = widget.feeMap.keys.first;
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        DiscreteSlider(
          valueMap: widget.feeMap,
          onChanged: (key) {
            setState(() {
              _confirmationTarget = key;
            });
            widget.onChanged(_getTotalSats().toDouble());
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                        "$_confirmationTarget block${int.parse(_confirmationTarget) > 1 ? "s" : ""}",
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(width: 4),
                    Text(
                      "(${widget.feeMap[_confirmationTarget]!.toStringAsFixed(4)} sats/vbyte)",
                    ),
                  ],
                ),
              ),
              Row(children: [
                Text("${satoshisToBtc(_getTotalSats()).toString()} BTC",
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(width: 4),
                Text(
                  "${_getTotalSats().toString()} sats",
                ),
              ]),
            ],
          ),
        )
      ],
    );
  }

  int _getTotalSats() {
    return (widget.virtualSize * widget.feeMap[_confirmationTarget]!).ceil();
  }
}

class ConfirmationPage extends StatefulWidget {
  final SubmitStateComposingSend composeSendState;
  final bool isDarkMode;
  final Address address;

  const ConfirmationPage(
      {super.key, required this.composeSendState,
      required this.isDarkMode,
      required this.address});

  @override
  ConfirmationPageState createState() => ConfirmationPageState();
}

class ConfirmationPageState extends State<ConfirmationPage> {
  late int fee;
  TextEditingController passwordController = TextEditingController();

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
    final inputFillColor = widget.isDarkMode
        ? dialogBackgroundColorDarkTheme
        : dialogBackgroundColorLightTheme;
    final sendParams = widget.composeSendState.composeSend.params;
    return Padding(
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
            isDarkMode: widget.isDarkMode,
            label: "Source Address",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            controller: TextEditingController(text: sendParams.source),
            enabled: false,
            fillColor: inputFillColor,
            textColor: widget.isDarkMode ? mainTextWhite : mainTextBlack,
          ),
          const SizedBox(height: 16.0),
          HorizonTextFormField(
            isDarkMode: widget.isDarkMode,
            label: "Destination Address",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            controller: TextEditingController(text: sendParams.destination),
            enabled: false,
            fillColor: inputFillColor,
            textColor: widget.isDarkMode ? mainTextWhite : mainTextBlack,
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: HorizonTextFormField(
                  isDarkMode: widget.isDarkMode,
                  label: "Quantity",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  controller: TextEditingController(
                      text: sendParams.quantityNormalized),
                  enabled: false,
                  fillColor: inputFillColor,
                  textColor: widget.isDarkMode ? mainTextWhite : mainTextBlack,
                ),
              ),
              const SizedBox(width: 16.0), // Spacing between inputs
              Expanded(
                child: HorizonTextFormField(
                  isDarkMode: widget.isDarkMode,
                  label: "Asset",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  controller: TextEditingController(text: sendParams.asset),
                  enabled: false,
                  fillColor: inputFillColor,
                  textColor: widget.isDarkMode ? mainTextWhite : mainTextBlack,
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(
              color: widget.isDarkMode
                  ? greyDarkThemeUnderlineColor
                  : greyLightThemeUnderlineColor,
              thickness: 1.0,
            ),
          ),
          HorizonTextFormField(
            isDarkMode: widget.isDarkMode,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            controller: passwordController,
            label: "Password",
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HorizonCancelButton(
                isDarkMode: widget.isDarkMode,
                onPressed: () {
                  context
                      .read<ComposeSendBloc>()
                      .add(FetchFormData(currentAddress: widget.address));
                },
                buttonText: 'BACK',
              ),
              HorizonContinueButton(
                isDarkMode: widget.isDarkMode,
                onPressed: () {
                  context
                      .read<ComposeSendBloc>()
                      .add(SignAndBroadcastTransactionEvent(
                        composeSend: widget.composeSendState.composeSend,
                        password: passwordController.text,
                        fee: fee,
                      ));
                },
                buttonText: 'SIGN AND BROADCAST',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
