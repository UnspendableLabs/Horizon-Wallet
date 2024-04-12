import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/data_bloc.dart';
import 'package:uniparty/bloc/onboarding_bloc.dart';
import 'package:uniparty/components/onboarding_pages/onboarding_page.dart';
import 'package:uniparty/components/wallet_pages/wallet.dart';

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
            if (settings.arguments == null) {
              // what to do?
            }
            return MultiBlocProvider(
              providers: [
                BlocProvider<DataBloc>(create: (_) => DataBloc()),
                BlocProvider<WalletBloc>(create: (_) => WalletBloc()),
                BlocProvider<NetworkBloc>(create: (_) => NetworkBloc())
              ],
              // child: Text('Wllet'),
              child: Wallet(
                  // payload: settings.arguments! as WalletRetrieveInfo,
                  ),
            );
          },
        );
      default:
        throw Exception('Invalid route: ${settings.name}');
    }
  }
}
