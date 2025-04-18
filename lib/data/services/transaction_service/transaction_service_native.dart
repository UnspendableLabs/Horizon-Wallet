import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

class TransactionServiceNative implements TransactionService {
  final Config config;
  final BitcoinRepository bitcoinRepository = GetIt.I.get<BitcoinRepository>();

  TransactionServiceNative({required this.config});

  Never _unimplemented(String method) {
    throw UnimplementedError(
        '[TransactionServiceNative] $method is not implemented for native platform.');
  }

  @override
  Future<MakeRBFResponse> makeRBF({
    required String source,
    required String txHex,
    required num oldFee,
    required num newFee,
  }) async {
    _unimplemented('makeRBF');
  }

  @override
  String signPsbt(String psbtHex, Map<int, String> inputPrivateKeyMap,
      [List<int>? sighashTypes]) {
    _unimplemented('signPsbt');
  }

  @override
  String psbtToUnsignedTransactionHex(String psbtHex) {
    _unimplemented('psbtToUnsignedTransactionHex');
  }

  @override
  String signMessage(String message, String privateKey) {
    _unimplemented('signMessage');
  }

  @override
  Future<String> signTransaction(
    String unsignedTransaction,
    String privateKey,
    String sourceAddress,
    Map<String, Utxo> utxoMap,
  ) async {
    final privateKey_ = ECPrivate.fromHex(privateKey);

    BtcTransaction transaction = BtcTransaction.deserialize(
        BytesUtils.fromHexString(unsignedTransaction));

    PsbtBuilderV2 psbt = PsbtBuilderV2.create();

    for (var input in transaction.inputs) {
      final utxo = utxoMap["${input.txId}:${input.txIndex}"];
      print(input.toString());
      print(utxo);
    }

    throw UnimplementedError("signTransac");
  }

  @override
  int getVirtualSize(String unsignedTransaction) {
    _unimplemented('getVirtualSize');
  }

  @override
  bool validateBTCAmount({
    required String rawtransaction,
    required String source,
    required int expectedBTC,
  }) {
    _unimplemented('validateBTCAmount');
  }

  @override
  bool validateFee({
    required String rawtransaction,
    required int expectedFee,
    required Map<String, Utxo> utxoMap,
  }) {
    _unimplemented('validateFee');
  }

  @override
  int countSigOps({required String rawtransaction}) {
    _unimplemented('countSigOps');
  }

  @override
  Future<String> constructChainAndSignTransaction({
    required String unsignedTransaction,
    required String sourceAddress,
    required List<Utxo> utxos,
    required int btcQuantity,
    required String sourcePrivKey,
    required String destinationAddress,
    required String destinationPrivKey,
    required num fee,
  }) async {
    _unimplemented('constructChainAndSignTransaction');
  }
}

TransactionService createTransactionServiceImpl({required Config config}) =>
    TransactionServiceNative(config: config);
