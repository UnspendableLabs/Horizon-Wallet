import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/presentation/common/transactions/success_animation.dart';
import 'package:horizon/presentation/common/transactions/transaction_error.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/extensions.dart';

import 'package:horizon/presentation/forms/asset_attach_form/asset_attach_form_view.dart';
import 'package:horizon/presentation/forms/create_psbt_form/create_psbt_form_view.dart';
import 'package:horizon/presentation/forms/swap_create_listing_confirmation_form/swap_create_listing_confirmation_form_view.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

sealed class AtomicSwapSellVariant {}

class AttachedAtomicSwapSell extends AtomicSwapSellVariant {
  final String asset;
  final String quantityNormalized;
  final int quantity;
  final UtxoID utxoId;
  final String utxoAddress;
  final bool divisible;

  AttachedAtomicSwapSell({
    required this.asset,
    required this.quantityNormalized,
    required this.quantity,
    required this.utxoId,
    required this.utxoAddress,
    required this.divisible,
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
          utxoId: UtxoID.fromString(entry.utxo!),
          divisible: multiAddressBalance.assetInfo.divisible,
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
  final DateTime? expiresAt;

  const SwapSellConfirmationDetails({
    required this.btcPrice,
    required this.signedPsbt,
    required this.sellDetails,
    required this.expiresAt,
  });
}

class OnChainPaymentDetails {
  final String id;
  final String signedPsbtHex;

  const OnChainPaymentDetails({
    required this.id,
    required this.signedPsbtHex,
  });
}

class AtomicSwapSellModel extends Equatable {
  final Option<AtomicSwapSellVariant> atomicSwapSellVariant;
  final Option<SwapSellConfirmationDetails> swapSellConfirmationDetails;
  final Option<OnChainPaymentDetails> onChainPaymentDetails;

  const AtomicSwapSellModel(
      {required this.atomicSwapSellVariant,
      required this.swapSellConfirmationDetails,
      required this.onChainPaymentDetails});

  @override
  List<Object?> get props => [];

  AtomicSwapSellModel copyWith(
          {Option<AtomicSwapSellVariant>? atomicSwapSellVariant,
          Option<SwapSellConfirmationDetails>? swapSellConfirmationDetails,
          Option<OnChainPaymentDetails>? onChainPaymentDetails}) =>
      AtomicSwapSellModel(
        atomicSwapSellVariant:
            atomicSwapSellVariant ?? this.atomicSwapSellVariant,
        swapSellConfirmationDetails:
            swapSellConfirmationDetails ?? this.swapSellConfirmationDetails,
        onChainPaymentDetails:
            onChainPaymentDetails ?? this.onChainPaymentDetails,
      );
}

class AtomicSwapSellFlowController extends FlowController<AtomicSwapSellModel> {
  AtomicSwapSellFlowController({required AtomicSwapSellModel initialState})
      : super(initialState);
}

class AtomicSwapSellFlowView extends StatefulWidget {
  final HttpConfig httpConfig;
  final Config _config;

  final AtomicSwapRepository _atomicSwapRepository;
  final UtxoRepository _utxoRepository;

  final List<AddressV2> addresses;
  final MultiAddressBalance balances;

  AtomicSwapSellFlowView(
      {required this.httpConfig,
      required this.addresses,
      required this.balances,
      Config? config,
      AtomicSwapRepository? atomicSwapRepository,
      UtxoRepository? utxoRepository,
      super.key})
      : _config = config ?? GetIt.I<Config>(),
        _utxoRepository = utxoRepository ?? GetIt.I<UtxoRepository>(),
        _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>();

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
            swapSellConfirmationDetails: Option.none(),
            onChainPaymentDetails: Option.none()));
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<AtomicSwapSellModel>(
      controller: _controller,
      onGeneratePages: (model, pages) {
        return [
          Option.of(MaterialPage(
              child: FlowStep(
            trailing: IconButton(
              onPressed: () {
                context.go("/");
              },
              icon: AppIcons.closeIcon(
                context: context,
                width: 24,
                height: 24,
                fit: BoxFit.fitHeight,
              ),
            ),
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
              disallowSelections: const [DisallowSelection.listingExists],
              httpConfig: widget.httpConfig,
              addresses:
                  widget.addresses.map((address) => address.address).toList(),
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
                    trailing: IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: AppIcons.closeIcon(
                          context: context,
                          width: 24,
                          height: 24,
                          fit: BoxFit.fitHeight,
                        )),
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
                        trailing: IconButton(
                            onPressed: () {
                              context.pop();
                            },
                            icon: AppIcons.closeIcon(
                              context: context,
                              width: 24,
                              height: 24,
                              fit: BoxFit.fitHeight,
                            )),
                        title: "Create PSBT",
                        widthFactor: .8,
                        body: CreatePsbtFormProvider(
                          utxoID: variant.utxoId.toString(),
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
                                            expiresAt:
                                                createPsbtSuccess.expiryDate,
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
                                utxo: variant.utxoId.toString(),
                                utxoAddress: variant.utxoAddress,
                              ),
                            ],
                          ),
                        ))),
              }),
          model.swapSellConfirmationDetails.map((details) => MaterialPage(
                child: FlowStep(
                    leading: IconButton(
                        onPressed: () {
                          _controller.update(
                            (model) => model.copyWith(
                              swapSellConfirmationDetails: const Option.none(),
                            ),
                          );
                        },
                        icon: AppIcons.backArrowIcon(
                          context: context,
                          width: 24,
                          height: 24,
                          fit: BoxFit.fitHeight,
                        )),
                    trailing: IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: AppIcons.closeIcon(
                          context: context,
                          width: 24,
                          height: 24,
                          fit: BoxFit.fitHeight,
                        )),
                    title: "Post Listing",
                    widthFactor: .9,
                    body: SwapCreateListingFormProvider(
                        signedSwapPsbtHex: details.signedPsbt,
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
                                    onSuccess: (data) => {
                                          _controller.update(
                                            (model) => model.copyWith(
                                                onChainPaymentDetails: Option
                                                    .of(OnChainPaymentDetails(
                                                        signedPsbtHex:
                                                            data.signedPsbtHex,
                                                        id: data
                                                            .onChainPaymentId))),
                                          )
                                        },
                                    onClose: () {
                                      actions.onCloseSignPsbtModalClicked();
                                    }),
                                SwapCreateListingConfirmationForm(
                                    actions: actions, state: state),
                              ],
                            ))),
              )),
          model.onChainPaymentDetails.map(
            (a) => MaterialPage(
                child: RemoteDataTaskEitherBuilder(
                    task: TaskEither<String, String>.Do(($) async {
              final swapSellDetails =
                  model.swapSellConfirmationDetails.getOrThrow();

              final signedSwapPsbt = swapSellDetails.signedPsbt;

              final sellerAddress = widget.addresses.firstWhere((address) =>
                  address.address == swapSellDetails.sellDetails.utxoAddress);

              final assetUtxoId = swapSellDetails.sellDetails.utxoId;

              final utxoMap =
                  await $(widget._utxoRepository.getUTXOMapForAddressT(
                httpConfig: widget.httpConfig,
                address: sellerAddress,
              ));

              final utxo = utxoMap[assetUtxoId.toString()];

              // if for some reason a recent attach isn't in the mempool,
              // we can fallback to `defaultEnvelopeSize`
              int utxoValue = utxo?.value ?? widget._config.defaultEnvelopeSize;

              final btcPrice = swapSellDetails.btcPrice;

              final assetQuantity = swapSellDetails.sellDetails.quantity;

              final atomicSwap =
                  await $(widget._atomicSwapRepository.atomicSwapCreateT(
                assetDivisible: swapSellDetails.sellDetails.divisible,
                httpConfig: widget.httpConfig,
                psbtHex: signedSwapPsbt,
                sellerAddress: sellerAddress.address,
                assetUtxoId: assetUtxoId.toString(),
                feePaymentPsbtHex: a.signedPsbtHex,
                feePaymentId: a.id,
                price: btcPrice.toInt(), // TODO
                assetQuantity: assetQuantity,
                assetUtxoValue: utxoValue,
                assetName: swapSellDetails.sellDetails.asset,
                expiresAt: swapSellDetails.expiresAt,
              ));

              return atomicSwap.id;

              // return hash;
            }), builder: (context, state, retry) {
              bool disabled = switch (state) {
                Initial() => false,
                Loading() => true,
                Failure() => false,
                Success() => true,
                Refreshing() => true,
              };

              return Scaffold(
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(72),
                    child: Container(
                      height: 46,
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          left: 12, top: 0, bottom: 0, right: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          disabled
                              ? const SizedBox.shrink()
                              : IconButton(
                                  onPressed: () {
                                    _controller.update(
                                      // i need to disable this button if submission
                                      // is success, but the state is lower
                                      // in the tree
                                      (model) => model.copyWith(
                                        onChainPaymentDetails:
                                            const Option.none(),
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
                          IconButton(
                            onPressed: () {
                              context.go("/");
                            },
                            icon: AppIcons.closeIcon(
                              context: context,
                              width: 24,
                              height: 24,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ],
                      ),
                    )),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: state.fold3(
                            onNone: () => Center(
                                child: Lottie.asset(
                              "assets/lottie/txn_success_anim.json",
                              width: 127,
                              key: const ValueKey('lottie'),
                            )),
                            onReplete: (_) =>
                                const Center(child: TxnSuccessAnimation()),
                            onFailure: (err) => TransactionError(
                              errorMessage: err.toString(),
                              onErrorButtonAction: retry,
                              buttonText: "Retry",
                            ),
                          )),
                      commonHeightSizedBox,
                      state.fold3(
                        onNone: () => Text(
                          "Creating swap...",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        onFailure: (_) => const SizedBox.shrink(),
                        onReplete: (hash) => Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Successfully created swap",
                                style:
                                    Theme.of(context).textTheme.titleMedium!),
                          ],
                        ),
                      ),
                      commonHeightSizedBox,
                      commonHeightSizedBox,
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(context)
                                    .inputDecorationTheme
                                    .outlineBorder
                                    ?.color ??
                                transparentBlack8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Swap id: ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.color,
                                            ),
                                      ),
                                      TextSpan(
                                        text: state.fold3(
                                            onNone: () => '',
                                            onFailure: (_) => '',
                                            onReplete: (hash) =>
                                                hash.replaceRange(
                                                    6, hash.length - 6, '...')),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                            ),
                                      ),
                                    ],
                                  ),
                                  overflow: TextOverflow.visible,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: TextButton(
                                style: Theme.of(context)
                                    .textButtonTheme
                                    .style
                                    ?.copyWith(
                                      backgroundColor: WidgetStateProperty.all(
                                        transparentPurple8,
                                      ),
                                      padding: WidgetStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 12),
                                      ),
                                    ),
                                onPressed: state.fold3(
                                    onNone: () => () {},
                                    onFailure: (_) => () {},
                                    onReplete: (hash) => () {
                                          Clipboard.setData(
                                              ClipboardData(text: hash));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'swap id copied to clipboard'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppIcons.copyIcon(
                                      context: context,
                                      width: 16,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'COPY',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      HorizonButton(
                        onPressed: state.fold3(
                            onNone: () => () {},
                            onFailure: (_) => () {},
                            onReplete: (hash) => () {
                                  _launchExplorer(hash, widget.httpConfig);
                                }),
                        disabled: state.fold3(
                          onNone: () => true,
                          onFailure: (_) => true,
                          onReplete: (_) => false,
                        ),
                        child: TextButtonContent(value: "View Swap"),
                        variant: ButtonVariant.black,
                      ),
                      commonHeightSizedBox,
                      HorizonButton(
                        onPressed: state.fold3(
                            onNone: () => () {},
                            onFailure: (_) => () {},
                            onReplete: (hash) => () {
                                  context.go("/");
                                }),
                        child: TextButtonContent(value: "Close"),
                        disabled: state.fold3(
                          onNone: () => true,
                          onFailure: (_) => true,
                          onReplete: (_) => false,
                        ),
                        variant: ButtonVariant.black,
                      ),
                    ],
                  ),
                ),
              );
            })),
          )
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }

  Future<void> _launchExplorer(
    String swapID,
    HttpConfig httpConfig,
  ) async {
    final uri = Uri.parse("${httpConfig.horizonMarket}/atomic-swaps/$swapID");
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
}
