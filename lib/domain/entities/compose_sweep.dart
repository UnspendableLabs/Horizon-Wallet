import 'package:horizon/domain/entities/compose_fn.dart';
import 'package:horizon/domain/entities/compose_response.dart';

class ComposeSweepParams extends ComposeParams {
  final String source;
  final String destination;
  final int flags;
  final String memo;

  ComposeSweepParams({
    required this.source,
    required this.destination,
    required this.flags,
    required this.memo,
  });

  @override
  List<Object?> get props => [source, destination, flags, memo];
}

class ComposeSweepResponse implements ComposeResponse {
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

  final ComposeSweepResponseParams params;

  ComposeSweepResponse({
    required this.psbt,
    required this.rawtransaction,
    required this.btcFee,
    required this.signedTxEstimatedSize,
    required this.data,
    required this.name,
    required this.params,
  });
}

class ComposeSweepResponseParams {
  final String source;
  final String destination;
  final int flags;
  final String memo;
  final bool skipValidation;

  ComposeSweepResponseParams({
    required this.source,
    required this.destination,
    required this.flags,
    required this.memo,
    required this.skipValidation,
  });
}
