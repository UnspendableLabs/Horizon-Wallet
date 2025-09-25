import 'package:flutter/material.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/format.dart';

import 'package:rational/rational.dart';
import 'package:decimal/decimal.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/presentation/common/expiry_selector.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart' hide Order, State;
import 'package:horizon/domain/repositories/order_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/order.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './bloc/swap_order_form_bloc.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isDarkMode = true;
  final bool disabled;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDarkMode
        ? const Color.fromARGB(19, 151, 112, 39)
        : transparentPurple33;
    final Color textColor = isDarkMode ? yellow1 : duskGradient2;

    return MouseRegion(
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
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final String? error;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.theme,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final muted =
        theme.extension<CustomThemeExtension>()!.mutedDescriptionTextColor;
    final isError = error != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: isError ? Colors.red : muted,
                ),
              ),
              SelectableText(
                value,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: isError ? Colors.red : null,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (isError && error!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                error!,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final String quantity;
  final String price;
  final Color color;

  const _OrderRow({
    required this.quantity,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(price,
              style: theme.textTheme.bodySmall!.copyWith(
                color: color,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              )),
          Text(quantity, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class SubmitParams {
  final AssetQuantity giveQuantity;
  final AssetQuantity getQuantity;
  final SimulatedOrders simulatedOrders;

  SubmitParams({
    required this.giveQuantity,
    required this.getQuantity,
    required this.simulatedOrders,
  });
}

class SwapOrderFormActions {
  final VoidCallback onClickAmountAsset;
  final VoidCallback onClickPriceAsset;
  final Function(SubmitParams params) onSubmitClicked;
  final Function(String value) onAmountChanged;
  final Function(String value) onPriceChanged;
  final Function(RelativePriceValue value) onRelativePriceButtonClicked;
  final Function(DateTime? date) onExpiryChanged;
  final VoidCallback onClickMax;
  // final Function(ContinueParams params)? onContinueClicked;

  SwapOrderFormActions({
    required this.onSubmitClicked,
    required this.onClickAmountAsset,
    required this.onClickPriceAsset,
    required this.onAmountChanged,
    required this.onPriceChanged,
    required this.onRelativePriceButtonClicked,
    required this.onExpiryChanged,
    required this.onClickMax,
  });
}

class SwapOrderFormProvider extends StatefulWidget {
  final OrderRepository _orderRepository;
  final AssetRepository _assetRepository;

  final String giveAsset;
  final Function(SubmitParams params) onSubmitClicked;

  final String getAsset;
  final AddressV2 address;
  final HttpConfig httpConfig;

  final Widget Function(
    SwapOrderFormActions actions,
    SwapOrderFormModel state,
  ) child;

  final MultiAddressBalanceEntry multiAddressBalanceEntry;

  SwapOrderFormProvider(
      {super.key,
      AssetRepository? assetRepository,
      OrderRepository? orderRepository,
      required this.onSubmitClicked,
      required this.multiAddressBalanceEntry,
      required this.child,
      required this.httpConfig,
      required this.address,
      required this.giveAsset,
      required this.getAsset})
      : _orderRepository = orderRepository ?? GetIt.I<OrderRepository>(),
        _assetRepository = assetRepository ?? GetIt.I<AssetRepository>();

  @override
  State<SwapOrderFormProvider> createState() => _SwapOrderFormProviderState();
}

class _SwapOrderFormProviderState extends State<SwapOrderFormProvider> {
  @override
  Widget build(BuildContext context) {
    final task = TaskEither.sequenceList([
      widget._assetRepository.getAssetVerboseT(
        assetName: widget.giveAsset,
        httpConfig: widget.httpConfig,
      ),
      widget._assetRepository.getAssetVerboseT(
        assetName: widget.getAsset,
        httpConfig: widget.httpConfig,
      ),
      widget._orderRepository.getByPairTE(
        status: "open",
        giveAsset: widget.getAsset,
        getAsset: widget.giveAsset,
        httpConfig: widget.httpConfig,
      ),
      widget._orderRepository.getByPairTE(
        giveAsset: widget.giveAsset,
        getAsset: widget.getAsset,
        status: "open",
        httpConfig: widget.httpConfig,
      ),
    ]);

    return RemoteDataTaskEitherBuilder(
        task: task,
        builder: (context, state, refresh) => state.fold3(
            onNone: () => const Center(child: CircularProgressIndicator()),
            onFailure: (error) =>
                Center(child: Text("unspecified error: $error")),
            onReplete: (data) => BlocProvider(
                  create: (_) => SwapOrderFormBloc(
                    giveAssetBalance: widget.multiAddressBalanceEntry,
                    address: widget.address,
                    httpConfig: widget.httpConfig,
                    giveAsset: data[0] as Asset,
                    getAsset: data[1] as Asset,
                    buyOrders: data[2] as List<Order>,
                    sellOrders: data[3] as List<Order>,
                  ),
                  child: BlocBuilder<SwapOrderFormBloc, SwapOrderFormModel>(
                    builder: (context, state) {
                      return widget.child(
                        SwapOrderFormActions(
                            onClickMax: () {
                              context
                                  .read<SwapOrderFormBloc>()
                                  .add(MaxButtonClicked());
                            },
                            onExpiryChanged: (value) {
                              context
                                  .read<SwapOrderFormBloc>()
                                  .add(ExpiryChanged(value: value));
                            },
                            onRelativePriceButtonClicked: (value) => context
                                .read<SwapOrderFormBloc>()
                                .add(RelativePriceButtonClicked(value: value)),
                            onSubmitClicked: (submitParams) =>
                                widget.onSubmitClicked(submitParams),
                            onAmountChanged: (value) {
                              context
                                  .read<SwapOrderFormBloc>()
                                  .add(AmountInputChanged(value: value));
                            },
                            onPriceChanged: (value) {
                              context
                                  .read<SwapOrderFormBloc>()
                                  .add(PriceInputChanged(value: value));
                            },
                            onClickPriceAsset: () {
                              context
                                  .read<SwapOrderFormBloc>()
                                  .add(PriceTypeClicked());
                            },
                            onClickAmountAsset: () {
                              context
                                  .read<SwapOrderFormBloc>()
                                  .add(AmountTypeClicked());
                            }),
                        state,
                      );
                    },
                  ),
                )));
  }
}

class SwapOrderForm extends StatelessWidget {
  final SwapOrderFormActions actions;
  final SwapOrderFormModel state;

  const SwapOrderForm({
    super.key,
    required this.actions,
    required this.state,
  });

  _gradQtyProperty(label, value, theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              textAlign: TextAlign.left,
              style: theme.inputDecorationTheme.hintStyle),
          QuantityText(
            quantity: value,
            style: const TextStyle(fontSize: 35),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Replace with actual form layout
        Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    await WoltModalSheet.show(
                        context: context,
                        modalTypeBuilder: (_) => WoltModalType.bottomSheet(),
                        pageListBuilder: (bottomSheetContext) => [
                              WoltModalSheetPage(
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
                                hasTopBarLayer: false,
                                child: OrderBookView(
                                  priceType: state.priceType,
                                  priceString: state.priceString,
                                  giveAsset: state.giveAsset,
                                  getAsset: state.getAsset,
                                  asks: state.buyOrdersView,
                                  bids: state.sellOrdersView,
                                ),
                              )
                            ]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                    child: Text("View Order Book",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme
                              .extension<CustomThemeExtension>()!
                              .inputTextColor,
                        )),
                  ),
                ),
              ],
            ),

            commonHeightSizedBox,
            OrderInputs(
              actions: actions,
              state: state,
              priceString: state.priceString,
              onClickAmountAsset: actions.onClickAmountAsset,
              onClickPriceAsset: actions.onClickPriceAsset,
              priceAsset: state.priceAsset,
              amountAsset: state.amountAsset,
              giveAsset: state.giveAsset,
              getAsset: state.getAsset,
              buyOrders: state.buyOrdersView,
              sellOrders: state.sellOrdersView,
            ),

            commonHeightSizedBox,
            commonHeightSizedBox,
            ExpirySelector(onChange: (date) {
              actions.onExpiryChanged(date);
            }),
            commonHeightSizedBox,
            commonHeightSizedBox,
            Column(
              children: [
                state.simulatedOrders.fold(
                    onInitial: () => const SizedBox.shrink(),
                    onLoading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                    onFailure: (error) => Text(error.toString()),
                    onRefreshing: (_) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                    onSuccess: (simulatedOrders) => Column(children: [
                          _SummaryRow(
                            label: "Receive",
                            value: simulatedOrders.summary.getNow.normalized(),
                            theme: theme,
                          ),
                          _SummaryRow(
                            label: "Spend",
                            value:
                                simulatedOrders.summary.totalGive.normalized(),
                            theme: theme,
                            error: switch (state.giveQuantityInput.error) {
                              GiveQuantityInputError.insufficientBalance => "",
                              _ => null,
                            },
                          ),
                          _SummaryRow(
                            label: "Escrowed",
                            value:
                                simulatedOrders.summary.giveEscrow.normalized(),
                            theme: theme,
                          ),
                          // _SummaryRow(
                          //   label: "Deferred",
                          //   value:
                          //       simulatedOrders.summary.getLater.normalized(),
                          //   theme: theme,
                          // ),
                          // CHAT: Help me polish this order UI
                        ]))
              ],
            ),

            commonHeightSizedBox,

            // Add more form fields as needed
          ],
        ),

        // Text("amount input:       ${state.amountInput.value}"),
        // Text("amount input error: ${state.amountInput.error}"),
        //
        // Text("price input:       ${state.priceInput.value}"),
        // Text("price input error: ${state.priceInput.error}"),
        //
        // Text(
        //     "price input as rational:       ${state.priceInputAsRational.value}"),
        // Text(
        //     "price input as rational error: ${state.priceInputAsRational.error}"),
        //
        // Text("price input:       ${state.priceInput.value}"),
        // Text("price input error: ${state.priceInput.error}"),
        //
        // Text("getQuantity input:       ${state.getQuantityInput.value}"),
        // Text("getQuantity input error: ${state.getQuantityInput.error}"),
        //
        // Text(
        //     "getQuantity input rational:       ${state.getQuantityInputRational.value}"),
        // Text(
        //     "getQuantity input rational error: ${state.getQuantityInputRational.error}"),
        //
        // Text("giveQuantity input:       ${state.giveQuantityInput.value}"),
        // Text("giveQuantity input error: ${state.giveQuantityInput.error}"),

        // Table(
        //   columnWidths: const {
        //     0: IntrinsicColumnWidth(), // size to fit the label
        //     1: FlexColumnWidth(), // expand the value
        //   },
        //   children: [
        //     TableRow(children: [
        //       const Text("amount input"),
        //       Text(state.amountInput.value),
        //     ]),
        //     TableRow(children: [
        //       const Text("amount input error"),
        //       Text("${state.amountInput.error}"),
        //     ]),
        //     TableRow(children: [
        //       const Text("price input"),
        //       Text(state.priceInput.value),
        //     ]),
        //     TableRow(children: [
        //       const Text("price input error"),
        //       Text("${state.priceInput.error}"),
        //     ]),
        //     TableRow(children: [
        //       const Text("price input as rational"),
        //       Text("${state.priceInputAsRational.value}"),
        //     ]),
        //     TableRow(children: [
        //       const Text("price input as rational error"),
        //       Text("${state.priceInputAsRational.error}"),
        //     ]),
        //     TableRow(children: [
        //       const Text("getQuantity input"),
        //       Text(state.getQuantityInput.value.toString()),
        //     ]),
        //     TableRow(children: [
        //       const Text("getQuantity input error"),
        //       Text("${state.getQuantityInput.error}"),
        //     ]),
        //     TableRow(children: [
        //       const Text("getQuantity input rational"),
        //       Text("${state.getQuantityInputRational.value}"),
        //     ]),
        //     TableRow(children: [
        //       const Text("getQuantity input rational error"),
        //       Text("${state.getQuantityInputRational.error}"),
        //     ]),
        //     TableRow(children: [
        //       const Text("giveQuantity input"),
        //       Text(state.giveQuantityInput.value.toString()),
        //     ]),
        //     TableRow(children: [
        //       const Text("giveQuantity input error"),
        //       Text("${state.giveQuantityInput.error}"),
        //     ]),
        //   ],
        // ),
        //
        // // Text("give"),
        // // Text(state.giveQuantityInput.value.quantity.toString()),
        // // Text("give"),
        // // Text(state.giveQuantityInput.value.quantity.toString()),
        // // Text("get"),
        // // Text(state.getQuantityInput.value.quantity.toString()),
        // // Text("get raitonaj"),
        // // Text(state.getQuantityInputRational.value.toDouble().toString()),
        //
        HorizonButton(
            disabled: state.isNotValid ||
                state.simulatedOrders.maybeWhen(
                  onSuccess: (_) => false,
                  orElse: () => true,
                ),
            onPressed: () {
              final cb = state.simulatedOrders.maybeWhen(
                onSuccess: (simulatedOrders) {
                  return () => actions.onSubmitClicked(SubmitParams(
                        giveQuantity: state.giveQuantityInput.value,
                        getQuantity: AssetQuantity.fromNormalizedString(
                            divisible: state.getAsset.divisible,
                            input: state.getQuantityInputRational.value
                                .toDouble()
                                .toString()),
                        simulatedOrders: simulatedOrders,
                      ));
                },
                orElse: () => null,
              );

              cb != null && cb();
            },
            child: TextButtonContent(value: "Continue")),
      ],
    );
  }
}

class OrderInputs extends StatefulWidget {
  final VoidCallback onClickAmountAsset;
  final VoidCallback onClickPriceAsset;

  final SwapOrderFormActions actions;
  final SwapOrderFormModel state;
  final String priceString;

  final Asset amountAsset;
  final Asset priceAsset;
  final Asset giveAsset;
  final Asset getAsset;
  final List<OrderViewModel> buyOrders;
  final List<OrderViewModel> sellOrders;

  const OrderInputs({
    super.key,
    required this.priceString,
    required this.actions,
    required this.state,
    required this.onClickAmountAsset,
    required this.onClickPriceAsset,
    required this.priceAsset,
    required this.amountAsset,
    required this.giveAsset,
    required this.getAsset,
    required this.buyOrders,
    required this.sellOrders,
  });

  @override
  State<OrderInputs> createState() => _OrderInputs();
}

class _OrderInputs extends State<OrderInputs> {
  late final TextEditingController _amountController;
  late final TextEditingController _limitPriceController;

  final appIcons = AppIcons();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _limitPriceController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return BlocConsumer<SwapOrderFormBloc, SwapOrderFormModel>(
        listenWhen: (previous, current) =>
            previous.amountInput.value != current.amountInput.value ||
            previous.priceInput.value != current.priceInput.value,
        listener: (context, state) {
          // Update the controllers when the state changes

          final newAmount = state.amountInput.value;

          // Only update if the user hasn't already typed this in
          if (_amountController.text != newAmount) {
            final cursorPos = _amountController.selection;
            _amountController.text = newAmount;

            // Try to preserve cursor position (if possible)
            final offset =
                cursorPos.baseOffset.clamp(0, _amountController.text.length);
            _amountController.selection =
                TextSelection.collapsed(offset: offset);
          }

          final newPrice = state.priceInput.value;

          if (_limitPriceController.text != newPrice) {
            final cursorPos = _limitPriceController.selection;
            _limitPriceController.text = newPrice;
            // Try to preserve cursor position (if possible)
            final offset = cursorPos.baseOffset
                .clamp(0, _limitPriceController.text.length);
            _limitPriceController.selection =
                TextSelection.collapsed(offset: offset);
          }
        },
        builder: (context, state) {
          bool isDarkMode = true;
          return Column(
            children: [
              HorizonCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
                          child: Text(
                              widget.state.amountType == AmountType.get
                                  ? "You're buying"
                                  : "You're selling",
                              style: theme.textTheme.titleSmall!.copyWith(
                                color: theme
                                    .extension<CustomThemeExtension>()!
                                    .mutedDescriptionTextColor,
                              )),
                        ),
                        AssetPill(
                            onTap: widget.onClickAmountAsset,
                            asset: widget.amountAsset,
                            appIcons: appIcons,
                            session: session,
                            theme: theme),
                      ],
                    ),
                    commonHeightSizedBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: QuantityInputV2(
                                style: const TextStyle(fontSize: 16),
                                divisible: widget.state.amountInputDivisibility,
                                value: widget.state.amountInput.value,
                                // controller: _amountController,
                                onChanged: (value) {
                                  widget.actions.onAmountChanged(value);
                                })),
                        if (state.amountType == AmountType.give)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                  widget.state.giveAssetBalance
                                      .quantityNormalized,
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(height: 1.2)),
                              const SizedBox(
                                width: 10,
                              ),
                              CustomButton(
                                label: "Max",
                                onPressed: () {
                                  widget.actions.onClickMax();
                                },
                              ),
                            ],
                          )
                      ],
                    ),
                  ],
                ),
              ),
              commonHeightSizedBox,
              commonHeightSizedBox,
              // Text(state.amountInputError.fold(() => "", (a) => a)),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  children: [
                    HorizonCard(
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("At price",
                                    style: theme.textTheme.titleSmall!.copyWith(
                                      color: theme
                                          .extension<CustomThemeExtension>()!
                                          .mutedDescriptionTextColor,
                                    )),
                                PriceToggle(
                                    onTap: widget.onClickPriceAsset,
                                    numerator: widget.state.priceNumeratorAsset,
                                    denominator:
                                        widget.state.priceDenominatorAsset,
                                    appIcons: appIcons,
                                    session: session,
                                    theme: theme),
                              ]),
                          commonHeightSizedBox,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: QuantityInputV2(
                                      style: const TextStyle(fontSize: 16),
                                      divisible: true,
                                      value: widget.state.priceInput.value,
                                      onChanged: (value) {
                                        widget.actions.onPriceChanged(value);
                                      })),
                              Row(
                                children: [
                                  CustomButton(
                                    label: "Floor",
                                    disabled: !widget.state.hasBuyOrders,
                                    onPressed: () {
                                      widget.actions
                                          .onRelativePriceButtonClicked(
                                        RelativePriceValue.floor,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  CustomButton(
                                    disabled: !widget.state.hasBuyOrders,
                                    label: "+5%",
                                    onPressed: () {
                                      widget.actions
                                          .onRelativePriceButtonClicked(
                                        RelativePriceValue.plus5,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  CustomButton(
                                    disabled: !widget.state.hasBuyOrders,
                                    label: "+10%",
                                    onPressed: () {
                                      widget.actions
                                          .onRelativePriceButtonClicked(
                                        RelativePriceValue.plus10,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  CustomButton(
                                    label: "+15%",
                                    disabled: !widget.state.hasBuyOrders,
                                    onPressed: () {
                                      widget.actions
                                          .onRelativePriceButtonClicked(
                                        RelativePriceValue.plus15,
                                      );
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    //   child: Column(
                    //     children: [
                    //       Row(
                    //         children: [
                    //           Padding(
                    //             padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
                    //             child: Text("To receive",
                    //                 style: theme.textTheme.titleSmall!.copyWith(
                    //                   color: theme
                    //                       .extension<CustomThemeExtension>()!
                    //                       .mutedDescriptionTextColor,
                    //                 )),
                    //           ),
                    //         ],
                    //       ),
                    //       HorizonCard(
                    //         child: Column(
                    //           children: [
                    //             Row(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.spaceBetween,
                    //               crossAxisAlignment: CrossAxisAlignment.center,
                    //               children: [
                    //                 Expanded(
                    //                     child: QuantityText(
                    //                         quantity: widget.state
                    //                             .receiveQuantityInput.value
                    //                             .normalizedPretty())),
                    //                 AssetPill(
                    //                     onTap: widget.onClickPriceAsset,
                    //                     asset: widget.receiveAsset,
                    //                     appIcons: appIcons,
                    //                     session: session,
                    //                     theme: theme),
                    //               ],
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

class PriceToggle extends StatelessWidget {
  const PriceToggle(
      {super.key,
      required this.appIcons,
      required this.session,
      required this.theme,
      required this.numerator,
      required this.denominator,
      required this.onTap});

  final VoidCallback onTap;
  final AppIcons appIcons;
  final SessionStateSuccess session;
  final ThemeData theme;
  final Asset numerator;
  final Asset denominator;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: transparentWhite8, width: 1)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // appIcons.assetIcon(
              //     httpConfig: session.httpConfig,
              //     assetName: numerator.asset,
              //     context: context,
              //     width: 24,
              //     height: 24),
              // const SizedBox(width: 8),

              Text(
                  "${truncateAssetName(numerator.displayName.toUpperCase())} / ${truncateAssetName(denominator.displayName.toUpperCase())}",
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontSize: 12,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class AssetPill extends StatelessWidget {
  const AssetPill(
      {super.key,
      required this.appIcons,
      required this.session,
      required this.theme,
      required this.asset,
      this.displayOverride,
      required this.onTap});

  final String? displayOverride;
  final VoidCallback onTap;
  final AppIcons appIcons;
  final SessionStateSuccess session;
  final ThemeData theme;
  final Asset asset;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: transparentWhite8, width: 1)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              appIcons.assetIcon(
                  httpConfig: session.httpConfig,
                  assetName: asset.asset,
                  context: context,
                  width: 24,
                  height: 24),
              const SizedBox(width: 8),
              Text(displayOverride ?? asset.displayName.toUpperCase(),
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontSize: 12,
                  )),
              const SizedBox(width: 2),
              // const SizedBox(width: 4),
              // AppIcons.caretDownIcon(
              //   context: context,
              //   width: 18,
              //   height: 18,
              // )
            ],
          ),
        ),
      ),
    );
  }
}

class OrderBookView extends StatelessWidget {
  final String priceString;

  final PriceType priceType;

  final Asset giveAsset;
  final Asset getAsset;
  final List<OrderViewModel> asks;
  final List<OrderViewModel> bids;

  const OrderBookView({
    super.key,
    required this.priceType,
    required this.priceString,
    required this.giveAsset,
    required this.getAsset,
    required this.asks,
    required this.bids,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = 1 + bids.length + 1 + asks.length;
    final theme = Theme.of(context);

    if (bids.isEmpty && asks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
              "No open orders for ${giveAsset.displayName}/${getAsset.displayName}",
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme
                    .extension<CustomThemeExtension>()!
                    .mutedDescriptionTextColor,
              )),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text("Price (${priceString.toUpperCase()})",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme
                              .extension<CustomThemeExtension>()!
                              .mutedDescriptionTextColor,
                        ))),
                Expanded(
                    child: Text("Volume",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme
                              .extension<CustomThemeExtension>()!
                              .mutedDescriptionTextColor,
                        ))),
              ],
            );
          }

          final buyCount = asks.length;
          final sellStartIndex = 1 + buyCount + 1;

          if (index == 1 + buyCount) {
            return const Divider();
          }

          if (index > 0 && index < 1 + buyCount) {
            final ask = asks[index - 1];

            return _OrderRow(
              quantity: ask.quantity.normalized(precision: 8),
              price: priceType == PriceType.give
                  ? ask.price.normalized(precision: 8)
                  // when get asset is not divisible we have to normalize the price
                  : adjustForDivisibility(
                          Rational.parse(ask.invertedPrice.quantity.toString()),
                          fromDivisible: giveAsset.divisible,
                          toDivisible: getAsset.divisible)
                      .toDecimal(scaleOnInfinitePrecision: 9)
                      .ceil(scale: 8)
                      .toString(),
              color: Colors.red,
            );
          }

          // TODO: i need to verify this
          final bid = bids[index - sellStartIndex];
          return _OrderRow(
            quantity: bid.quantity.normalized(precision: 8),
            price: priceType == PriceType.give
                ? bid.price.normalized(precision: 8)
                : adjustForDivisibility(
                        Rational.parse(bid.price.quantity.toString()),
                        fromDivisible: giveAsset.divisible,
                        toDivisible: getAsset.divisible)
                    .toDecimal(scaleOnInfinitePrecision: 9)
                    .ceil(scale: 8)
                    .toString(),
            color: Colors.green,
          );
        },
      ),
    );
  }
}
