import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/domain/entities/compose_response.dart';

class ComposeBurnParams extends ComposeParams {
  final String source;
  final int quantity;

  ComposeBurnParams({
    required this.source,
    required this.quantity,
  });

  @override
  List<Object> get props => [source, quantity];
}

class ComposeBurnResponse implements ComposeResponse {

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
  final int btcIn;
  final int btcOut;
  final int? btcChange;

  final ComposeBurnResponseParams params;

  ComposeBurnResponse({
    required this.psbt,
    required this.rawtransaction,
    required this.btcFee,
    required this.signedTxEstimatedSize,
    required this.data,
    required this.name,
    required this.btcIn,
    required this.btcOut,
    this.btcChange,
    required this.params,
  });
}

class ComposeBurnResponseParams {
  final String source;
  final int quantity;
  final bool overburn;
  final bool skipValidation;

  ComposeBurnResponseParams({
    required this.source,
    required this.quantity,
    required this.overburn,
    required this.skipValidation,
  });
}
