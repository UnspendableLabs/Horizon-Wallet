import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/repositories/fee_estimates_repository.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transactions/transaction_fee_selection.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';
import "./bloc/asset_attach_form_bloc.dart";
import 'package:horizon/presentation/common/remote_data_builder.dart';

class AssetAttachFormActions {
  final Function(String value) onAttachQuantityChanged;
  final Function(FeeOption value) onFeeOptionSelected;
  final VoidCallback onSubmitClicked;
  final VoidCallback onMaxClicked;

  const AssetAttachFormActions(
      {required this.onAttachQuantityChanged,
      required this.onFeeOptionSelected,
      required this.onSubmitClicked,
      required this.onMaxClicked});
}

class AssetAttachFormProvider extends StatelessWidget {
  final String asset;
  final int quantity;
  final String quantityNormalized;
  final String? description;
  final bool divisible;
  final FeeEstimatesRespository _feeEstimatesRepository;

  final Widget Function(
      AssetAttachFormActions actions, AssetAttachFormModel state) child;

  AssetAttachFormProvider({
    super.key,
    required this.child,
    required this.asset,
    required this.quantity,
    required this.quantityNormalized,
    required this.description,
    required this.divisible,
    FeeEstimatesRespository? feeEstimatesRepository,
  }) : _feeEstimatesRepository =
            feeEstimatesRepository ?? GetIt.I<FeeEstimatesRespository>();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return RemoteDataTaskEitherBuilder<String, FeeEstimates>(
        task: () => _feeEstimatesRepository.getFeeEstimates(
            httpConfig: session.httpConfig),
        builder: (context, state, refresh) => state.fold(
            onInitial: () => const SizedBox.shrink(),
            onLoading: () => const Center(child: CircularProgressIndicator()),
            onRefreshing: (_) => const Center(
                child: CircularProgressIndicator()), // should not happen
            onSuccess: (feeEstimates) => BlocProvider(
                create: (context) => AssetAttachFormBloc(
                      feeEstimates: feeEstimates,
                      assetName: asset,
                      assetBalance: quantity,
                      assetBalanceNormalized: quantityNormalized,
                      assetDivisibility: divisible,
                    ),
                child: BlocBuilder<AssetAttachFormBloc, AssetAttachFormModel>(
                    builder: (context, state) => child(
                          AssetAttachFormActions(
                            onAttachQuantityChanged: (value) {
                              context.read<AssetAttachFormBloc>().add(
                                    AttachQuantityChanged(value: value),
                                  );
                            },
                            onFeeOptionSelected: (value) {
                              context.read<AssetAttachFormBloc>().add(
                                    FeeOptionChanged(value),
                                  );
                            },
                            onSubmitClicked: () {
                              context.read<AssetAttachFormBloc>().add(
                                    const SubmitClicked(),
                                  );
                            },
                            onMaxClicked: () {
                              context.read<AssetAttachFormBloc>().add(
                                    const MaxQuantityClicked(),
                                  );
                            },
                          ),
                          state,
                        ))),
            onFailure: (error) => Center(
                  child: Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )));
  }
}

class AssetAttachForm extends StatefulWidget {
  final AssetAttachFormModel state;
  final AssetAttachFormActions actions;

  const AssetAttachForm({
    super.key,
    required this.state,
    required this.actions,
  });

  @override
  State<AssetAttachForm> createState() => _AssetAttachFormState();
}

class _AssetAttachFormState extends State<AssetAttachForm> {
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.state.attachQuantityInput.value);

    print("divisible: ${widget.state.assetDivisibility}");
  }

  @override
  void didUpdateWidget(covariant AssetAttachForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // keep the text in sync with bloc updates that originate elsewhere
    final newVal = widget.state.attachQuantityInput.value;
    if (newVal != _quantityController.text) {
      _quantityController.value = _quantityController.value.copyWith(
          text: newVal,
          selection: TextSelection.collapsed(offset: newVal.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appIcons = AppIcons();
    final isDarkMode = theme.brightness == Brightness.dark;
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            commonHeightSizedBox,
            HorizonCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: QuantityInputV2(
                        controller: _quantityController,
                        onChanged: widget.actions.onAttachQuantityChanged,
                        style: const TextStyle(fontSize: 35),
                        divisible: widget.state.assetDivisibility,
                      )),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          appIcons.assetIcon(
                              httpConfig: session.httpConfig,
                              assetName: widget.state.assetName,
                              context: context,
                              width: 24,
                              height: 24),
                          const SizedBox(width: 8),
                          Text(widget.state.assetName,
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                          "${widget.state.assetBalanceNormalized} ${widget.state.assetName}",
                          style: theme.textTheme.labelSmall
                              ?.copyWith(height: 1.2)),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.actions.onMaxClicked();
                        },
                        child: Container(
                          height: 24,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? transparentYellow8
                                : transparentPurple33,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Max',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                color: isDarkMode ? yellow1 : duskGradient2,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            TransactionFeeSelection(
              selectedFeeOption: widget.state.feeOptionInput.value,
              onFeeOptionSelected: (value) {
                widget.actions.onFeeOptionSelected(value);
              },
              feeEstimates: widget.state.feeEstimates,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: HorizonButton(
                  disabled: widget.state.submitDisabled,
                  onPressed: () {
                    if (widget.state.submitDisabled) {
                      return;
                    }
                    widget.actions.onSubmitClicked();
                  },
                  child: TextButtonContent(value: "Sign and Submit")),
            )
          ],
        ),
      ),
    );
  }
}
