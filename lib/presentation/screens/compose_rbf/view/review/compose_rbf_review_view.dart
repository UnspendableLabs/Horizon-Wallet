import 'package:flutter/material.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

import 'package:horizon/presentation/screens/compose_rbf/view/form/compose_rbf_form_bloc.dart'
    as rbfForm;

import 'package:flutter_bloc/flutter_bloc.dart';
import "../password/compose_rbf_password_bloc.dart";
import 'package:formz/formz.dart';

class ComposeRBFReview extends StatelessWidget {
  final bool passwordRequired;
  final rbfForm.RBFData rbfData;
  final MakeRBFResponse makeRBFResponse;
  final void Function() onContinue;
  final void Function() onBack;
  final void Function() onSuccess;

  const ComposeRBFReview(
      {required this.rbfData,
      required this.makeRBFResponse,
      required this.onBack,
      required this.onContinue,
      required this.onSuccess,
      required this.passwordRequired,
      super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeRbfPasswordBloc, FormStateModel>(
        listener: (context, state) {
      if (state.submissionStatus.isSuccess) {
        onSuccess();
      }
    }, builder: (context, state) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Replacing:',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Row(
            children: [
              Text(
                rbfData.tx.txid,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            'Fee:',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Row(
            children: [
              Text(
                "${rbfData.tx.fee} sats/vbyte",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
              ),
              const SizedBox(width: 8.0),
              Text(
                "${makeRBFResponse.fee} sats/vbyte",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.green),
              ),
            ],
          ),
          const HorizonUI.HorizonDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HorizonUI.HorizonCancelButton(
                onPressed: () => onBack(),
                buttonText: 'BACK',
              ),
              HorizonUI.HorizonContinueButton(
                onPressed: () => onContinue(),
                buttonText: passwordRequired ? 'CONTINUE' : 'SUBMIT',
              ),
            ],
          ),
        ]),
      );
    });
  }
}
