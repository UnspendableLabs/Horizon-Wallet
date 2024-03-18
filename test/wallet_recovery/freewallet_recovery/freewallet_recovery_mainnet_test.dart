import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';
import 'package:counterparty_wallet/wallet_recovery/freewallet_recovery.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load();

  group('FreewalletRecovery mainnet', () {
    var freewalletRecovery = FreewalletRecovery();

    // compatibility with freewallet verified by addresses/priv keys generated in freewallet
    test('recoverFreewallet bip39', () {
      String mnemonic =
          "silver similar slab poet cannon south antique finish large romance climb faculty";

      Map<String, WalletNode> expectedWalletNodes = {
        "18yGaEy48a3PPcg33e7xj3LSKA8pCTbAMh": WalletNode(
            address: '18yGaEy48a3PPcg33e7xj3LSKA8pCTbAMh',
            privateKey: 'KwTvdxA37H6SANujD3QQSHyTiWGEvLKvFRnbFGjfzR3iZsi7BYmz',
            publicKey: ""),
        "bc1q2akjey7dppxqjuv9amvjnfpp5xtm5uguxquql0": WalletNode(
            address: 'bc1q2akjey7dppxqjuv9amvjnfpp5xtm5uguxquql0',
            privateKey: 'KwTvdxA37H6SANujD3QQSHyTiWGEvLKvFRnbFGjfzR3iZsi7BYmz',
            publicKey: ""),
        "1NaidkrBeCMysjGj8d5xyFtGY1ZqPxjJFb": WalletNode(
            address: '1NaidkrBeCMysjGj8d5xyFtGY1ZqPxjJFb',
            privateKey: 'L2238VMCdiCy486xFmTUeGwWt1JbebB8VjjkW13fqCZfiHoeUQJ3',
            publicKey: ""),
        "bc1qaja37nwsrfp0mp3u6vrm7qx6j05rzt3ucg8cag": WalletNode(
            address: 'bc1qaja37nwsrfp0mp3u6vrm7qx6j05rzt3ucg8cag',
            privateKey: 'L2238VMCdiCy486xFmTUeGwWt1JbebB8VjjkW13fqCZfiHoeUQJ3',
            publicKey: ""),
        "18uu4keUgrH54SS1JN8BRF3YxoeG6NMjtw": WalletNode(
            address: '18uu4keUgrH54SS1JN8BRF3YxoeG6NMjtw',
            privateKey: 'KzSpvL5PpxQMznqRghJbN2LC5JhiMQLq8fyg379YVx2hFkyRsLCh',
            publicKey: ""),
        "bc1q2myl3n7nc7nxsfn5h3ge34jl4mdu3wax876xwd": WalletNode(
            address: 'bc1q2myl3n7nc7nxsfn5h3ge34jl4mdu3wax876xwd',
            privateKey: 'KzSpvL5PpxQMznqRghJbN2LC5JhiMQLq8fyg379YVx2hFkyRsLCh',
            publicKey: ""),
        "14ZcDQs3Bs4DEvqMcjnaCWihWPmhmNarW8": WalletNode(
            address: '14ZcDQs3Bs4DEvqMcjnaCWihWPmhmNarW8',
            privateKey: 'KxJh4Bvkf6s9MwmBWHqCZrLVcsbgKtmRRpSiTRkuyZham9Ms3eVU',
            publicKey: ""),
        "bc1qyuf325j0tw05ek6rpm0t0lgq66vqcsq38y4jyk": WalletNode(
            address: 'bc1qyuf325j0tw05ek6rpm0t0lgq66vqcsq38y4jyk',
            privateKey: 'KxJh4Bvkf6s9MwmBWHqCZrLVcsbgKtmRRpSiTRkuyZham9Ms3eVU',
            publicKey: ""),
        "1PB3rRptP6Wg5m6BsV7i4kpCYdCK9bDYRX": WalletNode(
            address: '1PB3rRptP6Wg5m6BsV7i4kpCYdCK9bDYRX',
            privateKey: 'L4aN1uRB78EszPQ75LuVDavCZ6zzfr7CDNRAcMzua83pQiG1X4Bn',
            publicKey: ""),
        "bc1q7vu5ajvup388rqltveprrpuagkk7kjz6lm3cuf": WalletNode(
            address: 'bc1q7vu5ajvup388rqltveprrpuagkk7kjz6lm3cuf',
            privateKey: 'L4aN1uRB78EszPQ75LuVDavCZ6zzfr7CDNRAcMzua83pQiG1X4Bn',
            publicKey: ""),
        "1GkE7L6eBWTUWZLo4fWseUiRca8ARHztPn": WalletNode(
            address: '1GkE7L6eBWTUWZLo4fWseUiRca8ARHztPn',
            privateKey: 'L1jUDgepYVERE6YWScYFKss5KgwgMiG5TjuoL7DtzpBZCfuKmi3e',
            publicKey: ""),
        "bc1q4jmtwnaenl5tl5mf744t9zk89pd6ncd4kva678": WalletNode(
            address: 'bc1q4jmtwnaenl5tl5mf744t9zk89pd6ncd4kva678',
            privateKey: 'L1jUDgepYVERE6YWScYFKss5KgwgMiG5TjuoL7DtzpBZCfuKmi3e',
            publicKey: ""),
        "1HBNfdbY3L3BCPao54YDMfbtQ2vGsSjzUr": WalletNode(
            address: '1HBNfdbY3L3BCPao54YDMfbtQ2vGsSjzUr',
            privateKey: 'L5R4NPf9sdygcvvpFvoGMBWZqHuXdq7mjgG3UEX2dGoBu7kHRRpC',
            publicKey: ""),
        "bc1qk9uyyy9thkhtl2vn2cm367p9fd5rdv6sh0ll06": WalletNode(
            address: 'bc1qk9uyyy9thkhtl2vn2cm367p9fd5rdv6sh0ll06',
            privateKey: 'L5R4NPf9sdygcvvpFvoGMBWZqHuXdq7mjgG3UEX2dGoBu7kHRRpC',
            publicKey: ""),
        "1KoWYtvDVCbGb4GanGxsQ7jDJcWhwMXGUB": WalletNode(
            address: '1KoWYtvDVCbGb4GanGxsQ7jDJcWhwMXGUB',
            privateKey: 'L1YvJQ8tQMYa7jnCZ5YHDJ9nwsrHLrG5ot2GwMY9JwokHWzdc6Sb',
            publicKey: ""),
        "bc1qeclpp0yuwwdvgtjsd3h8wnj7fcnaevlnaf4pwa": WalletNode(
            address: 'bc1qeclpp0yuwwdvgtjsd3h8wnj7fcnaevlnaf4pwa',
            privateKey: 'L1YvJQ8tQMYa7jnCZ5YHDJ9nwsrHLrG5ot2GwMY9JwokHWzdc6Sb',
            publicKey: ""),
        "15eYhZAqtZ2Mo7io14eS44SaCTTnvupx8Y": WalletNode(
            address: '15eYhZAqtZ2Mo7io14eS44SaCTTnvupx8Y',
            privateKey: 'L543PL6c8k7ub6K4Qskj8kj6zKJbxvj1mYWg4m2QUnLYNwoyrk61',
            publicKey: ""),
        "bc1qxta94knhpkyp2mck6l4sy0f9lhw5tnkg5nhe0m": WalletNode(
            address: 'bc1qxta94knhpkyp2mck6l4sy0f9lhw5tnkg5nhe0m',
            privateKey: 'L543PL6c8k7ub6K4Qskj8kj6zKJbxvj1mYWg4m2QUnLYNwoyrk61',
            publicKey: ""),
        "1GtzK7W8xyrsj7wnD8PXU8WYt6X57voWy5": WalletNode(
            address: '1GtzK7W8xyrsj7wnD8PXU8WYt6X57voWy5',
            privateKey: 'L52ijBQ5XTWW4FJYS4K2JWe5VbRsG1AiEX1YjPpES9coaWotx6QV',
            publicKey: ""),
        "bc1q4e00z4qp56cfngj9jp7ra7knw2lxu3u8ry7gfa": WalletNode(
            address: 'bc1q4e00z4qp56cfngj9jp7ra7knw2lxu3u8ry7gfa',
            privateKey: 'L52ijBQ5XTWW4FJYS4K2JWe5VbRsG1AiEX1YjPpES9coaWotx6QV',
            publicKey: "")
      };

      List<WalletNode> recoveredNodes = freewalletRecovery.recoverFreewallet(mnemonic);

      for (var recoveredNode in recoveredNodes) {
        WalletNode? walletNode = expectedWalletNodes[recoveredNode.address];
        String? expectedAdress = walletNode?.address;
        String? expectedPrivateKey = walletNode?.privateKey;

        expect(recoveredNode.address, expectedAdress);
        expect(recoveredNode.privateKey, expectedPrivateKey);
      }
    });
  });
}
