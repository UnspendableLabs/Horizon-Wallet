class DecodedTx {
  final String txid;
  final String hash;
  final int version;
  final int size;
  final int vsize;
  final int weight;
  final int locktime;
  final List<Vin> vin;
  final List<Vout> vout;

  const DecodedTx({
    required this.txid,
    required this.hash,
    required this.version,
    required this.size,
    required this.vsize,
    required this.weight,
    required this.locktime,
    required this.vin,
    required this.vout,
  });
}

class Vin {
  final String txid;
  final int vout;
  final ScriptSig scriptSig;
  final List<String>? txinwitness;
  final int sequence;

  const Vin({
    required this.txid,
    required this.vout,
    required this.scriptSig,
    this.txinwitness,
    required this.sequence,
  });
}

class Vout {
  final double value;
  final int n;
  final ScriptPubKey scriptPubKey;

  const Vout({
    required this.value,
    required this.n,
    required this.scriptPubKey,
  });
}

class ScriptSig {
  final String asm;
  final String hex;

  const ScriptSig({
    required this.asm,
    required this.hex,
  });
}

class ScriptPubKey {
  final String asm;
  final String desc;
  final String hex;
  final String? address;
  final String type;

  const ScriptPubKey({
    required this.asm,
    required this.desc,
    required this.hex,
    this.address,
    required this.type,
  });
}
