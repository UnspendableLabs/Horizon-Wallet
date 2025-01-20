import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import "./login_form/login_form_view.dart";
import "./login_form/login_form_bloc.dart";

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : whiteLightTheme;
    return BlocProvider<LoginFormBloc>(
        create: (context) => LoginFormBloc(),
        child: Scaffold(
            backgroundColor: scaffoldBackgroundColor,
            body: Center(
              child: Container(
                child: SizedBox(
                  height: 400,
                  width: 300,
                  child: LoginForm(),
                ),
              ),
            )));
  }
}
