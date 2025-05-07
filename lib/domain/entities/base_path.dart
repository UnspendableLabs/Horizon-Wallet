import 'package:horizon/domain/entities/network.dart';

class BasePath {
  String Function(Network network) get;
  BasePath(this.get);

  static const horizonMainnet = "m/84'/0'/";
  static const horizonTestnet = "m/84'/1'/";

  static const legacy_ = "m/";


  static final horizon = BasePath((Network network) => switch (network) {
        Network.mainnet => horizonMainnet,
        Network.testnet4 => horizonTestnet,
      });

  // counterwallet / freewallet
  static final legacy = BasePath((Network network) => switch (network) {
        Network.mainnet => legacy_,
        Network.testnet4 => legacy_,
      });

  String serialize() {
    return "${get(Network.mainnet)}|${get(Network.testnet4)}";
  }

  static BasePath deserialize(String serialized) {
    final parts = serialized.split("|");
    if (parts.length != 2) {
      throw Exception("Invalid serialized base path");
    }
    return BasePath((Network network) => switch (network) {
          Network.mainnet => parts[0],
          Network.testnet4 => parts[1]
        });
  }
}
