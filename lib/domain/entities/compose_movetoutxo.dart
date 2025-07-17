import "package:horizon/domain/entities/compose_response.dart";

import "./compose_fn.dart";

class ComposeMoveToUtxoParams extends ComposeParams {
  final String utxo;
  final String destination;

  ComposeMoveToUtxoParams({
    required this.utxo,
    required this.destination,
  });

  @override
  List<Object> get props => [utxo, destination];
}

class ComposeMoveToUtxoResponse implements ComposeResponse {
  @override
  final String psbt;

  @override
  final String rawtransaction;
  @override
  final int btcFee;
  @override
  final SignedTxEstimatedSize signedTxEstimatedSize;
  final String? data;
  final String name;

  final ComposeMoveToUtxoResponseParams params;

  ComposeMoveToUtxoResponse({
    required this.psbt,
    required this.rawtransaction,
    required this.btcFee,
    required this.signedTxEstimatedSize,
    required this.data,
    required this.name,
    required this.params,
  });
}

class ComposeMoveToUtxoResponseParams {
  final String source;
  final String destination;
  final bool skipValidation;

  ComposeMoveToUtxoResponseParams({
    required this.source,
    required this.destination,
    required this.skipValidation,
  });
}
