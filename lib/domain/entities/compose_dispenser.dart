class ComposeDispenser {
  final String rawtransaction;
  final ComposeDispenserParams params;
  final String name;

  const ComposeDispenser({
    required this.rawtransaction,
    required this.params,
    required this.name,
  });
}

class ComposeDispenserParams {
  final String source;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int status;
  final String? openAddress;
  final String? oracleAddress;

  ComposeDispenserParams({
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

class ComposeDispenserVerbose {
  final String rawtransaction;
  final ComposeDispenserVerboseParams params;
  final String name;
  final int btcIn;
  final int btcOut;
  final int btcChange;
  final int btcFee;
  final String data;

  const ComposeDispenserVerbose({
    required this.rawtransaction,
    required this.params,
    required this.name,
    required this.btcIn,
    required this.btcOut,
    required this.btcChange,
    required this.btcFee,
    required this.data,
  });
}

class ComposeDispenserVerboseParams {
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

  const ComposeDispenserVerboseParams({
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

