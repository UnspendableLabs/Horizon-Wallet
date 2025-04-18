import 'package:convert/convert.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/js/bitcoin.dart' as bitcoin;
import 'package:horizon/js/ecpair.dart' as ecpair;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;
import 'package:horizon/js/signer.dart';

class ImportedAddressServiceWeb implements ImportedAddressService {
  final Config config;
  ecpair.ECPairFactory ecpairFactory =
      ecpair.ECPairFactory(tinysecp256k1js.ecc);

  ImportedAddressServiceWeb({required this.config});

  @override
  Future<String> getAddressPrivateKeyFromWIF({required String wif}) async {
    final ecpair.ECPairInterface ecpair_ =
        ecpairFactory.fromWIF(wif, _getNetwork());

    if (ecpair_.privateKey == null) {
      throw Exception("Private key not found");
    }

    final privateKey = ecpair_.privateKey!.toDart;

    return hex.encode(privateKey);
  }

  @override
  Future<String> getAddressFromWIF(
      {required String wif, required ImportAddressPkFormat format}) async {
    final Signer signer = ecpairFactory.fromWIF(wif, _getNetwork());

    final network = _getNetwork();

    final paymentOpts =
        bitcoin.PaymentOptions(pubkey: signer.publicKey, network: network);

    switch (format) {
      case ImportAddressPkFormat.segwit:
        return bitcoin.p2wpkh(paymentOpts).address;
      case ImportAddressPkFormat.legacy:
        return bitcoin.p2pkh(paymentOpts).address;
    }
  }

  _getNetwork() => switch (config.network) {
        Network.mainnet => ecpair.bitcoin,
        Network.testnet => ecpair.testnet,
        Network.testnet4 => ecpair.testnet,
        Network.regtest => ecpair.regtest,
      };
}

ImportedAddressService createImportedAddressServiceImpl(
        {required Config config}) =>
    ImportedAddressServiceWeb(config: config);
