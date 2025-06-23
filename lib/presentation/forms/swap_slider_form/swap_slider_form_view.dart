import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/common/sats_to_usd_display.dart';

import "./bloc/swap_slider_form_bloc.dart";

class SwapSliderFormActions {
  void Function(int value) sliderDragged;

  SwapSliderFormActions({
    required this.sliderDragged,
  });
}

class SwapSliderFormProvider extends StatelessWidget {
  final String assetName;
  final HttpConfig httpConfig;
  final Widget Function(
    SwapSliderFormActions actions,
    SwapSliderFormModel state,
  ) child;
  const SwapSliderFormProvider({
    super.key,
    required this.child,
    required this.assetName,
    required this.httpConfig,
  });
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SwapSliderFormBloc(
        assetName: assetName,
        httpConfig: httpConfig,
      ),
      child: BlocBuilder<SwapSliderFormBloc, SwapSliderFormModel>(
          builder: (context, state) {
        return child(
            SwapSliderFormActions(
              sliderDragged: (value) => context
                  .read<SwapSliderFormBloc>()
                  .add(SliderDragged(value: value)),
            ),
            state);
      }),
    );
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
                        quantity: widget.state.total.normalized(precision: 2),
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
                                swap.quantity.normalized(precision: 2),
                                swap.pricePerUnit.toString(),
                                swap.price.toString(),
                                swap.selected,
                              );
                            },
                          ),
                          onRefreshing: (model) => ListView.builder(
                            itemCount: model.items.length,
                            itemBuilder: (context, index) {
                              final swap = model.items[index];
                              return _buildRow(
                                swap.quantity.normalized(precision: 2),
                                swap.pricePerUnit.toString(),
                                swap.price.toString(),
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
        HorizonButton(
          child: TextButtonContent(value: "Swap"),
          disabled: !widget.state.isValid,
          onPressed: () {},
          variant: ButtonVariant.green,
        ),
      ],
    );
  }

  Widget _buildRow(
      String quantity, String price, String total, bool isSelected) {
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
                Text(quantity, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: theme.textTheme.bodySmall),
                SatsToUsdDisplay(
                  sats: BigInt.parse(price),
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
                Text(total, style: theme.textTheme.bodySmall),


                SatsToUsdDisplay(
                  sats: BigInt.parse(total),
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
