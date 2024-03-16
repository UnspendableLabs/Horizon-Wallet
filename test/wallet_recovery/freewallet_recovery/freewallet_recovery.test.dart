import 'package:counterparty_wallet/secure_utils/models/wallet_info.dart';
import 'package:counterparty_wallet/wallet_recovery/freewallet_recovery.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test/test.dart';

void main() async {
  await dotenv.load();
  String findAddress(String targetAddress, List<String> addresses) =>
      addresses.firstWhere((address) => address == targetAddress);

  group('FreewalletRecovery', () {
    var freewalletRecovery = FreewalletRecovery();

    test('recoverFreewallet bip39', () {
      const List<String> expectedAddresses = [
        "18yGaEy48a3PPcg33e7xj3LSKA8pCTbAMh",
        "bc1q2akjey7dppxqjuv9amvjnfpp5xtm5uguxquql0",
        "1NaidkrBeCMysjGj8d5xyFtGY1ZqPxjJFb",
        "bc1qaja37nwsrfp0mp3u6vrm7qx6j05rzt3ucg8cag",
        "18uu4keUgrH54SS1JN8BRF3YxoeG6NMjtw",
        "bc1q2myl3n7nc7nxsfn5h3ge34jl4mdu3wax876xwd",
        "14ZcDQs3Bs4DEvqMcjnaCWihWPmhmNarW8",
        "bc1qyuf325j0tw05ek6rpm0t0lgq66vqcsq38y4jyk",
        "1PB3rRptP6Wg5m6BsV7i4kpCYdCK9bDYRX",
        "bc1q7vu5ajvup388rqltveprrpuagkk7kjz6lm3cuf",
        "1GkE7L6eBWTUWZLo4fWseUiRca8ARHztPn",
        "bc1q4jmtwnaenl5tl5mf744t9zk89pd6ncd4kva678",
        "1HBNfdbY3L3BCPao54YDMfbtQ2vGsSjzUr",
        "bc1qk9uyyy9thkhtl2vn2cm367p9fd5rdv6sh0ll06",
        "1KoWYtvDVCbGb4GanGxsQ7jDJcWhwMXGUB",
        "bc1qeclpp0yuwwdvgtjsd3h8wnj7fcnaevlnaf4pwa",
        "15eYhZAqtZ2Mo7io14eS44SaCTTnvupx8Y",
        "bc1qxta94knhpkyp2mck6l4sy0f9lhw5tnkg5nhe0m",
        "1GtzK7W8xyrsj7wnD8PXU8WYt6X57voWy5",
        "bc1q4e00z4qp56cfngj9jp7ra7knw2lxu3u8ry7gfa"
      ];
      String mnemonic =
          "silver similar slab poet cannon south antique finish large romance climb faculty";

      List<WalletInfo> wallets = freewalletRecovery.recoverFreewallet(mnemonic);

      for (var wallet in wallets) {
        print(wallet.address);
        expect(expectedAddresses.contains(wallet.address), true);
      }
      // expect(wallets.length, expectedAddresses.length);
      // for (int i = 0; i < wallets.length; i++) {
      //   WalletInfo wallet = wallets[i];
      //   // String address = findAddress(wallet.address, expectedAddresses);
      //   print('ADDRESS: ${wallet.address}');
      // }
    });
  });
}
