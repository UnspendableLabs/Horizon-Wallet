import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/data_bloc.dart';
import 'package:uniparty/components/wallet_pages/wallet.dart';
import 'package:uniparty/components/onboarding_pages/onboarding_page.dart';

class AppRouter {
  static const onboardingPage = 'onboardingPage';
  static const walletPage = 'walletPage';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboardingPage:
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) => BlocProvider<DataBloc>(
            create: (_) => DataBloc(),
            child: const OnboardingPage(),
          ),
        );
      case walletPage:
        return CupertinoPageRoute(
          settings: settings,
          builder: (context) {
            if (settings.arguments == null) {
              // what to do?
            }
            return BlocProvider(
              create: (_) => DataBloc(),
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
