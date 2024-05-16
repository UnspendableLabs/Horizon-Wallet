import 'package:uniparty/js/ecpair.dart' as ecpairjs;
import 'package:uniparty/js/tiny_secp256k1.dart' as tinysecp256k1js;



abstract class ECPairService<T, N> {
  T fromWIF(String wif, N network);
  N get testnet;
  N get mainnet;
}


class ECPairJSService implements ECPairService<ecpairjs.ECPair, ecpairjs.Network> {

  ecpairjs.ECPairFactory ecpair = ecpairjs.ECPairFactory(tinysecp256k1js.ecc);

  @override
  ecpairjs.ECPair fromWIF(String wif, ecpairjs.Network network) {
    return ecpair.fromWIF(wif, network);
  }

  @override
  get testnet => ecpairjs.testnet;

  @override
  get mainnet => ecpairjs.bitcoin;


}









