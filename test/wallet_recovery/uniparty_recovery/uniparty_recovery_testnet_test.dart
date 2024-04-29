import 'package:test/test.dart';
import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/services/create_wallet_service.dart';

void main() async {
  // TODO: verify testnet bech32 addresses
  group('Uniparty recovery testnet', () {
    final createWalletService = CreateWalletService();
    final bip39 = Bip39Impl();
    test('bip39 + bip44 test1', () async {
      String mnemonic = 'trend pond enable empower govern example melody bless alone grow stone genre';

      String seedHex = bip39.mnemonicToSeedHex(mnemonic);

      List<WalletNode> walletNodes = createWalletService.createWallet(NetworkEnum.testnet, seedHex, WalletTypeEnum.bip44);

      WalletNode walletNode = walletNodes[0];

      // expect(walletNode.address, 'tb1q...');
      expect(walletNode.publicKey, '03b22da4ea31c025dbff534f32a1a5fb6498fbd4d2f0517808101b83a164bbed6a');
      expect(walletNode.privateKey, 'cS9NzwfpCRK22faDntv4WK4yNJ7ZPtwVY9HqJVD4UaKzWoLuhRG1');
    });

    test('bip39 + bip44 test2', () async {
      String mnemonic = 'stumble prison flip merge negative ostrich myself winter naive try arctic olympic';

      String seedHex = bip39.mnemonicToSeedHex(mnemonic);

      List<WalletNode> walletNodes = createWalletService.createWallet(NetworkEnum.testnet, seedHex, WalletTypeEnum.bip44);

      WalletNode walletNode = walletNodes[0];

      // expect(walletNode.address, 'tb1q...');
      expect(walletNode.publicKey, '030971a53ef1ce6d8e53f925c43ab1b73fd0f2f7d0fc52d4321d3b120f41c34fff');
      expect(walletNode.privateKey, 'cQCThVTEueEX6jL3umWStyTyEjP7Gk9fufcgsUu6JmA3321JZaPo');
    });

    test('bip39 + bip44 test3', () async {
      String mnemonic = 'thunder member interest display shock unable clarify fiber insect lumber battle off';

      String seedHex = bip39.mnemonicToSeedHex(mnemonic);

      List<WalletNode> walletNodes = createWalletService.createWallet(NetworkEnum.testnet, seedHex, WalletTypeEnum.bip44);

      WalletNode walletNode = walletNodes[0];

      // expect(walletNode.address, 'tb1q...');
      expect(walletNode.publicKey, '03e95f48545072cef28e9df57a7d954f522d7400254485cd97dd17063466cd68c4');
      expect(walletNode.privateKey, 'cV216FvuzS89eUR8XzrbR2pUYzG5xoCF7fVsVhWppwfRn9JqwCr7');
    });

    test('bip39 + bip44 test4', () async {
      String mnemonic = 'crime speak truly valid movie describe blame essay crack skirt december obey';

      String seedHex = bip39.mnemonicToSeedHex(mnemonic);

      List<WalletNode> walletNodes = createWalletService.createWallet(NetworkEnum.testnet, seedHex, WalletTypeEnum.bip44);

      WalletNode walletNode = walletNodes[0];

      // expect(walletNode.address, 'tb1q...');
      expect(walletNode.publicKey, '038d58b916adf4f33059688ccc95272b02d7d210eb8a629584b3264451b3da4c09');
      expect(walletNode.privateKey, 'cR9pSgzwRq4mEqjNUtia1d1FrJrGBcYW2ZiksasVPSGoKfEfg9RR');
    });

    test('recoverUnparty5', () async {
      String mnemonic = 'sorry hub gadget wasp repeat wave disagree knock prosper rose gas dinner';

      String seedHex = bip39.mnemonicToSeedHex(mnemonic);

      List<WalletNode> walletNodes = createWalletService.createWallet(NetworkEnum.testnet, seedHex, WalletTypeEnum.bip44);

      WalletNode walletNode = walletNodes[0];

      // expect(walletNode.address, 'tb1q...');
      expect(walletNode.publicKey, '03ba775315a3cab21a9a1d429281dcbb5e939a83cd0e32b84d25e612642d6b10c7');
      expect(walletNode.privateKey, 'cULQ364pkbv4SS2K53D2cqqGd3oZCcUnj9eC5v6DDBnihNkb1GFK');
    });
  });
}
