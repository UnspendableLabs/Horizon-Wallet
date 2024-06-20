import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/deprecated/bloc/balance_bloc.dart';
import 'package:horizon/deprecated/bloc/network_bloc.dart';
import 'package:horizon/deprecated/bloc/onboarding_bloc.dart';
import 'package:horizon/deprecated/bloc/wallet_bloc.dart';
import 'package:horizon/deprecated/bloc/wallet_recovery_bloc.dart';
import 'package:horizon/deprecated/models/create_wallet_payload.dart';
import 'package:horizon/deprecated/widgets/onboarding_pages/onboarding_page.dart';
import 'package:horizon/deprecated/widgets/wallet_pages/wallet.dart';

class AppRouter {
  static const onboardingPage = 'onboardingPage';
  static const walletPage = 'walletPage';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboardingPage:
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) => MultiBlocProvider(providers: [
            BlocProvider<OnboardingBloc>(create: (_) => OnboardingBloc()),
            BlocProvider<WalletRecoveryBloc>(create: (_) => WalletRecoveryBloc()),
          ], child: const OnboardingPageWrapper()),
        );
      case walletPage:
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<WalletBloc>(create: (_) => WalletBloc()),
                BlocProvider<NetworkBloc>(create: (_) => NetworkBloc()),
                BlocProvider<BalanceBloc>(create: (_) => BalanceBloc()),
              ],
              child: Wallet(
                // optional payload that is sent on wallet creation
                payload: settings.arguments as CreateWalletPayload?,
              ),
            );
          },
        );
      default:
        throw Exception('Invalid route: ${settings.name}');
    }
  }
}