import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import "package:horizon/presentation/forms/base/base_form_state.dart";
import "package:horizon/presentation/forms/base/view/base_form_view.dart";
import "package:horizon/presentation/forms/base/base_form_event.dart";
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transactions/multi_address_balance_dropdown.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
// TODO: not sure if this should live here
import 'package:horizon/presentation/common/transactions/token_name_field.dart';
import 'package:horizon/presentation/common/transactions/gradient_quantity_input.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

import 'package:flow_builder/flow_builder.dart';

import "./loader/loader_bloc.dart";
import "./form/form_bloc.dart";
import "./form/form_state.dart";
import "./form/form_event.dart";

// TODO: do something with transaction error;
import 'package:horizon/presentation/common/transactions/transaction_fee_selection.dart';

import "generic.dart";

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
      create: (context) => SendAssetFormLoaderBloc(
        loader: SendAssetFormLoader(
          balanceRepository: GetIt.I<BalanceRepository>(),
          feeEstimatesRepository: GetIt.I<FeeEstimatesRespository>(),
        ),
      )..load(SendAssetFormLoaderArgs(
          assetName: assetName,
          addresses: addresses,
        )),
      child: const SendAssetWizard(),
    );
  }
}

class SendAssetWizard extends StatelessWidget {
  const SendAssetWizard({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendAssetFormLoaderBloc,
            BaseFormState<SendAssetFormLoaderData>>(
        listener: (context, state) {},
        builder: (context, state) {
          return FormLayout(
              child: switch (state) {
            Loading() => const Center(child: CircularProgressIndicator()),
            Success(value: var data) => BlocProvider(
                create: (context) => SendAssetFormBloc(
                    initialAddressBalanceValue:
                        data.multiAddressBalance.entries.first),
                child: TransactionFlowView<int>(
                  formView: FormView(
                    title: "Send asset",
                    widthFactor: .33,
                    footer: BlocBuilder<SendAssetFormBloc, FormModel>(
                        builder: (context, state) {
                      bool isSmallScreen =
                          MediaQuery.of(context).size.width < 500;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 30, horizontal: isSmallScreen ? 20 : 40),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 64,
                                child: HorizonOutlinedButton(
                                    isTransparent: false,
                                    onPressed: () {
                                      if (state.isValid) {
                                        context
                                            .flow<TransactionFlowModel<int>>()
                                            .update((_) => TransactionFlowModel(
                                                formData: 4));
                                      }
                                    },
                                    buttonText: "Review Transaction"),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    body: SendAssetFormBody(
                      multiAddressBalance: data.multiAddressBalance,
                      feeEstimates: data.feeEstimates,
                    ),
                  ),
                ),
              ),
            _ => Text(state.toString())
          });
        });
  }
}

class SendAssetFormBody extends StatelessWidget {
  final MultiAddressBalance multiAddressBalance;
  final FeeEstimates feeEstimates;

  final _destinationController = TextEditingController();
  final _quantityController = TextEditingController();

  SendAssetFormBody(
      {required this.multiAddressBalance,
      required this.feeEstimates,
      super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendAssetFormBloc, FormModel>(
        listener: (context, state) {
      _destinationController.value = _destinationController.value.copyWith(
        text: state.destinationInput.value,
        selection: TextSelection.collapsed(
            offset: state.destinationInput.value.length),
      );

      _quantityController.value = _quantityController.value.copyWith(
        text: state.quantityInput.value,
        selection:
            TextSelection.collapsed(offset: state.quantityInput.value.length),
      );
    }, builder: (context, state) {
      return Form(
          child: Column(
        children: [
          MultiAddressBalanceDropdown(
            loading: false,
            balances: multiAddressBalance,
            onChanged: (value) {
              context
                  .read<SendAssetFormBloc>()
                  .add(AddressBalanceInputChanged(value!));
            },
            selectedValue: state.addressBalanceInput.value,
          ),
          const SizedBox(height: 10),
          HorizonTextField(
            controller: _destinationController,
            label: 'Destination Address',
            onChanged: (value) {
              context
                  .read<SendAssetFormBloc>()
                  .add(DestinationInputChanged(value));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a destination address';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TokenNameField(
            loading: false,
            balance: multiAddressBalance,
            selectedBalanceEntry: state.addressBalanceInput.value,
          ),
          const SizedBox(height: 10),
          GradientQuantityInput(
            enabled: true,
            showMaxButton: true,
            balance: multiAddressBalance,
            selectedBalanceEntry: state.addressBalanceInput.value,
            controller: _quantityController,
            onChanged: (value) {
              context
                  .read<SendAssetFormBloc>()
                  .add(QuantityInputChanged(value));
            },
            validator: (value) {
              if ( state.quantityInput.isPure  )  {
                return null;
              }
              return switch (state.quantityInput.error) {
                QuantityInputError.required => 'Value is required',
                QuantityInputError.exceedsMax => 'Value exceeds max',
                QuantityInputError.invalid => 'Invalid',
                _ => null
              };
            },
          ),
          const SizedBox(height: 10),
          // TODO: think through how to make this mandatory
          TransactionFeeSelection(
              feeEstimates: feeEstimates,
              selectedFeeOption: state.feeOptionInput.value,
              onFeeOptionSelected: (value) {
                context.read<SendAssetFormBloc>().add(FeeOptionChanged(value));
              })
        ],
      ));
    });
  }
}
