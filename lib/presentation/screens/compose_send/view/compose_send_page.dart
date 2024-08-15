import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          accountUuid: state.currentAccountUuid,
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
  final String accountUuid;
  const _ComposeSendPage_(
      {required this.isDarkMode, required this.dashboardActivityFeedBloc, required this.accountUuid, super.key});

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
          dropdownMenuEntries: [const DropdownMenuEntry<String>(value: "", label: "")].toList()),
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

class _ComposeSendPageState extends State<_ComposeSendPage_> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController destinationAddressController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController assetController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? asset;
  String? fromAddress;
  Balance? balance_;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeSendBloc, ComposeSendState>(listener: (context, state) {
      state.submitState.maybeWhen(
          success: (txHash, sourceAddress) {
            // 0) reload activity feed
            widget.dashboardActivityFeedBloc.add(const Load()); // show "N more transactions".
            // show "N more transactions".

            // 1) close modal
            Navigator.of(context).pop();
            // 2) show snackbar with copy tx action
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: txHash));
                  },
                ),
                content: Text('Compose send success: $txHash'),
                behavior: SnackBarBehavior.floating));
          },
          error: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
          orElse: () => null);
    }, builder: (context, state) {
      return state.addressesState.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const SizedBox.shrink(),
        error: (e) => Text('Unable to compose send: $e'),
        success: (addresses) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  HorizonDropdownMenu(
                    isDarkMode: widget.isDarkMode,
                    selectedValue: fromAddress ?? addresses[0].address,
                    controller: fromAddressController,
                    label: 'Source Address',
                    onChanged: (String? a) {
                      setState(() {
                        balance_ = null;
                        fromAddress = a!;
                      });
                      context.read<ComposeSendBloc>().add(FetchBalances(address: a!));
                    },
                    items: addresses.map<DropdownMenuItem<String>>((address) {
                      return buildDropdownMenuItem(address.address, address.address);
                    }).toList(),
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
                          Balance? balance = balance_ ?? _getBalanceForSelectedAsset(balances, asset ?? balances[0].asset);

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
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                if (newValue.text.isEmpty) {
                                  return newValue;
                                }
                                if (double.tryParse(newValue.text) != null) {
                                  return newValue;
                                }
                                return oldValue;
                              }),
                              balance.assetInfo.divisible
                                  ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
                                  : FilteringTextInputFormatter.digitsOnly,
                            ], // Only
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a quantity';
                              }
                              Decimal input = Decimal.parse(value);
                              Decimal max = Decimal.parse(balance.quantityNormalized);

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
                                      Balance? balance = _getBalanceForSelectedAsset(balances, value!);

                                      if (balance == null) {
                                        throw Exception("invariant: No balance found for asset");
                                      }

                                      setState(() {
                                        asset = value;
                                        balance_ = balance;
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
                          throw Exception("invariant: No balance found for asset");
                        }

                        if (balance.assetInfo.divisible) {
                          quantity = (input * Decimal.fromInt(100000000)).toBigInt().toInt();
                        } else {
                          quantity = (input).toBigInt().toInt();
                        }

                        if (asset == null) {
                          throw Exception("no asset");
                        }

                        context.read<ComposeSendBloc>().add(ConfirmTransactionEvent(
                            sourceAddress: fromAddress ?? addresses[0].address,
                            destinationAddress: destinationAddressController.text,
                            asset: asset!,
                            quantity: quantity,
                            quantityDisplay: input.toString()));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
        confirmation: (unconfirmedSendState) {
          return _buildConfirmationPage(context, unconfirmedSendState, widget.accountUuid);
        },
      );
    });
  }

  Widget _buildConfirmationPage(
      BuildContext context, AddressStateSuccessUnconfirmed unconfirmedSendState, String accountUuid) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDarkTheme ? dialogBackgroundColorDarkTheme : dialogBackgroundColorLightTheme;
    final sendParams = unconfirmedSendState.composeSend.params;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Please review your transaction details.',
            style: TextStyle(fontSize: 16.0, color: mainTextWhite, fontWeight: FontWeight.bold),
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
            textColor: isDarkTheme ? mainTextWhite : mainTextBlack,
          ),
          const SizedBox(height: 16.0),
          HorizonTextFormField(
            isDarkMode: widget.isDarkMode,
            label: "Destination Address",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            controller: TextEditingController(text: sendParams.destination),
            enabled: false,
            fillColor: inputFillColor,
            textColor: isDarkTheme ? mainTextWhite : mainTextBlack,
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: HorizonTextFormField(
                  isDarkMode: widget.isDarkMode,
                  label: "Quantity",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  controller: TextEditingController(text: sendParams.quantityNormalized),
                  enabled: false,
                  fillColor: inputFillColor,
                  textColor: isDarkTheme ? mainTextWhite : mainTextBlack,
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
                  textColor: isDarkTheme ? mainTextWhite : mainTextBlack,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(
              color: isDarkTheme ? greyDarkThemeUnderlineColor : greyLightThemeUnderlineColor,
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
                  context.read<ComposeSendBloc>().add(FetchFormData(accountUuid: accountUuid));
                },
                buttonText: 'BACK',
              ),
              HorizonContinueButton(
                isDarkMode: widget.isDarkMode,
                onPressed: () {
                  context.read<ComposeSendBloc>().add(SendTransactionEvent(
                      composeSend: unconfirmedSendState.composeSend, password: passwordController.text));
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

  return balances.firstWhereOrNull((balance) => balance.asset == asset) ?? balances[0];
}
