import 'dart:async';
import 'package:horizon/domain/entities/account_v2.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:horizon/domain/entities/action.dart' as URLAction;
import 'package:horizon/domain/entities/extension_rpc.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/domain/entities/action.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'package:dio/dio.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/common/fn.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/version_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/domain/services/database_manager_service.dart';
import 'package:horizon/presentation/common/dialog_helper.dart';

import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/inactivity_monitor/inactivity_monitor_bloc.dart';
import 'package:horizon/presentation/inactivity_monitor/inactivity_monitor_view.dart';
import 'package:horizon/presentation/screens/send/view/send_view.dart';

import 'package:horizon/presentation/screens/swap/view/swap_view.dart';
import 'package:horizon/presentation/screens/dashboard/view/portfolio_view.dart';
import 'package:horizon/presentation/screens/login/login_view.dart';
import 'package:horizon/presentation/screens/accounts/accounts_screen.dart';
import 'package:horizon/presentation/screens/accounts/detail/accounts_detail_view.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_page.dart';
import 'package:horizon/presentation/screens/onboarding_create/view/onboarding_create_page.dart';
import 'package:horizon/presentation/screens/onboarding_import/view/onboarding_import_page.dart';
import 'package:horizon/presentation/screens/privacy_policy.dart';
import 'package:horizon/presentation/screens/settings/settings_view.dart';
import 'package:horizon/presentation/screens/tools/tools_view.dart';
import 'package:horizon/presentation/screens/settings/sub_settings_view.dart';
import 'package:horizon/presentation/screens/tos.dart';
import 'package:horizon/presentation/screens/activity/activity_view.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/shell/app_shell.dart';
import 'package:horizon/presentation/version_cubit.dart';
import 'package:horizon/setup.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:web/web.dart' as web;
import 'package:horizon/presentation/common/themes.dart';
import 'package:horizon/presentation/screens/action_handler/action_handler_view.dart';

import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/view/sign_psbt_form.dart';

import 'package:horizon/presentation/forms/sign_message/bloc/sign_message_bloc.dart';
import 'package:horizon/presentation/forms/sign_message/view/sign_message_form.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Always return the child directly, skipping any animation
    return child;
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({this.from, super.key});
  final String? from;

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0x001e1e38),
      );
}

class BottomTabNavigation extends StatelessWidget {
  final StatefulNavigationShell nav;

  const BottomTabNavigation({super.key, required this.nav});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted = theme.textButtonTheme.style?.foregroundColor?.resolve({}) ??
        Colors.grey;

    Color iconColor(bool selected) => selected ? onSurface : muted;
    final currentIndex = nav.currentIndex;

    Widget tab({
      required int index,
      required Widget icon,
      required String label,
    }) {
      return GestureDetector(
        onTap: () {
          // Re-tap current tab -> pop that branch to its initial location
          nav.goBranch(index, initialLocation: index == nav.currentIndex);
        },
        child: BottomNavItem(
          selected: currentIndex == index,
          icon: icon,
          label: label,
          isDarkTheme: isDarkTheme,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).dialogTheme.backgroundColor,
        border: Border(
          top: BorderSide(
            color:
                Theme.of(context).inputDecorationTheme.outlineBorder?.color ??
                    Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          tab(
            index: 0,
            icon: AppIcons.pieChartIcon(
              context: context,
              color: iconColor(currentIndex == 0),
            ),
            label: 'Portfolio',
          ),
          tab(
            index: 1,
            icon: Icon(
              Icons.reorder,
              color: iconColor(currentIndex == 1),
              size: 24,
            ),
            // AppIcons.swapIcon(
            //          context: context,
            //          color: iconColor(currentIndex == 1),
            //        ),
            label: 'Activity',
          ),
          tab(
            index: 2,
            icon: AppIcons.wrenchIcon(
              context: context,
              color: iconColor(currentIndex == 2),
            ),
            label: 'Tools',
          ),
          tab(
            index: 3,
            icon: AppIcons.settingsIcon(
              context: context,
              color: iconColor(currentIndex == 3),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final bool selected;
  final Widget icon;
  final String label;
  final bool isDarkTheme;

  const BottomNavItem({
    super.key,
    required this.selected,
    required this.icon,
    required this.label,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 74,
      decoration: BoxDecoration(
        color: selected && !isDarkTheme ? offWhite : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? Theme.of(context).inputDecorationTheme.outlineBorder?.color ??
                  Colors.black.withOpacity(0.1)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected
                    ? Theme.of(context).textTheme.bodyMedium?.color
                    : Theme.of(context)
                            .textButtonTheme
                            .style
                            ?.foregroundColor
                            ?.resolve({}) ??
                        Colors.grey,
              ),
              softWrap: false,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}

// class ScaffoldWithBottomNavigation extends StatelessWidget {
//   final Widget child;
//   final int currentIndex;
//
//   const ScaffoldWithBottomNavigation({
//     super.key,
//     required this.child,
//     required this.currentIndex,
//   });
//
//   static const tabs = [
//     '/dashboard',
//     '/settings',
//   ];
//
//   void _onTabTapped(BuildContext context, int index) {
//     context.go(tabs[index]);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: child,
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: currentIndex,
//         onTap: (index) => _onTabTapped(context, index),
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Dashboard',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }
// }

class AppRouter {
  static GoRouter router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: "/",
      routes: <RouteBase>[
        // if (GetIt.instance<Config>().isDatabaseViewerEnabled)
        GoRoute(
          path: "/db",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: DriftDbViewer(GetIt.instance<DatabaseManager>().database),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/privacy-policy",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const PrivacyPolicy(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/tos",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const TermsOfService(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/onboarding",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const OnboardingScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/onboarding/create",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const OnboardingCreatePageWrapper(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/onboarding/import",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const OnboardingImportPageWrapper(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        GoRoute(
          path: "/login",
          pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const LoginView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) => child),
        ),
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            // Check session state before showing the shell

            return ValueChangeObserver(
              cacheKey: SettingsKeys.inactivityTimeout.toString(),
              defaultValue: 5,
              builder: (context, inactivityTimeout, _) {
                return BlocProvider(
                  key: Key("inactivity-timeout:$inactivityTimeout"),
                  create: (_) {
                    return InactivityMonitorBloc(
                      logger: GetIt.I<Logger>(),
                      kvService: GetIt.I<SecureKVService>(),
                      inactivityTimeout: Duration(minutes: inactivityTimeout),
                    );
                  },
                  child: InactivityMonitorView(
                    onTimeout: () {
                      final session = context.read<SessionStateCubit>();
                      session.onLogout();
                    },
                    child: context.watch<SessionStateCubit>().state.maybeWhen(
                          success: (sessionState) {
                            // Only show the shell if the user is logged in
                            return AppShell(
                              currentRoute: state.matchedLocation,
                              actionRepository: GetIt.I<ActionRepository>(),
                              child: child,
                            );
                          },
                          orElse: () => const LoadingScreen(),
                        ),
                  ),
                );
              },
            );
          },
          routes: [
            GoRoute(
                path: "/rpc/get-addresses",
                builder: (context, state) {
                  final actionRepository = GetIt.I<ActionRepository>();

                  final action = actionRepository.dequeue().getOrThrow();

                  return ActionHandlerShell(
                      child: GetAddressesPage(
                          action: action as URLAction.RPCGetAddressesAction));
                }),
            GoRoute(
                path: "/rpc/sign-psbt",
                builder: (context, state) {
                  final session =
                      context.watch<SessionStateCubit>().state.successOrThrow();

                  final actionRepository = GetIt.I<ActionRepository>();

                  final action = actionRepository.dequeue().getOrThrow()
                      as RPCSignPsbtAction;

                  return BlocProvider(
                      create: (_) => SignPsbtBloc(
                            // TODO: audit this
                            addresses: session.addressIndexSet.list,
                            httpConfig: session.httpConfig,
                            passwordRequired: GetIt.I<SettingsRepository>()
                                .requirePasswordForCryptoOperations,
                            signInputs: action.signInputs,
                            sighashTypes: action.sighashTypes,
                            unsignedPsbt: action.psbt,
                          ),
                      child: ActionHandlerShell(
                          child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: AppIcons.shieldIcon(
                                      context: context,
                                      width: 32,
                                      height: 32,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'SIGN PSBT',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Text(
                                      //   'Requested by horizon.market',
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     color: Colors.grey,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SignPsbtForm(
                              key: Key(action.psbt),
                              passwordRequired: GetIt.I<SettingsRepository>()
                                  .requirePasswordForCryptoOperations,
                              onSuccess: (signedPsbtHex) {
                                final callback =
                                    GetIt.I<RPCSignPsbtSuccessCallback>();

                                callback(RPCSignPsbtSuccessCallbackArgs(
                                    tabId: action.tabId,
                                    requestId: action.requestId,
                                    signedPsbt: signedPsbtHex));

                                if (GetIt.I<Config>().isWebExtension) {
                                  web.window.close();
                                }
                              },
                            ),
                          ],
                        ),
                      )));
                }),
            GoRoute(
                path: "/rpc/sign-message",
                builder: (context, state) {
                  final session =
                      context.watch<SessionStateCubit>().state.successOrThrow();

                  final actionRepository = GetIt.I<ActionRepository>();

                  final action = actionRepository.dequeue().getOrThrow()
                      as RPCSignMessageAction;

                  final address =
                      session.addressIndexSet.getByAddress(action.address);

                  if (address == null) {
                    return ActionHandlerShell(
                        child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: AppIcons.shieldIcon(
                                    context: context,
                                    width: 32,
                                    height: 32,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SIGN MESSAGE',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Text(
                                    //   'Requested by horizon.market',
                                    //   style: TextStyle(
                                    //     fontSize: 14,
                                    //     color: Colors.grey,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                  "${action.address} not found in current account"),
                            ),
                          ),
                        ],
                      ),
                    ));
                  }

                  return BlocProvider(
                      create: (_) => SignMessageBloc(
                            address: address,
                            message: action.message,
                            httpConfig: session.httpConfig,
                            passwordRequired: GetIt.I<SettingsRepository>()
                                .requirePasswordForCryptoOperations,
                          ),
                      child: ActionHandlerShell(
                          child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: AppIcons.shieldIcon(
                                      context: context,
                                      width: 32,
                                      height: 32,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'SIGN MESSAGE',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Text(
                                      //   'Requested by horizon.market',
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     color: Colors.grey,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SignMessageForm(
                              key: Key(action.message),
                              passwordRequired: GetIt.I<SettingsRepository>()
                                  .requirePasswordForCryptoOperations,
                              onSuccess: (signature) {
                                final callback =
                                    GetIt.I<RPCSignMessageSuccessCallback>();

                                callback(RPCSignMessageSuccessCallbackArgs(
                                  address: "",
                                  tabId: action.tabId,
                                  requestId: action.requestId,
                                  signature: signature,
                                  messageHash: action.message,
                                ));

                                if (GetIt.I<Config>().isWebExtension) {
                                  web.window.close();
                                }
                              },
                            ),
                          ],
                        ),
                      )));
                }),
            StatefulShellRoute.indexedStack(
                builder: (BuildContext context, GoRouterState state,
                    StatefulNavigationShell nav) {
                  // Session gating for the tabbed area (like your original shell guarded it)
                  return context.watch<SessionStateCubit>().state.maybeWhen(
                        success: (sessionState) {
                          return AppShell(
                            currentRoute: state.matchedLocation,
                            actionRepository: GetIt.I<ActionRepository>(),
                            child: Scaffold(
                              body: nav, // <- active branch/content
                              bottomNavigationBar:
                                  BottomTabNavigation(nav: nav),
                            ),
                          );
                        },
                        orElse: () => const LoadingScreen(),
                      );
                },
                branches: [
                  StatefulShellBranch(routes: [
                    GoRoute(
                      path: "/",
                      builder: (context, state) {
                        final sessionState = context
                            .watch<SessionStateCubit>()
                            .state
                            .successOrThrow();
                        return Scaffold(
                          key: Key(
                              "portfolio:${sessionState.walletConfig.uuid}"),
                          body: PortfolioView(),
                          // bottomNavigationBar: BottomTabNavigation(
                          //   key: Key("dashboard"),
                          //   currentIndex: 0,
                          // ),

                          // CHAT GPT I NEED HELP WITH A SANE WAY / FLEXIBLE WAY OF ADDING BOTTOM TABS
                        );
                      },
                    )
                  ]),
                  StatefulShellBranch(routes: [
                    GoRoute(
                        path: "/activity",
                        builder: (context, state) {
                          final sessionState = context
                              .watch<SessionStateCubit>()
                              .state
                              .successOrThrow();

                          return Scaffold(
                            body: ActivityView(
                                key: Key(sessionState.walletConfig.uuid),
                                initialAddress:
                                    sessionState.addressIndexSet.list.first),
                            // bottomNavigationBar: BottomTabNavigation(
                            //   key: Key("manage"),
                            //   currentIndex: 1,
                            // ),
                          );
                        })
                  ]),
                  StatefulShellBranch(routes: [
                    GoRoute(
                      path: "/tools",
                      builder: (context, state) {
                        final sessionState = context
                            .watch<SessionStateCubit>()
                            .state
                            .successOrThrow();

                        return Scaffold(
                          body: ToolsView(
                            key: Key("tools:${sessionState.walletConfig.uuid}"),
                          ),
                          // bottomNavigationBar: BottomTabNavigation(
                          //   key: Key("tools"),
                          //   currentIndex: 2,
                          // ),
                        );
                      },
                    )
                  ]),
                  StatefulShellBranch(routes: [
                    GoRoute(
                      path: "/settings",
                      builder: (context, state) => Scaffold(
                        body: SettingsView(),
                        // bottomNavigationBar: const BottomTabNavigation(
                        //   key: Key("settings"),
                        //   currentIndex: 3,
                        // ),
                      ),
                    ),
                  ])
                ]),
            GoRoute(
              path: "/accounts",
              name: "accounts",
              builder: (context, state) {
                return Scaffold(
                    appBar: AppBar(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      elevation: 0,
                      centerTitle: false,
                      leadingWidth: 40,
                      toolbarHeight: 74,
                      title: Padding(
                        padding: const EdgeInsets.only(top: 18.0),
                        child: Text(
                          "Accounts",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 9.0, top: 18.0),
                        child: AppIcons.iconButton(
                            context: context,
                            width: 32,
                            height: 32,
                            icon: AppIcons.backArrowIcon(
                                context: context,
                                width: 24,
                                height: 24,
                                fit: BoxFit.fitHeight),
                            onPressed: () {
                              context.go("/");
                            }),
                      ),
                    ),
                    body: AccountsScreen());
              },
            ),
            GoRoute(
              path: '/accounts/detail',
              builder: (context, state) {
                final account = state.extra as AccountV2; // <-- retrieve it
                return Scaffold(
                    appBar: AppBar(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      elevation: 0,
                      centerTitle: false,
                      leadingWidth: 40,
                      toolbarHeight: 74,
                      title: Padding(
                        padding: const EdgeInsets.only(top: 18.0),
                        child: Text(
                          account.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 9.0, top: 18.0),
                        child: AppIcons.iconButton(
                            context: context,
                            width: 32,
                            height: 32,
                            icon: AppIcons.backArrowIcon(
                                context: context,
                                width: 24,
                                height: 24,
                                fit: BoxFit.fitHeight),
                            onPressed: () {
                              context.go("/accounts");
                            }),
                      ),
                    ),
                    body: AccountDetailView(account: account));
              },
            ),
            GoRoute(
              path: "/settings/:category",
              pageBuilder: (context, state) {
                final category = state.pathParameters['category'] ?? 'security';
                return CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: SubSettingsView(category: category),
                  transitionDuration: const Duration(milliseconds: 250),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(
                            0, 0.03), // 40px = 0.1 of screen height
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: "/atomic-swap",
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: SwapFlowView(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder:
                    (coext, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            ),
            GoRoute(
              path: "/send",
              builder: (context, state) => const SendView(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => ErrorScreen(
            error: state.error,
            onGoHome: () => context.go('/'),
          ),
      redirect: (context, state) {
        if (state.matchedLocation == "/db") {
          return "/db";
        }

        if (state.matchedLocation == "/privacy-policy") {
          return "/privacy-policy";
        }

        if (state.matchedLocation == "/tos") {
          return "/tos";
        }

        final preAuthRoutes = {
          '/login',
          '/onboarding',
          '/onboarding/create',
          '/onboarding/import',
          '/onboarding/import-pk',
        };

        final session = context.read<SessionStateCubit>();

//        final actionParam = state.uri.queryParameters['action'];
        // // print("actionParam: $actionParam");

        // final actionParam =
        //     "signMessage:ext,1423373097,bb542e03-af4e-44ca-b026-44b8a8afeac9,97122496-7d18-11f0-9fc7-2f9733e534f2,tb1q4zepxe42rkhq00l72tzk73seuqw9ydckgynzv5";

        //
        //
        //
        // print("actionParam: $actionParam");

        final actionParam = "getAddresses:ext,0,1";
        // final actionParam =
        //     "signPsbt:ext,1423373097,ddc38fce-13e4-4d70-ba1d-0f5162c54835,70736274ff01009a020000000200000000000000000000000000000000000000000000000000000000000000000000000000ffffffff1e8728d1ea12bfa4bed9fea098e6a06a1f3422bfc5c71afceb94d650b2e829f10000000000ffffffff020000000000000000160014a8b21366aa1dae07bffe52c56f4619e01c523716e803000000000000160014a8b21366aa1dae07bffe52c56f4619e01c5237160000000000010304020000000001011f2202000000000000160014a8b21366aa1dae07bffe52c56f4619e01c52371601030483000000000000,eyJ0YjFxNHplcHhlNDJya2hxMDBsNzJ0ems3M3NldXF3OXlkY2tneW56djUiOlsxXX0=,WzEzMSwxLDJd";
        // //
        final ActionRepository actionRepository =
            GetIt.instance<ActionRepository>();
        if (actionParam != null) {
          actionRepository
              .fromString(actionParam)
              .fold(noop1, (action) => actionRepository.enqueue(action));
        }

        final path = session.state.maybeWhen(
            loggedOut: () => "/login",
            onboarding: (onboarding) {
              return onboarding.when(
                initial: () => "/onboarding",
                create: () => "/onboarding/create",
                import: () => "/onboarding/import",
                importPK: () => "/onboarding/import-pk",
              );
            },
            loading: () {
              // TODO: maybe we change this to peak?

              final action = actionRepository.peek();

              final actionPath = action.fold(
                  () => null,
                  (action) => switch (action) {
                        RPCGetAddressesAction() => "/rpc/get-addresses",
                        RPCSignMessageAction() => "/rpc/sign-message",
                        RPCSignPsbtAction() => "/rpc/sign-psbt",
                        _ => null
                      });

              if (actionPath != null) {
                return actionPath;
              }

              return null;
            },
            success: (data) {
              final action = actionRepository.peek();

              final actionPath = action.fold(
                  () => null,
                  (action) => switch (action) {
                        RPCGetAddressesAction() => "/rpc/get-addresses",
                        RPCSignMessageAction() => "/rpc/sign-message",
                        RPCSignPsbtAction() => "/rpc/sign-psbt",
                        _ => null
                      });

              if (actionPath != null) {
                return actionPath;
              }

              final isPreAuthRoute =
                  preAuthRoutes.contains(state.matchedLocation);

              if (isPreAuthRoute) {
                return "/";
              }

              return null;
              // if (data.redirect) {
              //   return "/";
              // }
            },
            // if the session state is not yet loaded, show a loading screen
            orElse: () => null);

        return path;
      });
}

// Custom error screen widget
class ErrorScreen extends StatelessWidget {
  final Exception? error;
  final VoidCallback onGoHome;

  const ErrorScreen({super.key, this.error, required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('GoRouter Exception: ${error?.toString() ?? 'Unknown error'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onGoHome,
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  final href = web.window.location.href;

  setup();
  DialogHelper.init(_rootNavigatorKey);

  // Catch synchronous errors in Flutter framework
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // TODO: Is this error capture necessary?
    GetIt.I<ErrorService>().captureException(details.exception,
        context: {'runtimeType': details.exception.runtimeType.toString()});
  };

  // Catch uncaught asynchronous errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await initSettings();

    final version = GetIt.I<Config>().version;
    final versionInfo = GetIt.I<VersionRepository>().get();

    versionInfo.match((failure) {
      runApp(MyApp(
        currentVersion: version,
        latestVersion: version,
        warning: VersionServiceUnreachable(),
      ));
    }, (versionInfo) {
      if (version < versionInfo.min) {
        runApp(MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  AppIcons.warningIcon(
                    width: 60.0,
                    height: 60.0,
                    color: red1,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Upgrade Required!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Bold font weight
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                      "Your version ($version) is below the minimum supported version (${versionInfo.min})",
                      style: const TextStyle(
                        fontSize: 18.0, // Standard readable font size
                        color: Colors.black87,
                      )),
                ])),
          ),
        ));
      } else if (version < versionInfo.latest) {
        runApp(MyApp(
          currentVersion: version,
          latestVersion: versionInfo.latest,
          warning: NewVersionAvailable(),
        ));
      } else {
        runApp(MyApp(
          currentVersion: version,
          latestVersion: versionInfo.latest,
        ));
      }
    }).run();
  }, (Object error, StackTrace stackTrace) {
    final logger = GetIt.I<Logger>();

    // Handle different error types
    if (error is DioException) {
      logger.error(error.message ?? "", null, stackTrace);
    } else if (error is TypeError) {
      // Handle type errors (like the minified event type error)
      final errorMessage = 'Type Error: ${error.toString()}';
      logger.error(errorMessage, error, stackTrace);
      GetIt.I<ErrorService>().captureException(error,
          message: errorMessage,
          context: {'runtimeType': error.runtimeType.toString()});
    } else {
      // Add more specific error type handling here as needed
      const errorMessage = 'An unexpected error occurred';
      logger.error(errorMessage, null, stackTrace);
      GetIt.I<ErrorService>().captureException(FlutterError(errorMessage),
          message: errorMessage,
          context: {'errorType': error.runtimeType.toString()});
    }
  });
}

Future<ValueNotifier<Color>> initSettings() async {
  await Settings.init(
    cacheProvider: GetIt.I<CacheProvider>(),
  );
  final accentColor = ValueNotifier(Colors.blueAccent);
  return accentColor;
}

class MyApp extends StatelessWidget {
  final Version currentVersion;
  final Version latestVersion;
  final VersionWarning? warning;

  const MyApp({
    required this.currentVersion,
    required this.latestVersion,
    this.warning,
    super.key,
  });

  ThemeData _buildLightTheme() {
    final baseTextTheme = ThemeData.light().textTheme;
    const customTextTheme = TextTheme(
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black,
        fontFamily: 'Montserrat',
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        color: transparentBlack66,
        fontFamily: 'Montserrat',
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontFamily: 'Montserrat',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.black,
        fontFamily: 'Montserrat',
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        color: Colors.black,
        fontFamily: 'Montserrat',
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        color: transparentBlack66,
        fontFamily: 'Montserrat',
      ),
    );

    return ThemeData(
      fontFamily: 'Montserrat',
      brightness: Brightness.light,
      scaffoldBackgroundColor: offWhite,
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      primaryTextTheme: baseTextTheme.apply(fontFamily: 'Montserrat'),
      textTheme: customTextTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.all(20),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(color: transparentBlack8),
          ),
          padding: const EdgeInsets.all(20),
          foregroundColor: offBlack,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
          ),
          disabledBackgroundColor: const Color.fromRGBO(10, 10, 10, 0.16),
          disabledForegroundColor: Colors.white.withOpacity(0.5),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 8,
            fontWeight: FontWeight.w500,
            height: 1.2, // This gives us 9.6px line height (8 * 1.2 = 9.6)
            letterSpacing: 0,
          ),
          foregroundColor: transparentBlack33,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.fromLTRB(7, 11, 14, 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: transparentBlack8,
            ),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontFamily: 'Montserrat',
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(grey1),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shadowColor: WidgetStatePropertyAll(Colors.transparent),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: transparentBlack8,
          fontFamily: 'Montserrat',
        ),
        contentPadding: EdgeInsets.zero,
        outlineBorder: BorderSide(
          color: transparentBlack8,
          width: 1,
        ),
        border: InputBorder.none,
        hintStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: transparentBlack33,
          fontFamily: 'Montserrat',
        ),
      ),
      extensions: const [
        CustomThemeExtension.light,
      ],
    );
  }

  ThemeData _buildDarkTheme() {
    final baseTextTheme = ThemeData.dark().textTheme;
    const customTextTheme = TextTheme(
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: offWhite,
        fontFamily: 'Montserrat',
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        color: transparentWhite66,
        fontFamily: 'Montserrat',
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontFamily: 'Montserrat',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: offWhite,
        fontFamily: 'Montserrat',
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontFamily: 'Montserrat',
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        color: transparentWhite66,
        fontFamily: 'Montserrat',
      ),
    );

    return ThemeData(
      fontFamily: 'Montserrat',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: offBlack,
      dialogTheme: DialogThemeData(
        backgroundColor: black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      primaryTextTheme: baseTextTheme.apply(fontFamily: 'Montserrat'),
      textTheme: customTextTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.all(20),
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(color: transparentWhite8),
          ),
          padding: const EdgeInsets.all(20),
          foregroundColor: offWhite,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
          ),
          disabledBackgroundColor: const Color.fromRGBO(254, 251, 249, 0.16),
          disabledForegroundColor: Colors.white.withOpacity(0.5),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 8,
            fontWeight: FontWeight.w500,
            height: 1.2, // This gives us 9.6px line height (8 * 1.2 = 9.6)
            letterSpacing: 0,
          ),
          foregroundColor: transparentWhite33,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: black,
          foregroundColor: white,
          padding: const EdgeInsets.fromLTRB(7, 11, 14, 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: transparentWhite8,
            ),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontFamily: 'Montserrat',
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(grey5),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shadowColor: WidgetStatePropertyAll(Colors.transparent),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: transparentWhite8,
          fontFamily: 'Montserrat',
        ),
        isDense: true,
        contentPadding: EdgeInsets.zero,
        outlineBorder: BorderSide(color: transparentWhite8, width: 1),
        border: InputBorder.none,
        hintStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: transparentWhite33,
          fontFamily: 'Montserrat',
        ),
      ),
      extensions: const [
        CustomThemeExtension.dark,
        WoltModalSheetThemeData(
          backgroundColor: offBlack,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // if showWarning, just display a one off toast here?

    return MultiBlocProvider(
      providers: [
        BlocProvider<VersionCubit>(
          create: (context) => VersionCubit(VersionCubitState(
            latest: latestVersion,
            current: currentVersion,
            warning: warning,
          )),
        ),
        BlocProvider<SessionStateCubit>(
          create: (context) => SessionStateCubit(
              kvService: GetIt.I<SecureKVService>(),
              encryptionService: GetIt.I<EncryptionService>(),
              inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
              cacheProvider: GetIt.I<CacheProvider>(),
              // walletRepository: GetIt.I<WalletRepository>(),
              // accountRepository: GetIt.I<AccountRepository>(),
              // addressRepository: GetIt.I<AddressRepository>(),
              // importedAddressRepository: GetIt.I<ImportedAddressRepository>(),
              analyticsService: GetIt.I<AnalyticsService>())
            ..initialize(),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(GetIt.I<CacheProvider>()),
        ),
      ],
      child: BlocListener<SessionStateCubit, SessionState>(
        listener: (context, state) {
          AppRouter.router.refresh();
        },
        child: BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, themeMode) {
            final session = context.watch<SessionStateCubit>().state;

            bool loadingWidget = session.maybeWhen(
              initial: () => true,
              orElse: () => false,
            );

            if (loadingWidget) {
              return const Directionality(
                  textDirection: TextDirection.ltr,
                  child: Center(
                      child: SizedBox(
                          width: 440, height: 700, child: LoadingScreen())));
            }

            final app = MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: buildLightTheme().copyWith(
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android:
                        _NoAnimationPageTransitionsBuilder(),
                    TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
                    TargetPlatform.macOS: _NoAnimationPageTransitionsBuilder(),
                    TargetPlatform.windows:
                        _NoAnimationPageTransitionsBuilder(),
                    TargetPlatform.linux: _NoAnimationPageTransitionsBuilder(),
                  },
                ),
              ),
              darkTheme: buildDarkTheme().copyWith(
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android:
                        _NoAnimationPageTransitionsBuilder(),
                    TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
                    TargetPlatform.macOS: _NoAnimationPageTransitionsBuilder(),
                    TargetPlatform.windows:
                        _NoAnimationPageTransitionsBuilder(),
                    TargetPlatform.linux: _NoAnimationPageTransitionsBuilder(),
                  },
                ),
              ),
              themeMode: themeMode,
              routeInformationParser: AppRouter.router.routeInformationParser,
              routerDelegate: AppRouter.router.routerDelegate,
              routeInformationProvider:
                  AppRouter.router.routeInformationProvider,
            );

            if (kIsWeb && !GetIt.I<Config>().isWebExtension) {
              return Center(
                child: SizedBox(
                  width: 440,
                  height: 700,
                  child: app,
                ),
              );
            }

            return app;
          },
        ),
      ),
    );
  }
}
