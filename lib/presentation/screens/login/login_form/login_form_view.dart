import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import "./login_form_bloc.dart" as b;

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<b.LoginFormBloc, b.FormState>(
        listener: (context, state) {
      if (state.status.isSuccess) {
        final session = context.read<SessionStateCubit>();
        session.initialize();
      }
      if (state.status.isFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Password'),
          ),
        );
      }
    }, builder: (context, state) {
      return Form(
          key: _key,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'assets/logo-blue-3d.png',
                  height: 160,
                  width: 160,
                ),
                TextField(
                  onChanged: (value) => context
                      .read<b.LoginFormBloc>()
                      .add(b.PasswordChanged(value)),
                  onSubmitted: (_) {
                    context.read<b.LoginFormBloc>().add(b.FormSubmitted());
                  },
                  enabled: !state.status.isInProgressOrSuccess,
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: !state.password.isPure &&
                            state.password.error ==
                                b.PasswordValidationError.empty
                        ? 'Password is required'
                        : null,
                  ),
                ),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                          40), // fromHeight use double.infinity as width and 40 is the height
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                    ),
                    onPressed: () =>
                        context.read<b.LoginFormBloc>().add(b.FormSubmitted()),
                    child: const Text("UNLOCK"))
              ]));
    });
  }
}
