import 'package:formz/formz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/entities/psbt_type.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_state.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_event.dart';

// example import
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart'
    as HorizonUI;
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

class SignPsbtForm extends StatefulWidget {
  final bool passwordRequired;
  final PsbtType psbtType;

  final void Function(String) onSuccess;

  const SignPsbtForm({
    super.key,
    required this.onSuccess,
    required this.passwordRequired,
    required this.psbtType,
  });

  @override
  State<SignPsbtForm> createState() => _SignPsbtFormState();
}

class _SignPsbtFormState extends State<SignPsbtForm> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<SignPsbtBloc>().add(FetchFormEvent());
  }

  Widget _buildCreditView(AssetCredit credit, ThemeData theme) {
    return Column(children: [
      Row(children: [
        Text("+",
            style:
                theme.textTheme.headlineSmall?.copyWith(color: Colors.green)),
        Text(credit.quantity.normalized(),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.green,
            )),
        const SizedBox(width: 8),
        Text(credit.asset,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.green,
            )),
      ])
    ]);
  }

  Widget _buildDebitView(AssetDebit debit, ThemeData theme) {
    return Column(children: [
      Row(children: [
        Text("-", style: theme.textTheme.headlineSmall),
        Text(debit.quantity.normalized(), style: theme.textTheme.headlineSmall),
        const SizedBox(width: 8),
        Text(debit.asset, style: theme.textTheme.headlineSmall),
      ])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignPsbtBloc, SignPsbtState>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess) {
          widget.onSuccess(state.signedPsbt!);
        }
      },
      child:
          BlocBuilder<SignPsbtBloc, SignPsbtState>(builder: (context, state) {
        final theme = Theme.of(context);

        if (!state.isFormDataLoaded) {
          // Display a loading indicator while data is being fetched
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final session =
            context.watch<SessionStateCubit>().state.successOrThrow();

        return SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Network"),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: violet)),
                    child: Text(
                        switch (session.httpConfig.network) {
                          Network.mainnet => "mainnet",
                          Network.signet => "signet",
                          Network.testnet4 => "testnet4",
                        },
                        style: TextStyle(color: violet)))
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                switch (state.psbtSummaryViewModel) {
                  AtomicSwapListingFeeSummaryViewModel(
                    serviceFee: var serviceFee,
                    networkFee: var networkFee,
                  ) =>
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 8.0),
                          child: Row(
                            children: [
                              Text(
                                  "Inputs ( ${state.augmentedInputs != null ? state.augmentedInputs!.length : 0} )",
                                  style:
                                      Theme.of(context).textTheme.labelSmall!),
                              SizedBox(width: 8),
                              Spacer(),
                              Text(state.totalInputs.quantity.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 8.0),
                          child: Row(
                            children: [
                              Text("Service Fee",
                                  style:
                                      Theme.of(context).textTheme.labelSmall!),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(serviceFee.quantity.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 8.0),
                          child: Row(
                            children: [
                              Text("Network Fee",
                                  style:
                                      Theme.of(context).textTheme.labelSmall!),
                              Spacer(),
                              Text(networkFee.quantity.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 8.0),
                          child: Row(
                            children: [
                              Text("Change",
                                  style:
                                      Theme.of(context).textTheme.labelSmall!),
                              Spacer(),
                              Text(state.change.quantity.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.green)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 8.0),
                          child: Row(
                            children: [
                              Text("Total",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.white)),
                              Spacer(),
                              Text(state.net.quantity.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  _ => Text("placeholder")
                },
                // Column(
                //   children: state.debits
                //           ?.map(
                //             (debit) => _buildDebitView(debit, theme),
                //           )
                //           .toList() ??
                //       [],
                // ),
                // Column(
                //   children: state.credits
                //           ?.map(
                //             (credit) => _buildCreditView(credit, theme),
                //           )
                //           .toList() ??
                //       [],
                // ),
              ],
            ),
          ),

          const Divider(),
          ExpansionPanelList(
            elevation: 0,
            expansionCallback: (panelIndex, isExpanded) {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            children: [
              ExpansionPanel(
                backgroundColor: Colors.transparent,
                canTapOnHeader: true,
                isExpanded: _isExpanded,
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(
                      'Inputs & Outputs',
                      style: theme.textTheme.labelMedium,
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inputs (${state.augmentedInputs?.length})',
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(height: 8),
                      Column(
                          children: state.augmentedInputs
                                  ?.map(
                                      (input) => _buildInputView(input, theme))
                                  .toList() ??
                              []),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),

                      // --- OUTPUTS LIST ---
                      Text(
                        'Outputs (${state.augmentedOutputs?.length})',
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Column(
                        children: state.augmentedOutputs
                                ?.map(
                                    (output) => _buildOutputView(output, theme))
                                .toList() ??
                            [],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (widget.passwordRequired)
            Column(
              children: [
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: TextField(
                    onChanged: (password) => context
                        .read<SignPsbtBloc>()
                        .add(PasswordChanged(password)),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: state.password.displayError == null
                          ? null
                          : 'Password cannot be empty',
                    ),
                    obscureText: true,
                  ),
                ),
              ],
            ),

          // Submit Button
          const Divider(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: HorizonUI.HorizonButton(
                    variant: HorizonUI.ButtonVariant.black,
                    borderRadius: 10,
                    disabled: state.submissionStatus.isInProgressOrSuccess,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: HorizonUI.TextButtonContent(value: 'Cancel'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: HorizonUI.HorizonButton(
                    variant: HorizonUI.ButtonVariant.white,
                    borderRadius: 10,
                    disabled: state.submissionStatus.isInProgressOrSuccess,
                    onPressed: state.submissionStatus.isInProgressOrSuccess
                        ? null
                        : () => context
                            .read<SignPsbtBloc>()
                            .add(SignPsbtSubmitted()),
                    child: state.submissionStatus.isInProgress
                        ? HorizonUI.WidgetButtonContent(
                            value: const CircularProgressIndicator())
                        : HorizonUI.TextButtonContent(value: 'Confirm'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Status/Error Message
          if (state.submissionStatus.isFailure) ...[
            Text(
              state.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ]
        ]));
      }),
    );
  }

  Widget _buildInputView(AugmentedInput input, ThemeData theme) {
    // The address from input.address
    final address = _shortenAddress(input.address);

    // The BTC value from input.prevOut.value, if present
    final int btcValue = input.prevOut.value;

    // Show a "To sign" badge if signatureRequired
    final badge = input.signatureRequired
        ? Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "Signing",
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : const SizedBox.shrink();

    // If the input has attached balances (assets, ordinals, etc.), display them
    final balancesWidget = <Widget>[];
    if (input.balances.isNotEmpty) {
      balancesWidget.add(const SizedBox(height: 4));
      for (final b in input.balances) {
        // You might have a `b.assetName`, `b.assetId`, `b.quantityNormalized`, etc.
        balancesWidget.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text('${b.quantity.normalized()} ${b.asset}',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: address + badge
            Row(
              children: [
                Text(address, style: theme.textTheme.labelLarge),
                const SizedBox(width: 8),
                badge,
              ],
            ),
            // Right side: value
            Text("${satoshisToBtc(btcValue).toString()} BTC",
                style: theme.textTheme.labelMedium),
          ],
        ),
        input.balances.isNotEmpty
            ? Card(
                margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // <-- This ensures left alignment
                      children: [
                        Text("Attached Assets",
                            style: theme.textTheme.labelSmall),
                        ...balancesWidget,
                      ]),
                ))
            : const SizedBox.shrink()
      ],
    );
  }

  // Renders each AugmentedOutput
  Widget _buildOutputView(AugmentedOutput output, ThemeData theme) {
    // The address from output.vout.scriptPubKey.address
    // But you also have a getter in AugmentedOutput for `address`.

    final outputLabel =
        output.isOpReturn() ? "OP_RETURN" : _shortenAddress(output.address);

    // The BTC value from output.value
    final int btcValue = output.value;

    // If the input has attached balances (assets, ordinals, etc.), display them
    final balancesWidget = <Widget>[];
    if (output.balances.isNotEmpty) {
      balancesWidget.add(const SizedBox(height: 4));
      for (final b in output.balances) {
        // You might have a `b.assetName`, `b.assetId`, `b.quantityNormalized`, etc.
        balancesWidget.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text('${b.quantity.normalized()} ${b.asset}',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(outputLabel, style: theme.textTheme.labelLarge),
            Text("${satoshisToBtc(btcValue)} BTC",
                style: theme.textTheme.labelMedium),
          ],
        ),
      ],
    );
  }

  String _shortenAddress(String? address, {int prefix = 6, int suffix = 5}) {
    if (address == null || address.length < (prefix + suffix)) {
      return address ?? 'Unknown';
    }
    final start = address.substring(0, prefix);
    final end = address.substring(address.length - suffix);
    return '$start...$end';
  }
}
