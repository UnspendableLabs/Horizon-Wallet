import 'package:test/test.dart';
import 'package:uniparty/bitcoin_wallet_utils/legacy_seed/legacy_mnemonic.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/services/create_wallet_service.dart';

void main() async {
  group('CounterwalletRecovery', () {
    // compatibility with Counterwallet verified by addresses/priv keys generated in Freewallet
    // Counterwallet is currently down, so we test this functionality through Freewallet

    test('CreateWalletService - import counterwallet', () async {
      CreateWalletService createWalletService = CreateWalletService();
      String phrase = "stone freeze straight bus force crave admit any count driver complete lifeless";

      Map<String, WalletNode> expectedWalletNodes = {
        "1Ht2eCiDWRGrBr4QpL7VhvSucGGfymt9hz": WalletNode(
          address: '1Ht2eCiDWRGrBr4QpL7VhvSucGGfymt9hz',
          privateKey: 'KyxV1AwGkbvRYuEgJ8XyqjMxbde9Vz6p9W96ydwEtmKk8e631nru',
          publicKey: "",
          index: 0,
        ),
        "bc1qhy5f3338d7tdmgasprxku0cfuld7zj4v9m5sy3": WalletNode(
            address: 'bc1qhy5f3338d7tdmgasprxku0cfuld7zj4v9m5sy3',
            privateKey: 'KyxV1AwGkbvRYuEgJ8XyqjMxbde9Vz6p9W96ydwEtmKk8e631nru',
            publicKey: "",
            index: 0),
        "1LkyS9HBSCgSNvvwwaHeax1Jth5iDAchqx": WalletNode(
            address: '1LkyS9HBSCgSNvvwwaHeax1Jth5iDAchqx',
            privateKey: 'L4RB8dZV71gRn7BPGuxKycXP6x1B6mK2drawm5HMyRnMSufdF9zv',
            publicKey: "",
            index: 1),
        "bc1qmzakyuntha9fl4hxrqjz5d9jxqczjn4tncqevm": WalletNode(
            address: 'bc1qmzakyuntha9fl4hxrqjz5d9jxqczjn4tncqevm',
            privateKey: 'L4RB8dZV71gRn7BPGuxKycXP6x1B6mK2drawm5HMyRnMSufdF9zv',
            publicKey: "",
            index: 1),
        "14C7fUGn3JTdRhWk4oGDgJ2k8fCiHL1CP4": WalletNode(
            address: '14C7fUGn3JTdRhWk4oGDgJ2k8fCiHL1CP4',
            privateKey: 'L2TPTnvAWC5guQAPTqyUicgyok89BXNHbk9adtVqrz166AmQTK2q',
            publicKey: "",
            index: 2),
        "bc1qyvpg8c2dr9zdh7mq78r3tg8y38kktjkp995w2w": WalletNode(
            address: 'bc1qyvpg8c2dr9zdh7mq78r3tg8y38kktjkp995w2w',
            privateKey: 'L2TPTnvAWC5guQAPTqyUicgyok89BXNHbk9adtVqrz166AmQTK2q',
            publicKey: "",
            index: 2),
        "1PCjBKRk54CjJ5vccWuvjn4MZFkHrPrBZj": WalletNode(
            address: '1PCjBKRk54CjJ5vccWuvjn4MZFkHrPrBZj',
            privateKey: 'KytSKo2Qsg4XFN2J7z64D7dwnPXxTCfsLkLM5Jz2FksyK2TFTyKR',
            publicKey: "",
            index: 3),
        "bc1q7w9g6xryx80hak2csdtp7pww7wzk3c0jm6tfuk": WalletNode(
            address: 'bc1q7w9g6xryx80hak2csdtp7pww7wzk3c0jm6tfuk',
            privateKey: 'KytSKo2Qsg4XFN2J7z64D7dwnPXxTCfsLkLM5Jz2FksyK2TFTyKR',
            publicKey: "",
            index: 3),
        "145feLNWEDj2GE4ibbrMYM6VatR8MvwFjj": WalletNode(
            address: '145feLNWEDj2GE4ibbrMYM6VatR8MvwFjj',
            privateKey: 'L2S1HP9UUNhfHE7w1gTLhMAaX95R6fxnQ89ACZSS9tvNU89wSFX3',
            publicKey: "",
            index: 4),
        "bc1qy89yegyajpaup35640az7nrvfa2pq9sjxafzr8": WalletNode(
            address: 'bc1qy89yegyajpaup35640az7nrvfa2pq9sjxafzr8',
            privateKey: 'L2S1HP9UUNhfHE7w1gTLhMAaX95R6fxnQ89ACZSS9tvNU89wSFX3',
            publicKey: "",
            index: 4),
        "1BbMx536n7YfUuUTH1NytuGTggE1hVoazo": WalletNode(
            address: '1BbMx536n7YfUuUTH1NytuGTggE1hVoazo',
            privateKey: 'KyB3rwkXhvUFKjxRyoBn3zndPRtvhFDjkY2yHNsKjnLnWfFMbZsT',
            publicKey: "",
            index: 5),
        "bc1qwscwxej4v8uevn055ecyk3rl5apmu9vfna94xm": WalletNode(
            address: 'bc1qwscwxej4v8uevn055ecyk3rl5apmu9vfna94xm',
            privateKey: 'KyB3rwkXhvUFKjxRyoBn3zndPRtvhFDjkY2yHNsKjnLnWfFMbZsT',
            publicKey: "",
            index: 5),
        "1F3Xu1RcXNzwPchKd2X2ELLMYUUWcS98vB": WalletNode(
            address: '1F3Xu1RcXNzwPchKd2X2ELLMYUUWcS98vB',
            privateKey: 'L1pcjracG21sc4G7b1ERxMrNGHJ5tKiJ69QXzdTvLBMjFEbttdnD',
            publicKey: "",
            index: 6),
        "bc1qngxxy46grdwerhy6mfdntu99u7hllyekxtdyts": WalletNode(
            address: 'bc1qngxxy46grdwerhy6mfdntu99u7hllyekxtdyts',
            privateKey: 'L1pcjracG21sc4G7b1ERxMrNGHJ5tKiJ69QXzdTvLBMjFEbttdnD',
            publicKey: "",
            index: 6),
        "12QE3h9FdehTGJ8vzsP8SF6KvPeQQXNPTA": WalletNode(
            address: '12QE3h9FdehTGJ8vzsP8SF6KvPeQQXNPTA',
            privateKey: 'L1Kc5HkVXWomvrq7G3wKzz6VpgYMLFTBMoUm33RKCZrPjYavxnLA',
            publicKey: "",
            index: 7),
        "bc1qpawf2cyffddwalqq3u4c7efc50uq72g4gjzyac": WalletNode(
            address: 'bc1qpawf2cyffddwalqq3u4c7efc50uq72g4gjzyac',
            privateKey: 'L1Kc5HkVXWomvrq7G3wKzz6VpgYMLFTBMoUm33RKCZrPjYavxnLA',
            publicKey: "",
            index: 7),
        "1M2iGxTDY3TH8tduSZ5q4Fjhq15nMM3HyV": WalletNode(
            address: '1M2iGxTDY3TH8tduSZ5q4Fjhq15nMM3HyV',
            privateKey: 'L48y8CVK1DsqGxAPidqpJHDTBpKEjCLN1yCKWKmB3oZ68spC1Bim',
            publicKey: "",
            index: 8),
        "bc1qmw6k96r4uwgfq5xvusy3llewvj5jnseekz8wm6": WalletNode(
            address: 'bc1qmw6k96r4uwgfq5xvusy3llewvj5jnseekz8wm6',
            privateKey: 'L48y8CVK1DsqGxAPidqpJHDTBpKEjCLN1yCKWKmB3oZ68spC1Bim',
            publicKey: "",
            index: 8),
        "1DVDiVEiMXGVWVHHrzPEZDpVqcfk3cxrmR": WalletNode(
            address: '1DVDiVEiMXGVWVHHrzPEZDpVqcfk3cxrmR',
            privateKey: 'Kxkp3DL4QdY8ii7xNfu5CEQa66EoCJf9YamgsEtG3L6zrw61RnYA',
            publicKey: "",
            index: 9),
        "bc1q3rmu2sfradnvn89qsum7sk306pkl7eusnf6z7p": WalletNode(
            address: 'bc1q3rmu2sfradnvn89qsum7sk306pkl7eusnf6z7p',
            privateKey: 'Kxkp3DL4QdY8ii7xNfu5CEQa66EoCJf9YamgsEtG3L6zrw61RnYA',
            publicKey: "",
            index: 9)
      };

      String seedHex = LegacyMnemonic().mnemonicToSeed(phrase);

      List<WalletNode> recoveredNodes = createWalletService.createWallet(NetworkEnum.mainnet, seedHex, WalletTypeEnum.bip32);

      for (var recoveredNode in recoveredNodes) {
        WalletNode? expectedWalletNode = expectedWalletNodes[recoveredNode.address];
        String? expectedAdress = expectedWalletNode?.address;
        String? expectedPrivateKey = expectedWalletNode?.privateKey;

        expect(recoveredNode.address, expectedAdress);
        expect(recoveredNode.privateKey, expectedPrivateKey);
      }
    });
  }, skip: 'flutter_js package is not compiling');
}
