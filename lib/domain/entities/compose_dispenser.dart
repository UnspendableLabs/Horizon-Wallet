import "./compose_response.dart";
import "./compose_fn.dart";

class ComposeDispenserParams extends ComposeParams {
  final String source;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int? status;

  ComposeDispenserParams({
    required this.source,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    this.status,
  });

  @override
  List<Object> get props => [
        source,
        asset,
        giveQuantity,
        escrowQuantity,
        mainchainrate,
      ];
}

class ComposeDispenserResponse implements ComposeResponse {
  @override
  final String psbt;
  @override
  final String rawtransaction;
  @override
  final int btcFee;
  @override
  final SignedTxEstimatedSize signedTxEstimatedSize;
  final ComposeDispenserParams params;
  final String name;

  const ComposeDispenserResponse({
    required this.psbt,
    required this.rawtransaction,
    required this.btcFee,
    required this.signedTxEstimatedSize,
    required this.params,
    required this.name,
  });
}

class ComposeDispenserResponseParams {
  final String source;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int status;
  final String? openAddress;
  final String? oracleAddress;

  ComposeDispenserResponseParams({
    required this.source,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
    this.openAddress,
    this.oracleAddress,
  });
}

class ComposeDispenserResponseVerbose implements ComposeResponse {
  @override
  final String rawtransaction;

  @override
  final String psbt; 
  final ComposeDispenserResponseVerboseParams params;
  final String name;
  final int btcIn;
  final int btcOut;
  final int? btcChange;
  @override
  final int btcFee;
  @override
  final SignedTxEstimatedSize signedTxEstimatedSize;
  final String data;

  const ComposeDispenserResponseVerbose({
    required this.psbt,
    required this.rawtransaction,
    required this.params,
    required this.name,
    required this.btcIn,
    required this.btcOut,
    this.btcChange,
    required this.btcFee,
    required this.data,
    required this.signedTxEstimatedSize,
  });
}

class ComposeDispenserResponseVerboseParams {
  final String source;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int status;
  final String? openAddress;
  final String? oracleAddress;
  final String giveQuantityNormalized;
  final String escrowQuantityNormalized;

  const ComposeDispenserResponseVerboseParams({
    required this.source,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
    this.openAddress,
    this.oracleAddress,
    required this.giveQuantityNormalized,
    required this.escrowQuantityNormalized,
  });
}
