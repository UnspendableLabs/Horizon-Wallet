import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';
import 'package:counterparty_wallet/wallet_recovery/counterwallet_recovery.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load();

  group('CounterwalletRecovery', () {
    var counterwalletRecovery = CounterwalletRecovery();
    test('recoverCounterwalletFromFreewallet', () {
      String phrase =
          "stone freeze straight bus force crave admit any count driver complete lifeless";

      Map<String, WalletInfo> expectedWallets = {
        "1Ht2eCiDWRGrBr4QpL7VhvSucGGfymt9hz": WalletInfo(
            address: '1Ht2eCiDWRGrBr4QpL7VhvSucGGfymt9hz',
            privateKey: 'KyxV1AwGkbvRYuEgJ8XyqjMxbde9Vz6p9W96ydwEtmKk8e631nru',
            publicKey: ""),
        "bc1qhy5f3338d7tdmgasprxku0cfuld7zj4v9m5sy3": WalletInfo(
            address: 'bc1qhy5f3338d7tdmgasprxku0cfuld7zj4v9m5sy3',
            privateKey: 'KyxV1AwGkbvRYuEgJ8XyqjMxbde9Vz6p9W96ydwEtmKk8e631nru',
            publicKey: ""),
        "1LkyS9HBSCgSNvvwwaHeax1Jth5iDAchqx": WalletInfo(
            address: '1LkyS9HBSCgSNvvwwaHeax1Jth5iDAchqx',
            privateKey: 'L4RB8dZV71gRn7BPGuxKycXP6x1B6mK2drawm5HMyRnMSufdF9zv',
            publicKey: ""),
        "bc1qmzakyuntha9fl4hxrqjz5d9jxqczjn4tncqevm": WalletInfo(
            address: 'bc1qmzakyuntha9fl4hxrqjz5d9jxqczjn4tncqevm',
            privateKey: 'L4RB8dZV71gRn7BPGuxKycXP6x1B6mK2drawm5HMyRnMSufdF9zv',
            publicKey: ""),
        "14C7fUGn3JTdRhWk4oGDgJ2k8fCiHL1CP4": WalletInfo(
            address: '14C7fUGn3JTdRhWk4oGDgJ2k8fCiHL1CP4',
            privateKey: 'L2TPTnvAWC5guQAPTqyUicgyok89BXNHbk9adtVqrz166AmQTK2q',
            publicKey: ""),
        "bc1qyvpg8c2dr9zdh7mq78r3tg8y38kktjkp995w2w": WalletInfo(
            address: 'bc1qyvpg8c2dr9zdh7mq78r3tg8y38kktjkp995w2w',
            privateKey: 'L2TPTnvAWC5guQAPTqyUicgyok89BXNHbk9adtVqrz166AmQTK2q',
            publicKey: ""),
        "1PCjBKRk54CjJ5vccWuvjn4MZFkHrPrBZj": WalletInfo(
            address: '1PCjBKRk54CjJ5vccWuvjn4MZFkHrPrBZj',
            privateKey: 'KytSKo2Qsg4XFN2J7z64D7dwnPXxTCfsLkLM5Jz2FksyK2TFTyKR',
            publicKey: ""),
        "bc1q7w9g6xryx80hak2csdtp7pww7wzk3c0jm6tfuk": WalletInfo(
            address: 'bc1q7w9g6xryx80hak2csdtp7pww7wzk3c0jm6tfuk',
            privateKey: 'KytSKo2Qsg4XFN2J7z64D7dwnPXxTCfsLkLM5Jz2FksyK2TFTyKR',
            publicKey: ""),
        "145feLNWEDj2GE4ibbrMYM6VatR8MvwFjj": WalletInfo(
            address: '145feLNWEDj2GE4ibbrMYM6VatR8MvwFjj',
            privateKey: 'L2S1HP9UUNhfHE7w1gTLhMAaX95R6fxnQ89ACZSS9tvNU89wSFX3',
            publicKey: ""),
        "bc1qy89yegyajpaup35640az7nrvfa2pq9sjxafzr8": WalletInfo(
            address: 'bc1qy89yegyajpaup35640az7nrvfa2pq9sjxafzr8',
            privateKey: 'L2S1HP9UUNhfHE7w1gTLhMAaX95R6fxnQ89ACZSS9tvNU89wSFX3',
            publicKey: ""),
        "1BbMx536n7YfUuUTH1NytuGTggE1hVoazo": WalletInfo(
            address: '1BbMx536n7YfUuUTH1NytuGTggE1hVoazo',
            privateKey: 'KyB3rwkXhvUFKjxRyoBn3zndPRtvhFDjkY2yHNsKjnLnWfFMbZsT',
            publicKey: ""),
        "bc1qwscwxej4v8uevn055ecyk3rl5apmu9vfna94xm": WalletInfo(
            address: 'bc1qwscwxej4v8uevn055ecyk3rl5apmu9vfna94xm',
            privateKey: 'KyB3rwkXhvUFKjxRyoBn3zndPRtvhFDjkY2yHNsKjnLnWfFMbZsT',
            publicKey: ""),
        "1F3Xu1RcXNzwPchKd2X2ELLMYUUWcS98vB": WalletInfo(
            address: '1F3Xu1RcXNzwPchKd2X2ELLMYUUWcS98vB',
            privateKey: 'L1pcjracG21sc4G7b1ERxMrNGHJ5tKiJ69QXzdTvLBMjFEbttdnD',
            publicKey: ""),
        "bc1qngxxy46grdwerhy6mfdntu99u7hllyekxtdyts": WalletInfo(
            address: 'bc1qngxxy46grdwerhy6mfdntu99u7hllyekxtdyts',
            privateKey: 'L1pcjracG21sc4G7b1ERxMrNGHJ5tKiJ69QXzdTvLBMjFEbttdnD',
            publicKey: ""),
        "12QE3h9FdehTGJ8vzsP8SF6KvPeQQXNPTA": WalletInfo(
            address: '12QE3h9FdehTGJ8vzsP8SF6KvPeQQXNPTA',
            privateKey: 'L1Kc5HkVXWomvrq7G3wKzz6VpgYMLFTBMoUm33RKCZrPjYavxnLA',
            publicKey: ""),
        "bc1qpawf2cyffddwalqq3u4c7efc50uq72g4gjzyac": WalletInfo(
            address: 'bc1qpawf2cyffddwalqq3u4c7efc50uq72g4gjzyac',
            privateKey: 'L1Kc5HkVXWomvrq7G3wKzz6VpgYMLFTBMoUm33RKCZrPjYavxnLA',
            publicKey: ""),
        "1M2iGxTDY3TH8tduSZ5q4Fjhq15nMM3HyV": WalletInfo(
            address: '1M2iGxTDY3TH8tduSZ5q4Fjhq15nMM3HyV',
            privateKey: 'L48y8CVK1DsqGxAPidqpJHDTBpKEjCLN1yCKWKmB3oZ68spC1Bim',
            publicKey: ""),
        "bc1qmw6k96r4uwgfq5xvusy3llewvj5jnseekz8wm6": WalletInfo(
            address: 'bc1qmw6k96r4uwgfq5xvusy3llewvj5jnseekz8wm6',
            privateKey: 'L48y8CVK1DsqGxAPidqpJHDTBpKEjCLN1yCKWKmB3oZ68spC1Bim',
            publicKey: ""),
        "1DVDiVEiMXGVWVHHrzPEZDpVqcfk3cxrmR": WalletInfo(
            address: '1DVDiVEiMXGVWVHHrzPEZDpVqcfk3cxrmR',
            privateKey: 'Kxkp3DL4QdY8ii7xNfu5CEQa66EoCJf9YamgsEtG3L6zrw61RnYA',
            publicKey: ""),
        "bc1q3rmu2sfradnvn89qsum7sk306pkl7eusnf6z7p": WalletInfo(
            address: 'bc1q3rmu2sfradnvn89qsum7sk306pkl7eusnf6z7p',
            privateKey: 'Kxkp3DL4QdY8ii7xNfu5CEQa66EoCJf9YamgsEtG3L6zrw61RnYA',
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
