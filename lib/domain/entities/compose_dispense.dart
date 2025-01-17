import "./compose_response.dart";
import "./compose_fn.dart";

class ComposeDispenseParams extends ComposeParams {
  final String address;
  final String dispenser;
  final int quantity; // in satoshis

  ComposeDispenseParams(
      {required this.address, required this.dispenser, required this.quantity});

  @override
  List<Object> get props => [
        address,
        dispenser,
        quantity,
      ];
}

class ComposeDispenseResponse implements ComposeResponse {
  @override
  final String rawtransaction;
  @override
  final int btcFee;
  @override
  final SignedTxEstimatedSize signedTxEstimatedSize;
  final ComposeDispenseResponseParams params;
  final String name;
  final int btcIn;
  final int btcOut;
  final int? btcChange;
  // final String data;

  const ComposeDispenseResponse({
    required this.rawtransaction,
    required this.params,
    required this.name,
    required this.btcIn,
    required this.btcOut,
    this.btcChange,
    required this.btcFee,
    required this.signedTxEstimatedSize,
    // required this.data,
  });
}

class ComposeDispenseResponseParams {
  final String source;
  final String destination;
  final int quantity;
  // final String quantityNormalized;

  const ComposeDispenseResponseParams({
    required this.source,
    required this.destination,
    required this.quantity,
    // required this.quantityNormalized
  });
}
