import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import "./compose_rbf_password_bloc.dart";
import 'package:horizon/presentation/common/colors.dart';

class ComposeRBFPasswordForm extends StatefulWidget {
  final String? submissionError;

  const ComposeRBFPasswordForm({Key? key, this.submissionError})
      : super(key: key);

  @override
  State<ComposeRBFPasswordForm> createState() => _ComposeRBFPasswordForm();
}

class _ComposeRBFPasswordForm extends State<ComposeRBFPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeRbfPasswordBloc, FormStateModel>(
        listener: (context, state) {
      if (_passwordController.text != state.password.value) {
        _passwordController.text = state.password.value;
      }
    }, builder: (context, state) {
      return Form(
          key: _formKey,
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => context
                        .read<ComposeRbfPasswordBloc>()
                        .add(PasswordChanged(password: value)),
                    enabled: !state.submissionStatus.isInProgressOrSuccess,
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: !state.password.isPure &&
                              state.password.error ==
                                  PasswordValidationError.required
                          ? 'Password is required'
                          : null,
                    ),
                  ),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SelectableText(state.errorMessage!,
                          style: const TextStyle(color: redErrorText)),
                    ),
                  const HorizonUI.HorizonDivider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HorizonUI.HorizonCancelButton(
                        onPressed: () {},
                        buttonText: 'BACK',
                      ),
                      HorizonUI.HorizonContinueButton(
                        loading: state.submissionStatus.isInProgressOrSuccess,
                        onPressed: state.submissionStatus.isInProgressOrSuccess
                            ? () {}
                            : () {
                                context.read<ComposeRbfPasswordBloc>().add(
                                    FormSubmitted());

                                // widget.onSubmit(_passwordController.text, _formKey);
                              },
                        buttonText: 'SIGN AND BROADCAST',
                      ),
                    ],
                  ),
                ],
              )));
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
