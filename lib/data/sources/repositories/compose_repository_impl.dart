import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/asset_info.dart' as asset_info;
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/entities/compose_issuance.dart'
    as compose_issuance;
import 'package:horizon/domain/entities/compose_send.dart' as compose_send;
import 'package:horizon/domain/entities/compose_mpma_send.dart'
    as compose_mpma_send;
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
import 'package:horizon/domain/entities/compose_destroy.dart'
    as compose_destroy;
import 'package:horizon/domain/entities/compose_dividend.dart'
    as compose_dividend;
import 'package:horizon/domain/entities/compose_sweep.dart' as compose_sweep;
import 'package:horizon/domain/entities/compose_burn.dart' as compose_burn;
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';

import 'package:horizon/data/sources/network/counterparty_client_factory.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/http_config.dart';

class ComposeRepositoryImpl extends ComposeRepository {
  final CounterpartyClientFactory _counterpartyClientFactory;

  ComposeRepositoryImpl({CounterpartyClientFactory? counterpartyClientFactory})
      : _counterpartyClientFactory =
            counterpartyClientFactory ?? GetIt.I<CounterpartyClientFactory>();

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
      final error = extractInvalidUtxoErrors(e.toString());

      return error.fold(() => throw e, (invalidUtxos) {
        // Remove all invalid UTXOs from the current input set
        final newInputsSet =
            removeUtxosFromList(currentInputsSet, invalidUtxos);

        if (newInputsSet.isEmpty) {
          throw Exception('No valid UTXOs left after removing invalid UTXOs');
        }

        // Retry with the updated input set
        return _retryOnInvalidUtxo(apiCall, newInputsSet);
      });
    }
  }

  List<Utxo> removeUtxosFromList(
      List<Utxo> inputSet, List<InvalidUtxo> invalidUtxos) {
    return inputSet.where((utxo) {
      return !invalidUtxos.any((invalidUtxo) =>
          utxo.txid == invalidUtxo.txHash &&
          utxo.vout == invalidUtxo.outputIndex);
    }).toList();
  }

  @override
  Future<compose_send.ComposeSendResponse> composeSendVerbose(
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_send.ComposeSendParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<compose_send.ComposeSendResponse>(
      (currentInputSet) async {
        final source = params.source;
        final destination = params.destination;
        final asset = params.asset;
        final quantity = params.quantity;
        const excludeUtxosWithBalances = true;
        const allowUnconfirmedInputs = true;
        const disableUtxoLocks = false;
        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeSendVerbose(
                source,
                destination,
                asset,
                quantity,
                allowUnconfirmedInputs,
                satPerVbyte,
                inputsSetString,
                excludeUtxosWithBalances,
                disableUtxoLocks);

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
                  locked: txVerbose.params.assetInfo.locked,
                  assetLongname: txVerbose.params.assetInfo.assetLongname,
                  description: txVerbose.params.assetInfo.description,
                  divisible: txVerbose.params.assetInfo.divisible),
              quantityNormalized: txVerbose.params.quantityNormalized,
            ),
            btcFee: txVerbose.btcFee,
            rawtransaction: txVerbose.rawtransaction,
            name: txVerbose.name,
            signedTxEstimatedSize: txVerbose.signedTxEstimatedSize.toDomain());
      },
      inputsSet,
    );
  }

  @override
  Future<compose_mpma_send.ComposeMpmaSendResponse> composeMpmaSend(
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_mpma_send.ComposeMpmaSendParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<compose_mpma_send.ComposeMpmaSendResponse>(
      (currentInputSet) async {
        final source = params.source;
        final destinations = params.destinations;
        final assets = params.assets;
        final quantities = params.quantities;
        const excludeUtxosWithBalances = true;
        const allowUnconfirmedInputs = true;
        const disableUtxoLocks = false;
        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeMpmaSend(
                source,
                destinations,
                assets,
                quantities,
                allowUnconfirmedInputs,
                satPerVbyte,
                inputsSetString,
                excludeUtxosWithBalances,
                disableUtxoLocks);

        if (response.result == null) {
          throw Exception('Failed to compose mpma send');
        }

        final txVerbose = response.result!;
        return compose_mpma_send.ComposeMpmaSendResponse(
            rawtransaction: txVerbose.rawtransaction,
            btcFee: txVerbose.btcFee,
            params: compose_mpma_send.ComposeMpmaSendResponseParams(
              source: txVerbose.params.source,
              assetDestQuantList: txVerbose.params.assetDestQuantList,
              memo: txVerbose.params.memo,
              memoIsHex: txVerbose.params.memoIsHex,
              skipValidation: txVerbose.params.skipValidation,
            ),
            name: txVerbose.name,
            signedTxEstimatedSize: txVerbose.signedTxEstimatedSize.toDomain());
      },
      inputsSet,
    );
  }

  @override
  Future<compose_issuance.ComposeIssuanceResponseVerbose>
      composeIssuanceVerbose(
          num satPerVbyte,
          List<Utxo> inputsSet,
          compose_issuance.ComposeIssuanceParams params,
          HttpConfig httpConfig) async {
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
        const excludeUtxosWithBalances = true;
        const disableUtxoLocks = false;
        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeIssuanceVerbose(
                source,
                name,
                quantity,
                transferDestination,
                divisible,
                lock,
                reset,
                description,
                unconfirmed,
                satPerVbyte,
                inputsSetString,
                excludeUtxosWithBalances,
                disableUtxoLocks);
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
            name: name,
            signedTxEstimatedSize: txVerbose.signedTxEstimatedSize.toDomain());
      },
      inputsSet,
    );
  }

  @override
  Future<compose_dispenser.ComposeDispenserResponseVerbose>
      composeDispenserVerbose(
          num satPerVbyte,
          List<Utxo> inputsSet,
          compose_dispenser.ComposeDispenserParams params,
          HttpConfig httpConfig) async {
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
        const exactFee = null;
        const allowUnconfirmedInputs = true;
        const excludeUtxosWithBalances = true;
        const disableUtxoLocks = false;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeDispenserVerbose(
                sourceAddress,
                asset,
                giveQuantity,
                escrowQuantity,
                mainchainrate,
                status,
                openAddress,
                oracleAddress,
                allowUnconfirmedInputs,
                exactFee,
                satPerVbyte,
                inputsSetString,
                excludeUtxosWithBalances,
                disableUtxoLocks);

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
            name: txVerbose.name,
            signedTxEstimatedSize: txVerbose.signedTxEstimatedSize.toDomain());
      },
      inputsSet,
    );
  }

  @override
  Future<compose_dispense.ComposeDispenseResponse> composeDispense(
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_dispense.ComposeDispenseParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<compose_dispense.ComposeDispenseResponse>(
      (currentInputSet) async {
        final sourceAddress = params.address;
        final dispenser = params.dispenser;
        final quantity = params.quantity;
        const allowUnconfirmedInputs = true;
        const excludeUtxosWithBalances = true;
        const disableUtxoLocks = false;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeDispense(
                sourceAddress,
                dispenser,
                quantity,
                allowUnconfirmedInputs,
                satPerVbyte,
                inputsSetString,
                excludeUtxosWithBalances,
                disableUtxoLocks);

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
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_fairmint.ComposeFairmintParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<compose_fairmint.ComposeFairmintResponse>(
      (currentInputSet) async {
        final sourceAddress = params.source;
        final asset = params.asset;
        final quantity = params.quantity;
        const excludeUtxosWithBalances = true;
        const disableUtxoLocks = false;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeFairmintVerbose(sourceAddress, asset, quantity, satPerVbyte,
                inputsSetString, excludeUtxosWithBalances, disableUtxoLocks);

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
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_fairminter.ComposeFairminterParams params,
      HttpConfig httpConfig) async {
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
        const excludeUtxosWithBalances = true;
        const disableUtxoLocks = false;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeFairminterVerbose(
                sourceAddress,
                asset,
                assetParent,
                divisible,
                maxMintPerTx,
                hardCap,
                startBlock,
                endBlock,
                satPerVbyte,
                lockQuantity,
                inputsSetString,
                excludeUtxosWithBalances,
                disableUtxoLocks);

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
      composeDispenserChain(
          int exactFee,
          DecodedTx prevDecodedTransaction,
          compose_dispenser.ComposeDispenserParams params,
          HttpConfig httpConfig) async {
    final source = params.source;
    final asset = params.asset;
    final giveQuantity = params.giveQuantity;
    final escrowQuantity = params.escrowQuantity;
    final mainchainrate = params.mainchainrate;
    const allowUnconfirmedInputs = true;
    const oracleAddress = null;
    const openAddress = null;
    final status = params.status ?? 0;
    const excludeUtxosWithBalances = true;
    const validateCompose = false;
    const disableUtxoLocks = false;

    final Vout? outputForChaining = prevDecodedTransaction.vout
        .firstWhereOrNull((vout) => vout.scriptPubKey.address == params.source);

    if (outputForChaining == null) {
      throw Exception('Output for chaining not found');
    }

    final scriptPubKey = outputForChaining.scriptPubKey;
    final int value =
        (outputForChaining.value * SATOSHI_RATE).ceil(); // convert to sats
    final String txid = prevDecodedTransaction.txid;
    final int vout = outputForChaining.n;

    // since this utxo hasn't been confirmed yet, we need to add all the necessary info for value and scriptPubKey
    final newInputSet = '$txid:$vout:$value:${scriptPubKey.hex}';

    final response = await _counterpartyClientFactory
        .getClient(httpConfig)
        .composeDispenserVerbose(
          source,
          asset,
          giveQuantity,
          escrowQuantity,
          mainchainrate,
          status,
          openAddress,
          oracleAddress,
          allowUnconfirmedInputs,
          exactFee,
          null, // null satPerVbyte since we need to specify the exact fee for the dispenser chain
          newInputSet,
          excludeUtxosWithBalances,
          validateCompose,
          disableUtxoLocks,
        );

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
        name: txVerbose.name,
        signedTxEstimatedSize: txVerbose.signedTxEstimatedSize.toDomain());
  }

  // CHAT make same HttpConfig change to all below endpoints
  @override
  Future<compose_order.ComposeOrderResponse> composeOrder(
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_order.ComposeOrderParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<compose_order.ComposeOrderResponse>(
      (currentInputSet) async {
        final source = params.source;
        final giveQuantity = params.giveQuantity;
        final giveAsset = params.giveAsset;
        final getQuantity = params.getQuantity;
        final getAsset = params.getAsset;
        const allowUnconfirmedInputs = true;
        const excludeUtxosWithBalances = true;
        const disableUtxoLocks = false;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response =
            await _counterpartyClientFactory.getClient(httpConfig).composeOrder(
                source,
                giveAsset,
                giveQuantity,
                getAsset,
                getQuantity,
                4 * 2016, // Expiration, two months
                0, // fee required
                allowUnconfirmedInputs,
                satPerVbyte,
                inputsSetString,
                excludeUtxosWithBalances,
                disableUtxoLocks);

        if (response.result == null) {
          throw Exception('Failed to compose order');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }

  @override
  Future<compose_cancel.ComposeCancelResponse> composeCancel(
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_cancel.ComposeCancelParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<compose_cancel.ComposeCancelResponse>(
      (currentInputSet) async {
        final source = params.source;
        final offerHash = params.offerHash;
        const excludeUtxosWithBalances = true;
        const allowUnconfirmedInputs = true;
        const disableUtxoLocks = false;
        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeCancel(
                source,
                offerHash,
                allowUnconfirmedInputs,
                satPerVbyte,
                inputsSetString,
                excludeUtxosWithBalances,
                disableUtxoLocks);

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
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_attach_utxo.ComposeAttachUtxoParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<
        compose_attach_utxo.ComposeAttachUtxoResponse>(
      (currentInputSet) async {
        final address = params.address;
        final asset = params.asset;
        final quantity = params.quantity;
        const excludeUtxosWithBalances = true;
        const disableUtxoLocks = false;
        const allowUnconfirmedInputs = true;
        const destinationVout = null;
        const skipValidation = false;
        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeAttachUtxo(
                address,
                asset,
                quantity,
                destinationVout,
                skipValidation,
                allowUnconfirmedInputs,
                satPerVbyte,
                inputsSetString,
                excludeUtxosWithBalances,
                disableUtxoLocks);

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
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_detach_utxo.ComposeDetachUtxoParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<
        compose_detach_utxo.ComposeDetachUtxoResponse>(
      (currentInputSet) async {
        final utxo = params.utxo;
        final destination = params.destination;
        const excludeUtxosWithBalances = true;
        const disableUtxoLocks = false;
        const allowUnconfirmedInputs = true;
        const skipValidation = false;

        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeDetachUtxo(
              utxo,
              destination,
              skipValidation,
              allowUnconfirmedInputs,
              satPerVbyte,
              inputsSetString,
              excludeUtxosWithBalances,
              disableUtxoLocks,
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
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_movetoutxo.ComposeMoveToUtxoParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<
        compose_movetoutxo.ComposeMoveToUtxoResponse>(
      (currentInputSet) async {
        final utxo = params.utxo;
        final destination = params.destination;
        const excludeUtxosWithBalances = true;
        const disableUtxoLocks = false;
        const allowUnconfirmedInputs = true;
        const skipValidation = false;
        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeMoveToUtxo(
              utxo,
              destination,
              skipValidation,
              allowUnconfirmedInputs,
              satPerVbyte,
              inputsSetString,
              excludeUtxosWithBalances,
              disableUtxoLocks,
            );

        if (response.result == null) {
          throw Exception('Failed to compose move to utxo');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }

  @override
  Future<compose_destroy.ComposeDestroyResponse> composeDestroy(
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_destroy.ComposeDestroyParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<compose_destroy.ComposeDestroyResponse>(
      (currentInputSet) async {
        final source = params.source;
        final asset = params.asset;
        final quantity = params.quantity;
        final tag = params.tag;
        const excludeUtxosWithBalances = true;
        const disableUtxoLocks = false;
        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeDestroy(
              source,
              asset,
              quantity,
              tag,
              satPerVbyte,
              inputsSetString,
              excludeUtxosWithBalances,
              disableUtxoLocks,
            );

        if (response.result == null) {
          throw Exception('Failed to compose destroy');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }

  @override
  Future<compose_dividend.ComposeDividendResponse> composeDividend(
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_dividend.ComposeDividendParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<compose_dividend.ComposeDividendResponse>(
      (currentInputSet) async {
        final source = params.source;
        final asset = params.asset;
        final quantityPerUnit = params.quantityPerUnit;
        final dividendAsset = params.dividendAsset;
        const excludeUtxosWithBalances = true;
        const disableUtxoLocks = false;
        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .composeDividend(
              source,
              asset,
              quantityPerUnit,
              dividendAsset,
              satPerVbyte,
              inputsSetString,
              excludeUtxosWithBalances,
              disableUtxoLocks,
            );

        if (response.result == null) {
          throw Exception('Failed to compose dividend');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }

  @override
  Future<compose_sweep.ComposeSweepResponse> composeSweep(
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_sweep.ComposeSweepParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<compose_sweep.ComposeSweepResponse>(
      (currentInputSet) async {
        final source = params.source;
        final destination = params.destination;
        final flags = params.flags;
        final memo = params.memo;
        const skipValidation = false;
        const disableUtxoLocks = false;
        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response =
            await _counterpartyClientFactory.getClient(httpConfig).composeSweep(
                  source,
                  destination,
                  flags,
                  memo,
                  satPerVbyte,
                  inputsSetString,
                  skipValidation,
                  disableUtxoLocks,
                );

        if (response.result == null) {
          throw Exception('Failed to compose sweep');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }

  @override
  Future<compose_burn.ComposeBurnResponse> composeBurn(
      num satPerVbyte,
      List<Utxo> inputsSet,
      compose_burn.ComposeBurnParams params,
      HttpConfig httpConfig) async {
    return await _retryOnInvalidUtxo<compose_burn.ComposeBurnResponse>(
      (currentInputSet) async {
        final source = params.source;
        final quantity = params.quantity;
        const excludeUtxosWithBalances = true;
        const disableUtxoLocks = false;
        final inputsSetString =
            currentInputSet.map((e) => "${e.txid}:${e.vout}").join(',');

        final response =
            await _counterpartyClientFactory.getClient(httpConfig).composeBurn(
                  source,
                  quantity,
                  satPerVbyte,
                  inputsSetString,
                  excludeUtxosWithBalances,
                  disableUtxoLocks,
                );

        if (response.result == null) {
          throw Exception('Failed to compose burn');
        }

        return response.result!.toDomain();
      },
      inputsSet,
    );
  }
}

class InvalidUtxo {
  final String txHash;
  final int outputIndex;

  InvalidUtxo(this.txHash, this.outputIndex);
}

Option<List<InvalidUtxo>> extractInvalidUtxoErrors(String errorMessage) {
  return _extractInvalidUtxoErrors(errorMessage).fold(
      () => extractInvalidUtxoError(errorMessage).map((utxo) => [utxo]),
      (utxos) => Option.of(utxos));
}

Option<List<InvalidUtxo>> _extractInvalidUtxoErrors(String errorMessage) {
  // Match the new format: array of invalid UTXOs
  final RegExp newFormatRegex = RegExp(r'invalid UTXOs: (.+)');
  final match = newFormatRegex.firstMatch(errorMessage);

  try {
    final listStr = match!.group(1);

    final List<String> utxoStrings =
        listStr!.split(',').map((s) => s.trim()).toList();

    final List<InvalidUtxo> utxos = utxoStrings.map((utxo) {
      final parts = utxo.split(':');
      final txHash = parts[0];
      final outputIndex = int.parse(parts[1]);
      return InvalidUtxo(txHash, outputIndex);
    }).toList();

    return Option.of(utxos);
  } catch (e) {
    return const Option.none();
  }
}

Option<InvalidUtxo> extractInvalidUtxoError(String errorMessage) {
  final RegExp regex = RegExp(r'invalid UTXO: ([a-fA-F0-9]{64}):(\d+)');
  final match = regex.firstMatch(errorMessage);

  return Option.fromNullable(match).map((m) {
    final txHash = m.group(1)!;
    final outputIndex = int.parse(m.group(2)!);
    return InvalidUtxo(txHash, outputIndex);
  });
}

List<Utxo> removeUtxoFromList(
    List<Utxo> inputSet, String txidToRemove, int voutToRemove) {
  return inputSet
      .where(
          (utxo) => !(utxo.txid == txidToRemove && utxo.vout == voutToRemove))
      .toList();
}
