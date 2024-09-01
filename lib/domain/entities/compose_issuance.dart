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
  final int quantity;
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

class ComposeIssuanceVerbose {
  final String rawtransaction;
  final ComposeIssuanceVerboseParams params;
  final String name;

  const ComposeIssuanceVerbose({
    required this.rawtransaction,
    required this.params,
    required this.name,
  });
}

class ComposeIssuanceVerboseParams {
  final String source;
  final String asset;
  final int quantity;
  final bool? divisible;
  final bool? lock;
  final bool? reset;
  final String? description;
  final String? transferDestination;
  final String quantityNormalized;

  const ComposeIssuanceVerboseParams({
    required this.source,
    required this.asset,
    required this.quantity,
    this.divisible,
    this.lock,
    this.reset,
    this.description,
    required this.transferDestination,
    required this.quantityNormalized,
  });
}
