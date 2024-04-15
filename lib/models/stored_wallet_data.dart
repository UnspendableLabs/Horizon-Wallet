import 'dart:convert';

import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/wallet_node.dart';

class StoredWalletData {
  String seedHex;
  WalletTypeEnum walletType;
  List<WalletNode> mainnetNodes;
  List<WalletNode> testnetNodes;

  StoredWalletData({
    required this.seedHex,
    required this.walletType,
    required this.mainnetNodes,
    required this.testnetNodes,
  });

  factory StoredWalletData.fromJson(Map<String, dynamic> jsonData) => StoredWalletData(
        seedHex: jsonData['seed_hex'],
        walletType: WalletTypeEnum.values.firstWhere((element) => element.name == jsonData['wallet_type']),
        mainnetNodes: jsonData['mainnet'].map<WalletNode>((node) => WalletNode.fromJson(node)).toList(),
        testnetNodes: jsonData['testnet'].map<WalletNode>((node) => WalletNode.fromJson(node)).toList(),
      );

  static Map<String, dynamic> toMap(StoredWalletData model) => <String, dynamic>{
        'seed_hex': model.seedHex,
        'wallet_type': model.walletType.name,
        'mainnet': [...model.mainnetNodes.map((node) => WalletNode.toMap(node))],
        'testnet': [...model.testnetNodes.map((node) => WalletNode.toMap(node))]
      };

  static String serialize(StoredWalletData model) => json.encode(StoredWalletData.toMap(model));

  static StoredWalletData deserialize(String json) => StoredWalletData.fromJson(jsonDecode(json));
}
