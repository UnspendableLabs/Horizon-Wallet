import 'package:formz/formz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/common/format.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_state.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_event.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/colors.dart';

import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/balance.dart'; // example import
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';

/// A widget that shows information about a TX input (Vin),
/// including extended info like BTC value and attached assets.
// class VinCard extends StatefulWidget {
//   final Vin vin;
//
//   // You’d pass in whichever services or repos are needed.
//   final BitcoinRepository bitcoinRepository;
//   final BalanceRepository balanceRepository;
//
//   const VinCard({
//     Key? key,
//     required this.vin,
//     required this.bitcoinRepository,
//     required this.balanceRepository,
//   }) : super(key: key);
//
//   @override
//   State<VinCard> createState() => _VinCardState();
// }
//
// class _VinCardState extends State<VinCard> {
//   // Data we want to load asynchronously:
//   int? btcValue;
//   List<Balance>?
//       attachedAssets; // or whatever type your “getBalancesForUTXO” returns
//   String? errorMessage;
//   bool isLoading = true;
//   String? address;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchVinData();
//   }
//
//   Future<void> _fetchVinData() async {
//     try {
//       // 1) Find the transaction containing this VIN’s UTXO.
//       // 2) From that transaction, get the vout value.
//       // 3) Query the balanceRepository to see if there are any assets on this UTXO.
//
//       final txDetailsEither =
//           await widget.bitcoinRepository.getTransaction(widget.vin.txid);
//
//       // The repository likely returns an Either, so we’ll fold or handle success/failure.
//       final txDetails = txDetailsEither.fold(
//         (failure) => throw Exception("Unable to get transaction: $failure"),
//         (ok) => ok,
//       );
//
//       // This is the BTC amount from the referenced output.
//       final int outputValue = txDetails.vout[widget.vin.vout].value;
//
//       String? address = txDetails.vout[widget.vin.vout].scriptpubkeyAddress;
//
//       print("\n\n\n");
//       print(txDetails.vout[widget.vin.vout].scriptpubkeyAddress);
//
//       print("\n\n\n");
//       // If your chain expects BTC in "satoshis," you might convert it.
//       // We’ll assume outputValue is already in BTC.
//
//       // Now get any assets attached:
//       final String utxoKey = "${widget.vin.txid}:${widget.vin.vout}";
//       final balances =
//           await widget.balanceRepository.getBalancesForUTXO(utxoKey);
//
//       setState(() {
//         btcValue = outputValue;
//         attachedAssets = balances;
//         isLoading = false;
//         this.address = address;
//       });
//     } catch (err) {
//       setState(() {
//         errorMessage = err.toString();
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Card(
//         child: ListTile(
//           title: Text("Loading input data..."),
//         ),
//       );
//     }
//
//     if (errorMessage != null) {
//       return Card(
//         child: ListTile(
//           title: Text("Error loading input data"),
//           subtitle: Text(errorMessage!),
//         ),
//       );
//     }
//
//     // If we’re here, we have data
//     return Card(
//       child: ListTile(
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('address ${address}'),
//             Text('Vout index: ${widget.vin.vout}'),
//             Text('ScriptSig (asm): ${widget.vin.scriptSig.asm}'),
//             if (widget.vin.txinwitness != null &&
//                 widget.vin.txinwitness!.isNotEmpty)
//               Text('txinwitness: ${widget.vin.txinwitness}'),
//             Text('Sequence: ${widget.vin.sequence}'),
//             const SizedBox(height: 8),
//             if (btcValue != null) Text('Value: $btcValue BTC'),
//
//             // Render your asset details, if any
//             if (attachedAssets != null && attachedAssets!.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               Text('Assets: '),
//               for (final b in attachedAssets!)
//                 Text('- ${b.asset}: ${b.quantityNormalized}')
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
class SignPsbtForm extends StatefulWidget {
  final bool passwordRequired;
  final BalanceRepository balanceRepository;
  final BitcoinRepository bitcoinRepository;

  final void Function(String) onSuccess;

  const SignPsbtForm(
      {super.key,
      required this.onSuccess,
      required this.passwordRequired,
      required this.bitcoinRepository,
      required this.balanceRepository});

  @override
  State<SignPsbtForm> createState() => _SignPsbtFormState();
}

class _SignPsbtFormState extends State<SignPsbtForm> {
  @override
  void initState() {
    super.initState();
    context.read<SignPsbtBloc>().add(FetchFormEvent());
  }

  Widget _buildVoutCard(Vout output) {
    return Card(
      child: ListTile(
        title: Text('Value: ${output.value} BTC'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ScriptPubKey (asm): ${output.scriptPubKey.asm}'),
            const SizedBox(height: 4),
            Text('Type: ${output.scriptPubKey.type}'),
            const SizedBox(height: 4),
            // Address might be null
            if (output.scriptPubKey.address != null)
              Text('Address: ${output.scriptPubKey.address}'),
          ],
        ),
      ),
    );
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Basic transaction info

            // Inputs
            Text(
              'Inputs (${state.augmentedInputs?.length})',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Column(
                children: state.augmentedInputs
                        ?.map((input) => _buildInputView(input, theme))
                        .toList() ??
                    []),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            // --- OUTPUTS LIST ---
            Text(
              'Outputs (${state.augmentedOutputs?.length})',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Column(
              children: state.augmentedOutputs
                      ?.map((output) => _buildOutputView(output, theme))
                      .toList() ??
                  [],
            ),

            if (widget.passwordRequired)
              TextField(
                onChanged: (password) =>
                    context.read<SignPsbtBloc>().add(PasswordChanged(password)),
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: state.password.displayError == null
                      ? null
                      : 'Password cannot be empty',
                ),
                obscureText: true,
              ),

            // Submit Button
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: state.submissionStatus.isInProgressOrSuccess
                      ? null
                      : () =>
                          context.read<SignPsbtBloc>().add(SignPsbtSubmitted()),
                  child: state.submissionStatus.isInProgress
                      ? const CircularProgressIndicator()
                      : const Text('Sign PSBT'),
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
            ] else if (state.submissionStatus.isSuccess) ...[
              const Text(
                'Transaction signed successfully!',
                style: TextStyle(color: Colors.green),
              ),
              // Show the signed PSBT if needed
              if (state.signedPsbt != null)
                SelectableText(
                  'Signed PSBT: ${state.signedPsbt}',
                  style: const TextStyle(color: Colors.black),
                ),
            ],
          ]),
        );
      }),
    );

    // return Padding(
    //   padding: const EdgeInsets.all(16.0),
    //   child: Column(
    //     children: [
    //       Row(
    //         children: [
    //           const Text(
    //             "Inputs",
    //             style: TextStyle(
    //               fontSize: 20,
    //               fontWeight: FontWeight.bold,
    //             ),
    //           ),
    //         ],
    //       ),
    //       Column(
    //         children: state.transaction!.vin.map((input) {
    //           return VinCard(
    //               vin: input,
    //               bitcoinRepository: widget.bitcoinRepository,
    //               balanceRepository: widget.balanceRepository);
    //         }).toList(),
    //       ),
    //       const SizedBox(height: 20),
    //
    //       // Outputs
    //       Row(
    //         children: [
    //           Text(
    //             "Ouputs",
    //             style: TextStyle(
    //               fontSize: 20,
    //               fontWeight: FontWeight.bold,
    //             ),
    //           ),
    //         ],
    //       ),
    //       const SizedBox(height: 8),
    //       Column(
    //         children: state.transaction!.vout.map((output) {
    //           return _buildVoutCard(output);
    //         }).toList(),
    //       ),
    //       const Text(
    //         'Transaction Details',
    //         style: TextStyle(
    //           fontSize: 20,
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //       const SizedBox(height: 16),
    //
    //       // Password Field
    //       if (widget.passwordRequired)
    //         TextField(
    //           onChanged: (password) => context
    //               .read<SignPsbtBloc>()
    //               .add(PasswordChanged(password)),
    //           decoration: InputDecoration(
    //             labelText: 'Password',
    //             errorText: state.password.displayError == null
    //                 ? null
    //                 : 'Password cannot be empty',
    //           ),
    //           obscureText: true,
    //         ),
    //
    //       const SizedBox(height: 20),
    //       // Submit Button
    //       ElevatedButton(
    //         onPressed: state.submissionStatus.isInProgressOrSuccess
    //             ? null
    //             : () =>
    //                 context.read<SignPsbtBloc>().add(SignPsbtSubmitted()),
    //         child: state.submissionStatus.isInProgress
    //             ? const CircularProgressIndicator()
    //             : const Text('Sign PSBT asfd'),
    //       ),
    //       const SizedBox(height: 20),
    //       // Status/Error Message
    //       if (state.submissionStatus.isFailure) ...[
    //         Text(
    //           state.error!,
    //           style: const TextStyle(color: Colors.red),
    //         ),
    //       ] else if (state.submissionStatus.isSuccess) ...[
    //         const Text(
    //           'Transaction signed successfully!',
    //           style: TextStyle(color: Colors.green),
    //         ),
    //         // Show the signed PSBT if needed
    //         if (state.signedPsbt != null)
    //           SelectableText(
    //             'Signed PSBT: ${state.signedPsbt}',
    //             style: const TextStyle(color: Colors.black),
    //           ),
    //       ],
    //     ],
    //   ),
    // );
    //     },
    //   ),
    // );
  }

  Widget _buildInputView(AugmentedInput input, ThemeData theme) {
    // The address from input.address
    final address = _shortenAddress(input.address);

    // The BTC value from input.prevOut.value, if present
    final int btcValue = input.prevOut.value;
    final valueStr = '${btcValue.toStringAsFixed(8)} BTC';

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
                  child: Text('${b.quantityNormalized} ${b.asset}',
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
                margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
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
            : SizedBox.shrink()
      ],
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Row(
          children: [
            Expanded(child: Text('Input from: $address')),
            badge,
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Value: $valueStr'),
            ...balancesWidget,
          ],
        ),
      ),
    );
  }

  // Renders each AugmentedOutput
  Widget _buildOutputView(AugmentedOutput output, ThemeData theme) {
    // The address from output.vout.scriptPubKey.address
    // But you also have a getter in AugmentedOutput for `address`.
    final address = _shortenAddress(output.address);

    // The BTC value from output.value
    final double? btcValue = output.value;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(address, style: theme.textTheme.labelLarge),
            Text("${btcValue.toString()} BTC",
                style: theme.textTheme.labelMedium),
          ],
        ),
        // Right side: value
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
