import "package:horizon/domain/entities/compose_response.dart";

import "./compose_fn.dart";

class ComposeMoveToUtxoParams extends ComposeParams {
  final String utxo;
  final String destination;
  final String asset;
  final int quantity;
  ComposeMoveToUtxoParams({
    required this.utxo,
    required this.destination,
    required this.asset,
    required this.quantity,
  });

  @override
  List<Object> get props => [utxo, destination, asset, quantity];
}

class ComposeMoveToUtxoResponse implements ComposeResponse {
  @override
  final String rawtransaction;
  @override
  final int btcFee;
  final String? data;
  final String name;

  final ComposeMoveToUtxoResponseParams params;

  ComposeMoveToUtxoResponse({
    required this.rawtransaction,
    required this.btcFee,
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
