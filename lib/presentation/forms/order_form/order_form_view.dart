
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';

import "./order_form_bloc.dart";


class TradeFormScreen extends StatefulWidget {
  const TradeFormScreen({Key? key}) : super(key: key);

  @override
  _TradeFormScreenState createState() => _TradeFormScreenState();
}

class _TradeFormScreenState extends State<TradeFormScreen> {
  final TextEditingController _buyAssetController = TextEditingController();

  @override
  void dispose() {
    _buyAssetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Trade Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<FormBloc, FormStateModel>(
          listener: (context, state) {
            // Handle submission success
            // if (state.submissionStatus.isSuccess) {
            if (false) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Form submitted successfully!')),
              );
            }

            // Handle submission failure
            // if (state.submissionStatus.isFailure) {
            if (false){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Submission Failed')),
              );
            }

            // Update Buy Asset Controller when buy asset is set
            // if (state.buyAsset.value.isNotEmpty) {
            //   final selectedBuyAsset = (state.buyAssets is Success<List<Asset>>)
            //       ? (state.buyAssets as Success<List<Asset>>).data.firstWhere(
            //             (asset) => asset.id == state.buyAsset.value,
            //             orElse: () => Asset(id: '', name: ''),
            //           )
            //       : Asset(id: '', name: '');
            //   if (selectedBuyAsset.name.isNotEmpty) {
            //     _buyAssetController.text = selectedBuyAsset.name;
            //   }
            // }
          },
          child: BlocBuilder<FormBloc, FormStateModel>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sell Asset Dropdown
                    Text(
                      'Sell Asset',
                      // style: Theme.of(context).textTheme.subtitle1,
                    ),
                    const SizedBox(height: 8.0),
                    state.sellAssets is Loading
                        ? const Center(child: CircularProgressIndicator())
                        : state.sellAssets is Success<List<Asset>>
                            ? DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  errorText: 
                                  // state.sellAsset.invalid
                                  false
                                      ? 'Please select a sell asset'
                                      : null,
                                ),
                                value: state.sellAsset.value.isNotEmpty
                                    ? state.sellAsset.value
                                    : null,
                                isExpanded: true,
                                items: (state.sellAssets as Success<List<Asset>>)
                                    .data
                                    .map(
                                      (asset) => DropdownMenuItem<String>(
                                        value: asset.id,
                                        child: Text(asset.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<FormBloc>().add(SellAssetChanged(value));
                                  }
                                },
                                hint: const Text('Select Sell Asset'),
                              )
                            : state.sellAssets is Failure<List<Asset>>
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (state.sellAssets as Failure<List<Asset>>).error,
                                        style: TextStyle(color: Theme.of(context).errorColor),
                                      ),
                                      const SizedBox(height: 8.0),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<FormBloc>().add(LoadSellAssets());
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                    const SizedBox(height: 20.0),

                    // Buy Asset Typeahead Dropdown
                    Text(
                      'Buy Asset',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    const SizedBox(height: 8.0),
                    TypeAheadFormField<Asset>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _buyAssetController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          errorText: state.buyAsset.invalid
                              ? 'Please select a buy asset'
                              : null,
                          hintText: 'Type to search Buy Asset',
                        ),
                      ),
                      suggestionsCallback: (pattern) async {
                        if (pattern.isEmpty) {
                          return [];
                        }
                        // Fetch buy assets based on the input pattern
                        try {
                          final buyAssets = await context
                              .read<FormBloc>()
                              .assetRepository
                              .fetchBuyAssets(query: pattern);
                          return buyAssets;
                        } catch (e) {
                          // Optionally, handle errors here
                          return [];
                        }
                      },
                      itemBuilder: (context, Asset suggestion) {
                        return ListTile(
                          title: Text(suggestion.name),
                        );
                      },
                      onSuggestionSelected: (Asset suggestion) {
                        _buyAssetController.text = suggestion.name;
                        context.read<FormBloc>().add(BuyAssetChanged(suggestion.id));
                      },
                      validator: (value) {
                        return state.buyAsset.invalid
                            ? 'Please select a buy asset'
                            : null;
                      },
                      debounceDuration: const Duration(milliseconds: 300),
                    ),
                    const SizedBox(height: 20.0),

                    // Quantity Input
                    Text(
                      'Quantity',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      initialValue: state.quantity.value,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        errorText: state.quantity.invalid
                            ? 'Enter a valid quantity'
                            : null,
                        hintText: 'Enter quantity',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,}')),
                      ],
                      onChanged: (value) {
                        context.read<FormBloc>().add(QuantityChanged(value));
                      },
                    ),
                    const SizedBox(height: 20.0),

                    // Price Input
                    Text(
                      'Price (${state.sellAsset.value.isNotEmpty ? state.sellAsset.value : 'Sell Asset'})',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      initialValue: state.price.value,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        errorText:
                            state.price.invalid ? 'Enter a valid price' : null,
                        hintText: 'Enter price',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,}')),
                      ],
                      onChanged: (value) {
                        context.read<FormBloc>().add(PriceChanged(value));
                      },
                    ),
                    const SizedBox(height: 30.0),

                    // Submit Button
                    Center(
                      child: state.submissionStatus.isInProgress
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: state.validationStatus.isValidated &&
                                      !state.submissionStatus.isInProgress
                                  ? () {
                                      context.read<FormBloc>().add(FormSubmitted());
                                    }
                                  : null,
                              child: const Text('Submit'),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper method to display SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
