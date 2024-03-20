import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';
import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/wallet_recovery/bip32_recovery.dart';

void main() async {
  await dotenv.load();
  group('FreewalletRecovery testnet', () {
    dotenv.testLoad(fileInput: '''ENV=testnet''');
    final bip39 = Bip39();

    test('bip39 + bip32 recovery', () {
      String mnemonic =
          "silver similar slab poet cannon south antique finish large romance climb faculty";

      Map<String, WalletNode> expectedWalletNodes = {
        "moVDsJ42wbUeAj9emD6LYxYmB9jX4bQ9u9": WalletNode(
            address: 'moVDsJ42wbUeAj9emD6LYxYmB9jX4bQ9u9',
            privateKey: 'cMpv6s9tYLnhKpNzbTDXocUXLjZeanRcKTw4MhCBVXhipcrcaeH3',
            publicKey: ""),
        "tb1q2akjey7dppxqjuv9amvjnfpp5xtm5uguvx8nyu": WalletNode(
            address: 'tb1q2akjey7dppxqjuv9amvjnfpp5xtm5uguvx8nyu',
            privateKey: 'cMpv6s9tYLnhKpNzbTDXocUXLjZeanRcKTw4MhCBVXhipcrcaeH3',
            publicKey: ""),
        "n36fvowATDoEeqkLrC4LoB6bQ1AYKALCRZ": WalletNode(
            address: 'n36fvowATDoEeqkLrC4LoB6bQ1AYKALCRZ',
            privateKey: 'cSP2bQM44muEDZaDeBGc1bSaWEc1K3GpZmtDcRWBLKDfy2tw2B4Q',
            publicKey: ""),
        "tb1qaja37nwsrfp0mp3u6vrm7qx6j05rzt3ujwutxm": WalletNode(
            address: 'tb1qaja37nwsrfp0mp3u6vrm7qx6j05rzt3ujwutxm',
            privateKey: 'cSP2bQM44muEDZaDeBGc1bSaWEc1K3GpZmtDcRWBLKDfy2tw2B4Q',
            publicKey: ""),
        "moRrMojTVsiKqYud1w6ZFAFspoExzPk2ma": WalletNode(
            address: 'moRrMojTVsiKqYud1w6ZFAFspoExzPk2ma',
            privateKey: 'cQopPF5FG26dAEJh577ijLqFhY181rSXCi899Xc414ghWW4umFTQ',
            publicKey: ""),
        "tb1q2myl3n7nc7nxsfn5h3ge34jl4mdu3waxdcp447": WalletNode(
            address: 'tb1q2myl3n7nc7nxsfn5h3ge34jl4mdu3waxdcp447',
            privateKey: 'cQopPF5FG26dAEJh577ijLqFhY181rSXCi899Xc414ghWW4umFTQ',
            publicKey: ""),
        "mj5ZWTx1ztVU23JyLJkx2Rw2NPNQdw3opE": WalletNode(
            address: 'mj5ZWTx1ztVU23JyLJkx2Rw2NPNQdw3opE',
            privateKey: 'cNfgX6vc6AZQXPEStheKwAqZF6u5zLs7VrbBZrDRUgMb1tSz8gp7',
            publicKey: ""),
        "tb1qyuf325j0tw05ek6rpm0t0lgq66vqcsq3dzwpl9": WalletNode(
            address: 'tb1qyuf325j0tw05ek6rpm0t0lgq66vqcsq3dzwpl9',
            privateKey: 'cNfgX6vc6AZQXPEStheKwAqZF6u5zLs7VrbBZrDRUgMb1tSz8gp7',
            publicKey: ""),
        "n3h19UusC7wvrsZob465tg2XQco23AajqP": WalletNode(
            address: 'n3h19UusC7wvrsZob465tg2XQco23AajqP',
            privateKey: 'cUwMUpR2YBw99psNTkicauRGBLJQLJCtHQZdinTR5EhpfTKkKYEE',
            publicKey: ""),
        "tb1q7vu5ajvup388rqltveprrpuagkk7kjz64a2t86": WalletNode(
            address: 'tb1q7vu5ajvup388rqltveprrpuagkk7kjz64a2t86',
            privateKey: 'cUwMUpR2YBw99psNTkicauRGBLJQLJCtHQZdinTR5EhpfTKkKYEE',
            publicKey: ""),
        "mwGBQPBczXtjHfpQnEVFUPvkUZisFJVYG7": WalletNode(
            address: 'mwGBQPBczXtjHfpQnEVFUPvkUZisFJVYG7',
            privateKey: 'cS6TgbefyYvgPY1mq2MNhCN8wvF62AMmXn4GSXgQVvqZTQyAsgZo',
            publicKey: ""),
        "tb1q4jmtwnaenl5tl5mf744t9zk89pd6ncd4u2xf95": WalletNode(
            address: 'tb1q4jmtwnaenl5tl5mf744t9zk89pd6ncd4u2xf95',
            privateKey: 'cS6TgbefyYvgPY1mq2MNhCN8wvF62AMmXn4GSXgQVvqZTQyAsgZo',
            publicKey: ""),
        "mwhKxggWrMURyW4QndWbBapDG2WyoisAJJ": WalletNode(
            address: 'mwhKxggWrMURyW4QndWbBapDG2WyoisAJJ',
            privateKey: 'cVn3qJf1JhfwnNQ5eLcPiW1dTXCwJHDToiQWaeyY8PTC9rjvTJ4K',
            publicKey: ""),
        "tb1qk9uyyy9thkhtl2vn2cm367p9fd5rdv6safyv5f": WalletNode(
            address: 'tb1qk9uyyy9thkhtl2vn2cm367p9fd5rdv6safyv5f',
            privateKey: 'cVn3qJf1JhfwnNQ5eLcPiW1dTXCwJHDToiQWaeyY8PTC9rjvTJ4K',
            publicKey: ""),
        "mzKTqx1CJE2XNAkCVqwFE2wYAc7QnuutB9": WalletNode(
            address: 'mzKTqx1CJE2XNAkCVqwFE2wYAc7QnuutB9',
            privateKey: 'cRuumK8jqREqHBFTwVMQacera79h1JMmsvAk3mzep4TkYG1uLJpd',
            publicKey: ""),
        "tb1qeclpp0yuwwdvgtjsd3h8wnj7fcnaevlnh0wj4w": WalletNode(
            address: 'tb1qeclpp0yuwwdvgtjsd3h8wnj7fcnaevlnh0wj4w',
            privateKey: 'cRuumK8jqREqHBFTwVMQacera79h1JMmsvAk3mzep4TkYG1uLJpd',
            publicKey: ""),
        "mkAVzcFphaTcaECQidcosyeu4T4Vr2BsCJ": WalletNode(
            address: 'mkAVzcFphaTcaECQidcosyeu4T4Vr2BsCJ',
            privateKey: 'cVR2rF6TZopAkXnKoHZrW5EAcYc1dNphqaf9BBUuytzYdgt3v47k',
            publicKey: ""),
        "tb1qxta94knhpkyp2mck6l4sy0f9lhw5tnkg74v25g": WalletNode(
            address: 'tb1qxta94knhpkyp2mck6l4sy0f9lhw5tnkg74v25g',
            privateKey: 'cVR2rF6TZopAkXnKoHZrW5EAcYc1dNphqaf9BBUuytzYdgt3v47k',
            publicKey: ""),
        "mwQwcAb7n1J8WERPvhMuJ3isk67mycWJTP": WalletNode(
            address: 'mwQwcAb7n1J8WERPvhMuJ3isk67mycWJTP',
            privateKey: 'cVPiC6PvxXCmDgmopU89fq997pjGvTGQJZA1qpGjwGGoqFrSwh9D',
            publicKey: ""),
        "tb1q4e00z4qp56cfngj9jp7ra7knw2lxu3u8fz9mjw": WalletNode(
            address: 'tb1q4e00z4qp56cfngj9jp7ra7knw2lxu3u8fz9mjw',
            privateKey: 'cVPiC6PvxXCmDgmopU89fq997pjGvTGQJZA1qpGjwGGoqFrSwh9D',
            publicKey: "")
      };

      String seedEntropy = bip39.mnemonicToEntropy(mnemonic);

      List<WalletNode> recoveredNodes = recoverBip32Wallet(seedEntropy);

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
