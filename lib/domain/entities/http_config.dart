import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

sealed class HttpConfig {
  final Network network;
  final String counterparty;
  final String esplora;
  final String btcExplorer;
  final String horizonExplorer;
  final String horizonExplorerApi;
  final String mempoolSpaceApi;
  final Option<MeilisearchConfig> meilisearchConfig;

  const HttpConfig(
      {required this.network,
      required this.counterparty,
      required this.esplora,
      required this.btcExplorer,
      required this.horizonExplorer,
      required this.horizonExplorerApi,
      required this.mempoolSpaceApi,
      this.meilisearchConfig = const None()});

  static Mainnet mainnet() => Mainnet();
  static Testnet4 testnet4() => Testnet4();
}

class Mainnet extends HttpConfig {
  Mainnet()
      : super(
            network: Network.mainnet,
            counterparty: "https://api.unspendablelabs.com:4000/v2",
            esplora: "https://api.unspendablelabs.com:3000",
            btcExplorer: "https://mempool.space",
            horizonExplorer: "https://horizon.market/explorer",
            horizonExplorerApi: "https://horizon.market/api",
            mempoolSpaceApi: "https://mempool.space/api/v1",
            meilisearchConfig: GetIt.I<Config>().meilisearchConfigMainnet);
}

class Testnet4 extends HttpConfig {
  Testnet4()
      : super(
            network: Network.testnet4,
            counterparty: "https://testnet4.counterparty.io:44000/v2/",
            // esplora: "https://testnet4.counterparty.io:43000",
            esplora: "https://mempool.space/testnet4/api",
            btcExplorer: "https://mempool.space/testnet4",
            horizonExplorer:
                "https://horizon-market-testnet.vercel.app/explorer", // TODO: link to testnet
            horizonExplorerApi: "https://horizon-market-testnet.vercel.app/api",
            mempoolSpaceApi: "https://mempool.space/testnet4/api/v1",
            meilisearchConfig: GetIt.I<Config>().meilisearchConfigTestnet);
}

class Custom extends HttpConfig {
  const Custom(
      {required super.network,
      required super.esplora,
      required super.counterparty,
      required super.btcExplorer,
      required super.horizonExplorer,
      required super.horizonExplorerApi,
      required super.mempoolSpaceApi});
}
