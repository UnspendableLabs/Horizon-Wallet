import 'dart:developer';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hex/hex.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/counterparty_api/counterparty_api.dart';
// import 'package:uniparty/models/transaction.dart';
import 'package:uniparty/models/send_transaction.dart';
import 'package:uniparty/models/internal_utxo.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/services/bitcoin/transaction/parser.dart';
import 'package:uniparty/services/key_value_store_service.dart';
import 'package:uniparty/bitcoin_js.dart' as bitcoinjs;

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
  TransactionSuccess({required this.transactionHex});
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

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(InitializeTransactionLoading()) {
    on<InitializeTransactionEvent>(
        (event, emit) async => await _onInitializeTransaction(event, emit));

    on<SendTransactionEvent>(
        (event, emit) async => _onSendTransactionEvent(event, emit));
  }
}

_onInitializeTransaction(event, emit) async {
  emit(InitializeTransactionLoading());
  KeyValueService keyValueService = GetIt.I.get<KeyValueService>();

  List<String> addressOptions =
      await _getAddressOptionsForNetwork(emit, event.network, keyValueService);

  emit(TransactionInitial(sourceAddressOptions: addressOptions));
}

_onSendTransactionEvent(event, emit) async {
  emit(SendTransactionLoading());
  final keyValueService = GetIt.I.get<KeyValueService>();
  final CounterpartyApi counterpartyApi = GetIt.I.get<CounterpartyApi>();
  // final TransactionParserI transactionParser = GetIt.I.get<TransactionParserI>();


  debugger(when: true);


  try {
    // final response = await counterpartyApi.createSendTransaction(event.transaction, event.network);

    String prevBurnHex =
        '01000000019755f4f1def5f08d32ea2d43c9b46a6af38187266ee2520d5b1255b26462648f000000001976a914e3d4787f20cf11c0d10234bce832f99817c73d4888acffffffff0258020000000000001976a914a11b66a67b3ff69671c8f82254099faf374b800e88ac59810a00000000001976a914e3d4787f20cf11c0d10234bce832f99817c73d4888ac00000000';
    String mostRecentBurnHex =
        '02000000000101f44045600ea785218b4fff27d2224a6d26e88446ec201ab04eb089caaf691b5900000000160014bbfb0e0b6e264fef37aadf6b4f3f5c0fd997ed96ffffffff0258020000000000001976a914a11b66a67b3ff69671c8f82254099faf374b800e88ac38150f0000000000160014bbfb0e0b6e264fef37aadf6b4f3f5c0fd997ed9602000000000000';
    String newestBurn =
        '02000000000101f44045600ea785218b4fff27d2224a6d26e88446ec201ab04eb089caaf691b5900000000160014bbfb0e0b6e264fef37aadf6b4f3f5c0fd997ed96ffffffff0258020000000000001976a914a11b66a67b3ff69671c8f82254099faf374b800e88ac61150f0000000000160014bbfb0e0b6e264fef37aadf6b4f3f5c0fd997ed9602000000000000';

    String? activeWalletJson =
        await keyValueService.get(ACTIVE_TESTNET_WALLET_KEY);
    if (activeWalletJson == null) {
      return emit(TransactionError(message: 'No active wallet found'));
    }
    WalletNode activeWallet = WalletNode.deserialize(activeWalletJson);

    final utxos = await counterpartyApi.getUnspentTxOut(
        activeWallet.address, event.network);

    Map<String, InternalUTXO> utxoMap = {for (var e in utxos) e.txid: e};
    print('utxoMap: $utxoMap');

    print('HERE WE ARE BEFORE TX');
    Uint8List buffer = Uint8List.fromList(HEX.decode(newestBurn));

    // Transaction transaction = transactionParser.fromHex(newestBurn);

    // TransactionBuilder txb = new TransactionBuilder();

    debugger(when: true);

    bitcoinjs.Transaction transaction =
        bitcoinjs.Transaction.fromHex(newestBurn.toJS);

    bitcoinjs.Psbt psbt = bitcoinjs.Psbt();

    // TODO wrap the JSTransaction such that we don't call toDart here

    for (var i = 0; i < transaction.ins.toDart.length; i++) {

      // We get reversed tx hashes somehow after jjparsing


      // var txhash = transaction.ins.toDart[i].hash.toDart.reversed.toList().map();
      //
      // print('txhash: $txhash');
      // // print()
      // var prev = utxoMap[txhash];
      // print('prev: $prev');
      //
      //
      // bool isBech32 = activeWallet.address.startsWith('bc1');
      //
      //
      // Uint8List publicKeyBytes = Uint8List.fromList(activeWallet.publicKey.codeUnits);
      //
      // bitcoinjs.Payment script;
      //
      // if (isBech32) {
      //   script = bitcoinjs.p2wpkh(bitcoinjs.Payment('testnet', publicKeyBytes.toJS));
      //   
      // } else {
      //   script = bitcoinjs.p2wpkh(bitcoinjs.Payment('testnet', publicKeyBytes.toJS));
      // }
      //
      //
      // debugger(when: true);

      // if (prev != null) {
      //
      //
      //   //
      //   // payment = bitcoinjs.Payment('testnet', prev.script);
      //
      //   // txb.addInput(tx.ins[i].hash.toString('hex'), prev.vout, null, input.output);
      //   // psbt.addInput({
      //   //   hash: txhash,
      //   //   index: prev.vout,
      //   //   // witnessScript
      //   //   // sequence: transaction.ins[i].sequence,
      //   //   // witnessUtxo: {script: prev.script, value: prev.value}
      //   // });
      // }
      // if (prev) txb.addInput(tx.ins[i].hash.toString('hex'), prev.vout, null, input.output);
    }
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
