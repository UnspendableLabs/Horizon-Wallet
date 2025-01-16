import "package:horizon/domain/entities/compose_response.dart";

import "./compose_fn.dart";

class ComposeDetachUtxoParams extends ComposeParams {
  final String utxo;
  final String destination;

  ComposeDetachUtxoParams({
    required this.utxo,
    required this.destination,
  });

  @override
  List<Object> get props => [utxo, destination];
}

class ComposeDetachUtxoResponse implements ComposeResponse {
  @override
  final String rawtransaction;
  @override
  final int btcFee;
  @override
  final SignedTxEstimatedSize signedTxEstimatedSize;
  final String data;
  final String name;

  final ComposeDetachUtxoResponseParams params;

  ComposeDetachUtxoResponse({
    required this.rawtransaction,
    required this.btcFee,
    required this.signedTxEstimatedSize,
    required this.data,
    required this.name,
    required this.params,
  });
}

class ComposeDetachUtxoResponseParams {
  final String source;
  final String destination;
  final bool skipValidation;

  ComposeDetachUtxoResponseParams({
    required this.source,
    required this.destination,
    required this.skipValidation,
  });
}
