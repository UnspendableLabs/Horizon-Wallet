import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/repositories/fee_estimates_repository.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/presentation/common/transactions/transaction_fee_selection.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/send/bloc/send_compose_form_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';
import 'package:horizon/presentation/screens/send/forms/send_entry_form.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

class SendComposeFormProvider extends StatelessWidget {
  final List<MultiAddressBalance> balances;
  final List<SendEntryFormModel> initialEntries;
  final FeeEstimatesRespository _feeEstimatesRepository;
  final String sourceAddress;

  final Widget Function(
      SendComposeFormActions actions, SendComposeFormModel state) child;

  SendComposeFormProvider({
    super.key,
    required this.balances,
    required this.initialEntries,
    required this.sourceAddress,
    required this.child,
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
        onSuccess: (feeEstimates) {
          return BlocProvider(
            create: (context) => SendComposeFormBloc(
              initialBalances: balances,
              initialEntries: initialEntries,
              feeEstimates: feeEstimates,
              sourceAddress: sourceAddress,
              httpConfig: session.httpConfig,
            ),
            child: BlocBuilder<SendComposeFormBloc, SendComposeFormModel>(
              builder: (context, state) {
                return child(
                  SendComposeFormActions(
                    onFeeOptionSelected: (value) {
                      context.read<SendComposeFormBloc>().add(
                            FeeOptionChanged(value),
                          );
                    },
                    onSubmitClicked: () {
                      context.read<SendComposeFormBloc>().add(
                            const SubmitClicked(),
                          );
                    },
                    onEntryFormChanged: (index, value) {
                      context.read<SendComposeFormBloc>().add(
                            UpdateEntry(index, value),
                          );
                    },
                    onRemoveEntry: (index) {
                      context.read<SendComposeFormBloc>().add(
                            RemoveEntry(index),
                          );
                    },
                    onAddEntry: () {
                      context.read<SendComposeFormBloc>().add(AddEntry());
                    },
                  ),
                  state,
                );
              },
            ),
          );
        },
        onFailure: (error) => const SizedBox.shrink(),
      ),
    );
  }
}

class SendComposeFormActions {
  final Function(FeeOption value) onFeeOptionSelected;
  final VoidCallback onSubmitClicked;
  final Function(int index, SendEntryFormModel value) onEntryFormChanged;
  final Function(int index) onRemoveEntry;
  final Function() onAddEntry;

  const SendComposeFormActions({
    required this.onFeeOptionSelected,
    required this.onSubmitClicked,
    required this.onEntryFormChanged,
    required this.onRemoveEntry,
    required this.onAddEntry,
  });
}

class SendComposeSuccessHandler extends StatelessWidget {
  final Function(ComposeResponse value) onComposeResponse;
  const SendComposeSuccessHandler({super.key, required this.onComposeResponse});

  @override
  Widget build(context) {
    return BlocListener<SendComposeFormBloc, SendComposeFormModel>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess && state.composeResponse != null) {
          onComposeResponse(state.composeResponse!);
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}

class SendComposeForm extends StatefulWidget {
  final SendComposeFormActions actions;
  final SendComposeFormModel state;
  final bool mpmaMode;
  final bool disableBalanceSelector;
  const SendComposeForm(
      {super.key,
      required this.actions,
      required this.state,
      this.mpmaMode = false,
      this.disableBalanceSelector = false});

  @override
  State<SendComposeForm> createState() => _SendComposeFormState();
}

class _SendComposeFormState extends State<SendComposeForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ...widget.state.sendEntries.asMap().entries.map((entry) {
          final index = entry.key;
          return Column(
            children: [
              if (index > 0) ...[
                commonHeightSizedBox,
                HorizonButton(
                  variant: ButtonVariant.purple,
                  height: 32,
                  icon: AppIcons.closeIcon(
                      context: context, width: 24, height: 24),
                  onPressed: () {
                    widget.actions.onRemoveEntry(index);
                  },
                  child: TextButtonContent(
                      value: 'Close this entry',
                      style: theme.textTheme.bodySmall),
                ),
                commonHeightSizedBox,
              ],
              SendEntryFormProvider(
                balances: widget.state.balances,
                initialBalance: entry.value.balanceSelectorInput.value,
                onFormChanged: (form) {
                  widget.actions.onEntryFormChanged(index, form);
                },
                child: (actions, state) => SendEntryForm(
                  state: state,
                  actions: actions,
                  balances: widget.state.balances,
                  disableBalanceSelector: widget.disableBalanceSelector,
                ),
              ),
              if (index != widget.state.sendEntries.length - 1)
                const Divider(
                  height: 20,
                  thickness: 1,
                  color: transparentWhite8,
                ),
              commonHeightSizedBox
            ],
          );
        }),
        if (widget.mpmaMode)
        SizedBox(
          height: 32,
          child: IntrinsicWidth(
            child: HorizonButton(
                variant: ButtonVariant.purple,
                child: WidgetButtonContent(
                    value: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppIcons.plusIcon(
                        context: context,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 4),
                      Text("Add Another Entry",
                          style: theme.textTheme.titleSmall),
                    ],
                  ),
                )),
                onPressed: widget.actions.onAddEntry),
          ),
        ),
        const SizedBox(height: 24),
        TransactionFeeSelection(
            feeEstimates: widget.state.feeEstimates,
            selectedFeeOption: widget.state.feeOptionInput.value,
            onFeeOptionSelected: widget.actions.onFeeOptionSelected),
        if(widget.state.submissionStatus.isFailure && widget.state.error != null)
        ...[
          const SizedBox(height: 10),
          Text(widget.state.error!, style: theme.textTheme.bodySmall?.copyWith(color: redErrorText),),
        ],
        const SizedBox(height: 24),
        HorizonButton(
            child: TextButtonContent(value: "Review Send"),
            disabled: !widget.state.isValid,
            isLoading: widget.state.submissionStatus ==
                FormzSubmissionStatus.inProgress,
            onPressed: widget.actions.onSubmitClicked),
        const SizedBox(height: 24),
      ],
    );
  }
}
