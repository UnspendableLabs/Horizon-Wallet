import 'dart:js_interop';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/public_key_service.dart';
import 'package:horizon/js/buffer.dart';
import 'package:horizon/js/ecpair.dart' as ecpair;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:horizon/domain/repositories/config_repository.dart';

class PublicKeyServiceImpl implements PublicKeyService {
  final Config config;

  ecpair.ECPairFactory ecpairFactory =
      ecpair.ECPairFactory(tinysecp256k1js.ecc);
  final bitcoinRepository = GetIt.I.get<BitcoinRepository>();

  PublicKeyServiceImpl({required this.config});

  @override
  Future<String> fromPrivateKeyAsHex(String privateKey) async {
    Buffer privKeyJS =
        Buffer.from(Uint8List.fromList(hex.decode(privateKey)).toJS);

    final network = _getNetwork();

    ecpair.ECPair signer = ecpairFactory.fromPrivateKey(privKeyJS, network);

    return signer.publicKey.toDart
        .map(((byte) => byte.toRadixString(16).padLeft(2, "0")))
        .join();
  }

  _getNetwork() => switch (config.network) {
        Network.mainnet => ecpair.bitcoin,
        Network.testnet => ecpair.testnet,
        Network.testnet4 => ecpair.testnet,
        Network.regtest => ecpair.regtest,
      };
}
