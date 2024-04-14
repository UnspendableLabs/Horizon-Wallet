import 'dart:convert';

class WalletNode {
  String address;
  String publicKey;
  String privateKey;
  int index;

  WalletNode({
    required this.address,
    required this.publicKey,
    required this.privateKey,
    required this.index,
  });

  factory WalletNode.fromJson(Map<String, dynamic> jsonData) => WalletNode(
        address: jsonData['address'],
        publicKey: jsonData['public_key'],
        privateKey: jsonData['private_key'],
        index: jsonData['index'].toInt(),
      );

  static Map<String, dynamic> toMap(WalletNode model) => <String, dynamic>{
        'address': model.address,
        'public_key': model.publicKey,
        'private_key': model.privateKey,
        'index': model.index.toString(),
      };

  static String serialize(WalletNode model) => json.encode(WalletNode.toMap(model));

  static WalletNode deserialize(String json) => WalletNode.fromJson(jsonDecode(json));
}
