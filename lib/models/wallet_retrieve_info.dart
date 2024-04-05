import 'dart:convert';

class WalletRetrieveInfo {
  String seedHex;
  String walletType;

  WalletRetrieveInfo({
    required this.seedHex,
    required this.walletType,
  });

  factory WalletRetrieveInfo.fromJson(Map<String, dynamic> jsonData) => WalletRetrieveInfo(
        seedHex: jsonData['seed_hex'],
        walletType: jsonData['wallet_type'],
      );

  static Map<String, dynamic> toMap(WalletRetrieveInfo model) => <String, dynamic>{
        'seed_hex': model.seedHex,
        'wallet_type': model.walletType,
      };

  static String serialize(WalletRetrieveInfo model) => json.encode(WalletRetrieveInfo.toMap(model));

  static WalletRetrieveInfo deserialize(String json) => WalletRetrieveInfo.fromJson(jsonDecode(json));
}
