import 'package:test/test.dart';
import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/bitcoin_wallet_utils/create_wallet.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/wallet_node.dart';

void main() async {
  group('FreewalletRecovery mainnet', () {
    final bip39 = Bip39Impl();
    // compatibility with freewallet verified by addresses/priv keys generated in freewallet
    test('bip39 + bip32 recovery', () async {
      String mnemonic = "silver similar slab poet cannon south antique finish large romance climb faculty";

      Map<String, WalletNode> expectedWalletNodes = {
        "18yGaEy48a3PPcg33e7xj3LSKA8pCTbAMh": WalletNode(
            address: '18yGaEy48a3PPcg33e7xj3LSKA8pCTbAMh',
            privateKey: 'KwTvdxA37H6SANujD3QQSHyTiWGEvLKvFRnbFGjfzR3iZsi7BYmz',
            publicKey: "",
            index: 0),
        "bc1q2akjey7dppxqjuv9amvjnfpp5xtm5uguxquql0": WalletNode(
            address: 'bc1q2akjey7dppxqjuv9amvjnfpp5xtm5uguxquql0',
            privateKey: 'KwTvdxA37H6SANujD3QQSHyTiWGEvLKvFRnbFGjfzR3iZsi7BYmz',
            publicKey: "",
            index: 0),
        "1NaidkrBeCMysjGj8d5xyFtGY1ZqPxjJFb": WalletNode(
            address: '1NaidkrBeCMysjGj8d5xyFtGY1ZqPxjJFb',
            privateKey: 'L2238VMCdiCy486xFmTUeGwWt1JbebB8VjjkW13fqCZfiHoeUQJ3',
            publicKey: "",
            index: 1),
        "bc1qaja37nwsrfp0mp3u6vrm7qx6j05rzt3ucg8cag": WalletNode(
            address: 'bc1qaja37nwsrfp0mp3u6vrm7qx6j05rzt3ucg8cag',
            privateKey: 'L2238VMCdiCy486xFmTUeGwWt1JbebB8VjjkW13fqCZfiHoeUQJ3',
            publicKey: "",
            index: 1),
        "18uu4keUgrH54SS1JN8BRF3YxoeG6NMjtw": WalletNode(
            address: '18uu4keUgrH54SS1JN8BRF3YxoeG6NMjtw',
            privateKey: 'KzSpvL5PpxQMznqRghJbN2LC5JhiMQLq8fyg379YVx2hFkyRsLCh',
            publicKey: "",
            index: 2),
        "bc1q2myl3n7nc7nxsfn5h3ge34jl4mdu3wax876xwd": WalletNode(
            address: 'bc1q2myl3n7nc7nxsfn5h3ge34jl4mdu3wax876xwd',
            privateKey: 'KzSpvL5PpxQMznqRghJbN2LC5JhiMQLq8fyg379YVx2hFkyRsLCh',
            publicKey: "",
            index: 2),
        "14ZcDQs3Bs4DEvqMcjnaCWihWPmhmNarW8": WalletNode(
            address: '14ZcDQs3Bs4DEvqMcjnaCWihWPmhmNarW8',
            privateKey: 'KxJh4Bvkf6s9MwmBWHqCZrLVcsbgKtmRRpSiTRkuyZham9Ms3eVU',
            publicKey: "",
            index: 3),
        "bc1qyuf325j0tw05ek6rpm0t0lgq66vqcsq38y4jyk": WalletNode(
            address: 'bc1qyuf325j0tw05ek6rpm0t0lgq66vqcsq38y4jyk',
            privateKey: 'KxJh4Bvkf6s9MwmBWHqCZrLVcsbgKtmRRpSiTRkuyZham9Ms3eVU',
            publicKey: "",
            index: 3),
        "1PB3rRptP6Wg5m6BsV7i4kpCYdCK9bDYRX": WalletNode(
            address: '1PB3rRptP6Wg5m6BsV7i4kpCYdCK9bDYRX',
            privateKey: 'L4aN1uRB78EszPQ75LuVDavCZ6zzfr7CDNRAcMzua83pQiG1X4Bn',
            publicKey: "",
            index: 4),
        "bc1q7vu5ajvup388rqltveprrpuagkk7kjz6lm3cuf": WalletNode(
            address: 'bc1q7vu5ajvup388rqltveprrpuagkk7kjz6lm3cuf',
            privateKey: 'L4aN1uRB78EszPQ75LuVDavCZ6zzfr7CDNRAcMzua83pQiG1X4Bn',
            publicKey: "",
            index: 4),
        "1GkE7L6eBWTUWZLo4fWseUiRca8ARHztPn": WalletNode(
            address: '1GkE7L6eBWTUWZLo4fWseUiRca8ARHztPn',
            privateKey: 'L1jUDgepYVERE6YWScYFKss5KgwgMiG5TjuoL7DtzpBZCfuKmi3e',
            publicKey: "",
            index: 5),
        "bc1q4jmtwnaenl5tl5mf744t9zk89pd6ncd4kva678": WalletNode(
            address: 'bc1q4jmtwnaenl5tl5mf744t9zk89pd6ncd4kva678',
            privateKey: 'L1jUDgepYVERE6YWScYFKss5KgwgMiG5TjuoL7DtzpBZCfuKmi3e',
            publicKey: "",
            index: 5),
        "1HBNfdbY3L3BCPao54YDMfbtQ2vGsSjzUr": WalletNode(
            address: '1HBNfdbY3L3BCPao54YDMfbtQ2vGsSjzUr',
            privateKey: 'L5R4NPf9sdygcvvpFvoGMBWZqHuXdq7mjgG3UEX2dGoBu7kHRRpC',
            publicKey: "",
            index: 6),
        "bc1qk9uyyy9thkhtl2vn2cm367p9fd5rdv6sh0ll06": WalletNode(
            address: 'bc1qk9uyyy9thkhtl2vn2cm367p9fd5rdv6sh0ll06',
            privateKey: 'L5R4NPf9sdygcvvpFvoGMBWZqHuXdq7mjgG3UEX2dGoBu7kHRRpC',
            publicKey: "",
            index: 6),
        "1KoWYtvDVCbGb4GanGxsQ7jDJcWhwMXGUB": WalletNode(
            address: '1KoWYtvDVCbGb4GanGxsQ7jDJcWhwMXGUB',
            privateKey: 'L1YvJQ8tQMYa7jnCZ5YHDJ9nwsrHLrG5ot2GwMY9JwokHWzdc6Sb',
            publicKey: "",
            index: 7),
        "bc1qeclpp0yuwwdvgtjsd3h8wnj7fcnaevlnaf4pwa": WalletNode(
            address: 'bc1qeclpp0yuwwdvgtjsd3h8wnj7fcnaevlnaf4pwa',
            privateKey: 'L1YvJQ8tQMYa7jnCZ5YHDJ9nwsrHLrG5ot2GwMY9JwokHWzdc6Sb',
            publicKey: "",
            index: 7),
        "15eYhZAqtZ2Mo7io14eS44SaCTTnvupx8Y": WalletNode(
            address: '15eYhZAqtZ2Mo7io14eS44SaCTTnvupx8Y',
            privateKey: 'L543PL6c8k7ub6K4Qskj8kj6zKJbxvj1mYWg4m2QUnLYNwoyrk61',
            publicKey: "",
            index: 8),
        "bc1qxta94knhpkyp2mck6l4sy0f9lhw5tnkg5nhe0m": WalletNode(
            address: 'bc1qxta94knhpkyp2mck6l4sy0f9lhw5tnkg5nhe0m',
            privateKey: 'L543PL6c8k7ub6K4Qskj8kj6zKJbxvj1mYWg4m2QUnLYNwoyrk61',
            publicKey: "",
            index: 8),
        "1GtzK7W8xyrsj7wnD8PXU8WYt6X57voWy5": WalletNode(
            address: '1GtzK7W8xyrsj7wnD8PXU8WYt6X57voWy5',
            privateKey: 'L52ijBQ5XTWW4FJYS4K2JWe5VbRsG1AiEX1YjPpES9coaWotx6QV',
            publicKey: "",
            index: 9),
        "bc1q4e00z4qp56cfngj9jp7ra7knw2lxu3u8ry7gfa": WalletNode(
            address: 'bc1q4e00z4qp56cfngj9jp7ra7knw2lxu3u8ry7gfa',
            privateKey: 'L52ijBQ5XTWW4FJYS4K2JWe5VbRsG1AiEX1YjPpES9coaWotx6QV',
            publicKey: "",
            index: 9)
      };

      String seedEntropy = bip39.mnemonicToEntropy(mnemonic);

      List<WalletNode> recoveredNodes = createWallet(NetworkEnum.mainnet, seedEntropy, WalletType.freewallet);

      for (var recoveredNode in recoveredNodes) {
        WalletNode? walletNode = expectedWalletNodes[recoveredNode.address];
        String? expectedAdress = walletNode?.address;
        String? expectedPrivateKey = walletNode?.privateKey;
        int? expectedIndex = walletNode?.index;

        expect(recoveredNode.address, expectedAdress);
        expect(recoveredNode.privateKey, expectedPrivateKey);
        expect(recoveredNode.index, expectedIndex);
      }
    });
  });
}
