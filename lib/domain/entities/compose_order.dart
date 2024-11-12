import "./compose_response.dart";
import "./compose_fn.dart";

class ComposeOrderParams extends ComposeParams {
  final String source;
  final int giveQuantity;
  final String giveAsset;
  final int getQuantity;
  final String getAsset;

  ComposeOrderParams({
    required this.source,
    required this.giveQuantity,
    required this.giveAsset,
    required this.getQuantity,
    required this.getAsset,
  });

  @override
  List<Object> get props => [giveQuantity, giveAsset, getQuantity, getAsset];
}

class ComposeOrderResponse implements ComposeResponse {
  @override
  final String rawtransaction;
  @override
  final int btcFee;

  final ComposeOrderResponseParams params;

  const ComposeOrderResponse({
    required this.rawtransaction,
    required this.btcFee,
    required this.params,
  });
}

class ComposeOrderResponseParams {
  final String source;
  final String giveAsset;
  final int giveQuantity;
  final String giveQuantityNormalized;
  final int getQuantity;
  final String getQuantityNormalized;
  final String getAsset;

  ComposeOrderResponseParams(
      {required this.source,
      required this.giveAsset,
      required this.giveQuantity,
      required this.giveQuantityNormalized,
      required this.getQuantity,
      required this.getQuantityNormalized,
      required this.getAsset});
}
