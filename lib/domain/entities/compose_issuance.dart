class ComposeIssuance {
  final String rawtransaction;
  final ComposeIssuanceParams params;
  final String name;

  const ComposeIssuance({
    required this.rawtransaction,
    required this.params,
    required this.name,
  });
}

class ComposeIssuanceParams {
  final String source;
  final String asset;
  final double quantity;
  final bool? divisible;
  final bool? lock;
  final bool? reset;
  final String? description;
  final String? transferDestination;

  ComposeIssuanceParams({
    required this.source,
    required this.asset,
    required this.quantity,
    this.divisible,
    this.lock,
    this.reset,
    this.description,
    this.transferDestination,
  });
}
