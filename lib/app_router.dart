import 'package:counterparty_wallet/start_page.dart';
import 'package:counterparty_wallet/secure_utils/secure_storage.dart';
import 'package:counterparty_wallet/wallet_pages/wallet.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  GoRouter get router => _goRouter;

  AppRouter();

  Future<String?> getSeedHex() async {
    String? value = await SecureStorage().readSecureData('seed_hex');
    print('value: $value');
    return value;
  }

  late final GoRouter _goRouter = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(path: '/start', builder: (context, state) => const StartPage())
    ],
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      var userAutheticated = await getSeedHex();
      if (userAutheticated != null) {
        return '/wallet';
      } else {
        return '/start';
      }
    },
  );
}
