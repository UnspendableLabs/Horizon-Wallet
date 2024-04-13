import 'dart:convert';

class StoredWalletData {
  String seedHex;
  String walletType;

  StoredWalletData({
    required this.seedHex,
    required this.walletType,
  });

  factory StoredWalletData.fromJson(Map<String, dynamic> jsonData) => StoredWalletData(
        seedHex: jsonData['seed_hex'],
        walletType: jsonData['wallet_type'],
      );

  static Map<String, dynamic> toMap(StoredWalletData model) => <String, dynamic>{
        'seed_hex': model.seedHex,
        'wallet_type': model.walletType,
      };

  static String serialize(StoredWalletData model) => json.encode(StoredWalletData.toMap(model));

  static StoredWalletData deserialize(String json) => StoredWalletData.fromJson(jsonDecode(json));
}
