import 'package:redux/redux.dart';
import 'package:uniparty/redux/app_store.dart';
import 'package:uniparty/utils/secure_storage.dart';

Future<Null> Function(Store<AppState> store) saveWalletRetrieveInfo(
    String seedHex, String walletType) {
  return (Store<AppState> store) async {
    Future(() async {
      print('DO WE GET HERe: $store');
      final secureStorage = SecureStorage();
      await secureStorage.writeSecureData('seed_hex', seedHex);
      await secureStorage.writeSecureData('wallet_type', walletType);
      print('after???');
      return;
    });
  };
}
