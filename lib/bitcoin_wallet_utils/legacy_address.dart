import 'package:dartsv/dartsv.dart';
import 'package:uniparty/bitcoin_wallet_utils/key_derivation.dart';
import 'package:uniparty/common/constants.dart';

String deriveLegacyAdd(SVPublicKey publicKey, NetworkEnum network) {
  Address addr = publicKey.toAddress(getNetworkType(network));
  return addr.toBase58();
}
