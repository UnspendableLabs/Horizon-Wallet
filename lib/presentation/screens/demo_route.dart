import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/attach_assets_to_swap.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/choose_fund_source.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/create_swap_listing.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/review_swap_listing.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/swap_listing_slider.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/token_selection.dart';

enum DemoComponent {
  swapTokenSelector,
  swapSourceOfFundsSelector,
  swapCreateListing,
  swapListingReview,
  swapListingSuccess,
  swapListingSlider,
  attachAssetsToSwap,
}

class WidgetsDemoPage extends StatefulWidget {
  final DemoComponent component;
  const WidgetsDemoPage({super.key, required this.component});

  @override
  State<WidgetsDemoPage> createState() => _WidgetsDemoPageState();
}

class _WidgetsDemoPageState extends State<WidgetsDemoPage> {
  Widget _renderComponent() {
    switch (widget.component) {
      case DemoComponent.swapTokenSelector:
        return SwapFormTokenSelection(
          onNextStep: (_, __) {},
        );
      case DemoComponent.swapSourceOfFundsSelector:
        return SwapFundSourceSelector();
      case DemoComponent.swapListingSlider:
        return SwapListingSlider(onNextStep: () {});

      case DemoComponent.swapCreateListing:
        return CreateSwapListing();
      case DemoComponent.attachAssetsToSwap:
        return AttachAssetToSwap();
      case DemoComponent.swapListingReview:
        return SwapListingReview();

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _renderComponent(),
    );
  }
}

