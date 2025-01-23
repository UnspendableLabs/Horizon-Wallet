import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
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
        create: (context) => LoginFormBloc(
              walletRepository: GetIt.I<WalletRepository>(),
              encryptionService: GetIt.I<EncryptionService>(),
              inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
            ),
        child: Scaffold(
            backgroundColor: scaffoldBackgroundColor,
            body: Center(
              child: SizedBox(
                height: 600,
                width: 400,
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: LoginForm(),
                    )),
              ),
            )));
  }
}
