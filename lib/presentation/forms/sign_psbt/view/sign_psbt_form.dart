import 'package:formz/formz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/extension_rpc.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/entities/psbt_type.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/sats_to_usd_display.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_state.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_event.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

// example import
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart'
    as HorizonUI;
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

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

  TextEditingController passwordController = TextEditingController();

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

        final appIcons = AppIcons();
        return SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          //   child: Text("Review Transaction",
          //       style: Theme.of(context)
          //           .textTheme
          //           .titleMedium!
          //           .copyWith(color: Colors.white)),
          // ),
          Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 12),
              child: switch (state.psbtSummaryViewModel) {
                OrderSummaryViewModel(
                  giveAsset: var giveAsset,
                  giveQuantity: var giveQuantity,
                  getAsset: var getAsset,
                  getQuantity: var getQuantity,
                ) =>
                  Column(
                    children: [
                      SizedBox(
                          width: double.infinity,
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: HorizonUI.HorizonCard(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                child: Column(children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          appIcons.assetIcon(
                                            httpConfig: session.httpConfig,
                                            context: context,
                                            assetName: giveAsset,
                                            description:
                                                "", // TODO: add desc to summary.
                                            width: 34,
                                            height: 34,
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 0, 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Sell",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                              Text(
                                                giveAsset,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                        color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            giveQuantity
                                                .normalizedPretty()
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall!
                                                .copyWith(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ]),
                              ))),
                      SizedBox(height: 16),
                      SizedBox(
                          width: double.infinity,
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: HorizonUI.HorizonCard(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                child: Column(children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          appIcons.assetIcon(
                                            httpConfig: session.httpConfig,
                                            context: context,
                                            assetName: getAsset,
                                            description:
                                                "", // TODO: add desc to summary.
                                            width: 34,
                                            height: 34,
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 0, 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Buy",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                              Text(
                                                getAsset,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                        color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            getQuantity
                                                .normalizedPretty()
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall!
                                                .copyWith(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ]),
                              ))),
                    ],
                  ),
                XCPSendSummaryViewModel(
                  toAddress: var toAddress,
                  quantity: var quantity,
                  assetName: var assetName,
                ) =>
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 0, 0, 4.0),
                            child: Text(
                              "You're sending",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: HorizonUI.HorizonCard(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "To",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(color: Colors.grey),
                                      ),
                                      Text(
                                        " ${_shortenAddress(toAddress)}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          appIcons.assetIcon(
                                            httpConfig: session.httpConfig,
                                            context: context,
                                            assetName: assetName,
                                            description:
                                                "", // TODO: add desc to summary.
                                            width: 34,
                                            height: 34,
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 0, 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Quantity",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                              Text(
                                                assetName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                        color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            quantity
                                                .normalizedPretty()
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall!
                                                .copyWith(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ]),
                              ))),
                    ],
                  ),
                BtcSendSummaryViewModel(
                  toAddress: var toAddress,
                  btc: var btc,
                ) =>
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 0, 0, 4.0),
                            child: Text(
                              "You're sending",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: HorizonUI.HorizonCard(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "To",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(color: Colors.grey),
                                      ),
                                      Text(
                                        " ${_shortenAddress(toAddress)}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          appIcons.assetIcon(
                                            httpConfig: session.httpConfig,
                                            context: context,
                                            assetName: "BTC",
                                            description:
                                                "", // TODO: add desc to summary.
                                            width: 34,
                                            height: 34,
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 0, 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Quantity",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                              Text(
                                                "BTC",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                        color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${btc.quantity.toString()} sat",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall!
                                                .copyWith(color: Colors.white),
                                          ),
                                          SatsToUsdDisplay(
                                              sats: btc.quantity,
                                              child: (usdValue) => Text(
                                                    '\$${usdValue.toStringAsFixed(2)}',
                                                    style: theme
                                                        .textTheme.labelSmall
                                                        ?.copyWith(
                                                            fontSize: 10,
                                                            color: Colors.grey),
                                                  )),
                                        ],
                                      ),
                                    ],
                                  )
                                ]),
                              ))),
                    ],
                  ),
                AtomicSwapListingFeeSummaryViewModel(
                  serviceFee: var btc,
                ) =>
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24.0, 0, 0, 4.0),
                            child: Text(
                              "You're sending",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: HorizonUI.HorizonCard(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "To",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(color: Colors.grey),
                                      ),
                                      Text(
                                        "horizon.market",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          appIcons.assetIcon(
                                            httpConfig: session.httpConfig,
                                            context: context,
                                            assetName: "BTC",
                                            description:
                                                "", // TODO: add desc to summary.
                                            width: 34,
                                            height: 34,
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 0, 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Quantity",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                              Text(
                                                "BTC",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                        color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${btc.quantity.toString()} sat",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall!
                                                .copyWith(color: Colors.white),
                                          ),
                                          SatsToUsdDisplay(
                                              sats: btc.quantity,
                                              child: (usdValue) => Text(
                                                    '\$${usdValue.toStringAsFixed(2)}',
                                                    style: theme
                                                        .textTheme.labelSmall
                                                        ?.copyWith(
                                                            fontSize: 10,
                                                            color: Colors.grey),
                                                  )),
                                        ],
                                      ),
                                    ],
                                  )
                                ]),
                              ))),
                    ],
                  ),
                // AtomicSwapListingFeeSummaryViewModel() => SizedBox(
                //     width: double.infinity,
                //     child: Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //       child: HorizonUI.HorizonCard(
                //           padding:
                //               EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                //           child: Row(children: [
                //             Column(
                //               mainAxisAlignment: MainAxisAlignment.start,
                //               children: [
                //                 Padding(
                //                   padding:
                //                       const EdgeInsets.fromLTRB(4, 0, 8, 0),
                //                   child: Icon(
                //                     Icons.info,
                //                     size: 14,
                //                     color: Theme.of(context)
                //                         .textTheme
                //                         .bodySmall
                //                         ?.color,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //             Expanded(
                //                 child: Text(
                //                     "horizon.market charges \$2.00 per atomic swap listing.  After confirming this transaction, your listing will be posted to horizon.market",
                //                     style: Theme.of(context)
                //                         .textTheme
                //                         .bodySmall!
                //                         .copyWith(color: Colors.white)))
                //           ])),
                //     ),
                //   ),
                OpaquePsbtSummaryViewModel() => SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: HorizonUI.HorizonCard(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Row(children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(4, 0, 8, 0),
                                  child: Icon(
                                    Icons.info,
                                    size: 14,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                                child: Text(
                                    "A third party has requested that you sign this transaction.  It will not be broadcasted from your wallet, but may be broadcasted by the requesting party.  It is recommended that you verify the transaction inputs and outputs.",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(color: Colors.white)))
                          ])),
                    ),
                  ),
                AtomicSwapSellSummaryViewModel() => SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: HorizonUI.HorizonCard(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Row(children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(4, 0, 8, 0),
                                  child: Icon(
                                    Icons.info,
                                    size: 14,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                                child: Text(
                                    "You are creating a partially signed bitcoin transaction ( PSBT ).  Your listing will be posted to horizon.market when you broadcast the listing fee after creating the PSBT.  The transaction will not be broadcast to the network until a buyer purchases the listing.",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(color: Colors.white)))
                          ])),
                    ),
                  ),
                AtomicSwapBuySummaryViewModel() => SizedBox.shrink(),
              }),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Network",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(color: Colors.white)),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: violet)),
                    child: Text(
                        switch (session.httpConfig.network) {
                          Network.mainnet => "mainnet",
                          Network.signet => "signet",
                          Network.testnet4 => "testnet4",
                        },
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: violet)))
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
                  AtomicSwapSellSummaryViewModel() => Column(
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
                              Text(
                                  "${state.totalInputs.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Row(
                            children: [
                              Text("Change",
                                  style:
                                      Theme.of(context).textTheme.labelSmall!),
                              Spacer(),
                              Text("${state.change.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.green)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
                          child: Column(
                            children: [
                              Row(
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
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SatsToUsdDisplay(
                                  sats: state.net.quantity,
                                  child: (usdValue) => Text(
                                        '\$${usdValue.toStringAsFixed(2)}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                fontSize: 10,
                                                color: Colors.grey),
                                      )),
                            ],
                          ),
                        )
                      ],
                    ),
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
                              Text(
                                  "${state.totalInputs.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Service Fee",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          "${serviceFee.quantity.toString()} sat",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall!
                                              .copyWith(color: Colors.white)),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Service fee for posting listing",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: Colors.grey,
                                                fontSize: 10)),
                                    SatsToUsdDisplay(
                                        sats: serviceFee.quantity,
                                        child: (usdValue) => Text(
                                              '\$${usdValue.toStringAsFixed(2)}',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                      fontSize: 10,
                                                      color: Colors.grey),
                                            ))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Network Fee",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!),
                                  Spacer(),
                                  Text("${networkFee.quantity.toString()} sat",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(color: Colors.white)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SatsToUsdDisplay(
                                      sats: networkFee.quantity,
                                      child: (usdValue) => Text(
                                            '\$${usdValue.toStringAsFixed(2)}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                    fontSize: 10,
                                                    color: Colors.grey),
                                          )),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Row(
                            children: [
                              Text("Change",
                                  style:
                                      Theme.of(context).textTheme.labelSmall!),
                              Spacer(),
                              Text("${state.change.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.green)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
                          child: Column(
                            children: [
                              Row(
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
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SatsToUsdDisplay(
                                  sats: state.net.quantity,
                                  child: (usdValue) => Text(
                                        '\$${usdValue.toStringAsFixed(2)}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                fontSize: 10,
                                                color: Colors.grey),
                                      )),
                            ],
                          ),
                        )
                      ],
                    ),
                  XCPSendSummaryViewModel(
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
                              Text(
                                  "${state.totalInputs.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Network Fee",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!),
                                  Spacer(),
                                  Text("${networkFee.quantity.toString()} sat",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(color: Colors.white)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SatsToUsdDisplay(
                                      sats: networkFee.quantity,
                                      child: (usdValue) => Text(
                                            '\$${usdValue.toStringAsFixed(2)}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                    fontSize: 10,
                                                    color: Colors.grey),
                                          )),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Row(
                            children: [
                              Text("Change",
                                  style:
                                      Theme.of(context).textTheme.labelSmall!),
                              Spacer(),
                              Text("${state.change.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.green)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
                          child: Column(
                            children: [
                              Row(
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
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SatsToUsdDisplay(
                                  sats: state.net.quantity,
                                  child: (usdValue) => Text(
                                        '\$${usdValue.toStringAsFixed(2)}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                fontSize: 10,
                                                color: Colors.grey),
                                      )),
                            ],
                          ),
                        )
                      ],
                    ),
                  BtcSendSummaryViewModel(
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
                              Text(
                                  "${state.totalInputs.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Network Fee",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!),
                                  Spacer(),
                                  Text("${networkFee.quantity.toString()} sat",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(color: Colors.white)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SatsToUsdDisplay(
                                      sats: networkFee.quantity,
                                      child: (usdValue) => Text(
                                            '\$${usdValue.toStringAsFixed(2)}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                    fontSize: 10,
                                                    color: Colors.grey),
                                          )),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Row(
                            children: [
                              Text("Change",
                                  style:
                                      Theme.of(context).textTheme.labelSmall!),
                              Spacer(),
                              Text("${state.change.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.green)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
                          child: Column(
                            children: [
                              Row(
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
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SatsToUsdDisplay(
                                  sats: state.net.quantity,
                                  child: (usdValue) => Text(
                                        '\$${usdValue.toStringAsFixed(2)}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                fontSize: 10,
                                                color: Colors.grey),
                                      )),
                            ],
                          ),
                        )
                      ],
                    ),
                  OrderSummaryViewModel(
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
                              Text(
                                  "${state.totalInputs.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Network Fee",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!),
                                  Spacer(),
                                  Text("${networkFee.quantity.toString()} sat",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(color: Colors.white)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SatsToUsdDisplay(
                                      sats: networkFee.quantity,
                                      child: (usdValue) => Text(
                                            '\$${usdValue.toStringAsFixed(2)}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                    fontSize: 10,
                                                    color: Colors.grey),
                                          )),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Row(
                            children: [
                              Text("Change",
                                  style:
                                      Theme.of(context).textTheme.labelSmall!),
                              Spacer(),
                              Text("${state.change.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.green)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
                          child: Column(
                            children: [
                              Row(
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
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SatsToUsdDisplay(
                                  sats: state.net.quantity,
                                  child: (usdValue) => Text(
                                        '\$${usdValue.toStringAsFixed(2)}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                fontSize: 10,
                                                color: Colors.grey),
                                      )),
                            ],
                          ),
                        )
                      ],
                    ),
                  AtomicSwapBuySummaryViewModel(
                    networkFee: var networkFee,
                    royaltyFee: var royaltyFee
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
                              Text(
                                  "${state.totalInputs.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        royaltyFee != null
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text("Royalty fee",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall!),
                                        Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                                "${royaltyFee.quantity.toString()} sat",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                        color: Colors.white)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 2, 0, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SatsToUsdDisplay(
                                              sats: royaltyFee.quantity,
                                              child: (usdValue) => Text(
                                                    '\$${usdValue.toStringAsFixed(2)}',
                                                    style: theme
                                                        .textTheme.labelSmall
                                                        ?.copyWith(
                                                            fontSize: 10,
                                                            color: Colors.grey),
                                                  ))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Network Fee",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!),
                                  Spacer(),
                                  Text("${networkFee.quantity.toString()} sat",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(color: Colors.white)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SatsToUsdDisplay(
                                      sats: networkFee.quantity,
                                      child: (usdValue) => Text(
                                            '\$${usdValue.toStringAsFixed(2)}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                    fontSize: 10,
                                                    color: Colors.grey),
                                          )),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Row(
                            children: [
                              Text("Change",
                                  style:
                                      Theme.of(context).textTheme.labelSmall!),
                              Spacer(),
                              Text("${state.change.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.green)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
                          child: Column(
                            children: [
                              Row(
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
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SatsToUsdDisplay(
                                  sats: state.net.quantity,
                                  child: (usdValue) => Text(
                                        '\$${usdValue.toStringAsFixed(2)}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                fontSize: 10,
                                                color: Colors.grey),
                                      )),
                            ],
                          ),
                        )
                      ],
                    ),
                  OpaquePsbtSummaryViewModel(
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
                              Text(
                                  "${state.totalInputs.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Network Fee",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!),
                                  Spacer(),
                                  Text("${networkFee.quantity.toString()} sat",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(color: Colors.white)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SatsToUsdDisplay(
                                      sats: networkFee.quantity,
                                      child: (usdValue) => Text(
                                            '\$${usdValue.toStringAsFixed(2)}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                    fontSize: 10,
                                                    color: Colors.grey),
                                          )),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Row(
                            children: [
                              Text("Change",
                                  style:
                                      Theme.of(context).textTheme.labelSmall!),
                              Spacer(),
                              Text("${state.change.quantity.toString()} sat",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: Colors.green)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
                          child: Column(
                            children: [
                              Row(
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
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SatsToUsdDisplay(
                                  sats: state.net.quantity,
                                  child: (usdValue) => Text(
                                        '\$${usdValue.toStringAsFixed(2)}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                fontSize: 10,
                                                color: Colors.grey),
                                      )),
                            ],
                          ),
                        )
                      ],
                    ),
                },
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
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        _isExpanded ? "Inputs" : 'Inputs & Outputs',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        "Outputs",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Column(
                        children: state.augmentedOutputs
                                ?.asMap()
                                .map((i, output) => MapEntry(
                                    i,
                                    _buildOutputView(
                                        output,
                                        theme,
                                        switch ((widget.psbtType, i)) {
                                          (AtomicSwapSellPsbt(), 0) => true,
                                          _ => false,
                                        })))
                                .values
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
                  child: HorizonUI.HorizonTextField(
                    controller: passwordController,
                    onChanged: (password) => context
                        .read<SignPsbtBloc>()
                        .add(PasswordChanged(password)),
                    obscureText: true,
                    label: 'Password',
                    errorText: state.password.displayError == null
                        ? null
                        : 'Password cannot be empty',
                  ),
                ),
              ],
            ),
          if (state.submissionStatus.isFailure) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                state.error!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            )
          ],

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
                      final cb = switch (widget.psbtType) {
                        OpaquePsbt() => GetIt.I<RPCCancelCallback>(),
                        _ => () => Navigator.of(context).pop()
                      };

                      cb();
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
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: violet)),
            child: Text(
              "signing",
              style: TextStyle(
                color: violet,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : const SizedBox.shrink();

    final unconfirmed = !input.confirmed
        ? Container(
            margin: const EdgeInsets.only(left: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: violet)),
            child: Text(
              "unconfirmed",
              style: TextStyle(
                color: violet,
                fontSize: 8,
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
                Text(address, style: theme.textTheme.labelSmall),
                const SizedBox(width: 8),
                badge,
                unconfirmed
              ],
            ),
            // Right side: value
            Text("${(btcValue)} sat", style: theme.textTheme.labelSmall),
          ],
        ),
        input.balances.isNotEmpty
            ? Card(
                margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 4, 8.0, 4),
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
  Widget _buildOutputView(
      AugmentedOutput output, ThemeData theme, bool isDummyOutput) {
    // The address from output.vout.scriptPubKey.address
    // But you also have a getter in AugmentedOutput for `address`.

    String outputLabel =
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('${b.quantity.normalized()} ${b.asset}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    }

    if (isDummyOutput) {
      outputLabel = "BUYER_OUTPUT";
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(outputLabel,
                    style: Theme.of(context).textTheme.labelSmall),
                isDummyOutput
                    ? Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Tooltip(
                          message:
                              "This output will be replaced by the swap buyer.",
                          child: Icon(
                            Icons.help,
                            size: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                output.isOpReturn()
                    ? Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Tooltip(
                          message:
                              "Counterparty transaction data is encoded on this script output",
                          child: Icon(
                            Icons.info,
                            size: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            Row(
              children: [
                Text("${btcValue} sat",
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            )
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
