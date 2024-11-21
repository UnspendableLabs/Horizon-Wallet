import 'package:collection/collection.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/asset_info.dart' as asset_info;
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/entities/compose_issuance.dart'
    as compose_issuance;
import 'package:horizon/domain/entities/compose_send.dart' as compose_send;
import 'package:horizon/domain/entities/compose_dispenser.dart'
    as compose_dispenser;
import 'package:horizon/domain/entities/compose_fairmint.dart'
    as compose_fairmint;
import 'package:horizon/domain/entities/compose_fairminter.dart'
    as compose_fairminter;
import 'package:horizon/domain/entities/compose_dispense.dart'
    as compose_dispense;
import 'package:horizon/domain/entities/compose_order.dart' as compose_order;
import 'package:horizon/domain/entities/compose_cancel.dart' as compose_cancel;
import 'package:horizon/domain/entities/compose_attach_utxo.dart'
    as compose_attach_utxo;
import 'package:horizon/domain/entities/compose_detach_utxo.dart'
    as compose_detach_utxo;
import 'package:horizon/domain/entities/compose_movetoutxo.dart'
    as compose_movetoutxo;
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';

import 'package:logger/logger.dart';
import 'package:fpdart/fpdart.dart';

final logger = Logger();

class ComposeRepositoryImpl extends ComposeRepository {
  final V2Api api;

  ComposeRepositoryImpl({required this.api});

  Future<T> retryOnInvalidUtxo<T>(
      Future<T> Function(List<Utxo> inputsSet) apiCall,
      List<Utxo> inputsSet) async {
    return _retryOnInvalidUtxo(apiCall, inputsSet);
  }

  Future<T> _retryOnInvalidUtxo<T>(
      Future<T> Function(List<Utxo> inputsSet) apiCall,
      List<Utxo> currentInputsSet) async {
    try {
      return await apiCall(currentInputsSet);
    } catch (e) {
      final error = extractInvalidUtxoError(e.toString());

      return error.fold(() => throw e, (invalidUtxo) {
        final newInputsSet = removeUtxoFromList(
            currentInputsSet, invalidUtxo.txHash, invalidUtxo.outputIndex);
        if (newInputsSet.isEmpty) {
          throw Exception('No valid UTXOs left after removing invalid UTXO');
        }
        return _retryOnInvalidUtxo(apiCall, newInputsSet);
      });
    }
  }

  @override
  Future<compose_send.ComposeSendResponse> composeSendVerbose(int fee,
      List<Utxo> inputsSet, compose_send.ComposeSendParams params) async {
    return await _retryOnInvalidUtxo<compose_send.ComposeSendResponse>(
      (currentInputSet) async {
        final source = params.source;
        final destination = params.destination;
        final asset = params.asset;
        final quantity = params.quantity;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await api.composeSendVerbose(source, destination,
            asset, quantity, true, fee, null, inputsSetString);

        if (response.result == null) {
          throw Exception('Failed to compose send');
        }

        final txVerbose = response.result!;
        return compose_send.ComposeSendResponse(
            params: compose_send.ComposeSendResponseParams(
              source: txVerbose.params.source,
              destination: txVerbose.params.destination,
              asset: txVerbose.params.asset,
              quantity: txVerbose.params.quantity,
              useEnhancedSend: txVerbose.params.useEnhancedSend,
              assetInfo: asset_info.AssetInfo(
                  assetLongname: txVerbose.params.assetInfo.assetLongname,
                  description: txVerbose.params.assetInfo.description,
                  divisible: txVerbose.params.assetInfo.divisible),
              quantityNormalized: txVerbose.params.quantityNormalized,
            ),
            btcFee: txVerbose.btcFee,
            rawtransaction: txVerbose.rawtransaction,
            name: txVerbose.name);
      },
      inputsSet,
    );
  }

  @override
  Future<compose_issuance.ComposeIssuanceResponseVerbose>
      composeIssuanceVerbose(int fee, List<Utxo> inputsSet,
          compose_issuance.ComposeIssuanceParams params) async {
    return await _retryOnInvalidUtxo<
        compose_issuance.ComposeIssuanceResponseVerbose>(
      (currentInputSet) async {
        final source = params.source;
        final name = params.name;
        final quantity = params.quantity;
        final transferDestination = params.transferDestination;
        final divisible = params.divisible;
        final lock = params.lock;
        final reset = params.reset;
        final description = params.description;
        const unconfirmed = true;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await api.composeIssuanceVerbose(
            source,
            name,
            quantity,
            transferDestination,
            divisible,
            lock,
            reset,
            description,
            unconfirmed,
            fee,
            inputsSetString);
        if (response.result == null) {
          throw Exception('Failed to compose issuance');
        }

        final txVerbose = response.result!;
        return compose_issuance.ComposeIssuanceResponseVerbose(
            rawtransaction: txVerbose.rawtransaction,
            btcFee: txVerbose.btcFee,
            params: compose_issuance.ComposeIssuanceResponseVerboseParams(
              reset: txVerbose.params.reset,
              source: txVerbose.params.source,
              asset: txVerbose.params.asset,
              quantity: txVerbose.params.quantity,
              divisible: txVerbose.params.divisible,
              lock: txVerbose.params.lock,
              description: description,
              transferDestination: transferDestination,
              quantityNormalized: txVerbose.params.quantityNormalized,
            ),
            name: name);
      },
      inputsSet,
    );
  }

  @override
  Future<compose_dispenser.ComposeDispenserResponseVerbose>
      composeDispenserVerbose(int fee, List<Utxo> inputsSet,
          compose_dispenser.ComposeDispenserParams params) async {
    return await _retryOnInvalidUtxo<
        compose_dispenser.ComposeDispenserResponseVerbose>(
      (currentInputSet) async {
        final sourceAddress = params.source;
        final asset = params.asset;
        final giveQuantity = params.giveQuantity;
        final escrowQuantity = params.escrowQuantity;
        final mainchainrate = params.mainchainrate;
        final status = params.status ?? 0;
        const openAddress = null;
        const oracleAddress = null;
        const allowUnconfirmedTx = true;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await api.composeDispenserVerbose(
            sourceAddress,
            asset,
            giveQuantity,
            escrowQuantity,
            mainchainrate,
            status,
            openAddress,
            oracleAddress,
            allowUnconfirmedTx,
            fee,
            inputsSetString);

        if (response.result == null) {
          throw Exception('Failed to compose dispenser');
        }

        final txVerbose = response.result!;
        return compose_dispenser.ComposeDispenserResponseVerbose(
            rawtransaction: txVerbose.rawtransaction,
            btcIn: txVerbose.btcIn,
            btcOut: txVerbose.btcOut,
            btcChange: txVerbose.btcChange,
            btcFee: txVerbose.btcFee,
            data: txVerbose.data,
            params: compose_dispenser.ComposeDispenserResponseVerboseParams(
              source: txVerbose.params.source,
              asset: txVerbose.params.asset,
              giveQuantity: txVerbose.params.giveQuantity,
              escrowQuantity: txVerbose.params.escrowQuantity,
              mainchainrate: txVerbose.params.mainchainrate,
              status: txVerbose.params.status,
              openAddress: txVerbose.params.openAddress,
              oracleAddress: txVerbose.params.oracleAddress,
              giveQuantityNormalized: txVerbose.params.giveQuantityNormalized,
              escrowQuantityNormalized:
                  txVerbose.params.escrowQuantityNormalized,
            ),
            name: txVerbose.name);
      },
      inputsSet,
    );
  }

  @override
  Future<compose_dispense.ComposeDispenseResponse> composeDispense(
      int fee,
      List<Utxo> inputsSet,
      compose_dispense.ComposeDispenseParams params) async {
    return await _retryOnInvalidUtxo<compose_dispense.ComposeDispenseResponse>(
      (currentInputSet) async {
        final sourceAddress = params.address;
        final dispenser = params.dispenser;
        final quantity = params.quantity;
        const allowUnconfirmedTx = true;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await api.composeDispense(sourceAddress, dispenser,
            quantity, allowUnconfirmedTx, fee, inputsSetString);

        if (response.result == null) {
          throw Exception('Failed to compose dispense');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }

  @override
  Future<compose_fairmint.ComposeFairmintResponse> composeFairmintVerbose(
      int fee,
      List<Utxo> inputsSet,
      compose_fairmint.ComposeFairmintParams params) async {
    return await _retryOnInvalidUtxo<compose_fairmint.ComposeFairmintResponse>(
      (currentInputSet) async {
        final sourceAddress = params.source;
        final asset = params.asset;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await api.composeFairmintVerbose(
            sourceAddress, asset, fee, inputsSetString);

        if (response.result == null) {
          throw Exception('Failed to compose fairmint');
        }
        return response.result!.toDomain();
      },
      inputsSet,
    );
  }

  @override
  Future<compose_fairminter.ComposeFairminterResponse> composeFairminterVerbose(
      int fee,
      List<Utxo> inputsSet,
      compose_fairminter.ComposeFairminterParams params) async {
    return await _retryOnInvalidUtxo<
        compose_fairminter.ComposeFairminterResponse>(
      (currentInputSet) async {
        final sourceAddress = params.source;
        final asset = params.asset;
        final assetParent = params.assetParent;
        final maxMintPerTx = params.maxMintPerTx;
        final hardCap = params.hardCap;
        final startBlock = params.startBlock;
        final endBlock = params.endBlock;
        final divisible = params.divisible;
        final lockQuantity = params.lockQuantity;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await api.composeFairminterVerbose(
            sourceAddress,
            asset,
            assetParent,
            divisible,
            maxMintPerTx,
            hardCap,
            startBlock,
            endBlock,
            fee,
            lockQuantity,
            inputsSetString);

        if (response.result == null) {
          throw Exception('Failed to compose fairminter');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }

  @override
  Future<compose_dispenser.ComposeDispenserResponseVerbose>
      composeDispenserChain(int fee, DecodedTx prevDecodedTransaction,
          compose_dispenser.ComposeDispenserParams params) async {
    final source = params.source;
    final asset = params.asset;
    final giveQuantity = params.giveQuantity;
    final escrowQuantity = params.escrowQuantity;
    final mainchainrate = params.mainchainrate;
    final status = params.status ?? 0;

    final Vout? outputForChaining = prevDecodedTransaction.vout
        .firstWhereOrNull((vout) => vout.scriptPubKey.address == params.source);

    if (outputForChaining == null) {
      throw Exception('Output for chaining not found');
    }

    final scriptPubKey = outputForChaining.scriptPubKey;
    final int value =
        (outputForChaining.value * 100000000).toInt(); // convert to sats
    final String txid = prevDecodedTransaction.txid;
    final int vout = outputForChaining.n;

    // since this utxo hasn't been confirmed yet, we need to add all the necessary info for value and scriptPubKey
    final newInputSet = '$txid:$vout:$value:${scriptPubKey.hex}';

    final response = await api.composeDispenserVerbose(
        source,
        asset,
        giveQuantity,
        escrowQuantity,
        mainchainrate,
        status,
        null,
        null,
        true,
        fee,
        newInputSet,
        null,
        false,
        true);

    if (response.result == null) {
      throw Exception('Failed to compose send');
    }

    final txVerbose = response.result!;
    return compose_dispenser.ComposeDispenserResponseVerbose(
        rawtransaction: txVerbose.rawtransaction,
        btcIn: txVerbose.btcIn,
        btcOut: txVerbose.btcOut,
        btcChange: txVerbose.btcChange,
        btcFee: txVerbose.btcFee,
        data: txVerbose.data,
        params: compose_dispenser.ComposeDispenserResponseVerboseParams(
          source: txVerbose.params.source,
          asset: txVerbose.params.asset,
          giveQuantity: txVerbose.params.giveQuantity,
          escrowQuantity: txVerbose.params.escrowQuantity,
          mainchainrate: txVerbose.params.mainchainrate,
          status: txVerbose.params.status,
          openAddress: txVerbose.params.openAddress,
          oracleAddress: txVerbose.params.oracleAddress,
          giveQuantityNormalized: txVerbose.params.giveQuantityNormalized,
          escrowQuantityNormalized: txVerbose.params.escrowQuantityNormalized,
        ),
        name: txVerbose.name);
  }

  @override
  Future<compose_order.ComposeOrderResponse> composeOrder(int fee,
      List<Utxo> inputsSet, compose_order.ComposeOrderParams params) async {
    return await _retryOnInvalidUtxo<compose_order.ComposeOrderResponse>(
      (currentInputSet) async {
        final source = params.source;
        final giveQuantity = params.giveQuantity;
        final giveAsset = params.giveAsset;
        final getQuantity = params.getQuantity;
        final getAsset = params.getAsset;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await api.composeOrder(
            source,
            giveAsset,
            giveQuantity,
            getAsset,
            getQuantity,
            4 * 2016, // Two months,
            0, // fee required
            true, //  allow unconfirmed
            fee, //exect fee
            inputsSetString);

        if (response.result == null) {
          throw Exception('Failed to compose order');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }

  @override
  Future<compose_cancel.ComposeCancelResponse> composeCancel(int fee,
      List<Utxo> inputsSet, compose_cancel.ComposeCancelParams params) async {
    return await _retryOnInvalidUtxo<compose_cancel.ComposeCancelResponse>(
      (currentInputSet) async {
        final source = params.source;
        final offerHash = params.offerHash;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await api.composeCancel(
            source,
            offerHash,
            true, //  allow unconfirmed
            fee, //exect fee
            inputsSetString);

        if (response.result == null) {
          throw Exception('Failed to compose cancel');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }

  @override
  Future<compose_attach_utxo.ComposeAttachUtxoResponse> composeAttachUtxo(
      int fee,
      List<Utxo> inputsSet,
      compose_attach_utxo.ComposeAttachUtxoParams params) async {
    return await _retryOnInvalidUtxo<
        compose_attach_utxo.ComposeAttachUtxoResponse>(
      (currentInputSet) async {
        final address = params.address;
        final asset = params.asset;
        final quantity = params.quantity;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await api.composeAttachUtxo(
            address,
            asset,
            quantity,
            null,
            false,
            true, //  allow unconfirmed
            fee, //exect fee
            inputsSetString);

        if (response.result == null) {
          throw Exception('Failed to compose attach utxo');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }

  @override
  Future<compose_detach_utxo.ComposeDetachUtxoResponse> composeDetachUtxo(
      int fee,
      List<Utxo> inputsSet,
      compose_detach_utxo.ComposeDetachUtxoParams params) async {
    return await _retryOnInvalidUtxo<
        compose_detach_utxo.ComposeDetachUtxoResponse>(
      (currentInputSet) async {
        final utxo = params.utxo;
        final destination = params.destination;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await api.composeDetachUtxo(
          utxo,
          destination,
          false,
          true, //  allow unconfirmed
          fee, //exect fee
          inputsSetString,
        );

        if (response.result == null) {
          throw Exception('Failed to compose detach utxo');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }

  @override
  Future<compose_movetoutxo.ComposeMoveToUtxoResponse> composeMoveToUtxo(
      int fee,
      List<Utxo> inputsSet,
      compose_movetoutxo.ComposeMoveToUtxoParams params) async {
    return await _retryOnInvalidUtxo<
        compose_movetoutxo.ComposeMoveToUtxoResponse>(
      (currentInputSet) async {
        final utxo = params.utxo;
        final destination = params.destination;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await api.composeMoveToUtxo(
          utxo,
          destination,
          false,
          true, //  allow unconfirmed
          fee, //exect fee
          inputsSetString,
        );

        if (response.result == null) {
          throw Exception('Failed to compose move to utxo');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }
}

class InvalidUtxoError {
  final String txHash;
  final int outputIndex;

  InvalidUtxoError(this.txHash, this.outputIndex);
}

Option<InvalidUtxoError> extractInvalidUtxoError(String errorMessage) {
  final RegExp regex = RegExp(r'invalid UTXO: ([a-fA-F0-9]{64}):(\d+)');
  final match = regex.firstMatch(errorMessage);

  return Option.fromNullable(match).map((m) {
    final txHash = m.group(1)!;
    final outputIndex = int.parse(m.group(2)!);
    return InvalidUtxoError(txHash, outputIndex);
  });
}

List<Utxo> removeUtxoFromList(
    List<Utxo> inputSet, String txidToRemove, int voutToRemove) {
  return inputSet
      .where(
          (utxo) => !(utxo.txid == txidToRemove && utxo.vout == voutToRemove))
      .toList();
}
