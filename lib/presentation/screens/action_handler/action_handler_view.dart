import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/action.dart' as URLAction;
import 'package:horizon/domain/entities/extension_rpc.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/main.dart';
import 'package:horizon/presentation/screens/login/login_view.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:web/web.dart' as web;
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/presentation/forms/get_addresses/view/get_addresses_form.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_bloc.dart';

class ActionHandlerShell extends StatelessWidget {
  final Widget child;
  const ActionHandlerShell({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Theme.of(context).dialogTheme.backgroundColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width > 500 ? 500 : double.infinity,
        ),
        child: SingleChildScrollView(child: child),
      ),
    ));
  }
}

class GetAddressesPage extends StatelessWidget {
  final URLAction.RPCGetAddressesAction action;

  const GetAddressesPage({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionStateCubit, SessionState>(
      builder: (context, state) {
        return state.maybeWhen(
          success: (session) => Scaffold(
            body: Center(
              child: BlocProvider(
                create: (_) => GetAddressesBloc(
                  httpConfig: session.httpConfig,
                  passwordRequired: GetIt.I<SettingsRepository>()
                      .requirePasswordForCryptoOperations,
                  inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
                  encryptionService: GetIt.I<EncryptionService>(),
                  importedAddressService: GetIt.I<ImportedAddressService>(),
                  addressService: GetIt.I<AddressService>(),
                  accounts: session.accounts
                      .where((account) => account.isBip32)
                      .toList(),
                ),
                child: GetAddressesForm(
                  passwordRequired: GetIt.I<SettingsRepository>()
                      .requirePasswordForCryptoOperations,
                  accounts: session.accounts
                      .where((account) => account.isBip32)
                      .toList(),
                  dappUrl: action.origin,
                  dappTitle: action.title,
                  dappFavicon: action.favicon,
                  onCancel: () {
                    GetIt.I<RPCCancelCallback>()();
                  },
                  onSuccess: (addresses) {
                    GetIt.I<RPCGetAddressesSuccessCallback>()(
                        RPCGetAddressesSuccessCallbackArgs(
                            tabId: action.tabId,
                            requestId: action.requestId,
                            addresses: addresses));
                    if (GetIt.I<Config>().isWebExtension) {
                      web.window.close();
                    }
                  },
                ),
              ),
            ),
          ),
          loggedOut: () => const LoginView(),
          orElse: () => const LoadingScreen(),
        );
      },
    );
  }
}
