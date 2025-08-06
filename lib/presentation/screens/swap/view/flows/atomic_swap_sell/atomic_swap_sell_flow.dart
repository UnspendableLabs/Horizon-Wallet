import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';
import 'package:horizon/extensions.dart';

import 'package:horizon/presentation/forms/asset_attach_form/asset_attach_form_view.dart';
import 'package:horizon/presentation/forms/create_psbt_form/create_psbt_form_view.dart';
import 'package:horizon/presentation/forms/swap_create_listing_confirmation_form/swap_create_listing_confirmation_form_view.dart';

sealed class AtomicSwapSellVariant {}

class AttachedAtomicSwapSell extends AtomicSwapSellVariant {
  final String asset;
  final String quantityNormalized;
  final int quantity;
  final String utxo;
  final String utxoAddress;

  AttachedAtomicSwapSell({
    required this.asset,
    required this.quantityNormalized,
    required this.quantity,
    required this.utxo,
    required this.utxoAddress,
  });
}

class UnattachedAtomicSwapSell extends AtomicSwapSellVariant {
  final String? description;
  final bool divisible;
  final String address;
  final String asset;
  final String quantityNormalized;
  final int quantity;

  UnattachedAtomicSwapSell({
    required this.address,
    required this.divisible,
    required this.asset,
    required this.quantityNormalized,
    required this.quantity,
    required this.description,
  });
}

extension AtomicSwapSellVariantX on AssetBalanceFormModel {
  Either<String, AtomicSwapSellVariant> get atomicSwapSellVariant {
    final input = balanceInput.value;
    if (input == null) {
      return left("Balance input is null");
    }

    final entry = input.entry;
    final asset = multiAddressBalance.asset;

    if (entry.address != null) {
      return right(
        UnattachedAtomicSwapSell(
          address: entry.address!,
          asset: asset,
          quantityNormalized: entry.quantityNormalized,
          quantity: entry.quantity,
          description: multiAddressBalance.assetInfo.description,
          divisible: multiAddressBalance.assetInfo.divisible,
        ),
      );
    }

    if (entry.utxo != null && entry.utxoAddress != null) {
      return right(
        AttachedAtomicSwapSell(
          asset: asset,
          quantityNormalized: entry.quantityNormalized,
          quantity: entry.quantity,
          utxo: entry.utxo!,
          utxoAddress: entry.utxoAddress!,
        ),
      );
    }

    return left("Invalid balance input");
  }
}

class SwapSellConfirmationDetails {
  final BigInt btcPrice;
  final String signedPsbt;
  final AttachedAtomicSwapSell sellDetails;

  const SwapSellConfirmationDetails({
    required this.btcPrice,
    required this.signedPsbt,
    required this.sellDetails,
  });
}

class AtomicSwapSellModel extends Equatable {
  final Option<AtomicSwapSellVariant> atomicSwapSellVariant;
  final Option<SwapSellConfirmationDetails> swapSellConfirmationDetails;

  const AtomicSwapSellModel(
      {required this.atomicSwapSellVariant,
      required this.swapSellConfirmationDetails});

  @override
  List<Object?> get props => [];

  AtomicSwapSellModel copyWith(
          {Option<AtomicSwapSellVariant>? atomicSwapSellVariant,
          Option<SwapSellConfirmationDetails>? swapSellConfirmationDetails}) =>
      AtomicSwapSellModel(
        atomicSwapSellVariant:
            atomicSwapSellVariant ?? this.atomicSwapSellVariant,
        swapSellConfirmationDetails:
            swapSellConfirmationDetails ?? this.swapSellConfirmationDetails,
      );
}

class AtomicSwapSellFlowController extends FlowController<AtomicSwapSellModel> {
  AtomicSwapSellFlowController({required AtomicSwapSellModel initialState})
      : super(initialState);
}

class AtomicSwapSellFlowView extends StatefulWidget {
  final List<AddressV2> addresses;

  final MultiAddressBalance balances;

  const AtomicSwapSellFlowView(
      {required this.addresses, required this.balances, super.key});

  @override
  State<AtomicSwapSellFlowView> createState() => _AtomicSwapSellFlowViewState();
}

class _AtomicSwapSellFlowViewState extends State<AtomicSwapSellFlowView> {
  late AtomicSwapSellFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AtomicSwapSellFlowController(
        initialState: const AtomicSwapSellModel(
            atomicSwapSellVariant: Option.none(),
            swapSellConfirmationDetails: Option.none()));
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<AtomicSwapSellModel>(
      controller: _controller,
      onGeneratePages: (model, pages) {
        return [
          Option.of(MaterialPage(
              child: FlowStep(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: AppIcons.backArrowIcon(
                context: context,
                width: 24,
                height: 24,
                fit: BoxFit.fitHeight,
              ),
            ),
            title: "Choose your asset / address",
            widthFactor: .4,
            body: AssetBalanceFormProvider(
              multiAddressBalance: widget.balances,
              child: (actions, state) => Column(
                children: [
                  AssetBalanceSuccessHandler<AtomicSwapSellVariant>(
                      mapSuccess: (state) {
                    return state.atomicSwapSellVariant;
                  }, onSuccess: (option) {
                    _controller.update(
                      (model) => model.copyWith(
                        atomicSwapSellVariant: Option.of(option),
                      ),
                    );
                  }),
                  AssetBalanceForm(
                    state: state,
                    actions: actions,
                  ),
                ],
              ),
            ),
          ))),
          model.atomicSwapSellVariant.map((variant) => switch (variant) {
                UnattachedAtomicSwapSell() => MaterialPage(
                      child: FlowStep(
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: AppIcons.backArrowIcon(
                        context: context,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    title: "Attach assets to swap",
                    widthFactor: .5,
                    body: AssetAttachFormProvider(
                        address: widget.addresses.firstWhere(
                            (address) => address.address == variant.address),
                        asset: variant.asset,
                        quantity: variant.quantity,
                        quantityNormalized: variant.quantityNormalized,
                        description: variant.description,
                        divisible: variant.divisible,
                        child: (actions, state) => Column(
                              children: [
                                AssetAttachSuccessHandler(
                                    onSuccess: (attachedAtomicSwapSell) {
                                  _controller.update(
                                    (model) => model.copyWith(
                                      atomicSwapSellVariant:
                                          Option.of(attachedAtomicSwapSell),
                                    ),
                                  );
                                }),
                                AssetAttachForm(state: state, actions: actions),
                              ],
                            )),
                  )),
                AttachedAtomicSwapSell() => MaterialPage(
                    child: FlowStep(
                        leading: IconButton(
                          onPressed: () {
                            _controller.update(
                              (model) => model.copyWith(
                                atomicSwapSellVariant: const Option.none(),
                              ),
                            );
                          },
                          icon: AppIcons.backArrowIcon(
                            context: context,
                            width: 24,
                            height: 24,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        title: "Create PSBT",
                        widthFactor: .8,
                        body: CreatePsbtFormProvider(
                          utxoID: variant.utxo,
                          address: widget.addresses.firstWhere((address) =>
                              address.address == variant.utxoAddress),
                          child: (actions, state) => Column(
                            children: [
                              CreatePsbtSuccessHandler(
                                  onSuccess: (createPsbtSuccess) {
                                _controller.update(
                                  (model) => model.copyWith(
                                    swapSellConfirmationDetails: Option.of(
                                        SwapSellConfirmationDetails(
                                            signedPsbt:
                                                createPsbtSuccess.signedPsbtHex,
                                            btcPrice:
                                                createPsbtSuccess.btcQuantity,
                                            sellDetails: variant)),
                                  ),
                                );
                              }),
                              CreatePsbtSignHandler(
                                  address: variant.utxoAddress,
                                  onSuccess: actions.onSignatureCompleted,
                                  onClose: () {
                                    actions.onCloseSignPsbtModalClicked();
                                  }),
                              CreatePsbtForm(
                                actions: actions,
                                state: state,
                                asset: variant.asset,
                                quantity: variant.quantity,
                                quantityNormalized: variant.quantityNormalized,
                                utxo: variant.utxo,
                                utxoAddress: variant.utxoAddress,
                              ),
                            ],
                          ),
                        ))),
              }),
          model.swapSellConfirmationDetails.map((details) => MaterialPage(
                child: FlowStep(
                    title: "Post Listing",
                    widthFactor: .9,
                    body: SwapCreateListingFormProvider(
                        address: widget.addresses.firstWhere((address) =>
                            address.address == details.sellDetails.utxoAddress),
                        giveAsset: details.sellDetails.asset,
                        giveQuantity: details.sellDetails.quantity,
                        giveQuantityNormalized:
                            details.sellDetails.quantityNormalized,
                        btcPrice: details.btcPrice,
                        child: (actions, state) => Column(
                              children: [
                                SwapOnChainFeeSignHandler(
                                    address: details.sellDetails.utxoAddress,
                                    onSuccess: actions.onSignatureCompleted,
                                    onClose: () {
                                      actions.onCloseSignPsbtModalClicked();
                                    }),
                                SwapCreateListingConfirmationForm(
                                    actions: actions, state: state),
                              ],
                            ))),
              ))
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }
}
