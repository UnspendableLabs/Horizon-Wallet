import 'package:horizon/models/transaction.dart';
import 'package:test/test.dart';

// class BitcoinjsTransaction {
//   int version;
//   List<TxInput> ins = [];
//   List<TxOutput> outs = [];
//   int locktime;
//   bool hasWitnesses = false;
// BitcoinjsTransaction({this.version = 1, this.locktime = 0});
//
//   bool checkWitnesses() {
//     return ins.any((input) => input.witness.isNotEmpty);
//   }
// }
//
// class TxInput {
//   Uint8List hash;
//   int index;
//   Uint8List script;
//   int sequence;
//   List<Uint8List> witness;
//
//   TxInput({required this.hash, required this.index, required this.script, required this.sequence, this.witness = const []});
// }
//
// class TxOutput {
//   int value;
//   Uint8List script;
//
//   TxOutput({required this.value, required this.script});
// }

void main() async {
  group('legacy', () {
    test('parsed unsigned', () {
      // TODO: move raw tx out of file
      String tx =
          '01000000019755f4f1def5f08d32ea2d43c9b46a6af38187266ee2520d5b1255b26462648f000000001976a914e3d4787f20cf11c0d10234bce832f99817c73d4888acffffffff0258020000000000001976a914a11b66a67b3ff69671c8f82254099faf374b800e88ac59810a00000000001976a914e3d4787f20cf11c0d10234bce832f99817c73d4888ac00000000';

      Transaction parsed = Transaction.fromHex(tx);

      expect(parsed.version, 1);
      expect(parsed.hasWitnesses, false);

      expect(parsed.ins.length, 1);
      expect(parsed.ins[0].index, 0);
      expect(parsed.ins[0].hash, "8f646264b255125b0d52e26e268781f36a6ab4c9432dea328df0f5def1f45597");
      expect(parsed.ins[0].script, "76a914e3d4787f20cf11c0d10234bce832f99817c73d4888ac");
      expect(parsed.ins[0].sequence, 4294967295);
    });
  });
  group('segwit', () {
    test('parses unsigned', () {
      String tx =
          '02000000000101f44045600ea785218b4fff27d2224a6d26e88446ec201ab04eb089caaf691b5900000000160014bbfb0e0b6e264fef37aadf6b4f3f5c0fd997ed96ffffffff0258020000000000001976a914a11b66a67b3ff69671c8f82254099faf374b800e88ac61150f0000000000160014bbfb0e0b6e264fef37aadf6b4f3f5c0fd997ed9602000000000000';
    });
  });
}
