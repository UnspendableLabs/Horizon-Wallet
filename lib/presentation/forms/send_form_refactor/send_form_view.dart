import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import "./send_form_bloc.dart";
import "package:horizon/presentation/forms/base/base_form_state.dart";
import "package:horizon/presentation/forms/base/view/base_form_view.dart";
import "package:horizon/presentation/forms/base/base_form_event.dart";
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transactions/multi_address_balance_dropdown.dart';

class SendFormProvider extends StatelessWidget {
  final String assetName;
  final List<String> addresses;

  const SendFormProvider({
    super.key,
    required this.assetName,
    required this.addresses,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SendAssetFormBloc(
        loader: SendAssetFormLoader(
          balanceRepository: GetIt.I<BalanceRepository>(),
          feeEstimatesRepository: GetIt.I<FeeEstimatesRespository>(),
        ),
      )..load(SendAssetFormLoaderArgs(
          assetName: assetName,
          addresses: addresses,
        )),
      child: const SendAssetFormView(),
    );
  }
}

class SendAssetFormView extends StatelessWidget {
  const SendAssetFormView({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendAssetFormBloc,
            BaseFormState<SendAssetFormLoaderData>>(
        listener: (context, state) {},
        builder: (context, state) {
          return FormLayout(
              title: "Send asset",
              widthFactor: .33,
              body: switch (state) {
                Loading() => const Center(child: CircularProgressIndicator()),
                Success(value: var data) => Form(
                      child: Column(
                    children: [
                      MultiAddressBalanceDropdown(
                        loading: false,
                        balances: data.multiAddressBalance,
                        onChanged: (value) {
                          print(value);
                          // setState(() {
                          //   selectedBalanceEntry = value;
                          //   quantityController.clear();
                          // });
                        },
                        selectedValue: data.multiAddressBalance.entries.first,
                      ),
                    ],
                  )),
                _ => Text(state.toString())
              });
        });
  }
}
