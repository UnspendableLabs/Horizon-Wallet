
import 'package:uniparty/models/transaction.dart';
// import 'package:bdk_flutter/bdk_flutter.dart' as bdk;

abstract class TransactionParserI {
  Transaction fromHex(String txHash);
}

class DefaultTransactionParser implements TransactionParserI {
  @override
  Transaction fromHex(String txHash) {
    return Transaction.fromHex(txHash);
  }
}

// BDK not available on web, calls C from dart:ffi
// class BDKTransactionParser implements TransactionParserI {
//   @override
//   Transaction fromHex(String txHash) {
//     throw new UnimplementedError();
//   }
// }




