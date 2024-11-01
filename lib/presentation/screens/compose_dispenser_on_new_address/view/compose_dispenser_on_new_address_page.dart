import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_state.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeDispenserOnNewAddressPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String originalAddress;
  final String asset;
  final String giveQuantity;
  final String escrowQuantity;
  final String mainchainrate;
  final bool divisible;

  const ComposeDispenserOnNewAddressPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.originalAddress,
    required this.divisible,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ComposeDispenserOnNewAddressBloc(),
      child: ComposeDispenserOnNewAddressPage(
        originalAddress: originalAddress,
        asset: asset,
        giveQuantity: giveQuantity,
        escrowQuantity: escrowQuantity,
        mainchainrate: mainchainrate,
        divisible: divisible,
      ),
    );
  }
}

class ComposeDispenserOnNewAddressPage extends StatefulWidget {
  final String originalAddress;
  final String asset;
  final String giveQuantity;
  final String escrowQuantity;
  final String mainchainrate;
  final bool divisible;
  const ComposeDispenserOnNewAddressPage({
    required this.originalAddress,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.divisible,
    super.key,
  });

  @override
  State<ComposeDispenserOnNewAddressPage> createState() =>
      _ComposeDispenserOnNewAddressPageState();
}

class _ComposeDispenserOnNewAddressPageState
    extends State<ComposeDispenserOnNewAddressPage> {
  final passwordController = TextEditingController();
  final initialFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComposeDispenserOnNewAddressBloc,
        ComposeDispenserOnNewAddressState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      child: BlocBuilder<ComposeDispenserOnNewAddressBloc,
          ComposeDispenserOnNewAddressState>(
        builder: (context, state) {
          return state.maybeWhen(
            initial: () => Form(
              key: initialFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    HorizonUI.HorizonTextFormField(
                      label: 'Open Address',
                      enabled: false,
                      controller: TextEditingController(text: 'To be created'),
                    ),
                    const SizedBox(height: 16.0),
                    HorizonUI.HorizonTextFormField(
                      label: 'Asset',
                      enabled: false,
                      controller: TextEditingController(text: widget.asset),
                    ),
                    const SizedBox(height: 16.0),
                    HorizonUI.HorizonTextFormField(
                      label: 'Give Quantity',
                      enabled: false,
                      controller:
                          TextEditingController(text: widget.giveQuantity),
                    ),
                    const SizedBox(height: 16.0),
                    HorizonUI.HorizonTextFormField(
                      label: 'Escrow Quantity',
                      enabled: false,
                      controller:
                          TextEditingController(text: widget.escrowQuantity),
                    ),
                    const SizedBox(height: 16.0),
                    HorizonUI.HorizonTextFormField(
                      label: 'Price Per Unit (BTC)',
                      enabled: false,
                      controller:
                          TextEditingController(text: widget.mainchainrate),
                    ),
                    _buildBackContinueButtons(
                      onBack: () {
                        Navigator.of(context).pop();
                      },
                      onContinue: () {
                        if (initialFormKey.currentState!.validate()) {
                          context
                              .read<ComposeDispenserOnNewAddressBloc>()
                              .add(CollectPassword());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            collectPassword: (error) => Form(
              key: passwordFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    HorizonUI.HorizonTextFormField(
                      controller: passwordController,
                      label: 'Password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    _buildBackContinueButtons(
                      onBack: () {
                        Navigator.of(context).pop();
                      },
                      onContinue: () {
                        if (passwordFormKey.currentState!.validate()) {
                          Decimal giveInput =
                              Decimal.parse(widget.giveQuantity);
                          Decimal escrowInput =
                              Decimal.parse(widget.escrowQuantity);
                          Decimal mainchainrateBtc = Decimal.parse(
                              widget.mainchainrate); // Price in BTC

                          int giveQuantity;
                          int escrowQuantity;

                          // Handle divisibility for the give quantity
                          if (widget.divisible) {
                            giveQuantity =
                                (giveInput * Decimal.fromInt(100000000))
                                    .toBigInt()
                                    .toInt();
                            escrowQuantity =
                                (escrowInput * Decimal.fromInt(100000000))
                                    .toBigInt()
                                    .toInt();
                          } else {
                            giveQuantity = giveInput.toBigInt().toInt();
                            escrowQuantity = escrowInput.toBigInt().toInt();
                          }

                          int mainchainrate =
                              (mainchainrateBtc * Decimal.fromInt(100000000))
                                  .toBigInt()
                                  .toInt();

                          // Dispatch the event with the calculated values

                          context
                              .read<ComposeDispenserOnNewAddressBloc>()
                              .add(ComposeTransactions(
                                originalAddress: widget.originalAddress,
                                divisible: widget.divisible,
                                asset: widget.asset,
                                giveQuantity: giveQuantity,
                                escrowQuantity: escrowQuantity,
                                mainchainrate: mainchainrate,
                                status: 0,
                              ));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildBackContinueButtons(
      {required VoidCallback onBack, required VoidCallback onContinue}) {
    return Column(
      children: [
        const HorizonUI.HorizonDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HorizonUI.HorizonCancelButton(
              onPressed: onBack,
              buttonText: 'BACK',
            ),
            HorizonUI.HorizonContinueButton(
              onPressed: onContinue,
              buttonText: 'CONTINUE',
            ),
          ],
        ),
      ],
    );
  }
}
