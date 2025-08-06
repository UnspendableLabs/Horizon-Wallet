import "./compose_response.dart";
import "./compose_fn.dart";

class ComposeCancelParams extends ComposeParams {
  final String source;
  final String offerHash;

  ComposeCancelParams({
    required this.source,
    required this.offerHash,
  });

  @override
  List<Object> get props => [offerHash];
}

class ComposeCancelResponse implements ComposeResponse {

  @override
  final String psbt;

  @override
  final String rawtransaction;
  @override
  final int btcFee;
  @override
  final SignedTxEstimatedSize signedTxEstimatedSize;

  final ComposeCancelResponseParams params;

  const ComposeCancelResponse({
    required this.psbt,
    required this.rawtransaction,
    required this.btcFee,
    required this.signedTxEstimatedSize,
    required this.params,
  });
}

class ComposeCancelResponseParams {
  final String source;
  final String offerHash;

  ComposeCancelResponseParams({required this.source, required this.offerHash});
}
