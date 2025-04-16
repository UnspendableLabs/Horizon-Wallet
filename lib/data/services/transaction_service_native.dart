import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/js/ecpair.dart' as ecpair;
import 'package:horizon/js/tiny_secp256k1.dart' as tinysecp256k1js;

class TransactionServiceNative implements TransactionService {
  final Config config;
  ecpair.ECPairFactory ecpairFactory =
      ecpair.ECPairFactory(tinysecp256k1js.ecc);
  final bitcoinRepository = GetIt.I.get<BitcoinRepository>();

  TransactionServiceNative({required this.config});

  @override
  Future<MakeRBFResponse> makeRBF({
    required String source,
    required String txHex,
    required num oldFee,
    required num newFee,
  }) async {
    throw UnimplementedError();
  }

  @override
  String signPsbt(String psbtHex, Map<int, String> inputPrivateKeyMap,
      [List<int>? sighashTypes]) {
    throw UnimplementedError();
  }

  @override
  String signMessage(String message, String privateKey) {
    throw UnimplementedError();
  }

  @override
  Future<String> signTransaction(
    String unsignedTransaction,
    String privateKey,
    String sourceAddress,
    Map<String, Utxo> utxoMap,
  ) async {
    throw UnimplementedError();
  }

  @override
  int getVirtualSize(String unsignedTransaction) {
    throw UnimplementedError();
  }

  @override
  bool validateFee(
      {required String rawtransaction,
      required int expectedFee,
      required Map<String, Utxo> utxoMap}) {
    throw UnimplementedError();
  }

  @override
  bool validateBTCAmount({
    required String rawtransaction,
    required String source,
    required int expectedBTC,
  }) {
    throw UnimplementedError();
  }

  @override
  int countSigOps({required String rawtransaction}) {
    throw UnimplementedError();
  }


  @override
  Future<String> constructChainAndSignTransaction(
      {required String unsignedTransaction,
      required String sourceAddress,
      required List<Utxo> utxos,
      required int btcQuantity,
      required String sourcePrivKey,
      required String destinationAddress,
      required String destinationPrivKey,
      required num fee}) async {
    throw UnimplementedError();
  }


  @override
  String psbtToUnsignedTransactionHex(String psbtHex) {
    throw UnimplementedError();
  }
}

