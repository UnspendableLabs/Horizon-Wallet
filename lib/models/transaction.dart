import 'package:uniparty/common/constants.dart';

class Transaction {
  final String sourceAddress;
  final String destinationAddress;
  final double quantity;
  final AssetEnum asset;
  final String? memo;
  final bool? memoIsHex;

  Transaction(
      {required this.sourceAddress,
      required this.destinationAddress,
      required this.quantity,
      required this.asset,
      this.memo,
      this.memoIsHex});
}
