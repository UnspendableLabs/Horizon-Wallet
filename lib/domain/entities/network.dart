import "package:collection/collection.dart";
import "package:fpdart/fpdart.dart";

enum Network { mainnet, testnet4, signet }

extension NetworkX on Network {
  static Option<Network> fromString(String value) {
    return Option.fromNullable(Network.values.firstWhereOrNull(
      (e) => e.name == value,
    ));
  }

  bool get isMainnet {
    return this == Network.mainnet;
  }

  bool get isTestnet4 {
    return this == Network.testnet4;
  }

  bool get isSignet {
    return this == Network.signet;
  }
}
