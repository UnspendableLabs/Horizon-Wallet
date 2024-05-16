import 'dart:developer';
import 'dart:js_interop';
import 'dart:js_util';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hex/hex.dart';
import 'package:uniparty/js/bitcoin.dart' as bitcoinjs;

import 'package:uniparty/common/constants.dart';
import 'package:uniparty/counterparty_api/counterparty_api.dart';
import 'package:uniparty/models/internal_utxo.dart';
// import 'package:uniparty/models/transaction.dart';
import 'package:uniparty/models/send_transaction.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/services/bitcoind.dart';
import 'package:uniparty/services/key_value_store_service.dart';

import 'package:uniparty/services/ecpair.dart' as ecpair;


import "package:uniparty/api/v2_api.dart" as v2_api;

import 'package:dio/dio.dart';

// TODO: move this to service def
final dio = Dio();
final client = v2_api.V2Api(dio);


sealed class TransactionState {
  const TransactionState();
}

class TransactionInitial extends TransactionState {
  final List<String> sourceAddressOptions;
  TransactionInitial({required this.sourceAddressOptions});
}

class InitializeTransactionLoading extends TransactionState {
  InitializeTransactionLoading();
}

class SendTransactionLoading extends TransactionState {
  SendTransactionLoading();
}

class TransactionSuccess extends TransactionState {
  final String transactionHex;
  final v2_api.Info info;
  TransactionSuccess({required this.transactionHex, required this.info});
}

class TransactionSignSuccess extends TransactionState {
  final String signedTransaction;
  TransactionSignSuccess({required this.signedTransaction});
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError({required this.message});
}

sealed class TransactionEvent {
  const TransactionEvent();
}

class InitializeTransactionEvent extends TransactionEvent {
  final NetworkEnum network;
  const InitializeTransactionEvent({required this.network});
}

class SendTransactionEvent extends TransactionEvent {
  final SendTransaction sendTransaction;
  final NetworkEnum network;
  SendTransactionEvent({required this.sendTransaction, required this.network});
}

class SignTransactionEvent extends TransactionEvent {
  final String unsignedTransaction;
  final NetworkEnum network;
  SignTransactionEvent(
      {required this.unsignedTransaction, required this.network});
}

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(InitializeTransactionLoading()) {
    on<InitializeTransactionEvent>(
        (event, emit) async => await _onInitializeTransaction(event, emit));

    on<SendTransactionEvent>(
        (event, emit) async => _onSendTransactionEvent(event, emit));

    on<SignTransactionEvent>(
        (event, emit) async => _onSignTransactionEvent(event, emit));
  }
}

_onInitializeTransaction(event, emit) async {
  emit(InitializeTransactionLoading());
  KeyValueService keyValueService = GetIt.I.get<KeyValueService>();

  List<String> addressOptions =
      await _getAddressOptionsForNetwork(emit, event.network, keyValueService);

  emit(TransactionInitial(sourceAddressOptions: addressOptions));
}

class DartPayment {
  /**
   * export interface Payment {
    name?: string;
    network?: Network;
    output?: Buffer; data?: Buffer[]; m?: number; n?: number; pubkeys?: Buffer[]; input?: Buffer; signatures?: Buffer[]; internalPubkey?: Buffer; pubkey?: Buffer;
    signature?: Buffer;
    address?: string;
    hash?: Buffer;
    redeem?: Payment;
    redeemVersion?: number;
    scriptTree?: Taptree;
    witness?: Buffer[];
}
   */
  String network;
  JSUint8Array pubkey;
  String address;
  String hash;

  DartPayment(
      {required this.network,
      required this.pubkey,
      required this.address,
      required this.hash});
}

_onSignTransactionEvent(event, emit) async {
  final bitcoindService = GetIt.I.get<BitcoindService>();
  final keyValueService = GetIt.I.get<KeyValueService>();
  final ecpairService = GetIt.I.get<ecpair.ECPairService>();
  // final TransactionParserI transactionParser = GetIt.I.get<TransactionParserI>();

  try {
    String? activeWalletJson =
        await keyValueService.get(ACTIVE_TESTNET_WALLET_KEY);

    if (activeWalletJson == null) {
      return emit(TransactionError(message: 'No active wallet found'));
    }
    WalletNode activeWallet = WalletNode.deserialize(activeWalletJson);

    final utxoResponse =
        await client.getUnspentUTXOs(activeWallet.address, false);

    if (utxoResponse.error != null) {
      return emit(TransactionError(message: utxoResponse.error!));
    }


    Map<String, v2_api.UTXO> utxoMap = {for (var e in utxoResponse.result! ) e.txid: e};

    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(event.unsignedTransaction);

    bitcoinjs.Psbt psbt = bitcoinjs.Psbt();



    print(activeWallet.privateKey);


    dynamic signer = ecpairService.fromWIF(activeWallet.privateKey, ecpairService.testnet);

    print("signer");
    print(signer);
    print(ecpairService.testnet);

    bool isSegwit = activeWallet.address.startsWith("bc") ||
        activeWallet.address.startsWith("tb");

    bitcoinjs.Payment script;
    if (isSegwit) {
      script = bitcoinjs.p2wpkh(bitcoinjs.PaymentOptions(
          pubkey: signer.publicKey, network: ecpairService.testnet));
    } else {
      script = bitcoinjs.p2pkh(bitcoinjs.PaymentOptions(
          pubkey: signer.publicKey, network: ecpairService.testnet));
    }

    for (var i = 0; i < transaction.ins.toDart.length; i++) {
      bitcoinjs.TxInput input = transaction.ins.toDart[i];

      var txHash = HEX.encode(input.hash.toDart.reversed.toList());

      var prev = utxoMap[txHash];

      if (prev != null) {
        if (isSegwit) {
          input.witnessUtxo = bitcoinjs.WitnessUTXO(
              script: script.output, value: prev.value.toJS);
          psbt.addInput(input);
        } else {
          input.script = script.output;
        }
      } else {
        debugger(when: true);
        print(utxoMap);

        print(transaction.ins);

        // TODO: handle errors in UI
        throw Exception('Invariant: No utxo found for txHash: $txHash');
      }
    }

    for (var i = 0; i < transaction.outs.toDart.length; i++) {
      bitcoinjs.TxOutput output = transaction.outs.toDart[i];

      psbt.addOutput(output);
    }

    psbt.signAllInputs(signer);

    psbt.finalizeAllInputs();

    bitcoinjs.Transaction tx = psbt.extractTransaction();

    String txHex = tx.toHex();

    bitcoindService.sendrawtransaction(txHex);

    emit(TransactionSignSuccess(signedTransaction: txHex));
  } catch (error) {
    rethrow;
    // emit(TransactionError(message: error.toString()));
  }
}

_onSendTransactionEvent(event, emit) async {
  emit(SendTransactionLoading());
  final keyValueService = GetIt.I.get<KeyValueService>();
  // final TransactionParserI transactionParser = GetIt.I.get<TransactionParserI>();

  try {
    String? activeWalletJson =
        await keyValueService.get(ACTIVE_TESTNET_WALLET_KEY);
    if (activeWalletJson == null) {
      return emit(TransactionError(message: 'No active wallet found'));
    }
    WalletNode activeWallet = WalletNode.deserialize(activeWalletJson);

    print(activeWallet.privateKey);

    final source = activeWallet.address;
    final destination = event.sendTransaction.destinationAddress;
    final quantity = event.sendTransaction
        .quantity; // TODO: Make asset dynamic ( probably shouldn't use enum to model asset type since we won't know all possible assets )
    // final asset = event.sendTransaction.asset;
    // final memo = event.sendTransaction.memo;
    // final memoIsHex = event.sendTransaction.memoIsHex;

    // String prevBurnHex =
    //     '01000000019755f4f1def5f08d32ea2d43c9b46a6af38187266ee2520d5b1255b26462648f000000001976a914e3d4787f20cf11c0d10234bce832f99817c73d4888acffffffff0258020000000000001976a914a11b66a67b3ff69671c8f82254099faf374b800e88ac59810a00000000001976a914e3d4787f20cf11c0d10234bce832f99817c73d4888ac00000000';
    // String mostRecentBurnHex =
    //     '02000000000101f44045600ea785218b4fff27d2224a6d26e88446ec201ab04eb089caaf691b5900000000160014bbfb0e0b6e264fef37aadf6b4f3f5c0fd997ed96ffffffff0258020000000000001976a914a11b66a67b3ff69671c8f82254099faf374b800e88ac38150f0000000000160014bbfb0e0b6e264fef37aadf6b4f3f5c0fd997ed9602000000000000';
    // String newestBurn =
    //     '02000000000101f44045600ea785218b4fff27d2224a6d26e88446ec201ab04eb089caaf691b5900000000160014bbfb0e0b6e264fef37aadf6b4f3f5c0fd997ed96ffffffff0258020000000000001976a914a11b66a67b3ff69671c8f82254099faf374b800e88ac61150f0000000000160014bbfb0e0b6e264fef37aadf6b4f3f5c0fd997ed9602000000000000';

    // V2 not running on testnet

    final response =
        await client.composeSend(source, destination, "XCP", quantity, true);



    if (response.error != null) {
      return emit(TransactionError(message: response.error!));
    }

    final txInfoResponse =
        await client.getTransactionInfo(response.result!.rawtransaction);

    if (txInfoResponse.error != null) {
      return emit(TransactionError(message: txInfoResponse.error!));
    }

    emit(TransactionSuccess(
        transactionHex: response.result!.rawtransaction,
        info: txInfoResponse.result!));
  } catch (error) {
    rethrow;
    // emit(TransactionError(message: error.toString()));
  }
}

Future<List<String>> _getAddressOptionsForNetwork(
    emit, NetworkEnum network, KeyValueService keyValueService) async {
  switch (network) {
    case NetworkEnum.mainnet:
      String? mainnetNodesJson =
          await keyValueService.get(MAINNET_WALLET_NODES_KEY);

      if (mainnetNodesJson == null) {
        return emit(TransactionError(message: 'No mainnet wallet nodes found'));
      }

      List<WalletNode> mainnetNodes =
          WalletNode.deserializeList(mainnetNodesJson);

      return mainnetNodes.map((e) => e.address).toList();

    case NetworkEnum.testnet:
      String? testnetNodesJson =
          await keyValueService.get(TESTNET_WALLET_NODES_KEY);

      if (testnetNodesJson == null) {
        return emit(TransactionError(message: 'No testnet wallet nodes found'));
      }

      List<WalletNode> testnetNodes =
          WalletNode.deserializeList(testnetNodesJson);

      return testnetNodes.map((e) => e.address).toList();
  }
}
