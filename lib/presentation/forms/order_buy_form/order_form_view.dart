import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import './order_form_bloc.dart';

class OrderBuyForm extends StatelessWidget {
  final BalanceRepository balanceRepository;
  final String currentAddress;

  const OrderBuyForm(
      {super.key,
      required this.balanceRepository,
      required this.currentAddress});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return OrderBuyFormBloc(
            balanceRepository: balanceRepository,
            currentAddress: currentAddress)
          ..add(LoadGiveAssets());
      },
      child: OrderBuyForm_(),
    );
  }
}

class OrderBuyForm_ extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBuyFormBloc, FormStateModel>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Dispenser Created Successfully')));
        } else if (state.submissionStatus.isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? 'Submission Failed')));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GiveAssetInputField(),
          SizedBox(height: 16),
          GetAssetInputField(),
          SizedBox(height: 16),
          QuantityInputField(),
          SizedBox(height: 16),
          PriceInputField(),
          SizedBox(height: 32),
          SubmitButton(),
        ],
      ),
    );
  }
}

class GiveAssetInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBuyFormBloc, FormStateModel>(
      buildWhen: (previous, current) =>
          previous.giveAssets != current.giveAssets ||
          previous.giveAsset != current.giveAsset,
      builder: (context, state) {
        if (state.giveAssets is Loading) {
          return Center(child: CircularProgressIndicator());
        } else if (state.giveAssets is Success<List<Balance>>) {
          final giveAssets = (state.giveAssets as Success<List<Balance>>).data;

          return HorizonUI.HorizonDropdownMenu<String>(
            enabled: true,
            controller: TextEditingController(text: state.giveAsset.value),
            label: 'Give Asset',
            onChanged: (selectedAsset) {
              if (selectedAsset != null) {
                context
                    .read<OrderBuyFormBloc>()
                    .add(GiveAssetChanged(selectedAsset));
              }
            },
            // selectedValue: state.giveAsset.value,
            items: giveAssets.map<DropdownMenuItem<String>>((balance) {
              return HorizonUI.buildDropdownMenuItem(
                  balance.asset, balance.asset);
            }).toList(),
          );
        } else if (state.giveAssets is Failure) {
          return Text('Failed to load assets',
              style: TextStyle(color: Colors.red));
        } else {
          return Text("not asked");
        }
      },
    );
  }
}

class GetAssetInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBuyFormBloc, FormStateModel>(
      buildWhen: (previous, current) => previous.getAsset != current.getAsset,
      builder: (context, state) {
        return TextField(
          onChanged: (value) =>
              context.read<OrderBuyFormBloc>().add(GetAssetChanged(value)),
          decoration: InputDecoration(
            labelText: 'Get Asset',
            // errorText: state.getAsset.invalid ? 'Please select an asset to get' : null,
          ),
        );
      },
    );
  }
}

class QuantityInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBuyFormBloc, FormStateModel>(
      buildWhen: (previous, current) => previous.quantity != current.quantity,
      builder: (context, state) {
        return TextField(
          onChanged: (value) =>
              context.read<OrderBuyFormBloc>().add(QuantityChanged(value)),
          decoration: InputDecoration(
            labelText: 'Quantity',
            // errorText: state.quantity.invalid ? 'Invalid quantity' : null,
          ),
          keyboardType: TextInputType.number,
        );
      },
    );
  }
}

class PriceInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBuyFormBloc, FormStateModel>(
      buildWhen: (previous, current) => previous.price != current.price,
      builder: (context, state) {
        return TextField(
          onChanged: (value) =>
              context.read<OrderBuyFormBloc>().add(PriceChanged(value)),
          decoration: InputDecoration(
            labelText: 'Price',
            // errorText: state.price.invalid ? 'Invalid price' : null,
          ),
          keyboardType: TextInputType.number,
        );
      },
    );
  }
}

class SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBuyFormBloc, FormStateModel>(
      buildWhen: (previous, current) =>
          previous.submissionStatus != current.submissionStatus,
      builder: (context, state) {
        return state.submissionStatus.isInProgress
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  print("safd");
                },
                child: Text('Submit'),
              );
      },
    );
  }
}
