import 'dart:typed_data';

import 'package:uniparty/models/buffer_reader.dart';
import 'package:hex/hex.dart';

class BitcoinjsTransaction {
  int version;
  List<TxInput> ins = [];
  List<TxOutput> outs = [];
  int locktime;
  bool hasWitnesses = false;

  BitcoinjsTransaction({this.version = 1, this.locktime = 0});

  bool checkWitnesses() {
    return ins.any((input) => input.witness.isNotEmpty);
  }

  factory BitcoinjsTransaction.fromHex(String txHex) {

    final buffer = Uint8List.fromList( HEX.decode(txHex));
    final reader = BufferReader(buffer);
    final tx = BitcoinjsTransaction();
    tx.version = reader.readInt32();
    final marker = reader.readUInt8();
    final flag = reader.readUInt8();

    if (marker == 0 && flag == 1) {
      tx.hasWitnesses = true;
    } else {
      reader.offset -= 2; // Rewind the offset if it's not a witness transaction
    }

    var vinLen = reader.readVarInt();
    for (int i = 0; i < vinLen; i++) {
      tx.ins.add(TxInput(
        hash: HEX.encode(reader.readSlice(32).reversed.toList()),
        index: reader.readUInt32(),
        script: HEX.encode(reader.readSlice(reader.readVarInt())),
        sequence: reader.readUInt32(),
      ));
    }

    var voutLen = reader.readVarInt();
    for (int i = 0; i < voutLen; i++) {
      tx.outs.add(TxOutput(
        value: reader.readUInt64().toInt(),
        script: reader.readSlice(reader.readVarInt()),
      ));
    }

    if (tx.hasWitnesses) {
      for (var input in tx.ins) {
        input.witness = reader.readVector();
      }
    }

    tx.locktime = reader.readUInt32();
    return tx;
  }
}

class TxInput {
  String hash;
  int index;
  String script;
  int sequence;
  List<Uint8List> witness;

  TxInput(
      {required this.hash,
      required this.index,
      required this.script,
      required this.sequence,
      this.witness = const []});
}

class TxOutput {
  int value;
  Uint8List script;

  TxOutput({required this.value, required this.script});
}
