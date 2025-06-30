import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/action.dart' as URLAction;
import 'package:horizon/domain/entities/extension_rpc.dart';
import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/main.dart';
import 'package:horizon/presentation/common/themes.dart';
import 'package:horizon/presentation/screens/login/login_view.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:web/web.dart' as web;
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/presentation/forms/get_addresses/view/get_addresses_form.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/presentation/forms/get_addresses/bloc/get_addresses_bloc.dart';

class ActionHandlerShell extends StatelessWidget {
  Widget child;
  ActionHandlerShell({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Theme.of(context).dialogTheme.backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width > 500 ? 500 : double.infinity,
          ),
          child: child,
        ),
      ),
    ));
  }
}

class ActionHandlerApp extends StatelessWidget {
  final ActionRepository actionRepository;
  ActionHandlerApp({
    super.key,
  }) : actionRepository = GetIt.I<ActionRepository>();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final actionParam = state.uri.queryParameters['action'];
            if (actionParam == null) {
              return ActionHandlerShell(
                  child: const Center(child: Text("No action specified.")));
            }

            final actionEither = actionRepository.fromString(actionParam);

            return actionEither.fold(
              (l) => ActionHandlerShell(
                  child: Center(child: Text("Invalid action: $l"))),
              (action) {
                switch (action.runtimeType) {
                  case URLAction.RPCGetAddressesAction:
                    return ActionHandlerShell(
                        child: GetAddressesPage(
                            action: action as URLAction.RPCGetAddressesAction));
                  // TODO: Add other action handlers here
                  default:
                    return ActionHandlerShell(
                        child: Center(child: Text("Unsupported action type")));
                }
              },
            );
          },
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionStateCubit>(
          create: (context) => SessionStateCubit(
              kvService: GetIt.I<SecureKVService>(),
              encryptionService: GetIt.I<EncryptionService>(),
              inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
              cacheProvider: GetIt.I<CacheProvider>(),
              analyticsService: GetIt.I<AnalyticsService>())
            ..initialize(),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(GetIt.I<CacheProvider>()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: themeMode,
            routerConfig: router,
          );
        },
      ),
    );
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
                  accounts: session.accounts,
                ),
                child: GetAddressesForm(
                  passwordRequired: GetIt.I<SettingsRepository>()
                      .requirePasswordForCryptoOperations,
                  accounts: session.accounts,
                  onCancel: () {
                    if (GetIt.I<Config>().isWebExtension) {
                      web.window.close();
                    }
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
