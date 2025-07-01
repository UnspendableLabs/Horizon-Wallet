import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meilisearch/meilisearch.dart';
import './bloc/swap_order_form_bloc.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class LimitPriceInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextStyle? style;
  final bool divisible; // allows 1.23 vs 123

  const LimitPriceInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.style,
    this.divisible = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: isDark
          ? const [goldenGradient1, yellow1, goldenGradient2, goldenGradient3]
          : const [duskGradient2, duskGradient1],
      stops: isDark ? const [0.0, .325, .65, 1.0] : const [0.0, 1.0],
    );

    final baseStyle = TextStyle(
      fontFamily: 'Lato',
      fontSize: style?.fontSize ?? 14,
      fontWeight: style?.fontWeight ?? FontWeight.w400,
      color: Colors.white, // <- solid colour for masking
    );

    // TODO: we need this capability in a generic text input that can also take arbitrary styles.
    // we keep reinventing the wheel
    final fmt = divisible
        ? FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d{0,8}$'),
          )
        : FilteringTextInputFormatter.digitsOnly;

    return ShaderMask(
      blendMode: BlendMode.srcIn, // keep only the text's alpha
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: TextField(
        controller: controller,
        inputFormatters: [fmt],
        onChanged: onChanged,
        keyboardType: TextInputType.numberWithOptions(
          decimal: divisible,
          signed: false,
        ),
        textAlign: TextAlign.left,
        style: baseStyle,
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isCollapsed: true, // shrink to fit the text
          contentPadding: EdgeInsets.zero,
        ),
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

class SwapOrderFormActions {
  final VoidCallback onClickAmountAsset;
  final VoidCallback onClickPriceAsset;
  final VoidCallback onSubmitClicked;
  final Function(String value) onAmountChanged;

  SwapOrderFormActions(
      {required this.onSubmitClicked,
      required this.onClickAmountAsset,
      required this.onClickPriceAsset,
      required this.onAmountChanged});
}

class SwapOrderFormProvider extends StatefulWidget {
  final String giveAsset;

  final String receiveAsset;
  final AddressV2 address;
  final HttpConfig httpConfig;

  final Widget Function(
    SwapOrderFormActions actions,
    SwapOrderFormModel state,
  ) child;

  const SwapOrderFormProvider(
      {super.key,
      required this.child,
      required this.httpConfig,
      required this.address,
      required this.giveAsset,
      required this.receiveAsset});

  @override
  State<SwapOrderFormProvider> createState() => _SwapOrderFormProviderState();
}

class _SwapOrderFormProviderState extends State<SwapOrderFormProvider> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SwapOrderFormBloc(
        address: widget.address,
        httpConfig: widget.httpConfig,
        receiveAsset: widget.receiveAsset,
        giveAsset: widget.giveAsset,
      ),
      child: BlocBuilder<SwapOrderFormBloc, SwapOrderFormModel>(
        builder: (context, state) {
          return widget.child(
            SwapOrderFormActions(
                onSubmitClicked: () => print("submit clicked"),
                onAmountChanged: (value) {
                  context
                      .read<SwapOrderFormBloc>()
                      .add(AmountInputChanged(value: value));
                },
                onClickPriceAsset: () {
                  context.read<SwapOrderFormBloc>().add(PriceTypeClicked());
                },
                onClickAmountAsset: () {
                  context.read<SwapOrderFormBloc>().add(AmountTypeClicked());
                }),
            state,
          );
        },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Replace with actual form layout
        state.viewModel.fold(
          onInitial: () => const Center(child: CircularProgressIndicator()),
          onLoading: () => const Center(child: CircularProgressIndicator()),
          onFailure: (error) => Text(
            "Error: $error",
            style: theme.textTheme.bodyMedium!.copyWith(color: Colors.red),
          ),
          onSuccess: (data) => Column(
            children: [
              OrderInputs(
                actions: actions,
                state: state,
                priceString: data.priceString,
                onClickAmountAsset: actions.onClickAmountAsset,
                onClickPriceAsset: actions.onClickPriceAsset,
                priceAsset: data.priceAsset,
                amountAsset: data.amountAsset,
                giveAsset: state.giveAsset,
                receiveAsset: state.receiveAsset,
                buyOrders: data.buyOrders,
                sellOrders: data.sellOrders,
              ),
              OrderBookView(
                priceType: state.priceType,
                priceString: data.priceString,
                giveAsset: state.giveAsset,
                receiveAsset: state.receiveAsset,
                buyOrders: data.buyOrders,
                sellOrders: data.sellOrders,
              ),
              // Add more form fields as needed
            ],
          ),
          onRefreshing: (data) => Column(
            children: [
              OrderInputs(
                priceString: data.priceString,
                actions: actions,
                state: state,
                onClickAmountAsset: actions.onClickAmountAsset,
                onClickPriceAsset: actions.onClickPriceAsset,
                priceAsset: data.priceAsset,
                giveAsset: state.giveAsset,
                amountAsset: data.amountAsset,
                receiveAsset: state.receiveAsset,
                buyOrders: data.buyOrders,
                sellOrders: data.sellOrders,
              ),
              OrderBookView(
                priceType: state.priceType,
                priceString: data.priceString,
                giveAsset: state.giveAsset,
                receiveAsset: state.receiveAsset,
                buyOrders: data.buyOrders,
                sellOrders: data.sellOrders,
              ),
              // Add more form fields as needed
            ],
          ),
        ),

        ElevatedButton(
          onPressed: state.isValid ? actions.onSubmitClicked : null,
          child: const Text("Submit Order"),
        ),
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

  final String amountAsset;
  final String priceAsset;
  final String giveAsset;
  final String receiveAsset;
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
    required this.receiveAsset,
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

    return Column(
      children: [
        Row(
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
          ],
        ),
        HorizonCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: QuantityInputV2(
                      style: const TextStyle(fontSize: 16),
                      divisible: widget.state.amountInput.value.divisible,
                      controller:
                          _amountController, // chat helpo me with a stateful controller hre,
                      onChanged: (value) {
                        widget.actions.onAmountChanged(value);
                      })),
              AssetPill(
                  onTap: widget.onClickAmountAsset,
                  asset: widget.amountAsset,
                  appIcons: appIcons,
                  session: session,
                  theme: theme),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
                    child: Text(
                        "At ${_limitPriceController.text} ${widget.priceString}",
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: theme
                              .extension<CustomThemeExtension>()!
                              .mutedDescriptionTextColor,
                        )),
                  ),
                ],
              ),
              HorizonCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: LimitPriceInput(
                                style: const TextStyle(fontSize: 16),
                                divisible: true,
                                controller:
                                    _limitPriceController, // chat helpo me with a stateful controller hre,
                                onChanged: (value) {
                                  print(value);
                                })),

                        // chat i'd like to wrap this in a rounded border
                        AssetPill(
                            onTap: widget.onClickPriceAsset,
                            asset: widget.priceAsset,
                            appIcons: appIcons,
                            session: session,
                            theme: theme),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
      this.onTap});

  final VoidCallback? onTap;
  final AppIcons appIcons;
  final SessionStateSuccess session;
  final ThemeData theme;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: transparentWhite8, width: 1)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              appIcons.assetIcon(
                  httpConfig: session.httpConfig,
                  assetName: asset,
                  context: context,
                  width: 24,
                  height: 24),
              const SizedBox(width: 8),
              Text(asset.toUpperCase(),
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontSize: 12,
                  )),
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

  final String giveAsset;
  final String receiveAsset;
  final List<OrderViewModel> buyOrders;
  final List<OrderViewModel> sellOrders;

  const OrderBookView({
    super.key,
    required this.priceType,
    required this.priceString,
    required this.giveAsset,
    required this.receiveAsset,
    required this.buyOrders,
    required this.sellOrders,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = 1 + sellOrders.length + 1 + buyOrders.length;
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
          child: HorizonCard(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // chat make first left aligned and last right aligned
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

                final buyCount = buyOrders.length;
                final sellStartIndex = 1 + buyCount + 1;

                if (index == 1 + buyCount) {
                  return const Divider();
                }

                if (index > 0 && index < 1 + buyCount) {
                  final buy = buyOrders[index - 1];
                  return _OrderRow(
                    quantity: buy.quantity.normalized(precision: 8),
                    price: priceType == PriceType.give
                        ? buy.price.normalized(precision: 8)
                        : buy.invertedPrice.normalized(precision: 8),
                    color: Colors.red,
                  );
                }

                // Buy orders
                final sell = sellOrders[index - sellStartIndex];
                return _OrderRow(
                  quantity: sell.quantity.normalized(precision: 8),
                  price: priceType == PriceType.give
                      ? sell.price.normalized(precision: 8)
                      : sell.invertedPrice.normalized(precision: 8),
                  color: Colors.green,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
