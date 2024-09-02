import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/fee_estimation.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_bloc.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_cancel_button.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_continue_button.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_dialog.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_text_field.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class ComposeIssuancePage extends StatelessWidget {
  final bool isDarkMode;
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;

  const ComposeIssuancePage({
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
        create: (context) => ComposeIssuanceBloc()
          ..add(FetchFormData(currentAddress: state.currentAddress)),
        child: _ComposeIssuancePage_(
          address: state.currentAddress,
          isDarkMode: isDarkMode,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ComposeIssuancePage_ extends StatefulWidget {
  final bool isDarkMode;
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;
  const _ComposeIssuancePage_(
      {required this.address,
      required this.isDarkMode,
      required this.dashboardActivityFeedBloc});

  @override
  _ComposeIssuancePageState createState() => _ComposeIssuancePageState();
}

class _ComposeIssuancePageState extends State<_ComposeIssuancePage_> {
  final balanceRepository = GetIt.I.get<BalanceRepository>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = UpperCaseTextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController assetController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String? asset;

  bool isDivisible = true;
  bool isLocked = false;
  bool isReset = false;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address.address;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeIssuanceBloc, ComposeIssuanceState>(
        listener: (context, state) {
      state.submitState.maybeWhen(
        success: (txHash) {
          // 0) reload activity feed
          widget.dashboardActivityFeedBloc
              .add(const Load()); // show "N more transactions".

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
              content: Text(txHash),
              behavior: SnackBarBehavior.floating));
          widget.dashboardActivityFeedBloc
              .add(const Load()); // show "N more transactions".

          // Navigator.of(context).pop();
        },
        orElse: () => null,
      );
    }, builder: (context, state) {
      return state.submitState.maybeWhen(
        loading: () => const CircularProgressIndicator(),
        error: (msg) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText('An error occurred: $msg')),
        initial: () {
          return state.balancesState.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (e) => SelectableText('An error occurred: $e'),
            success: (balances) {
              bool hasXCPBalance = balances.isNotEmpty &&
                  balances.any((balance) => balance.asset == 'XCP');
              Balance? xcpBalance = hasXCPBalance
                  ? balances.firstWhere((element) => element.asset == 'XCP')
                  : null;
              bool isNamedAssetEnabled =
                  xcpBalance != null && xcpBalance.quantity >= 50000000;
              String quantity =
                  xcpBalance != null ? xcpBalance.quantityNormalized : '0';

              return Form(
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
                        fillColor: widget.isDarkMode
                            ? dialogBackgroundColorDarkTheme
                            : dialogBackgroundColorLightTheme,
                        textColor:
                            widget.isDarkMode ? mainTextWhite : mainTextBlack,
                      ),
                      const SizedBox(height: 16.0),
                      HorizonTextFormField(
                        isDarkMode: widget.isDarkMode,
                        controller: nameController,
                        label: "Token name",
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name for your asset';
                          }
                          if (!isNamedAssetEnabled &&
                              !RegExp(r'^A\d+$').hasMatch(value)) {
                            return 'You must have at least 0.5 XCP to create a named asset. Your balance is: $quantity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      HorizonTextFormField(
                        isDarkMode: widget.isDarkMode,
                        controller: quantityController,
                        label: 'Quantity',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: false),
                        inputFormatters: [
                          isDivisible == true
                              ? FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*$'))
                              : FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a quantity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      HorizonTextFormField(
                        isDarkMode: widget.isDarkMode,
                        controller: descriptionController,
                        label: 'Description (optional)',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      const SizedBox(height: 16.0),
                      Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isDivisible,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isDivisible = value ?? false;
                                    quantityController.text = '';
                                  });
                                },
                              ),
                              Text('Divisible',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.isDarkMode
                                          ? mainTextWhite
                                          : mainTextBlack)),
                            ],
                          ),
                          const Row(
                            children: [
                              SizedBox(width: 30.0),
                              Expanded(
                                child: Text(
                                  'Whether this asset is divisible or not. Defaults to true.',
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: isLocked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isLocked = value ?? false;
                                  });
                                },
                              ),
                              Text('Lock',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.isDarkMode
                                          ? mainTextWhite
                                          : mainTextBlack)),
                            ],
                          ),
                          const Row(
                            children: [
                              SizedBox(width: 30.0),
                              Expanded(
                                child: Text(
                                  'Whether this issuance should lock supply of this asset forever. Defaults to false.',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16.0),
                          Row(
                            children: [
                              Checkbox(
                                value: isReset,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isReset = value ?? false;
                                  });
                                },
                              ),
                              Text('Reset',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.isDarkMode
                                          ? mainTextWhite
                                          : mainTextBlack)),
                            ],
                          ),
                          const Row(
                            children: [
                              SizedBox(width: 30.0),
                              Expanded(
                                child: Text(
                                  'Whether this issuance should reset any existing supply. Defaults to false.',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      HorizonDialogSubmitButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // TODO: wrap this in function and write some tests
                            Decimal input =
                                Decimal.parse(quantityController.text);

                            int quantity;

                            if (isDivisible) {
                              quantity = (input * Decimal.fromInt(100000000))
                                  .toBigInt()
                                  .toInt();
                            } else {
                              quantity = (input).toBigInt().toInt();
                            }

                            context
                                .read<ComposeIssuanceBloc>()
                                .add(ComposeTransactionEvent(
                                  sourceAddress: widget.address.address,
                                  name: nameController.text,
                                  quantity: quantity,
                                  description: descriptionController.text,
                                  divisible: isDivisible,
                                  lock: isLocked,
                                  reset: isReset,
                                ));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        composing: (composeIssuanceState) => ComposeIssuanceConfirmationPage(
          isDarkMode: widget.isDarkMode,
          composeIssuanceState: composeIssuanceState,
          address: widget.address,
        ),
        orElse: () => const SizedBox.shrink(),
      );
    });
  }
}

class ComposeIssuanceConfirmationPage extends StatefulWidget {
  final bool isDarkMode;
  final SubmitStateComposingIssuance composeIssuanceState;
  final Address address;

  const ComposeIssuanceConfirmationPage(
      {super.key,
      required this.isDarkMode,
      required this.composeIssuanceState,
      required this.address});

  @override
  State<ComposeIssuanceConfirmationPage> createState() =>
      _ComposeIssuanceConfirmationPageState();
}

class _ComposeIssuanceConfirmationPageState
    extends State<ComposeIssuanceConfirmationPage> {
  late int fee;
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // initialize fee
    fee = (widget.composeIssuanceState.virtualSize *
            widget.composeIssuanceState.feeEstimates[
                widget.composeIssuanceState.feeEstimates.keys.first]!)
        .ceil();
  }

  @override
  Widget build(BuildContext context) {
    final inputFillColor = widget.isDarkMode
        ? dialogBackgroundColorDarkTheme
        : dialogBackgroundColorLightTheme;
    final issueParams = widget.composeIssuanceState.composeIssuance.params;
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
              isDarkMode: widget.isDarkMode,
              label: "Source Address",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              controller: TextEditingController(text: issueParams.source),
              enabled: false,
              fillColor: inputFillColor,
              textColor: widget.isDarkMode ? mainTextWhite : mainTextBlack,
            ),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              isDarkMode: widget.isDarkMode,
              label: "Token name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              controller: TextEditingController(
                  text: widget.composeIssuanceState.composeIssuance.name),
              enabled: false,
              fillColor: inputFillColor,
              textColor: widget.isDarkMode ? mainTextWhite : mainTextBlack,
            ),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              isDarkMode: widget.isDarkMode,
              label: "Quantity",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              controller: TextEditingController(
                  text: widget.composeIssuanceState.composeIssuance.params
                      .quantityNormalized),
              enabled: false,
              fillColor: inputFillColor,
              textColor: widget.isDarkMode ? mainTextWhite : mainTextBlack,
            ),
            const SizedBox(height: 16.0),
            widget.composeIssuanceState.composeIssuance.params.description != ''
                ? HorizonTextFormField(
                    isDarkMode: widget.isDarkMode,
                    label: "Description",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    controller: TextEditingController(
                        text: widget.composeIssuanceState.composeIssuance.params
                            .description),
                    enabled: false,
                    fillColor: inputFillColor,
                    textColor:
                        widget.isDarkMode ? mainTextWhite : mainTextBlack,
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              isDarkMode: widget.isDarkMode,
              label: "Divisible",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              controller: TextEditingController(
                  text: issueParams.divisible == true ? 'true' : 'false'),
              enabled: false,
              fillColor: inputFillColor,
              textColor: widget.isDarkMode ? mainTextWhite : mainTextBlack,
            ),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              isDarkMode: widget.isDarkMode,
              label: "Lock",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              controller: TextEditingController(
                  text: issueParams.lock == true ? 'true' : 'false'),
              enabled: false,
              fillColor: inputFillColor,
              textColor: widget.isDarkMode ? mainTextWhite : mainTextBlack,
            ),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              isDarkMode: widget.isDarkMode,
              label: "Reset",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              controller: TextEditingController(
                  text: issueParams.reset == true ? 'true' : 'false'),
              enabled: false,
              fillColor: inputFillColor,
              textColor: widget.isDarkMode ? mainTextWhite : mainTextBlack,
            ),
            Column(
              children: [
                const SizedBox(height: 16.0),
                FeeEstimation(
                    feeMap: widget.composeIssuanceState.feeEstimates,
                    virtualSize: widget.composeIssuanceState.virtualSize,
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
                            .read<ComposeIssuanceBloc>()
                            .add(FetchFormData(currentAddress: widget.address));
                      },
                      buttonText: 'BACK',
                    ),
                    HorizonContinueButton(
                      isDarkMode: widget.isDarkMode,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ComposeIssuanceBloc>().add(
                                SignAndBroadcastTransactionEvent(
                                  composeIssuance: widget
                                      .composeIssuanceState.composeIssuance,
                                  password: passwordController.text,
                                  fee: fee,
                                ),
                              );
                        }
                      },
                      buttonText: 'SIGN AND BROADCAST',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
