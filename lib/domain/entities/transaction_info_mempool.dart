class TransactionInfoMempool {
  final String txid;
  final int version;
  final int locktime;
  final List<Input> inputs;
  final List<Output> outputs;
  final int size;
  final int weight;
  final int fee;
  final TransactionStatusMempool status;

  const TransactionInfoMempool({
    required this.txid,
    required this.version,
    required this.locktime,
    required this.inputs,
    required this.outputs,
    required this.size,
    required this.weight,
    required this.fee,
    required this.status,
  });
}

class Input {
  final String txid;
  final int vout;
  final String? address;
  final int? value;
  final bool isCoinbase;
  final int sequence;

  const Input({
    required this.txid,
    required this.vout,
    this.address,
    this.value,
    required this.isCoinbase,
    required this.sequence,
  });
}

class Output {
  final String? address;
  final int value;
  final String scriptType;

  const Output({
    this.address,
    required this.value,
    required this.scriptType,
  });
}

class TransactionStatusMempool {
  final bool confirmed;
  final int? blockHeight;
  final String? blockHash;
  final int? blockTime;

  const TransactionStatusMempool({
    required this.confirmed,
    this.blockHeight,
    this.blockHash,
    this.blockTime,
  });
}
