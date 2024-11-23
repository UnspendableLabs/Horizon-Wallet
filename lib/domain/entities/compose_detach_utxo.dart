import "package:horizon/domain/entities/compose_response.dart";

import "./compose_fn.dart";

class ComposeDetachUtxoParams extends ComposeParams {
  final String utxo;
  final String destination;
  final int quantity;
  ComposeDetachUtxoParams({
    required this.utxo,
    required this.destination,
    required this.quantity,
  });

  @override
  List<Object> get props => [utxo, destination, quantity];
}

class ComposeDetachUtxoResponse implements ComposeResponse {
  @override
  final String rawtransaction;
  @override
  final int btcFee;
  final String data;
  final String name;

  final ComposeDetachUtxoResponseParams params;

  ComposeDetachUtxoResponse({
    required this.rawtransaction,
    required this.btcFee,
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
