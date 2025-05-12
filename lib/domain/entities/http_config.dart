import 'package:horizon/domain/entities/network.dart';

sealed class HttpConfig {
  final Network network;
  final String counterparty;
  final String esplora;

  const HttpConfig({
    required this.network,
    required this.counterparty,
    required this.esplora,
  });
}

class Mainnet extends HttpConfig {
  const Mainnet()
      : super(
          network: Network.mainnet,
          counterparty: "https://api.unspendablelabs.com:4000/v2",
          esplora: "https://api.unspendablelabs.com:3000",
        );
}

class Testnet4 extends HttpConfig {
  const Testnet4()
      : super(
          network: Network.testnet4,
          counterparty: "https://testnet4.counterparty.io:44000/v2/",
          esplora: "https://testnet4.counterparty.io:43000",
        );
}

class Custom extends HttpConfig {
  const Custom(
      {required super.network,
      required super.esplora,
      required super.counterparty});
}
