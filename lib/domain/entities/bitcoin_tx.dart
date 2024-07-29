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

enum TransactionType { sender, recipient, neither }

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

  TransactionType getTransactionType(List<String> addresses) {
    bool isSender = vin
        .any((input) => addresses.contains(input.prevout.scriptpubkeyAddress));
    bool isRecipient =
        vout.any((output) => addresses.contains(output.scriptpubkeyAddress));

    if (isSender) {
      return TransactionType.sender;
    } else if (isRecipient) {
      return TransactionType.recipient;
    } else {
      return TransactionType.neither;
    }
  }

  Decimal getAmountSent(List<String> addresses) {
    // First, calculate the total input amount from the given addresses
    Decimal totalInput = vin
        .where((input) => addresses.contains(input.prevout.scriptpubkeyAddress))
        .fold(Decimal.zero,
            (sum, input) => sum + Decimal.fromInt(input.prevout.value));

    // Then, calculate the amount that goes back to the same addresses (change)
    Decimal changeAmount = vout
        .where((output) => addresses.contains(output.scriptpubkeyAddress))
        .fold(
            Decimal.zero, (sum, output) => sum + Decimal.fromInt(output.value));

    // The amount sent is the difference between total input and change
    return totalInput - changeAmount - Decimal.fromInt(fee);
  }

  Decimal getAmountReceived(List<String> addresses) {
    return vout
        .where((output) => addresses.contains(output.scriptpubkeyAddress))
        .fold(
            Decimal.zero, (sum, output) => sum + Decimal.fromInt(output.value));
  }

  // TODO: this isn't necessarily a perfect heuristic
  bool isCounterpartyTx() {
    return vout.any((output) => output.scriptpubkeyType == "op_return");
  }
}
