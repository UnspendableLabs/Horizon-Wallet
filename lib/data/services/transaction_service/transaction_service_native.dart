import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';

import 'package:horizon/presentation/common/shared_util.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

class OPReturn implements BitcoinBaseAddress {
  final Script script;
  OPReturn(this.script);

  @override
  BitcoinAddressType get type => throw UnimplementedError();

  @override
  String get addressProgram => throw UnimplementedError();

  @override
  String pubKeyHash() => throw UnimplementedError();

  @override
  Script toScriptPubKey() => script;

  @override
  String toAddress(_) => "OP_RETURN";
}

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
    ECPrivate priv = ECPrivate.fromHex(privateKey);
    ECPublic pub = priv.getPublic();
    Script script = addressIsSegwit(sourceAddress)
        ? pub.toSegwitAddress().toScriptPubKey()
        : pub.toAddress().toScriptPubKey();

    BtcTransaction transaction = BtcTransaction.deserialize(
        BytesUtils.fromHexString(unsignedTransaction));

    PsbtBuilderV2 psbt = PsbtBuilderV2.create();

    for (TxInput input in transaction.inputs) {
      final prev = utxoMap["${input.txId}:${input.txIndex}"];
      if (prev == null) {
        throw Exception("Missing UTXO for ${input.txId}:${input.txIndex}");
      }

      final psbtUtxo = PsbtUtxo(
        utxo: BitcoinUtxo(
          txHash: prev.txid,
          vout: input.txIndex,
          value: BigInt.from(prev.value),
          scriptType: addressIsSegwit(sourceAddress)
              ? SegwitAddressType.p2wpkh
              : P2pkhAddressType.p2pkh,
        ),
        privateKeys: [priv],
        scriptPubKey: script,
      );

      final psbtInput = PsbtTransactionInput.fromUtxo(psbtUtxo);

      psbt.addInput(psbtInput);
    }

    for (TxOutput output in transaction.outputs) {
      final isOpReturn = output.scriptPubKey.script.isNotEmpty &&
          output.scriptPubKey.script.first == BitcoinOpcode.opReturn.name;

      final psbtOutput = PsbtTransactionOutput(
        amount: output.amount,
        address: isOpReturn
            ? OPReturn(output.scriptPubKey)
            : BitcoinScriptUtils.findAddressFromScriptPubKey(
                output.scriptPubKey),
      );

      psbt.addOutput(psbtOutput);
    }

    PsbtBtcSigner signer = PsbtDefaultSigner(priv);

    psbt.signAllInput((psbtSignerParams) {
      if (psbtSignerParams.scriptPubKey != script) {
        return null;
      }
      // assert(psbtSignerParams.address == sourceAddress);
      return PsbtSignerResponse(
          sighash: BitcoinOpCodeConst.sighashAll, signers: [signer]);
    });

    BtcTransaction signedTransaction = psbt.finalizeAll();

    return signedTransaction.toHex();
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
