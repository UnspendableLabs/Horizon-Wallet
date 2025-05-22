import 'package:horizon/domain/entities/network.dart';

sealed class HttpConfig {
  final Network network;
  final String counterparty;
  final String esplora;
  final String btcExplorer;
  final String horizonExplorer;
  final String horizonExplorerApi;
  const HttpConfig(
      {required this.network,
      required this.counterparty,
      required this.esplora,
      required this.btcExplorer,
      required this.horizonExplorer,
      required this.horizonExplorerApi});
}

class Mainnet extends HttpConfig {
  const Mainnet()
      : super(
          network: Network.mainnet,
          counterparty: "https://api.unspendablelabs.com:4000/v2",
          esplora: "https://api.unspendablelabs.com:3000",
          btcExplorer: "https://mempool.space",
          horizonExplorer: "https://horizon.market/explorer",
          horizonExplorerApi: "https://horizon.market/api",
        );
}

class Testnet4 extends HttpConfig {
  const Testnet4()
      : super(
          network: Network.testnet4,
          counterparty: "https://testnet4.counterparty.io:44000/v2/",
          esplora: "https://testnet4.counterparty.io:43000",
          btcExplorer: "https://mempool.space/testnet4",
          horizonExplorer:
              "https://horizon-market-testnet.vercel.app/explorer", // TODO: link to testnet
          horizonExplorerApi: "https://horizon.market/api",
        );
}

class Custom extends HttpConfig {
  const Custom(
      {required super.network,
      required super.esplora,
      required super.counterparty,
      required super.btcExplorer,
      required super.horizonExplorer,
      required super.horizonExplorerApi});
}
