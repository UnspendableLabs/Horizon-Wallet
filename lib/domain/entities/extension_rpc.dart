import 'package:horizon/domain/entities/address_rpc.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:flutter/foundation.dart';

class RPCGetAddressesSuccessCallbackArgs {
  final int tabId;
  final String requestId;
  final List<AddressRpc> addresses;
  final Network network;

  RPCGetAddressesSuccessCallbackArgs(
      {required this.tabId,
      required this.requestId,
      required this.addresses,
      required this.network});
}

typedef RPCCancelCallback = VoidCallback;

typedef RPCGetAddressesSuccessCallback = void Function(
    RPCGetAddressesSuccessCallbackArgs);

class RPCSignPsbtSuccessCallbackArgs {
  final int tabId;
  final String requestId;
  final String signedPsbt;

  RPCSignPsbtSuccessCallbackArgs(
      {required this.tabId, required this.requestId, required this.signedPsbt});
}

typedef RPCSignPsbtSuccessCallback = void Function(
    RPCSignPsbtSuccessCallbackArgs);

class RPCSignMessageSuccessCallbackArgs {
  final int tabId;
  final String requestId;
  final String signature;
  final String messageHash;
  final String address;

  RPCSignMessageSuccessCallbackArgs({
    required this.tabId,
    required this.requestId,
    required this.signature,
    required this.messageHash,
    required this.address,
  });
}

typedef RPCSignMessageSuccessCallback = void Function(
    RPCSignMessageSuccessCallbackArgs);

class RPCSignMessageBLSSuccessCallbackArgs {
  final int tabId;
  final String requestId;
  final String signature;
  final String publicKey;

  RPCSignMessageBLSSuccessCallbackArgs({
    required this.tabId,
    required this.requestId,
    required this.signature,
    required this.publicKey,
  });
}

typedef RPCSignMessageBLSSuccessCallback = void Function(
    RPCSignMessageBLSSuccessCallbackArgs);

class RPCGetBLSPoPSuccessCallbackArgs {
  final int tabId;
  final String requestId;
  final String xpubkey;
  final String blsPubkey;
  final String schnorrSig;
  final String blsSig;

  RPCGetBLSPoPSuccessCallbackArgs({
    required this.tabId,
    required this.requestId,
    required this.xpubkey,
    required this.blsPubkey,
    required this.schnorrSig,
    required this.blsSig,
  });
}

typedef RPCGetBLSPoPSuccessCallback = void Function(
    RPCGetBLSPoPSuccessCallbackArgs);

class RPCExportEncryptedBlsPrivateKeySuccessCallbackArgs {
  final int tabId;
  final String requestId;
  final String encryptedBlsPrivateKey;

  RPCExportEncryptedBlsPrivateKeySuccessCallbackArgs({
    required this.tabId,
    required this.requestId,
    required this.encryptedBlsPrivateKey,
  });
}

typedef RPCExportEncryptedBlsPrivateKeySuccessCallback = void Function(
    RPCExportEncryptedBlsPrivateKeySuccessCallbackArgs);

class RPCGetBalanceSuccessCallbackArgs {
  final int tabId;
  final String requestId;
  final String confirmed;
  final String unconfirmed;
  final String total;

  RPCGetBalanceSuccessCallbackArgs({
    required this.tabId,
    required this.requestId,
    required this.confirmed,
    required this.unconfirmed,
    required this.total,
  });
}

typedef RPCGetBalanceSuccessCallback = void Function(
    RPCGetBalanceSuccessCallbackArgs);

class RPCSendTransferSuccessCallbackArgs {
  final int tabId;
  final String requestId;
  final String txid;

  RPCSendTransferSuccessCallbackArgs({
    required this.tabId,
    required this.requestId,
    required this.txid,
  });
}

typedef RPCSendTransferSuccessCallback = void Function(
    RPCSendTransferSuccessCallbackArgs);

// Shared failure payload for the sats-connect getBalance / sendTransfer routes.
// Lets a fatal (non-retryable) failure return the real reason to the dApp and
// close the popup, instead of leaving the request hanging until the user
// manually closes the window — which the background then reports, misleadingly,
// as a user rejection.
class RPCErrorCallbackArgs {
  final int tabId;
  final String requestId;
  final String error;

  RPCErrorCallbackArgs({
    required this.tabId,
    required this.requestId,
    required this.error,
  });
}

// One error shape for every sats-connect RPC route: the JSON-RPC error is
// identical regardless of which method failed, so a single callback type backs
// them all (registered once, resolved by every route).
typedef RPCErrorCallback = void Function(RPCErrorCallbackArgs);
