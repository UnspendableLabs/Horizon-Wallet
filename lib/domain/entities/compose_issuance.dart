import "./compose_response.dart";

class ComposeIssuanceResponse implements ComposeResponse {
  @override
  final String rawtransaction;
  final ComposeIssuanceResponseParams params;
  final String name;

  const ComposeIssuanceResponse({
    required this.rawtransaction,
    required this.params,
    required this.name,
  });
}

class ComposeIssuanceResponseParams {
  final String source;
  final String asset;
  final int quantity;
  final bool? divisible;
  final bool? lock;
  final bool? reset;
  final String? description;
  final String? transferDestination;

  ComposeIssuanceResponseParams({
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

class ComposeIssuanceResponseVerbose implements ComposeResponse {
  @override
  final String rawtransaction;
  final ComposeIssuanceResponseVerboseParams params;
  final String name;

  const ComposeIssuanceResponseVerbose({
    required this.rawtransaction,
    required this.params,
    required this.name,
  });
}

class ComposeIssuanceResponseVerboseParams {
  final String source;
  final String asset;
  final int quantity;
  final bool? divisible;
  final bool? lock;
  final bool? reset;
  final String? description;
  final String? transferDestination;
  final String quantityNormalized;

  const ComposeIssuanceResponseVerboseParams({
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
