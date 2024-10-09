import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/presentation/common/fee_estimation_v2.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";

class ComposeBasePage<B extends ComposeBaseBloc<S>, S extends ComposeStateBase>
    extends StatefulWidget {
  final Address address;
  final List<Widget> Function(S, bool, GlobalKey<FormState>)
      buildInitialFormFields;
  final void Function(FeeOption) onFeeChange;
  final void Function() onInitialCancel;
  final void Function(GlobalKey<FormState>) onInitialSubmit;
  final List<Widget> Function(dynamic, GlobalKey<FormState>)
      buildConfirmationFormFields;
  final void Function() onConfirmationBack;
  final void Function(dynamic, int, GlobalKey<FormState>)
      onConfirmationContinue;
  final void Function(String, GlobalKey<FormState>) onFinalizeSubmit;
  final void Function() onFinalizeCancel;

  final DashboardActivityFeedBloc dashboardActivityFeedBloc;

  const ComposeBasePage({
    super.key,
    required this.address,
    required this.buildInitialFormFields,
    required this.onFeeChange,
    required this.onInitialCancel,
    required this.onInitialSubmit,
    required this.dashboardActivityFeedBloc,
    required this.buildConfirmationFormFields,
    required this.onConfirmationBack,
    required this.onConfirmationContinue,
    required this.onFinalizeSubmit,
    required this.onFinalizeCancel,
  });

  @override
  ComposeBasePageState<B, S> createState() => ComposeBasePageState<B, S>();
}

class ComposeBasePageState<B extends ComposeBaseBloc<S>,
    S extends ComposeStateBase> extends State<ComposeBasePage<B, S>> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, S>(
      listener: (context, state) {
        switch (state.submitState) {
          case SubmitSuccess(transactionHex: var txHash):
            widget.dashboardActivityFeedBloc.add(const Load());
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: txHash));
                  },
                ),
                content: Text(txHash),
                behavior: SnackBarBehavior.floating));
          case _:
            break;
        }
      },
      builder: (context, state) {
        return switch (state.submitState) {
          SubmitInitial(error: var error, loading: var loading) =>
            ComposeBaseInitialPage(
              state: state,
              error: error,
              loading: loading,
              buildInitialFormFields: (state, loading, formKey) =>
                  widget.buildInitialFormFields(state, loading, formKey),
              onFeeChange: widget.onFeeChange,
              onCancel: widget.onInitialCancel,
              onSubmit: (formKey) => widget.onInitialSubmit(formKey),
            ),
          SubmitError(error: var msg) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText('An error occurred: $msg'),
            ),
          SubmitComposingTransaction(
            composeTransaction: var composeTransaction,
            fee: var fee,
            feeRate: var feeRate,
          ) =>
            ComposeBaseConfirmationPage(
              composeTransaction: composeTransaction,
              address: widget.address,
              fee: fee,
              feeRate: feeRate,
              buildConfirmationFormFields: (composeTransaction, formKey) =>
                  widget.buildConfirmationFormFields(
                      composeTransaction, formKey),
              onBack: widget.onConfirmationBack,
              onContinue: (composeTransaction, fee, formKey) => widget
                  .onConfirmationContinue(composeTransaction, fee, formKey),
            ),
          SubmitFinalizing(
            composeTransaction: var composeTransaction,
            fee: var fee,
            error: var error,
            loading: var loading
          ) =>
            ComposeBaseFinalizePage(
              state: state,
              composeTransaction: composeTransaction,
              fee: fee,
              error: error,
              loading: loading,
              onSubmit: (password, formKey) =>
                  widget.onFinalizeSubmit(password, formKey),
              onCancel: widget.onFinalizeCancel,
            ),
          SubmitSuccess() => const SizedBox.shrink(),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

class ComposeBaseInitialPage<S extends ComposeStateBase>
    extends StatefulWidget {
  final S state;
  final String? error;
  final bool loading;
  final List<Widget> Function(S, bool, GlobalKey<FormState>)
      buildInitialFormFields;
  final void Function(FeeOption) onFeeChange;
  final void Function() onCancel;
  final void Function(GlobalKey<FormState>) onSubmit;

  const ComposeBaseInitialPage({
    super.key,
    required this.state,
    required this.error,
    required this.loading,
    required this.buildInitialFormFields,
    required this.onFeeChange,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  ComposeBaseInitialPageState<S> createState() =>
      ComposeBaseInitialPageState<S>();
}

class ComposeBaseInitialPageState<S extends ComposeStateBase>
    extends State<ComposeBaseInitialPage<S>> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ...widget
                .buildInitialFormFields(widget.state, widget.loading, _formKey)
                .map((formWidget) {
              if (formWidget is HorizonUI.HorizonTextFormField) {
                return widget.loading
                    ? formWidget.copyWith(enabled: false)
                    : formWidget;
              } else if (formWidget is HorizonUI.HorizonDropdownMenu<dynamic>) {
                return widget.loading
                    ? formWidget.copyWith(enabled: false)
                    : formWidget;
              } else if (formWidget is FeeSelectionV2) {
                return widget.loading
                    ? formWidget.copyWith(enabled: false)
                    : formWidget;
              }
              return formWidget;
            }),
            const HorizonUI.HorizonDivider(),
            FeeSelectionV2(
              value: widget.state.feeOption,
              feeEstimates: widget.state.feeState.maybeWhen(
                success: (feeEstimates) =>
                    FeeEstimateSuccess(feeEstimates: feeEstimates),
                orElse: () => FeeEstimateLoading(),
              ),
              onSelected: widget.onFeeChange,
              layout: MediaQuery.of(context).size.width > 768
                  ? FeeSelectionLayout.row
                  : FeeSelectionLayout.column,
              onFieldSubmitted: () {
                widget.onSubmit(_formKey);
              },
              enabled: !widget.loading,
            ),
            if (widget.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SelectableText(
                  widget.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const HorizonUI.HorizonDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HorizonUI.HorizonCancelButton(
                  onPressed: widget.onCancel,
                  buttonText: 'CANCEL',
                ),
                HorizonUI.HorizonContinueButton(
                  loading: widget.loading,
                  onPressed: widget.loading
                      ? () {}
                      : () {
                          widget.onSubmit(_formKey);
                        },
                  buttonText: 'CONTINUE',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ComposeBaseConfirmationPage extends StatefulWidget {
  final dynamic composeTransaction;
  final Address address;
  final int fee;
  final int feeRate;
  final List<Widget> Function(dynamic, GlobalKey<FormState>)
      buildConfirmationFormFields;
  final void Function() onBack;
  final void Function(dynamic, int, GlobalKey<FormState>) onContinue;

  const ComposeBaseConfirmationPage({
    super.key,
    required this.composeTransaction,
    required this.address,
    required this.fee,
    required this.feeRate,
    required this.buildConfirmationFormFields,
    required this.onBack,
    required this.onContinue,
  });

  @override
  ComposeBaseConfirmationPageState createState() =>
      ComposeBaseConfirmationPageState();
}

class ComposeBaseConfirmationPageState
    extends State<ComposeBaseConfirmationPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Please review your transaction details.',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            ...widget.buildConfirmationFormFields(
                widget.composeTransaction, _formKey),
            HorizonUI.HorizonTextFormField(
              label: "Fee",
              controller: TextEditingController(
                text: "${widget.fee} sats (${widget.feeRate} sats/vbyte)",
              ),
              enabled: false,
            ),
            const HorizonUI.HorizonDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HorizonUI.HorizonCancelButton(
                  onPressed: () => widget.onBack(),
                  buttonText: 'BACK',
                ),
                HorizonUI.HorizonContinueButton(
                  onPressed: () => widget.onContinue(
                      widget.composeTransaction, widget.fee, _formKey),
                  buttonText: 'CONTINUE',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ComposeBaseFinalizePage<S extends ComposeStateBase>
    extends StatefulWidget {
  final S state;
  final dynamic composeTransaction;
  final int fee;
  final String? error;
  final bool loading;
  final void Function(String, GlobalKey<FormState>) onSubmit;
  final void Function() onCancel;

  const ComposeBaseFinalizePage({
    super.key,
    required this.state,
    required this.composeTransaction,
    required this.fee,
    required this.error,
    required this.loading,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  ComposeBaseFinalizePageState<S> createState() =>
      ComposeBaseFinalizePageState<S>();
}

class ComposeBaseFinalizePageState<S extends ComposeStateBase>
    extends State<ComposeBaseFinalizePage<S>> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            HorizonUI.HorizonTextFormField(
              enabled: !widget.loading,
              controller: _passwordController,
              label: "Password",
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                widget.onSubmit(value, _formKey);
              },
            ),
            if (widget.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SelectableText(widget.error!,
                    style: const TextStyle(color: redErrorText)),
              ),
            const HorizonUI.HorizonDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HorizonUI.HorizonCancelButton(
                  onPressed: widget.onCancel,
                  buttonText: 'BACK',
                ),
                HorizonUI.HorizonContinueButton(
                  loading: widget.loading,
                  onPressed: widget.loading
                      ? () {}
                      : () {
                          widget.onSubmit(_passwordController.text, _formKey);
                        },
                  buttonText: 'SIGN AND BROADCAST',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
