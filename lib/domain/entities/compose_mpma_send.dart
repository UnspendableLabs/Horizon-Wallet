import "./compose_response.dart";
import "./compose_fn.dart";

class ComposeMpmaSendParams extends ComposeParams {
  final String source;
  final String destinations;
  final String assets;
  final String quantities;
  final List<String>? memos; // ?memos=memo1&memos=memo2...

  ComposeMpmaSendParams({
    required this.source,
    required this.destinations,
    required this.assets,
    required this.quantities,
    this.memos,
  });

  @override
  List<Object> get props => [
        source,
        destinations,
        assets,
        quantities,
      ];
}

class ComposeMpmaSendResponseParams {
  final String source;
  final List<dynamic> assetDestQuantList;
  final String? memo;
  final bool? memoIsHex;
  final bool? skipValidation;

  ComposeMpmaSendResponseParams(
      {required this.source,
      required this.assetDestQuantList,
      this.memo,
      this.memoIsHex,
      this.skipValidation});
}

class ComposeMpmaSendResponse extends ComposeResponse {
  @override
  final String rawtransaction;
  @override
  final int btcFee;
  @override
  final SignedTxEstimatedSize signedTxEstimatedSize;
  final ComposeMpmaSendResponseParams params;
  final String name;

  ComposeMpmaSendResponse({
    required this.rawtransaction,
    required this.params,
    required this.name,
    required this.btcFee,
    required this.signedTxEstimatedSize,
  });
}
