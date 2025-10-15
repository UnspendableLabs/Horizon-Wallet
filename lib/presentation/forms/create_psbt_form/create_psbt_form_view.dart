import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/psbt_type.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/royalty_by_asset.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/view/sign_psbt_form.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/common/expiry_selector.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/sats_to_usd_display.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/common/format.dart';
import './bloc/create_psbt_form_bloc.dart';

// just putting this here for now
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isDarkMode = true;
  final bool disabled;
  final String? tooltip;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.disabled = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDarkMode
        ? const Color.fromARGB(19, 151, 112, 39)
        : transparentPurple33;
    final Color textColor = isDarkMode ? yellow1 : duskGradient2;

    Widget button = MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: disabled ? null : onPressed,
        child: Opacity(
          opacity: disabled ? 0.5 : 1.0,
          child: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                ),
                if (tooltip != null && tooltip!.isNotEmpty) ...[
                  SizedBox(width: 4),
                  Tooltip(
                    message: tooltip!,
                    child: Icon(
                      Icons.help,
                      size: 14,
                      color: textColor,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );

    return button;
  }
}

class CreatePsbtFormActions {
  final Function(String value) onBtcValueChanged;
  final Function(DateTime? date) onExpiryDateSelected;
  final VoidCallback onSubmitClicked;
  final VoidCallback onCloseSignPsbtModalClicked;
  final Function(String signedPsbtHex) onSignatureCompleted;
  final Function(RelativePriceValue value) onRelativePriceChanged;

  const CreatePsbtFormActions(
      {required this.onBtcValueChanged,
      required this.onSubmitClicked,
      required this.onCloseSignPsbtModalClicked,
      required this.onSignatureCompleted,
      required this.onExpiryDateSelected,
      required this.onRelativePriceChanged});
}

class CreatePsbtFormProvider extends StatelessWidget {
  final String asset;
  final fp.Option<RoyaltyByAsset> assetRoyalty;
  final AddressV2 address;
  final UtxoID utxoID;
  final BitcoinTx utxoTransaction;
  final AssetQuantity utxoQuantity;

  final Widget Function(
      CreatePsbtFormActions actions, CreatePsbtFormModel state) child;

  CreatePsbtFormProvider({
    super.key,
    required this.asset,
    required this.assetRoyalty,
    required this.utxoID,
    required this.address,
    required this.child,
    required this.utxoTransaction,
    required this.utxoQuantity,
    AtomicSwapRepository? atomicSwapRepository,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return BlocProvider(
        create: (context) => CreatePsbtFormBloc(
              asset: asset,
              utxoQuantity: utxoQuantity,
              utxoTransaction: utxoTransaction,
              assetRoyalty: assetRoyalty,
              address: address,
              httpConfig: session.httpConfig,
              utxoID: utxoID,
            ),
        child: BlocBuilder<CreatePsbtFormBloc, CreatePsbtFormModel>(
            builder: (context, state) => child(
                CreatePsbtFormActions(
                    onRelativePriceChanged: (relativePriceValue) {
                  context.read<CreatePsbtFormBloc>().add(
                      RelativePriceButtonClicked(value: relativePriceValue));
                }, onBtcValueChanged: (value) {
                  context
                      .read<CreatePsbtFormBloc>()
                      .add(BtcPriceInputChanged(value: value));
                }, onExpiryDateSelected: (date) {
                  context
                      .read<CreatePsbtFormBloc>()
                      .add(ExpiryDateSelected(date: date));
                }, onSubmitClicked: () {
                  context.read<CreatePsbtFormBloc>().add(SubmitClicked());
                }, onSignatureCompleted: (String signedPsbtHex) {
                  context
                      .read<CreatePsbtFormBloc>()
                      .add(SignatureCompleted(signedPsbtHex: signedPsbtHex));
                }, onCloseSignPsbtModalClicked: () {
                  context
                      .read<CreatePsbtFormBloc>()
                      .add(const CloseSignPsbtModalClicked());
                }),
                state)));
  }
}

class CreatePsbtSuccess {
  final String signedPsbtHex;
  final BigInt btcTotal;
  final BigInt royaltyTotal;
  final DateTime? expiryDate;

  const CreatePsbtSuccess({
    required this.signedPsbtHex,
    required this.btcTotal,
    required this.expiryDate,
    required this.royaltyTotal,
  });
}

class CreatePsbtSuccessHandler extends StatelessWidget {
  final Function(CreatePsbtSuccess createPsbtSuccess) onSuccess;

  const CreatePsbtSuccessHandler({super.key, required this.onSuccess});

  @override
  Widget build(context) {
    return BlocListener<CreatePsbtFormBloc, CreatePsbtFormModel>(
        listener: (context, state) {
          if (state.submissionStatus.isSuccess) {
            onSuccess(CreatePsbtSuccess(
                royaltyTotal: state.royaltyAmount,
                expiryDate: state.expiryDate,
                signedPsbtHex: state.signedPsbt!,
                btcTotal: state.btcPriceInput.asSats
                    .getOrThrow() // will never be called if this is undefiend

                ));
          }
        },
        child: const SizedBox.shrink());
  }
}

class CreatePsbtSignHandler extends StatelessWidget {
  final Function(String signedPsbtHex) onSuccess;
  final VoidCallback onClose;
  final String address;

  const CreatePsbtSignHandler(
      {super.key,
      required this.onSuccess,
      required this.onClose,
      required this.address});

  @override
  Widget build(context) {
    final session = context.read<SessionStateCubit>().state.successOrThrow();

    return BlocListener<CreatePsbtFormBloc, CreatePsbtFormModel>(
        listener: (context, state) async {
          final settings = GetIt.I<SettingsRepository>();

          if (state.showSignPsbtModal) {
            final result = await WoltModalSheet.show(
                context: context,
                modalTypeBuilder: (_) => WoltModalType.bottomSheet(),
                pageListBuilder: (bottomSheetContext) => [
                      WoltModalSheetPage(
                          isTopBarLayerAlwaysVisible: true,
                          hasTopBarLayer: true,
                          topBarTitle: Text("Review Transaction",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: Colors.white)),
                          trailingNavBarWidget: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: AppIcons.closeIcon(
                              context: context,
                              width: 24,
                              height: 24,
                            ),
                          ),
                          // pageTitle: Text("Sign PSBT",
                          //     style: Theme.of(context).textTheme.headlineSmall),
                          child: state.unsignedPsbtHex.fold(
                            () => const SizedBox.shrink(),
                            (unsignedPsbtHex) => BlocProvider(
                                create: (context) => SignPsbtBloc(
                                        psbtType: AtomicSwapSellPsbt(),
                                        httpConfig: session.httpConfig,
                                        addresses: session.addressIndexSet.list,
                                        passwordRequired: settings
                                            .requirePasswordForCryptoOperations,
                                        unsignedPsbt: unsignedPsbtHex,
                                        signInputs: {
                                          address: [1]
                                        },
                                        sighashTypes: [
                                          // single | anyone_can_pay | none
                                          0x03 | 0x80 | 0x02,
                                        ]),
                                child: SignPsbtForm(
                                  psbtType: AtomicSwapSellPsbt(),
                                  key: Key(unsignedPsbtHex),
                                  passwordRequired: settings
                                      .requirePasswordForCryptoOperations,
                                  onSuccess: (signedPsbtHex) {
                                    onSuccess(signedPsbtHex);

                                    Navigator.of(context).pop();
                                  },
                                )),
                          ))
                    ]);

            onClose();

            // show wolt modal but only if it's not already displayed
          }
        },
        child: const SizedBox.shrink());
  }
}

class CreatePsbtForm extends StatefulWidget {
  final CreatePsbtFormModel state;
  final CreatePsbtFormActions actions;

  final String asset;
  final String quantityNormalized;
  final int quantity;
  final String utxo;
  final String utxoAddress;

  const CreatePsbtForm(
      {required this.state,
      required this.actions,
      required this.asset,
      required this.quantityNormalized,
      required this.quantity,
      required this.utxo,
      required this.utxoAddress,
      super.key});

  @override
  State<CreatePsbtForm> createState() => _CreatePsbtFormState();
}

class _CreatePsbtFormState extends State<CreatePsbtForm> {
  late final TextEditingController _btcController;

  final appIcons = AppIcons();

  @override
  void initState() {
    super.initState();
    // Seed it with whatever value the bloc already holds (or '' if none).
    _btcController =
        TextEditingController(text: widget.state.btcPriceInput.value);
  }

  @override
  void dispose() {
    _btcController.dispose(); // ALWAYS dispose controllers
    super.dispose();
  }

  HorizonCard _buildFromCard(BuildContext context, HttpConfig httpConfig) {
    final theme = Theme.of(context);
    return HorizonCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: QuantityText(
                  quantity: widget.quantityNormalized,
                  style: const TextStyle(fontSize: 35),
                ),
              )),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  appIcons.assetIcon(
                      httpConfig: httpConfig,
                      assetName: widget.asset,
                      context: context,
                      width: 24,
                      height: 24),
                  const SizedBox(width: 8),
                  Text((truncateAssetName(widget.asset)),
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontSize: 12,
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  HorizonCard _buildToCard(BuildContext context, HttpConfig httpConfig) {
    final theme = Theme.of(context);
    return HorizonCard(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                label: "Floor",
                tooltip: widget.state.relativePriceButtonTooltip,
                disabled: widget.state.relativePriceButtonsDisabled,
                onPressed: () {
                  widget.actions.onRelativePriceChanged(
                    RelativePriceValue.floor,
                  );
                },
              ),
              const SizedBox(width: 4),
              CustomButton(
                disabled: widget.state.relativePriceButtonsDisabled,
                label: "+5%",
                onPressed: () {
                  widget.actions.onRelativePriceChanged(
                    RelativePriceValue.plus5,
                  );
                },
              ),
              const SizedBox(width: 4),
              CustomButton(
                disabled: widget.state.relativePriceButtonsDisabled,
                label: "+10%",
                onPressed: () {
                  widget.actions.onRelativePriceChanged(
                    RelativePriceValue.plus10,
                  );
                },
              ),
              const SizedBox(width: 4),
              CustomButton(
                label: "+15%",
                disabled: widget.state.relativePriceButtonsDisabled,
                onPressed: () {
                  widget.actions.onRelativePriceChanged(
                    RelativePriceValue.plus15,
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: QuantityInputV2(
                      placeholder: "0.00",
                      style: const TextStyle(fontSize: 35),
                      divisible: true,
                      value: widget.state.btcPriceInput.value,
                      // controller:
                      //     _btcController, // chat helpo me with a stateful controller hre,
                      onChanged: (value) {
                        widget.actions.onBtcValueChanged(value);
                      })),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  appIcons.assetIcon(
                      httpConfig: httpConfig,
                      assetName: "BTC",
                      context: context,
                      width: 24,
                      height: 24),
                  const SizedBox(width: 8),
                  Text("BTC",
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontSize: 12,
                      )),
                ],
              ),
            ],
          ),

          // const SizedBox(
          //   height: 20,
          // ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!widget.state.btcPriceInput.isPure)
              switch (widget.state.btcPriceInput.error) {
                null => SatsToUsdDisplay(
                    sats: widget.state.btcPriceInput.asSats
                        .getOrElse(() => BigInt.zero),
                    child: (usdValue) => Text(
                          '${usdValue.toStringAsFixed(2)} USD',
                          style:
                              theme.textTheme.labelSmall?.copyWith(height: 1.2),
                        )),
                BtcPriceInputError.isLessThanDust => Text(
                    "price < dust ($dust sats)",
                    style: theme.textTheme.labelSmall?.copyWith(height: 1.2)),
                BtcPriceInputError.isTooSmallBecauseOfRoyalty => Text(
                    "Min price with royalty = ${widget.state.minPrice} sats",
                    style: theme.textTheme.labelSmall?.copyWith(height: 1.2)),
                _ => const Text("")
              },
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            commonHeightSizedBox,
            Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                        height: 132,
                        child: _buildFromCard(context, session.httpConfig)),
                    commonHeightSizedBox,
                    SizedBox(
                        height: 132,
                        child: _buildToCard(context, session.httpConfig)),
                  ],
                ),
                Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Material(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          hoverColor: transparentPurple8,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: transparentWhite8, width: 1),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: AppIcons.arrowDownIcon(
                                context: context, width: 24, height: 24),
                          ),
                        ),
                      ),
                    ))
              ],
            ),
            commonHeightSizedBox,
            ExpirySelector(onChange: (date) {
              widget.actions.onExpiryDateSelected(date);
            }),
            commonHeightSizedBox,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: HorizonButton(
                  disabled: widget.state.submitDisabled,
                  isLoading: widget.state.submissionStatus.isInProgress,
                  onPressed: () {
                    if (!widget.state.submitDisabled) {
                      widget.actions.onSubmitClicked();
                    }
                  },
                  child: TextButtonContent(value: "Create listing")),
            ),
          ],
        ),
      ),
    );
  }
}
