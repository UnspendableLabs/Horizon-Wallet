import "dart:convert";
import 'package:decimal/decimal.dart';
import "package:horizon/common/constants.dart";
import "package:horizon/domain/entities/asset.dart";
import "package:horizon/domain/entities/asset_quantity.dart";
import "package:horizon/domain/entities/psbt_type.dart";
import "package:horizon/domain/repositories/action_repository.dart";
import "package:horizon/domain/entities/action.dart";
import "package:fpdart/fpdart.dart";

// sign PSBT
const signPsbtAction =
    "signPsbt,1423382259,5f2306bc-6b41-4c74-9972-688ee27614a9,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff01009a020000000200000000000000000000000000000000000000000000000000000000000000000000000000ffffffff1a0c8c8d1fb07eecb8e024517e0b53830d73580e075c50367b7d187bb13eebfd0000000000ffffffff020000000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c80841e0000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c0000000000010304020000000001011f2202000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c01030483000000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlsxXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoic3dhcC1jcmVhdGUiLCJpbmZvIjp7ImFzc2V0IjoiQ1NBVCIsInF1YW50aXR5IjoxMDAwMDAwMDAsInByaWNlIjoyMDAwMDAwLCJleHBpcmVzX2F0IjoiMjAyNS0xMS0xOVQxNDo1Mjo1MS4zODRaIiwidXR4b19pZCI6ImZkZWIzZWIxN2IxODdkN2IzNjUwNWMwNzBlNTg3MzBkODM1MzBiN2U1MTI0ZTBiOGVjN2ViMDFmOGQ4YzBjMWE6MCIsInV0eG9fdmFsdWUiOjU0Niwic2VsbGVyX2FkZHJlc3MiOiJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiLCJhc3NldF9kaXZpc2liaWxpdHkiOmZhbHNlfX0=";

// DETACH
// parsing action string: signPsbt,1423381683,a806e4cb-8fa1-45ae-84ac-effa1a36c8f0,https://horizon.market,Horizon Market | Trade Bitcoin NFTs & Counterparty Tokens,https://horizon.market/icon0.ico?ca04633c4c0c2f74,70736274ff01004802000000011a0c8c8d1fb07eecb8e024517e0b53830d73580e075c50367b7d187bb13eebfd0000000000ffffffff0100000000000000000c6a0ac152adfb537dd25c6839000000000001011f2202000000000000160014ac2f1826c10fd1461de8e95fe17913ddecb2000c010304010000000000,eyJiYzFxNHNoM3Nma3BwbGc1djgwZ2E5MDd6N2dubWhrdHlxcXZlN3k1bjIiOlswXX0=,WzEzMSwxLDJd,eyJ0eXBlIjoiZGV0YWNoIiwiaW5mbyI6eyJ0eF9oYXNoIjoiZmRlYjNlYjE3YjE4N2Q3YjM2NTA1YzA3MGU1ODczMGQ4MzUzMGI3ZTUxMjRlMGI4ZWM3ZWIwMWY4ZDhjMGMxYSIsImFzc2V0IjoiIiwicXVhbnRpdHkiOjB9fQ==

//
// // Specific transaction info types
// export type DetachTransactionInfo = {
//   tx_hash: string;
// };
//
// export type AttachTransactionInfo = {
//   asset: string;
//   quantity: number;
//   asset_divisibility: boolean;
// };
//
// export type IssuanceTransactionInfo = {
//   asset?: string;
//   quantity?: number;
//   divisible?: boolean;
// };
//
// export type FairminterTransactionInfo = {
//   issuance_type?: string;
//   asset?: string;
//   quantity?: number;
//   divisible?: boolean;
//   max_mint_per_tx?: number;
//   quantity_by_price?: number;
//   premint_quantity?: number;
//   minted_asset_commission?: number;
//   encoding?: string | null;
//   inscription?: string | null | boolean;
//   description?: string;
//   mime_type?: string | null;
//   audio?: string | null;
//   media?: string | null;
//   start_block?: number;
//   end_block?: number;
//   soft_cap?: number;
//   soft_cap_deadline_block?: number;
// };
//
// export type FairmintTransactionInfo = {
//   asset: string;
//   quantity: number;
//   asset_divisibility: boolean;
// };
//
// export type SwapBuyTransactionInfo = {
//   asset: string | null;
//   quantity: number | null;
//   utxo_id: string;
//   price: number;
//   fee: number;
//   royalty: number;
//   issuer_address?: string;
//   asset_divisibility: boolean | null;
// };
//
// export type SwapCreateTransactionInfo = {
//   asset?: string;
//   quantity?: number;
//   price: number;
//   expires_at?: Date;
//   utxo_id: string;
//   utxo_value: number;
//   seller_address: string;
//   asset_divisibility?: boolean;
// };
//
// export type SwapCreateFeeTransactionInfo = {
//   seller_address: string;
// };
//
// export type SwapMultiBuyTransactionInfo = {
//   swaps: Array<{
//     id: string;
//     asset: string | null;
//     quantity: number | null;
//     price: number;
//     utxo_id: string;
//     asset_divisibility: boolean | null;
//   }>;
//   fee: number;
//   royalty: number;
//   issuer_address?: string;
// };
//
// export type CancelOrderTransactionInfo = {
//   tx_hash: string;
//   asset?: string | null;
//   quantity?: string | number | null;
//   price?: string | number;
//   xcp_price?: string | number | null;
//   created_at?: string | number | Date;
//   asset_divisibility?: boolean | null;
// };
//
// export type OrderCreateTransactionInfo = {
//   get_asset: string;
//   give_asset: string;
//   get_quantity: string;
//   give_quantity: string;
//   expiration: number;
//   get_asset_divisibility: boolean | null;
//   give_asset_divisibility: boolean | null;
// };
//
// // Tool-specific transaction info types
// export type SendTransactionInfo = {
//   destination: string;
//   asset: string;
//   quantity: number;
//   asset_divisibility: boolean;
// };
//
// export type MpmaTransactionInfo = {
//   sends: Array<{
//     destination: string;
//     asset: string;
//     quantitie: number;
//     asset_divisibility: boolean;
//   }>;
// };
//
// export type SweepTransactionInfo = {
//   destination: string;
//   flags: number;
//   memo: string;
// };
//
// export type MoveTransactionInfo = {
//   utxo: string;
//   destination: string;
// };
//
// export type DividendTransactionInfo = {
//   asset: string;
//   dividend_asset: string;
//   quantity_per_unit: number;
//   asset_divisibility: boolean;
// };
//
// export type DestroyTransactionInfo = {
//   asset: string;
//   quantity: number;
//   tag: string;
//   asset_divisibility: boolean;
// };
//
// export type LockQuantityTransactionInfo = {
//   asset: string;
//   quantity: number;
//   lock: boolean;
//   divisible: boolean;
//   asset_divisibility: boolean;
// };
//
// export type LockDescriptionTransactionInfo = {
//   asset: string;
//   quantity: number;
//   description: string;
//   divisible: boolean;
//   asset_divisibility: boolean;
// };
//
// export type ChangeDescriptionTransactionInfo = {
//   asset: string;
//   description: string;
//   quantity: number;
//   divisible: boolean;
//   asset_divisibility: boolean;
// };
//
// export type ChangeOwnershipTransactionInfo = {
//   asset: string;
//   transfer_destination: string;
//   quantity: number;
//   divisible: boolean;
//   asset_divisibility: boolean;
// };
//
// export type ResetTransactionInfo = {
//   asset: string;
//   quantity: number;
//   divisible: boolean;
//   reset: boolean;
//   asset_divisibility: boolean;
// };
//
// export type IssueMoreTransactionInfo = {
//   asset: string;
//   quantity: number;
//   divisible: boolean;
//   asset_divisibility: boolean;
// };
//
// // Discriminated union for all transaction types
// export type TransactionInfo =
//   | { type: "detach"; info: DetachTransactionInfo }
//   | { type: "attach"; info: AttachTransactionInfo }
//   | { type: "issuance"; info: IssuanceTransactionInfo }
//   | { type: "fairminter"; info: FairminterTransactionInfo }
//   | { type: "fairmint"; info: FairmintTransactionInfo }
//   | { type: "swap-buy"; info: SwapBuyTransactionInfo }
//   | { type: "swap-create"; info: SwapCreateTransactionInfo }
//   | { type: "swap-create-fee"; info: SwapCreateFeeTransactionInfo }
//   | { type: "swap-multi-buy"; info: SwapMultiBuyTransactionInfo }
//   | { type: "cancel-order"; info: CancelOrderTransactionInfo }
//   | { type: "order-create"; info: OrderCreateTransactionInfo }
//   | { type: "send"; info: SendTransactionInfo }
//   | { type: "mpma"; info: MpmaTransactionInfo }
//   | { type: "sweep"; info: SweepTransactionInfo }
//   | { type: "move"; info: MoveTransactionInfo }
//   | { type: "dividend"; info: DividendTransactionInfo }
//   | { type: "destroy"; info: DestroyTransactionInfo }
//   | { type: "lock-quantity"; info: LockQuantityTransactionInfo }
//   | { type: "lock-description"; info: LockDescriptionTransactionInfo }
//   | { type: "change-description"; info: ChangeDescriptionTransactionInfo }
//   | { type: "change-ownership"; info: ChangeOwnershipTransactionInfo }
//   | { type: "reset"; info: ResetTransactionInfo }
//   | { type: "issue-more"; info: IssueMoreTransactionInfo };

const Set<String> originWhitelist = {
  "https://horizon.market",
  "https://horizon-market-testnet.vercel.app",
  "https://horizon-market-signet.vercel.app"
};

RPCSignPsbtAction _buildSignPsbtAction({
  required String tabId,
  required String requestId,
  required String origin,
  required String title,
  required String favicon,
  required String psbt,
  required String signInputsB64,
  required String sighashTypesB64,
  required String txInfoB64,
}) {
  final intTabId = int.parse(tabId);
  final decOrigin = Uri.decodeComponent(origin);
  final decTitle = Uri.decodeComponent(title);
  final decFavicon = Uri.decodeComponent(favicon);

  final signInputs =
      _parseSignInputs(signInputsB64); // throws on bad format (kept)

  final sighashTypes = _parseNullableSighashTypes(sighashTypesB64);

  final txInfo = _parseNullableTxInfo(txInfoB64);

  final psbtType = _derivePsbtType(origin: decOrigin, txInfo: txInfo);

  return RPCSignPsbtAction(
    intTabId,
    requestId,
    decOrigin,
    decTitle,
    decFavicon,
    psbt,
    signInputs,
    sighashTypes,
    psbtType,
  );
}

Map<String, List<int>> _parseSignInputs(String signInputsStr) {
  try {
    // Decode from base64 → UTF8 → JSON
    final str = utf8.decode(base64.decode(signInputsStr));
    final jsonMap = json.decode(str) as Map<String, dynamic>;

    // Convert JSON map to Map<String, List<int>>
    return jsonMap.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.cast<int>());
      } else {
        throw const FormatException("Invalid signInputs format");
      }
    });
  } catch (e) {
    throw FormatException("Failed to parse signInputs: $e");
  }
}

List<int>? _parseNullableSighashTypes(String b64) {
  try {
    final bytes = base64.decode(b64);
    final v = json.decode(utf8.decode(bytes));
    if (v == null) return null; // JSON null
    if (v is List && v.every((e) => e is num)) {
      return v.map((e) => (e as num).toInt()).toList();
    }
    return null; // anything else → treat as absent
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _parseNullableTxInfo(String b64) {
  try {
    final bytes = base64.decode(b64);
    final v = json.decode(utf8.decode(bytes));
    if (v == null) return null; // JSON null
    return (v is Map<String, dynamic>) ? v : null;
  } catch (_) {
    return null;
  }
}

PsbtType _derivePsbtType({
  required String? origin,
  required Map<String, dynamic>? txInfo,
}) {
  if (txInfo == null) return OpaquePsbt();
  if (origin == null || !originWhitelist.contains(origin)) return OpaquePsbt();

  final type = txInfo["type"];
  final info = txInfo["info"];

  if (type is! String || info is! Map<String, dynamic>) return OpaquePsbt();

  print("Deriving PsbtType for type='$type', info=$info");

  switch (type) {
    case "fairminter":
      final issuanceType = _asString(info["issuance_type"]);
      final asset = _asString(info["asset"]);
      final quantityInt = _asInt(info["quantity"]);
      final divisible = _asBool(info["divisible"]);
      final maxMintPerTx = _asInt(info["max_mint_per_tx"]);
      final quantityByPriceInt = _asInt(info["quantity_by_price"]);
      final premintQuantityInt = _asInt(info["premint_quantity"]);
      final mintedAssetCommission = info["minted_asset_commission"] is num
          ? (info["minted_asset_commission"] as num).toDouble()
          : null;
      final encoding = _asString(info["encoding"]);
      final inscription = info["inscription"] is String
          ? info["inscription"] as String
          : (info["inscription"] is bool
              ? (info["inscription"] as bool).toString()
              : null);
      final description = _asString(info["description"]);
      final mimeType = _asString(info["mime_type"]);
      final audio = _asString(info["audio"]);
      final media = _asString(info["media"]);
      final startBlock = _asInt(info["start_block"]);
      final endBlock = _asInt(info["end_block"]);
      final softCap = _asInt(info["soft_cap"]);
      final softCapDeadlineBlock = _asInt(info["soft_cap_deadline_block"]);

      return Fairminter(
        issuanceType: issuanceType,
        asset: asset,
        quantity: quantityInt != null
            ? AssetQuantity(
                divisible: divisible,
                quantity: BigInt.from(quantityInt),
              )
            : null,
        maxMintPerTx: maxMintPerTx != null
            ? AssetQuantity(
                divisible: divisible,
                quantity: BigInt.from(maxMintPerTx),
              )
            : null,
        quantityByPrice:
            quantityByPriceInt != null ? BigInt.from(quantityByPriceInt) : null,
        premintQuantity: premintQuantityInt != null
            ? AssetQuantity(
                divisible: divisible,
                quantity: BigInt.from(premintQuantityInt),
              )
            : null,
        mintedAssetCommission: mintedAssetCommission,
        encoding: encoding,
        inscription: inscription,
        description: description,
        mimeType: mimeType,
        audio: audio,
        media: media,
        startBlock: startBlock,
        endBlock: endBlock,
        softCap: softCap,
        softCapDeadlineBlock: softCapDeadlineBlock,
      );
    case "issuance":
      final asset = _asString(info["asset"]);
      final quantityInt = _asInt(info["quantity"]);
      final divisible = _asBool(info["divisible"]);

      return Issuance(
          asset: asset ?? "-",
          quantity: AssetQuantity(
            divisible: divisible,
            quantity: BigInt.from(quantityInt ?? 0),
          ));
    case "issue-more":
      final asset = _asString(info["asset"]);
      final quantityInt = _asInt(info["quantity"]);
      final divisible = _asBool(info["divisible"]);

      return IssueMore(
          asset: asset ?? "-",
          quantity: AssetQuantity(
            divisible: divisible,
            quantity: BigInt.from(quantityInt ?? 0),
          ));
    case "reset":
      final asset = _asString(info["asset"]);
      final reset = _asBool(info["reset"]);
      final quantityInt = _asInt(info["quantity"]);
      final divisible = _asBool(info["divisible"]);

      return Reset(
          asset: asset ?? "-",
          reset: reset,
          quantity: AssetQuantity(
            divisible: divisible,
            quantity: BigInt.from(quantityInt ?? 0),
          ));
    case "change-ownership":
      final asset = _asString(info["asset"]);
      final transferDestination = _asString(info["transfer_destination"]);

      return ChangeOwnership(
        asset: asset ?? "-",
        transferDestination: transferDestination ?? "-",
      );
    case "change-description":
      final asset = _asString(info["asset"]);
      final description = _asString(info["description"]);

      return ChangeDescription(
        asset: asset ?? "-",
        description: description ?? "",
      );
    case "lock-description":
      final asset = _asString(info["asset"]);
      final description = _asString(info["description"]);

      return LockDescription(
        asset: asset ?? "-",
        description: description ?? "",
      );
    case "lock-quantity":
      final asset = _asString(info["asset"]);
      final quantityInt = _asInt(info["quantity"]);
      final lock = _asBool(info["lock"]);
      final assetDivisibility = _asBool(info["asset_divisibility"]);

      return LockQuantity(
        asset: asset ?? "-",
        quantity: AssetQuantity(
          divisible: assetDivisibility,
          quantity: BigInt.from(quantityInt ?? 0),
        ),
        lock: lock,
      );

    case "destroy":
      final asset = _asString(info["asset"]);
      final quantityInt = _asInt(info["quantity"]);
      final assetDivisibility = _asBool(info["asset_divisibility"]);
      final tag = _asString(info["tag"]);
      return Destroy(
        asset: asset ?? "-",
        quantity: AssetQuantity(
          divisible: assetDivisibility,
          quantity: BigInt.from(quantityInt ?? 0),
        ),
        tag: tag ?? "",
      );
    case "move":
      final destination = _asString(info["destination"]);
      return UtxoMove(destination: destination ?? "-");
    case "sweep":
      final destination = _asString(info["destination"]);
      return Sweep(destination: destination ?? "-");
    case "order-create":
      final giveAsset = _asString(info["give_asset"]);
      final giveQuantityInt = _asInt(info["give_quantity"]);
      final giveAssetDivisibility = _asBool(info["give_asset_divisibility"]);
      final getAsset = _asString(info["get_asset"]);
      final getQuantityInt = _asInt(info["get_quantity"]);
      final getAssetDivisibility = _asBool(info["get_asset_divisibility"]);

      return OrderPsbt(
        giveAsset: giveAsset ?? "-",
        giveQuantity: AssetQuantity(
          divisible: giveAssetDivisibility,
          quantity: BigInt.from(giveQuantityInt ?? 0),
        ),
        getAsset: getAsset ?? "-",
        getQuantity: AssetQuantity(
          divisible: getAssetDivisibility,
          quantity: BigInt.from(getQuantityInt ?? 0),
        ),
      );
    case "cancel-order":
      final asset = _asString(info["asset"]);
      final quantity = _asInt(info["quantity"]);
      final assetDivisibility = _asBool(info["asset_divisibility"]);
      final xcpPrice = Decimal.parse(info["xcp_price"]);

      final Price price = Price(
        pair: MarketPair(
          quoteDivisible: true,
          baseDivisible: assetDivisibility,
        ),
        numer: (xcpPrice * TenToTheEigth.decimal).toBigInt(),
        denom: BigInt.from(quantity ?? 1),
      );

      return CancelOrder(
        xcpPrice: price,
        asset: asset ?? "-",
        quantity: AssetQuantity(
          divisible: assetDivisibility,
          quantity: BigInt.from(quantity ?? 0),
        ),
      );
    case "attach":
      final asset = _asString(info["asset"]);
      final quantityInt = _asInt(info["quantity"]);
      final assetDivisibility = _asBool(info["asset_divisibility"]);
      return AttachPsbt(
          asset: asset ?? "-",
          quantity: AssetQuantity(
            divisible: assetDivisibility,
            quantity: BigInt.from(quantityInt ?? 0),
          ));
    case "detach":
      return DetachPsbt();
    case "send":
      final asset = _asString(info["asset"]);
      final quantityInt = _asInt(info["quantity"]);
      final divisibility = _asBool(info["asset_divisibility"]);

      final destination = _asString(info["destination"]);

      if (asset == null || quantityInt == null || destination == null) {
        return OpaquePsbt();
      }

      if (asset.toLowerCase() == "btc") {
        // we should never hit this case actually
        return BtcSendPsbt(
          toAddress: destination,
          sats: BigInt.from(quantityInt),
        );
      } else {
        return XCPSendPsbt(
          toAddress: destination,
          asset: asset,
          quantity: AssetQuantity(
              quantity: BigInt.from(quantityInt), divisible: divisibility),
        );
      }

    case "swap-buy":
      final royaltyInt = _asInt(info["royalty"]);
      final royalty = royaltyInt == null
          ? null
          : AssetQuantity(divisible: true, quantity: BigInt.from(royaltyInt));
      return AtomicSwapBuyPsbt(royalty: royalty);
    case "swap-multi-buy":
      final royaltyInt = _asInt(info["royalty"]);
      final royalty = royaltyInt == null
          ? null
          : AssetQuantity(divisible: true, quantity: BigInt.from(royaltyInt));
      return AtomicSwapBuyPsbt(royalty: royalty);
    case "swap-create-fee":
      return AtomicSwapListingFee();
    case "swap-create":
      return AtomicSwapSellPsbt();

    default:
      return OpaquePsbt();
  }
}

String? _asString(dynamic v) {
  if (v is String) return v;
  return null;
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  return false;
}

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

class ActionRepositoryImpl implements ActionRepository {
  Action? _currentAction;

  @override
  Either<String, Action> fromString(String str) {
    return Either.tryCatch(() {
      return _parse(str);
    }, (e, __) => "Failed to parse action");
  }

  Action _parse(String str) {
    // IMPORTANT: split first (no global decode)
    final parts = str.split(',');

    if (parts.isEmpty) throw Exception('Empty action string');

    switch (parts[0]) {
      case 'getAddresses':
        if (parts.length != 6) {
          throw Exception('getAddresses expects 6 fields, got ${parts.length}');
        }
        return RPCGetAddressesAction(
          int.parse(parts[1]),
          parts[2],
          Uri.decodeComponent(parts[3]),
          Uri.decodeComponent(parts[4]),
          Uri.decodeComponent(parts[5]),
        );

      case 'signPsbt':
        // Accept BOTH shapes:
        //  - 10 fields: includes txInfoB64
        //  - 9 fields:  no txInfoB64 provided
        if (parts.length != 10 && parts.length != 9) {
          throw Exception(
              'signPsbt expects 9 or 10 fields, got ${parts.length}');
        }

        final tabId = parts[1];
        final requestId = parts[2];
        final origin = parts[3]; // decode inside builder
        final title = parts[4];
        final favicon = parts[5];
        final psbt = parts[6]; // raw hex
        final signInputsB64 = parts[7]; // base64
        final sighashB64 = parts[8]; // base64
        final txInfoB64 =
            (parts.length == 10) ? parts[9] : 'bnVsbA=='; // JSON null

        return _buildSignPsbtAction(
          tabId: tabId,
          requestId: requestId,
          origin: origin,
          title: title,
          favicon: favicon,
          psbt: psbt,
          signInputsB64: signInputsB64,
          sighashTypesB64: sighashB64,
          txInfoB64: txInfoB64,
        );

      case 'signMessage':
        if (parts.length != 8) {
          throw Exception('signMessage expects 8 fields, got ${parts.length}');
        }
        return RPCSignMessageAction(
          int.parse(parts[1]),
          parts[2],
          Uri.decodeComponent(parts[3]),
          Uri.decodeComponent(parts[4]),
          Uri.decodeComponent(parts[5]),
          // DECODE the message so "Hello%20World" => "Hello World"
          Uri.decodeComponent(parts[6]),
          parts[7],
        );

      default:
        throw Exception('Unknown action: ${parts[0]}');
    }
  }

  // Action _parse(String str) {
  //   print("parsing action string: $str");
  //
  //   // 1) Split first — DO NOT decode the whole string.
  //   final parts = str.split(',');
  //
  //   print("Parsing action, parts.length=${parts.length}");
  //   // Quick guard so we can see what came in:
  //   if (parts.isEmpty) throw Exception('Empty action string');
  //
  //   switch (parts[0]) {
  //     case 'getAddresses':
  //       if (parts.length != 6) {
  //         throw Exception('getAddresses expects 6 fields, got ${parts.length}');
  //       }
  //       final tabId = int.parse(parts[1]);
  //       final requestId = parts[2];
  //       final origin = Uri.decodeComponent(parts[3]);
  //       final title = Uri.decodeComponent(parts[4]);
  //       final favicon = Uri.decodeComponent(parts[5]);
  //
  //       return RPCGetAddressesAction(tabId, requestId, origin, title, favicon);
  //
  //     case 'signPsbt':
  //       if (parts.length != 11) {
  //         throw Exception('signPsbt expects 11 fields, got ${parts.length}');
  //       }
  //       final tabId = parts[1];
  //       final requestId = parts[2];
  //       final origin = parts[3]; // decode inside builder
  //       final title = parts[4];
  //       final favicon = parts[5];
  //       final psbt = parts[6]; // raw hex, do NOT decode
  //       final signInputs = parts[7]; // base64, do NOT decode here
  //       final sighashTypes = parts[8]; // base64, do NOT decode here
  //       final txInfo = parts[9]; // base64, do NOT decode here
  //       // NOTE: parts[10]?? In your example there are 11 fields (index 0..10).
  //       // If your format includes exactly 11, adjust indices accordingly:
  //       final txInfoB64 = parts[10];
  //
  //       return _buildSignPsbtAction(
  //         tabId: tabId,
  //         requestId: requestId,
  //         origin: origin,
  //         title: title,
  //         favicon: favicon,
  //         psbt: psbt,
  //         signInputsB64: signInputs,
  //         sighashTypesB64: sighashTypes,
  //         txInfoB64: txInfoB64,
  //       );
  //
  //     case 'signMessage':
  //       if (parts.length != 8) {
  //         throw Exception('signMessage expects 8 fields, got ${parts.length}');
  //       }
  //       final tabId = int.parse(parts[1]);
  //       final requestId = parts[2];
  //       final origin = Uri.decodeComponent(parts[3]);
  //       final title = Uri.decodeComponent(parts[4]);
  //       final favicon = Uri.decodeComponent(parts[5]);
  //       final message =
  //           parts[6]; // plain text (already URL-encoded in link if needed)
  //       final address = parts[7];
  //
  //       return RPCSignMessageAction(
  //           tabId, requestId, origin, title, favicon, message, address);
  //
  //     default:
  //       throw Exception('Unknown action: ${parts[0]}');
  //   }
  // }

  // Action _parse(String str) {
  //   print("parsing action string: $str");
  //   final arr = str.split(',').toList();
  //
  //   print("Parsing action: $arr");
  //
  //   return switch (arr) {
  //     [
  //       "getAddresses",
  //       String tabId,
  //       String requestId,
  //       String origin,
  //       String title,
  //       String favicon
  //     ] =>
  //       RPCGetAddressesAction(
  //           int.tryParse(tabId)!,
  //           requestId,
  //           Uri.decodeComponent(origin),
  //           Uri.decodeComponent(title),
  //           Uri.decodeComponent(favicon)),
  //     [
  //       "signPsbt",
  //       String tabId,
  //       String requestId,
  //       String origin,
  //       String title,
  //       String favicon,
  //       String psbt,
  //       String signInputs,
  //       String sighashTypes,
  //       String txInfo
  //     ] =>
  //       _buildSignPsbtAction(
  //         tabId: tabId,
  //         requestId: requestId,
  //         origin: origin,
  //         title: title,
  //         favicon: favicon,
  //         psbt: psbt,
  //         signInputsB64: signInputs,
  //         sighashTypesB64: sighashTypes,
  //         txInfoB64: txInfo,
  //       ),
  //     [
  //       "signMessage",
  //       String tabId,
  //       String requestId,
  //       String origin,
  //       String title,
  //       String favicon,
  //       String message,
  //       String address,
  //     ] =>
  //       RPCSignMessageAction(
  //           int.tryParse(tabId)!,
  //           requestId,
  //           Uri.decodeComponent(origin),
  //           Uri.decodeComponent(title),
  //           Uri.decodeComponent(favicon),
  //           message,
  //           address),
  //     _ => throw Exception()
  //   };
  // }

  @override
  void enqueue(Action action) {
    _currentAction = action; // Store the single action
  }

  @override
  Option<Action> peek() {
    return Option.fromNullable(_currentAction);
  }

  @override
  Option<Action> dequeue() {
    final action = _currentAction;
    _currentAction = null; // Clear the action after dequeuing
    return Option.fromNullable(action);
  }

  List<int>? _parseSighashTypes(String sighashTypesStr) {
    try {
      final value = json.decode(utf8.decode(base64.decode(sighashTypesStr)));
      if (value is List) {
        return value.cast<int>();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Map<String, List<int>> _parseSignInputs(String signInputsStr) {
    try {
      final str = utf8.decode(base64.decode(signInputsStr));
      final jsonMap = json.decode(str) as Map<String, dynamic>;

      // Convert to Map<String, List<int>>
      return jsonMap.map((key, value) {
        if (value is List) {
          return MapEntry(key, value.cast<int>());
        } else {
          throw const FormatException("Invalid signInputs format");
        }
      });
    } catch (e) {
      throw FormatException("Failed to parse signInputs: $e");
    }
  }
}
