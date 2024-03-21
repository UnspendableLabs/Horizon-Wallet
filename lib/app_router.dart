import 'package:go_router/go_router.dart';
import 'package:uniparty/components/wallet_pages/wallet.dart';
import 'package:uniparty/start_page.dart';
import 'package:uniparty/utils/secure_storage.dart';

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
        builder: (context, state) => const Wallet(),
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
