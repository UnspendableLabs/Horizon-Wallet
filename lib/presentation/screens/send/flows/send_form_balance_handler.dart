import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';

class SendFormBalanceSuccessHandler extends StatelessWidget {
  final Function(AssetBalanceFormModel) onSuccess;
  const SendFormBalanceSuccessHandler({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetBalanceFormBloc, AssetBalanceFormModel>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess) {
          onSuccess(state);
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}