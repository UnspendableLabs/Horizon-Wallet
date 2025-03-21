import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:lottie/lottie.dart';
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

  Widget buildAnimationAsset() {
    final Config config = GetIt.I<Config>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (config.isWebExtension) {
      final appBarAsset =
          isDarkMode ? 'app-bar-H-dark-mode.png' : 'app-bar-H-light-mode.png';
      return Image.asset(
        'assets/$appBarAsset',
        fit: BoxFit.contain,
      );
    }
    final animationAsset = isDarkMode
        ? 'logo_animation-gradient-dark.json'
        : 'logo_animation-gradient-light.json';
    return Lottie.asset(
      kDebugMode ? animationAsset : 'assets/$animationAsset',
      fit: BoxFit.contain,
    );
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
                Center(
                  child: SizedBox(
                    width: 109,
                    height: 116,
                    child: buildAnimationAsset(),
                  ),
                ),
                HorizonTextField(
                  enabled: !state.status.isInProgressOrSuccess,
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                  onChanged: (value) => context
                      .read<b.LoginFormBloc>()
                      .add(b.PasswordChanged(value)),
                  onSubmitted: (_) {
                    context.read<b.LoginFormBloc>().add(b.FormSubmitted());
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                SizedBox(
                    height: 50,
                    child: HorizonOutlinedButton(
                        onPressed: () => context
                            .read<b.LoginFormBloc>()
                            .add(b.FormSubmitted()),
                        buttonText: "Unlock"))
              ]));
    });
  }
}
