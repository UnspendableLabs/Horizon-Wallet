import "package:collection/collection.dart";
import "package:fpdart/fpdart.dart";

enum Network { mainnet, testnet4 }

extension NetworkX on Network {
  static Option<Network> fromString(String value) {
    return Option.fromNullable(Network.values.firstWhereOrNull(
      (e) => e.name == value,
    ));
  }
}


// CHAT I WANT TO ADD A STATIC fromString and toString method


