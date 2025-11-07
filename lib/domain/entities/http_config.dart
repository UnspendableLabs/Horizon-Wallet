import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

sealed class HttpConfig {
  final Network network;
  final String counterparty;
  final String esplora;
  final String btcExplorer;
  final String horizonMarket;
  final String horizonMarketApi;
  final String mempoolSpaceApi;

  const HttpConfig({
    required this.network,
    required this.counterparty,
    required this.esplora,
    required this.btcExplorer,
    required this.horizonMarket,
    required this.horizonMarketApi,
    required this.mempoolSpaceApi,
  });

  static Mainnet mainnet() => Mainnet();
  static Testnet4 testnet4() => Testnet4();
  static Signet signet() => Signet();
}

class Mainnet extends HttpConfig {
  Mainnet()
      : super(
          network: Network.mainnet,
          counterparty: "https://api.unspendablelabs.com:4000/v2",
          esplora: "https://api.unspendablelabs.com:3000",
          btcExplorer: "https://mempool.space",
          horizonMarket: "https://horizon.market",
          horizonMarketApi: "https://horizon.market/api",
          mempoolSpaceApi: "https://mempool.space/api/v1",
        );
}

class Testnet4 extends HttpConfig {
  Testnet4()
      : super(
          network: Network.testnet4,
          counterparty: "https://testnet4.counterparty.io:44000/v2/",
          esplora: "https://testnet4.counterparty.io:43000",
          btcExplorer: "https://mempool.space/testnet4",
          horizonMarket: "https://horizon-market-testnet.vercel.app",
          horizonMarketApi: "https://horizon-market-testnet.vercel.app/api",
          mempoolSpaceApi: "https://mempool.space/testnet4/api/v1",
        );
}

class Signet extends HttpConfig {
  Signet()
      : super(
          network: Network.signet,
          counterparty: "https://signet.counterparty.io:34000/v2/",
          esplora: "https://signet.counterparty.io:33000",
          btcExplorer: "https://mempool.space/signet",
          horizonMarket: "http://localhost:3000",
          horizonMarketApi: "http://localhost:3000/api",
          mempoolSpaceApi: "https://mempool.space/signet/api/v1",
        );
}

class Custom extends HttpConfig {
  const Custom(
      {required super.network,
      required super.esplora,
      required super.counterparty,
      required super.btcExplorer,
      required super.horizonMarket,
      required super.horizonMarketApi,
      required super.mempoolSpaceApi});
}
