import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';

import "./login_form/login_form_view.dart";
import "./login_form/login_form_bloc.dart";

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginFormBloc>(
        create: (context) => LoginFormBloc(
              importedAddressRepository: GetIt.I<ImportedAddressRepository>(),
              importedAddressService: GetIt.I<ImportedAddressService>(),
              walletRepository: GetIt.I<WalletRepository>(),
              encryptionService: GetIt.I<EncryptionService>(),
              inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
            ),
        child: Scaffold(
            body: Center(
          child: SizedBox(
            height: 600,
            width: 400,
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                            .inputDecorationTheme
                            .border
                            ?.borderSide
                            .color ??
                        Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                  child: LoginForm(),
                )),
          ),
        )));
  }
}
