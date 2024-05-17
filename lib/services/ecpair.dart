import 'package:uniparty/js/ecpair.dart' as ecpairjs;
import 'package:uniparty/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:uniparty/js/common.dart' as common;



abstract class ECPairService<T, N> {
  T fromWIF(String wif, N network);
  N get testnet;
  N get mainnet;
}


class ECPairJSService implements ECPairService<ecpairjs.ECPair, common.Network> {

  ecpairjs.ECPairFactory ecpair = ecpairjs.ECPairFactory(tinysecp256k1js.ecc);

  @override
  ecpairjs.ECPair fromWIF(String wif, common.Network network) {
    return ecpair.fromWIF(wif, network);
  }

  @override
  get testnet => ecpairjs.testnet;

  @override
  get mainnet => ecpairjs.bitcoin;


}









