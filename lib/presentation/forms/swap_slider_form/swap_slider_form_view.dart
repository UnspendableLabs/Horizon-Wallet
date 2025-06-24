import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/common/sats_to_usd_display.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/services/mempool_price_service.dart';

import "./bloc/swap_slider_form_bloc.dart";

class SwapSliderFormActions {
  void Function(int value) sliderDragged;
  final VoidCallback onSubmitClicked;

  SwapSliderFormActions({
    required this.sliderDragged,
    required this.onSubmitClicked,
  });
}

class SwapSliderFormProvider extends StatefulWidget {
  final String assetName;
  final HttpConfig httpConfig;
  final Widget Function(
    SwapSliderFormActions actions,
    SwapSliderFormModel state,
  ) child;

  final MultiAddressBalanceEntry bitcoinBalance;

  const SwapSliderFormProvider({
    super.key,
    required this.child,
    required this.assetName,
    required this.httpConfig,
    required this.bitcoinBalance,
  });

  @override
  State<SwapSliderFormProvider> createState() => _SwapSliderFormProviderState();
}

class _SwapSliderFormProviderState extends State<SwapSliderFormProvider> {
  final _priceService = GetIt.I<MempoolPriceService>();

  @override
  void initState() {
    super.initState();
    _priceService.startListening(httpConfig: widget.httpConfig);
  }

  @override
  void dispose() {
    _priceService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SwapSliderFormBloc(
        assetName: widget.assetName,
        bitcoinBalance: widget.bitcoinBalance,
        httpConfig: widget.httpConfig,
      ),
      child: BlocBuilder<SwapSliderFormBloc, SwapSliderFormModel>(
          builder: (context, state) {
        return widget.child(
            SwapSliderFormActions(
                sliderDragged: (value) => context
                    .read<SwapSliderFormBloc>()
                    .add(SliderDragged(value: value)),
                onSubmitClicked: () =>
                    context.read<SwapSliderFormBloc>().add(SubmitClicked())),
            state);
      }),
    );
  }
}

class SwapFormSuccessHandler extends StatelessWidget {
  final Function(List<AtomicSwap> swaps) onSuccess;

  const SwapFormSuccessHandler({super.key, required this.onSuccess});

  @override
  Widget build(context) {
    return BlocListener<SwapSliderFormBloc, SwapSliderFormModel>(
        listener: (context, state) {
          if (state.submissionStatus.isSuccess) {
            onSuccess(state.selectedSwapsInput.value);
          }
        },
        child: const SizedBox.shrink());
  }
}

class SwapSliderForm extends StatefulWidget {
  final SwapSliderFormActions actions;
  final SwapSliderFormModel state;

  const SwapSliderForm({
    super.key,
    required this.actions,
    required this.state,
  });

  @override
  State<SwapSliderForm> createState() => _SwapSliderFormState();
}

class _SwapSliderFormState extends State<SwapSliderForm> {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final theme = Theme.of(context);
    final appIcons = AppIcons();

    final cardHeight = 366.0;

    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          width: double.infinity,
          child: HorizonCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuantityText(
                        quantity: widget.state.selectedSwapsInput.totalQuantity
                            .normalized(precision: 2),
                        style: const TextStyle(fontSize: 35),
                      ),
                      Row(
                        children: [
                          appIcons.assetIcon(
                            httpConfig: session.httpConfig,
                            assetName: widget.state.assetName,
                            context: context,
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.state.assetName,
                            style: theme.textTheme.titleMedium!
                                .copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                widget.state.atomicSwapListModel.fold(
                  onFailure: (_) => Center(
                    child: HorizonSlider(
                      value: 0,
                      min: 0,
                      max: 100,
                      onChanged: (value) {},
                    ),
                  ),
                  onInitial: () => Center(
                    child: HorizonSlider(
                      value: 0,
                      min: 0,
                      max: 100,
                      onChanged: (value) {},
                    ),
                  ),
                  onLoading: () => Center(
                    child: HorizonSlider(
                      value: 0,
                      min: 0,
                      max: 100,
                      onChanged: (value) {},
                    ),
                  ),
                  onSuccess: (model) => Center(
                    child: HorizonSlider(
                      value: widget.state.sliderInput.value.toDouble(),
                      min: 0,
                      max: model.items.length.toDouble(),
                      steps: model.items.length + 1,
                      onChanged: (value) {
                        widget.actions.sliderDragged(value.toInt());
                      },
                    ),
                  ),
                  onRefreshing: (model) => Center(
                    child: HorizonSlider(
                      value: widget.state.sliderInput.value.toDouble(),
                      min: 0,
                      max: model.items.length.toDouble(),
                      steps: model.items.length + 1,
                      onChanged: (value) {
                        widget.actions.sliderDragged(value.toInt());
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 34,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Quantity',
                                  style: theme.textTheme.bodySmall),
                            ),
                            Expanded(
                              child: Text(
                                  'Price (sats/${widget.state.assetName})',
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.bodySmall),
                            ),
                            Expanded(
                              child: Text('Total',
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.bodySmall),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: widget.state.atomicSwapListModel.fold(
                          onInitial: () => Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          onLoading: () => Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          onSuccess: (model) => ListView.builder(
                            itemCount: model.items.length,
                            itemBuilder: (context, index) {
                              final swap = model.items[index];
                              return _buildRow(
                                swap.quantity,
                                swap.pricePerUnit,
                                swap.price,
                                swap.selected,
                              );
                            },
                          ),
                          onRefreshing: (model) => ListView.builder(
                            itemCount: model.items.length,
                            itemBuilder: (context, index) {
                              final swap = model.items[index];
                              return _buildRow(
                                swap.quantity,
                                swap.pricePerUnit,
                                swap.price,
                                swap.selected,
                              );
                            },
                          ),
                          onFailure: (error) => Text("Error: $error"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("You Pay", style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 12),
                  QuantityText(
                      quantity:
                          "${widget.state.totalCostInput.value.normalized(precision: 8)} BTC",
                      style: TextStyle(fontSize: 12)),
                ],
              ),
              SatsToUsdDisplay(
                  sats: widget.state.totalCostInput.value.quantity,
                  child: (value) => Text(
                        "\$${value.toStringAsFixed(2)}",
                        textAlign: TextAlign.end,
                      ))
            ],
          ),
        ),
        HorizonButton(
          child: TextButtonContent(value: "Swap"),
          disabled: !widget.state.isValid,
          onPressed: () {
            if (widget.state.isValid) {
              widget.actions.onSubmitClicked();
            }
          },
          variant: ButtonVariant.green,
        ),
      ],
    );
  }

  Widget _buildRow(
      AssetQuantity quantity, AssetQuantity price, AssetQuantity total, bool isSelected) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                if (isSelected)
                  AppIcons.checkCircleIcon(
                      context: context, color: green1, width: 24, height: 24)
                else
                  AppIcons.plusCircleIcon(
                      context: context,
                      color: transparentPurple33,
                      width: 24,
                      height: 24),
                const SizedBox(width: 8),
                Text(quantity.normalized(precision: 2), style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price.quantity.toString(), style: theme.textTheme.bodySmall),
                SatsToUsdDisplay(
                  sats: price.quantity,
                  child: (value) => Text("\$${value.toStringAsFixed(2)}",
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: theme
                            .extension<CustomThemeExtension>()!
                            .mutedDescriptionTextColor,
                      )),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(total.quantity.toString(), style: theme.textTheme.bodySmall),
                SatsToUsdDisplay(
                  sats: total.quantity,
                  child: (value) => Text("\$${value.toStringAsFixed(2)}",
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: theme
                            .extension<CustomThemeExtension>()!
                            .mutedDescriptionTextColor,
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
