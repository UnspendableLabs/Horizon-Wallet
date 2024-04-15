import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/network_bloc.dart';
import 'package:uniparty/bloc/onboarding_bloc.dart';
import 'package:uniparty/bloc/stored_wallet_data_bloc.dart';
import 'package:uniparty/bloc/wallet_bloc.dart';
import 'package:uniparty/widgets/onboarding_pages/onboarding_page.dart';
import 'package:uniparty/widgets/wallet_pages/wallet.dart';
import 'package:uniparty/models/create_wallet_payload.dart';

class AppRouter {
  static const onboardingPage = 'onboardingPage';
  static const walletPage = 'walletPage';

// TODO: research router!
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboardingPage:
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) => BlocProvider<OnboardingBloc>(
            create: (_) => OnboardingBloc(),
            child: const OnboardingPageWrapper(),
          ),
        );
      case walletPage:
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<StoredWalletDataBloc>(create: (_) => StoredWalletDataBloc()),
                BlocProvider<WalletBloc>(create: (_) {
                  return WalletBloc();
                }),
                BlocProvider<NetworkBloc>(create: (_) => NetworkBloc())
              ],
              child: Wallet(
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
