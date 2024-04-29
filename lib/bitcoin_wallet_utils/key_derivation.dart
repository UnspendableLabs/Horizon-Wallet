import 'package:dartsv/dartsv.dart';
import 'package:uniparty/common/constants.dart';

HDPrivateKey deriveSeededKey(String seedHex, NetworkEnum network) {
  return HDPrivateKey.fromSeed(seedHex, getNetworkType(network));
}

HDPrivateKey deriveChildKey(HDPrivateKey seededKey, String path) {
  return seededKey.deriveChildKey(path);
}

NetworkType getNetworkType(NetworkEnum network) {
  switch (network) {
    case (NetworkEnum.testnet):
      return NetworkType.TEST; // testnet
    case (NetworkEnum.mainnet):
      return NetworkType.MAIN; // mainnet
  }
}
