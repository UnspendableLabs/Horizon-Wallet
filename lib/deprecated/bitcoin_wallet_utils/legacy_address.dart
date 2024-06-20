import 'package:dartsv/dartsv.dart';
import 'package:horizon/deprecated/bitcoin_wallet_utils/key_derivation.dart';
import 'package:horizon/common/constants.dart';

String deriveLegacyAddress(SVPublicKey publicKey, NetworkEnum network) {
  Address addr = publicKey.toAddress(getNetworkType(network));
  return addr.toBase58();
}