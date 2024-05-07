// import 'dart:typed_data';

// // ignore: depend_on_referenced_packages
// import 'package:hex/hex.dart';
// import 'package:pointycastle/export.dart';

// String signTransaction(String rawTxHex, String privateKeyHex) {
//   // Initialize ECC curve for Bitcoin
//   final secp256k1 = ECCurve_secp256k1();

//   // Get the domain parameters directly from the predefined secp256k1 curve
//   ECCurve curve = secp256k1.curve;
//   ECPoint G = secp256k1.G; // Generator point
//   BigInt n = secp256k1.n; // Order of the curve
//   BigInt? h = secp256k1.h; // Cofactor

//   ECDomainParameters domainParams = ECDomainParametersImpl(
//       "secp256k1", // Name of the domain
//       curve, // ECCurve instance
//       G, // Generator point
//       n, // Order of the curve
//       h // Cofactor, usually 1 for secp256k1
//       );

//   // Decode the private key and create the key parameters
//   var privateKeyInt = BigInt.parse(privateKeyHex, radix: 16);
//   var privateKeyParams = ECPrivateKey(privateKeyInt, domainParams);

//   // Assume rawTxHex needs to be hashed for signing (double SHA256)
//   var rawTxBytes = HEX.decode(rawTxHex);
//   var txHash = SHA256Digest().process(SHA256Digest().process(Uint8List.fromList(rawTxBytes)));

//   // Sign the transaction hash
//   var signer = ECSignatureGenerator(domainParams);
//   var signature = signer.generateSignature(txHash, privateKeyParams);

//   // Format the signature and transaction to create a signed transaction hex
//   // This is highly simplified and specific to your transaction type and structure
//   String r = signature.r.toRadixString(16).padLeft(64, '0');
//   String s = signature.s.toRadixString(16).padLeft(64, '0');
//   String sigHex = '30${r.length.toRadixString(16)}$r${s.length.toRadixString(16)}$s'; // Simplified DER encoding

//   // This is a placeholder: You need to insert this signature into the correct place in your transaction
//   return rawTxHex + sigHex;
// }

// class SHA256Digest {
//   final digest = Digest("SHA-256");

//   Uint8List process(Uint8List data) {
//     return Uint8List.fromList(digest.process(data));
//   }
// }

// class ECSignatureGenerator {
//   final ECDomainParameters domain;

//   ECSignatureGenerator(this.domain);

//   ECSignature generateSignature(Uint8List hash, ECPrivateKey privateKey) {
//     var signer = Signer("SHA-256/ECDSA");
//     signer.init(true, PrivateKeyParameter<ECPrivateKey>(privateKey));
//     return signer.generateSignature(hash) as ECSignature;
//   }
// }

import 'dart:typed_data';
import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart';

String signTransaction(String rawTxHex, String privateKeyHex) {
  // Initialize ECC curve for Bitcoin
  final secp256k1 = ECCurve_secp256k1();

  // Get the domain parameters directly from the predefined secp256k1 curve
  ECCurve curve = secp256k1.curve;
  ECPoint G = secp256k1.G; // Generator point
  BigInt n = secp256k1.n; // Order of the curve
  BigInt? h = secp256k1.h; // Cofactor

  ECDomainParameters domainParams = ECDomainParametersImpl("secp256k1", curve, G, n, h);

  // Decode the private key and create the key parameters
  var privateKeyInt = BigInt.parse(privateKeyHex, radix: 16);
  var privateKeyParams = ECPrivateKey(privateKeyInt, domainParams);

  // Parsing and preparing the transaction for signing would go here
  // This involves creating a special version of the transaction with scriptSigs cleared, etc.

  var rawTxBytes = HEX.decode(rawTxHex);
  var txHash = SHA256Digest().process(SHA256Digest().process(Uint8List.fromList(rawTxBytes)));

  // Sign the transaction hash
  var signer = ECSignatureGenerator(domainParams);
  var signature = signer.generateSignature(txHash, privateKeyParams);

  // Properly format the signature with DER encoding and append Sighash type
  String r = signature.r.toRadixString(16).padLeft(64, '0');
  String s = signature.s.toRadixString(16).padLeft(64, '0');
  String sigHex = '30${r.length.toRadixString(16)}$r${s.length.toRadixString(16)}$s';
  sigHex += "01"; // Assuming SIGHASH_ALL

  // Proper insertion of the signature and public key into the transaction inputs
  // This step is crucial and needs specific handling depending on the transaction type

  return rawTxHex + sigHex; // Placeholder: Actual integration is more complex
}

class SHA256Digest {
  final digest = Digest("SHA-256");

  Uint8List process(Uint8List data) {
    return Uint8List.fromList(digest.process(data));
  }
}

class ECSignatureGenerator {
  final ECDomainParameters domain;

  ECSignatureGenerator(this.domain);

  ECSignature generateSignature(Uint8List hash, ECPrivateKey privateKey) {
    var signer = Signer("SHA-256/ECDSA");
    signer.init(true, PrivateKeyParameter<ECPrivateKey>(privateKey));
    return signer.generateSignature(hash) as ECSignature;
  }
}

String insertSignature({
  required String rawTxHex,
  required String sigHex,
  required String pubKeyHex,
  required int inputIndex,
  required List<String> originalScriptSigs,
}) {
  // Decode and parse the transaction
  // This step is highly simplified
  List<String> txParts = parseTransaction(rawTxHex);
  String scriptSig = formatScriptSig(sigHex, pubKeyHex);

  // Insert the scriptSig into the correct input
  txParts[inputIndex] = replaceScriptSig(txParts[inputIndex], scriptSig);

  // Rebuild the transaction from parts
  return rebuildTransaction(txParts, originalScriptSigs);
}

String formatScriptSig(String sigHex, String pubKeyHex) {
  return "$sigHex $pubKeyHex";
}

List<String> parseTransaction(String rawTxHex) {
  // Dummy function: real implementation needed to parse the hex into components
  return [rawTxHex]; // Placeholder
}

String replaceScriptSig(String input, String scriptSig) {
  // Dummy function: replace the scriptSig portion of the input
  return input; // Placeholder
}

String rebuildTransaction(List<String> parts, List<String> scriptSigs) {
  // Dummy function: serialize transaction parts back to hex
  return parts.join(); // Placeholder
}


