import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';
import 'package:counterparty_wallet/wallet_recovery/counterwallet_recovery.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load();

  group('CounterwalletRecovery', () {
    var counterwalletRecovery = CounterwalletRecovery();
    dotenv.testLoad(fileInput: '''ENV=testnet''');
    test('recoverCounterwalletFromFreewallet', () {
      String phrase =
          "stone freeze straight bus force crave admit any count driver complete lifeless";

      Map<String, WalletInfo> expectedWallets = {
        "mxPywFoCKSi6xxY2Xu5sXqfEUFsNtSKKPf": WalletInfo(
            address: 'mxPywFoCKSi6xxY2Xu5sXqfEUFsNtSKKPf',
            privateKey: 'cQKUU5w8BfcgiLhwgYM7D3s2DrwZASCWDYHa64PkPsykPP6pP2cG',
            publicKey: ""),
        "tb1qhy5f3338d7tdmgasprxku0cfuld7zj4v0a0rlz": WalletInfo(
            address: 'tb1qhy5f3338d7tdmgasprxku0cfuld7zj4v0a0rlz',
            privateKey: 'cQKUU5w8BfcgiLhwgYM7D3s2DrwZASCWDYHa64PkPsykPP6pP2cG',
            publicKey: ""),
        "n1GvjCNAFE7hA3QZf9G2QsDdkggRCKehSr": WalletInfo(
            address: 'n1GvjCNAFE7hA3QZf9G2QsDdkggRCKehSr',
            privateKey: 'cUnAbYZLY5NgwYeefKmTLw2SjBJamDQihtjQsVjsUYSMheho6Hhi',
            publicKey: ""),
        "tb1qmzakyuntha9fl4hxrqjz5d9jxqczjn4te7m2hg": WalletInfo(
            address: 'tb1qmzakyuntha9fl4hxrqjz5d9jxqczjn4te7m2hg',
            privateKey: 'cUnAbYZLY5NgwYeefKmTLw2SjBJamDQihtjQsVjsUYSMheho6Hhi',
            publicKey: ""),
        "mii4xXMkrKttCozMnNEbWDF4zeoR9ztfbz": WalletInfo(
            address: 'mii4xXMkrKttCozMnNEbWDF4zeoR9ztfbz',
            privateKey: 'cSpNvhv1wFmx4qderFnc5wC3RyRYqyTyfnJ3kJxMN6f6LutMpdqr',
            publicKey: ""),
        "tb1qyvpg8c2dr9zdh7mq78r3tg8y38kktjkp0r0a3a": WalletInfo(
            address: 'tb1qyvpg8c2dr9zdh7mq78r3tg8y38kktjkp0r0a3a',
            privateKey: 'cSpNvhv1wFmx4qderFnc5wC3RyRYqyTyfnJ3kJxMN6f6LutMpdqr',
            publicKey: ""),
        "n3igUNWit5dz5CQEL5tJZhGgRFLzqu7MS9": WalletInfo(
            address: 'n3igUNWit5dz5CQEL5tJZhGgRFLzqu7MS9',
            privateKey: 'cQFRni2GJjknQoVZWPuBaS91QcqN7emZQnUpBjSXksXyZmX4bHAe',
            publicKey: ""),
        "tb1q7w9g6xryx80hak2csdtp7pww7wzk3c0j3us689": WalletInfo(
            address: 'tb1q7w9g6xryx80hak2csdtp7pww7wzk3c0j3us689',
            privateKey: 'cQFRni2GJjknQoVZWPuBaS91QcqN7emZQnUpBjSXksXyZmX4bHAe',
            publicKey: ""),
        "mibcwPTV3FAH3LYLKApjNGJpSt1qKTFfAH": WalletInfo(
            address: 'mibcwPTV3FAH3LYLKApjNGJpSt1qKTFfAH',
            privateKey: 'cSnzkJ9KuSPvSfbCQ6GU4ffe9NNpm84UUAHdJytwf1aNisGMXbtP',
            publicKey: ""),
        "tb1qy89yegyajpaup35640az7nrvfa2pq9sjvmj3c5": WalletInfo(
            address: 'tb1qy89yegyajpaup35640az7nrvfa2pq9sjvmj3c5',
            privateKey: 'cSnzkJ9KuSPvSfbCQ6GU4ffe9NNpm84UUAHdJytwf1aNisGMXbtP',
            publicKey: ""),
        "mr7KF885b8yvG1x4zaMMipUnYfpic6v4s1": WalletInfo(
            address: 'mr7KF885b8yvG1x4zaMMipUnYfpic6v4s1',
            privateKey: 'cPY3KrkP8zAWVBRhNCzuRKHh1fCLMhKRpaBSPoKqEtznmQJntU8H',
            publicKey: ""),
        "tb1qwscwxej4v8uevn055ecyk3rl5apmu9vfem7xag": WalletInfo(
            address: 'tb1qwscwxej4v8uevn055ecyk3rl5apmu9vfem7xag',
            privateKey: 'cPY3KrkP8zAWVBRhNCzuRKHh1fCLMhKRpaBSPoKqEtznmQJntU8H',
            publicKey: ""),
        "muZVC4WbLQSCAjAwLbVQ4FYgQU5DTzWK1X": WalletInfo(
            address: 'muZVC4WbLQSCAjAwLbVQ4FYgQU5DTzWK1X',
            privateKey: 'cSBcCmaTh5i8mVjNyR3ZKgMRtWbVYmozABZ173vRqJ1jVyifJTJW',
            publicKey: ""),
        "tb1qngxxy46grdwerhy6mfdntu99u7hllyekvdkhsr": WalletInfo(
            address: 'tb1qngxxy46grdwerhy6mfdntu99u7hllyekvdkhsr',
            privateKey: 'cSBcCmaTh5i8mVjNyR3ZKgMRtWbVYmozABZ173vRqJ1jVyifJTJW',
            publicKey: ""),
        "mgvBLkEESg8i3QcYiSMWGAJenPF7FzutwG": WalletInfo(
            address: 'mgvBLkEESg8i3QcYiSMWGAJenPF7FzutwG',
            privateKey: 'cRgbYCkLxaW36JJNeTkTNJbZSuqkzhYsRqdE9TsphgWPzHeNomSe',
            publicKey: ""),
        "tb1qpawf2cyffddwalqq3u4c7efc50uq72g4z5ehxt": WalletInfo(
            address: 'tb1qpawf2cyffddwalqq3u4c7efc50uq72g4z5ehxt',
            privateKey: 'cRgbYCkLxaW36JJNeTkTNJbZSuqkzhYsRqdE9TsphgWPzHeNomSe',
            publicKey: ""),
        "n1Yfa1YCM4tXv17XA84CtAx2gzgVGPouJM": WalletInfo(
            address: 'n1Yfa1YCM4tXv17XA84CtAx2gzgVGPouJM',
            privateKey: 'cUVxb7VASHa6SPdf73ewfbiWp3cePeS461LnckDgYvD6PczX95BA',
            publicKey: ""),
        "tb1qmw6k96r4uwgfq5xvusy3llewvj5jnseeuyuaqf": WalletInfo(
            address: 'tb1qmw6k96r4uwgfq5xvusy3llewvj5jnseeuyuaqf',
            privateKey: 'cUVxb7VASHa6SPdf73ewfbiWp3cePeS461LnckDgYvD6PczX95BA',
            publicKey: ""),
        "mt1B1YKhAYhkHbkuaZMcP92phcGT1XWeBZ": WalletInfo(
            address: 'mt1B1YKhAYhkHbkuaZMcP92phcGT1XWeBZ',
            privateKey: 'cP7oW8KuqhEPt9bDm5iCZYudiKYCrkkqccv9yfLmYSm17gBcZUZ4',
            publicKey: ""),
        "tb1q3rmu2sfradnvn89qsum7sk306pkl7euse0p39j": WalletInfo(
            address: 'tb1q3rmu2sfradnvn89qsum7sk306pkl7euse0p39j',
            privateKey: 'cP7oW8KuqhEPt9bDm5iCZYudiKYCrkkqccv9yfLmYSm17gBcZUZ4',
            publicKey: "")
      };

      List<WalletInfo> wallets = counterwalletRecovery.recoverCounterwalletFromFreewallet(phrase);

      for (var wallet in wallets) {
        WalletInfo? walletInfo = expectedWallets[wallet.address];
        String? expectedAdress = walletInfo?.address;
        String? privateKey = walletInfo?.privateKey;

        expect(wallet.address, expectedAdress);
        expect(wallet.privateKey, privateKey);
      }
    });
  });
}
