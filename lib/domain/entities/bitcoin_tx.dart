import 'package:decimal/decimal.dart';

class Prevout {
  final String scriptpubkey;
  final String scriptpubkeyAsm;
  final String scriptpubkeyType;
  final String? scriptpubkeyAddress;
  final int value;

  Prevout({
    required this.scriptpubkey,
    required this.scriptpubkeyAsm,
    required this.scriptpubkeyType,
    this.scriptpubkeyAddress,
    required this.value,
  });
}

class Vin {
  final String txid;
  final int vout;
  final Prevout prevout;
  final String scriptsig;
  final String scriptsigAsm;
  final List<String> witness;
  final bool isCoinbase;
  final int sequence;

  Vin({
    required this.txid,
    required this.vout,
    required this.prevout,
    required this.scriptsig,
    required this.scriptsigAsm,
    required this.witness,
    required this.isCoinbase,
    required this.sequence,
  });
}

class Vout {
  final String scriptpubkey;
  final String scriptpubkeyAsm;
  final String scriptpubkeyType;
  final String? scriptpubkeyAddress;
  final int value;

  Vout({
    required this.scriptpubkey,
    required this.scriptpubkeyAsm,
    required this.scriptpubkeyType,
    this.scriptpubkeyAddress,
    required this.value,
  });
}

class Status {
  final bool confirmed;
  final int? blockHeight;
  final String? blockHash;
  final int? blockTime;

  Status({
    required this.confirmed,
    this.blockHeight,
    this.blockHash,
    this.blockTime,
  });
}

class BitcoinTx {
  final String txid;
  final int version;
  final int locktime;
  final List<Vin> vin;
  final List<Vout> vout;
  final int size;
  final int weight;
  final int fee;
  final Status status;

  BitcoinTx({
    required this.txid,
    required this.version,
    required this.locktime,
    required this.vin,
    required this.vout,
    required this.size,
    required this.weight,
    required this.fee,
    required this.status,
  });

  bool isSender(String address) {
    return vin.any((input) => input.prevout.scriptpubkeyAddress == address);
  }

  bool isRecipient(String address) {
    return vout.any((output) => output.scriptpubkeyAddress == address);
  }

  Decimal getAmountSent(String address) {
    return vin
        .where((input) => input.prevout.scriptpubkeyAddress == address)
        .fold(Decimal.zero,
            (sum, input) => sum + Decimal.fromInt(input.prevout.value));
  }

  Decimal getAmountReceived(String address) {
    return vout.where((output) => output.scriptpubkeyAddress == address).fold(
        Decimal.zero, (sum, output) => sum + Decimal.fromInt(output.value));
  }
}
