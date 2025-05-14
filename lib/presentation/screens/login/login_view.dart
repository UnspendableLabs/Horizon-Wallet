import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/presentation/common/theme_toggle.dart';

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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Container(
                padding: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height,
                child: const Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: HorizonThemeToggle(),
                    ),
                    Align(alignment: Alignment.center, child: LoginForm()),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
