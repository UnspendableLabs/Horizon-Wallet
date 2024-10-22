import 'package:decimal/decimal.dart';
import 'package:simple_rc4/simple_rc4.dart';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:horizon/core/logging/logger.dart';

String encodeHex(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

const String PREFIX = 'CNTRPRTY';

const String OP_CHECKSIG = 'OP_CHECKSIG';
const String OP_CHECKSIGVERIFY = 'OP_CHECKSIGVERIFY';
const String OP_CHECKMULTISIG = 'OP_CHECKMULTISIG';
const String OP_CHECKMULTISIGVERIFY = 'OP_CHECKMULTISIGVERIFY';
const int WITNESS_SCALE_FACTOR = 4;
const int MAX_PUBKEYS_PER_MULTISIG = 20;
final Decimal btcFactor = Decimal.fromInt(100000000);

class Script {

  final String pubkey; 
  final String pubkeyAsm;
  final String pubkeyType;
  final String? pubkeyAddress;



  Script({
    required this.pubkey,
    required this.pubkeyAsm,
    required this.pubkeyType,
    this.pubkeyAddress
    });

  int getSigOpCount({bool accurate = true}) {

    // TODO: validate that it's okay to ignore
    //       p2sh case
    int nSigOps = 0;
    List<String> ops = pubkeyAsm.split(' ');
    String lastOpcode = '';

    for (var op in ops) {
      if (op == OP_CHECKSIG || op == OP_CHECKSIGVERIFY) {
        nSigOps += 1;
      } else if (op == OP_CHECKMULTISIG || op == OP_CHECKMULTISIGVERIFY) {
        if (accurate && _isOpN(lastOpcode)) {
          int m = _decodeOpN(lastOpcode);
          nSigOps += m;
        } else {
          nSigOps += MAX_PUBKEYS_PER_MULTISIG;
        }
      }
      lastOpcode = op;
    }

    return nSigOps;
  }

  /// Checks if an opcode represents OP_N (OP_1 to OP_16).
  bool _isOpN(String opcode) {
    if (opcode.startsWith('OP_')) {
      var n = opcode.substring(3);
      if (n == '1NEGATE') return false;
      var value = int.tryParse(n);
      if (value != null && value >= 1 && value <= 16) {
        return true;
      }
    }
    return false;
  }

  /// Decodes OP_N opcode to its integer value (1 to 16).
  int _decodeOpN(String opcode) {
    if (_isOpN(opcode)) {
      return int.parse(opcode.substring(3));
    }
    return -1; // Invalid OP_N
  }
}

class Prevout {
  Script script;
  // final String scriptpubkey;
  // final String scriptpubkeyAsm;
  // final String scriptpubkeyType;
  // final String? scriptpubkeyAddress;
  final int value;
  //
  Prevout({
    required this.script,
    required this.value,
  });
}

class Vin {
  final String txid;
  final int vout;
  final Prevout? prevout;
  final String scriptsig;
  final String scriptsigAsm;
  final List<String>? witness;
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
  // final String scriptpubkey;
  // final String scriptpubkeyAsm;
  // final String scriptpubkeyType;
  // final String? scriptpubkeyAddress;
  final Script script;
  final int value;

  Vout({
    required this.script,
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
    bool isSender = vin.any((input) =>
        input.prevout?.script.pubkeyAddress != null &&
        addresses.contains(input.prevout!.script.pubkeyAddress));
    bool isRecipient =
        vout.any((output) => addresses.contains(output.script.pubkeyAddress));

    if (isSender) {
      return TransactionType.sender;
    } else if (isRecipient) {
      return TransactionType.recipient;
    } else {
      return TransactionType.neither;
    }
  }

  Decimal getAmountSent(List<String> addresses) {
    // Calculate the total input amount from the given addresses
    Decimal totalInput = vin.fold(Decimal.zero, (sum, input) {
      if (input.prevout != null &&
          addresses.contains(input.prevout!.script.pubkeyAddress)) {
        return sum + Decimal.fromInt(input.prevout!.value);
      }
      return sum;
    });

    // Calculate the amount that goes back to the same addresses (change)
    Decimal changeAmount = vout
        .where((output) => addresses.contains(output.script.pubkeyAddress))
        .fold(
            Decimal.zero, (sum, output) => sum + Decimal.fromInt(output.value));

    // The amount sent is the difference between total input and change
    return totalInput - changeAmount - Decimal.fromInt(fee);
  }

  Decimal getAmountReceived(List<String> addresses) {
    return vout
        .where((output) => addresses.contains(output.script.pubkeyAddress))
        .fold(
            Decimal.zero, (sum, output) => sum + Decimal.fromInt(output.value));
  }

  Decimal getAmountSentNormalized(List<String> addresses) {
    Decimal sats = getAmountSent(addresses);

    final btcValue = sats / btcFactor;

    return btcValue.toDecimal().round(scale: 8);
  }

  Decimal getAmountReceivedNormalized(List<String> addresses) {
    Decimal sats = getAmountReceived(addresses);

    final btcValue = sats / btcFactor;

    return btcValue.toDecimal().round(scale: 8);
  }

  bool isCounterpartyTx(Logger logger) {
    List<String> logs = [];

    try {
      if (vin.isEmpty) {
        logs.add("Transaction has no inputs.");
        return false;
      }

      // Use vin[0].txid as the RC4 key
      Uint8List vinTxidBytes = _hexToBytes(vin[0].txid);

      logs.add("$txid.isCounterpartyTx()");
      logs.add("Input vin[0].txid: ${vin[0].txid}");
      logs.add(
          "Using vin[0].txid bytes as RC4 key: ${encodeHex(vinTxidBytes)}");

      // Iterate through each output in the transaction
      for (Vout output in vout) {
        logs.add(
            "Processing output scriptpubkeyType: ${output.script.pubkeyType}");

        // Check if the output is an OP_RETURN output
        if (output.script.pubkeyType == 'op_return') {
          logs.add("Found OP_RETURN output");

          // Extract and clean hex data
          String dataHex = output.script.pubkeyAsm.replaceAll('OP_RETURN ', '');
          if (dataHex.contains("OP_PUSHBYTES")) {
            // Remove OP_PUSHBYTES_xx
            List<String> parts = dataHex.split(' ');
            dataHex = parts.last;
          }

          logs.add("Cleaned OP_RETURN data (hex): $dataHex");

          // Check if the data is valid hex
          if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(dataHex)) {
            logs.add(
                "Invalid hex data: ${dataHex.length > 20 ? '${dataHex.substring(0, 20)}...' : dataHex}");
            continue;
          }

          // Convert the hex data to bytes
          Uint8List dataBytes = _hexToBytes(dataHex);
          logs.add("OP_RETURN data (bytes): ${encodeHex(dataBytes)}");

          // Initialize the RC4 cipher with the vin[0].txid bytes as the key
          RC4 rc4 = RC4.fromBytes(vinTxidBytes);
          logs.add("Initialized RC4 with key: ${encodeHex(vinTxidBytes)}");

          // Decrypt the data
          List<int> decryptedData = rc4.encodeBytes(dataBytes);
          logs.add(
              "Decrypted data (bytes): ${encodeHex(Uint8List.fromList(decryptedData))}");
          // Convert decrypted bytes to string and log result
          String decodedData = String.fromCharCodes(decryptedData);
          // logs.add(
          //     "Decrypted data (string): ${decodedData.length > 20 ? decodedData.substring(0, 20) + '...' : decodedData}");

          // Check for Counterparty prefix
          if (decodedData.startsWith(PREFIX)) {
            logs.add("Counterparty transaction detected.");
            logger.info(logs.join("\n"));
            return true;
          } else {
            logs.add("Decoded data does not contain Counterparty prefix.");
          }
        } else if (output.script.pubkeyAsm.contains('OP_CHECKMULTISIG')) {
          logs.add("Processing potential multisig Counterparty transaction");

          // Extract the public keys from the scriptpubkeyAsm
          List<String> parts = output.script.pubkeyAsm.split(' ');
          List<String> pubKeys = [];
          for (int i = 0; i < parts.length; i++) {
            if (parts[i].startsWith('OP_PUSHBYTES')) {
              if (i + 1 < parts.length) {
                pubKeys.add(parts[i + 1]);
              }
            }
          }

          if (pubKeys.isNotEmpty) {
            logs.add("Found public keys in multisig script.");

            // Assemble the data chunk from the public keys
            String dataHex = '';
            for (String pubKey in pubKeys.sublist(0, pubKeys.length - 1)) {
              // Skip sign byte and nonce byte (first and last bytes of pubkey)
              if (pubKey.length >= 66) {
                dataHex += pubKey.substring(2, pubKey.length - 2);
              }
            }

            logs.add("Assembled data hex from pubkeys: $dataHex");

            // Convert the hex data to bytes
            Uint8List dataBytes = _hexToBytes(dataHex);
            logs.add("Multisig data (bytes): ${encodeHex(dataBytes)}");

            // Initialize the RC4 cipher with the vin[0].txid bytes as the key
            RC4 rc4 = RC4.fromBytes(vinTxidBytes);
            logs.add("Initialized RC4 with key: ${encodeHex(vinTxidBytes)}");

            // Decrypt the data
            List<int> decryptedData = rc4.encodeBytes(dataBytes);
            logs.add(
                "Decrypted data (bytes): ${encodeHex(Uint8List.fromList(decryptedData))}");

            // Decrypted data has a length byte at the start
            if (decryptedData.length > PREFIX.length + 1) {
              // Extract the length byte
              int chunkLength = decryptedData[0];
              logs.add("Chunk length from decrypted data: $chunkLength");

              // Check that the chunk length is valid
              if (chunkLength + 1 <= decryptedData.length) {
                // Extract the chunk
                Uint8List chunk = Uint8List.fromList(
                    decryptedData.sublist(1, 1 + chunkLength));

                // Check for Counterparty prefix
                if (chunk.length >= PREFIX.length) {
                  String prefixString =
                      String.fromCharCodes(chunk.sublist(0, PREFIX.length));
                  logs.add("Prefix from chunk: $prefixString");

                  if (prefixString == PREFIX) {
                    logs.add("Counterparty transaction detected.");
                    logger.debug(logs.join("\n"));
                    return true;
                  } else {
                    logs.add("Chunk does not contain Counterparty prefix.");
                  }
                } else {
                  logs.add(
                      "Chunk is too short to contain Counterparty prefix.");
                }
              } else {
                logs.add("Chunk length exceeds decrypted data length.");
              }
            } else {
              logs.add(
                  "Decrypted data is too short to contain Counterparty prefix.");
            }
          }
        }
      }

      // No valid Counterparty transaction detected
      logs.add("No Counterparty transaction detected.");
      logger.debug(logs.join("\n"));
      return false;
    } catch (e, stacktrace) {
      logs.add("An error occurred: $e");
      logs.add("Stacktrace: $stacktrace");
      logger.error(logs.join("\n"), null, stacktrace);
      return false;
    }
  }

  Uint8List _hexToBytes(String val) {
    List<int> bytes = hex.decode(val);
    return Uint8List.fromList(bytes);
  }
}
