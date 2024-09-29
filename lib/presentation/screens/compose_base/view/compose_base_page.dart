import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_cancel_button.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_continue_button.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_text_field.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";

class ComposeBasePage<B extends ComposeBaseBloc<S>, S extends ComposeStateBase>
    extends StatefulWidget {
  final Address address;
  final Widget Function(BuildContext, S, String?, bool) buildInitialForm;
  final Widget Function(BuildContext, dynamic, int, bool, String?)
      buildFinalizingForm;
  final List<Widget> Function(dynamic) buildConfirmationFormFields;
  final void Function(BuildContext) onConfirmationBack;
  final void Function(BuildContext, dynamic, int) onConfirmationContinue;

  final DashboardActivityFeedBloc dashboardActivityFeedBloc;

  const ComposeBasePage({
    super.key,
    required this.address,
    required this.buildInitialForm,
    required this.buildFinalizingForm,
    required this.dashboardActivityFeedBloc,
    required this.buildConfirmationFormFields,
    required this.onConfirmationBack,
    required this.onConfirmationContinue,
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
              behavior: SnackBarBehavior.floating,
            ));
          case _:
            break;
        }
      },
      builder: (context, state) {
        return switch (state.submitState) {
          SubmitInitial(error: var error, loading: var loading) =>
            widget.buildInitialForm(context, state, error, loading),
          SubmitError(error: var msg) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText('An error occurred: $msg'),
            ),
          SubmitComposingTransaction(
            composeTransaction: var composeTransaction,
            fee: var fee,
            feeRate: var feeRate,
            virtualSize: var virtualSize,
          ) =>
            ComposeBaseConfirmationPage(
              composeTransaction: composeTransaction,
              address: widget.address,
              fee: fee,
              feeRate: feeRate,
              virtualSize: virtualSize,
              buildConfirmationFormFields: widget.buildConfirmationFormFields,
              onBack: widget.onConfirmationBack,
              onContinue: (context, composeTransaction, fee) => widget
                  .onConfirmationContinue(context, composeTransaction, fee),
            ),
          SubmitFinalizing(
            composeTransaction: var composeTransaction,
            fee: var fee,
            loading: var loading,
            error: var error,
          ) =>
            widget.buildFinalizingForm(
                context, composeTransaction, fee, loading, error),
          SubmitSuccess() => const SizedBox.shrink(),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

class ComposeBaseConfirmationPage extends StatefulWidget {
  final dynamic composeTransaction;
  final Address address;
  final int fee;
  final int feeRate;
  final int virtualSize;
  final List<Widget> Function(dynamic) buildConfirmationFormFields;
  final void Function(BuildContext) onBack;
  final void Function(BuildContext, dynamic, int) onContinue;

  const ComposeBaseConfirmationPage({
    super.key,
    required this.composeTransaction,
    required this.address,
    required this.fee,
    required this.feeRate,
    required this.virtualSize,
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
            ...widget.buildConfirmationFormFields(widget.composeTransaction),
            HorizonTextFormField(
              label: "Fee",
              controller: TextEditingController(
                text: "${widget.fee} sats (${widget.feeRate} sats/vbyte)",
              ),
              enabled: false,
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HorizonCancelButton(
                  onPressed: () => widget.onBack(context),
                  buttonText: 'BACK',
                ),
                HorizonContinueButton(
                  onPressed: () => widget.onContinue(
                      context, widget.composeTransaction, widget.fee),
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