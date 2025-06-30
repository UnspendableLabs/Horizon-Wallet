import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './bloc/swap_order_form_bloc.dart';

import 'package:flutter/material.dart';

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
          Text(quantity, style: theme.textTheme.bodySmall),
          Text(price, style: theme.textTheme.bodySmall!.copyWith(color: color)),
        ],
      ),
    );
  }
}

class SwapOrderFormActions {
  final VoidCallback onSubmitClicked;

  SwapOrderFormActions({
    required this.onSubmitClicked,
  });
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
                onSubmitClicked: () => print("submit clicked")),
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
              OrderBookWidget(
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
              OrderBookWidget(
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

class OrderBookWidget extends StatelessWidget {
  final String giveAsset;
  final String receiveAsset;
  final List<OrderViewModel> buyOrders;
  final List<OrderViewModel> sellOrders;

  const OrderBookWidget({
    super.key,
    required this.giveAsset,
    required this.receiveAsset,
    required this.buyOrders,
    required this.sellOrders,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Total rows = header + sell + divider + buy
    final itemCount = 1 + sellOrders.length + 1 + buyOrders.length;

    return ListView.builder(
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
                  child: Text("Size (${receiveAsset.toUpperCase()})",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  child: Text("Price (${giveAsset.toUpperCase()})",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
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
            price: buy.price.normalized(precision: 8),
            color: Colors.red,
          );
        }

        // Buy orders
        final sell = sellOrders[index - sellStartIndex];
        return _OrderRow(
          quantity: sell.quantity.normalized(precision: 8),
          price: sell.price.normalized(precision: 8),
          color: Colors.green,
        );
      },
    );
  }
}
