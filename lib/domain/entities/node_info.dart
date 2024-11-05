class NodeInfo {
  final bool serverReady;
  final String network;
  final String version;
  final int backendHeight;
  final int counterpartyHeight;
  final String documentation;
  final String routes;
  final String blueprint;

  const NodeInfo({
    required this.serverReady,
    required this.network,
    required this.version,
    required this.backendHeight,
    required this.counterpartyHeight,
    required this.documentation,
    required this.routes,
    required this.blueprint,
  });
}
