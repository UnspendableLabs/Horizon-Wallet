import "dart:convert";
import 'package:decimal/decimal.dart';
import "package:horizon/common/constants.dart";
import "package:horizon/domain/entities/asset_quantity.dart";
import "package:horizon/domain/entities/psbt_type.dart";
import "package:horizon/domain/repositories/action_repository.dart";
import "package:horizon/domain/entities/action.dart";
import "package:fpdart/fpdart.dart";

const Set<String> originWhitelist = {
  "https://horizon.market",
  "https://testnet4.horizon.market",
  "https://signet.horizon.market",
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
  if (txInfo == null) return OpaquePsbt(rpc: true);
  if (origin == null || !originWhitelist.contains(origin)) {
    return OpaquePsbt(rpc: true);
  }

  final type = txInfo["type"];
  final info = txInfo["info"];

  if (type is! String || info is! Map<String, dynamic>) {
    return OpaquePsbt(rpc: true);
  }

  switch (type) {
    case "fairmint":
      final asset = _asString(info["asset"]);
      final divivisible = _asBool(info["asset_divisibility"]);
      final quantityInt = _asInt(info["quantity"]);
      return Fairmint(
          rpc: true,
          asset: asset ?? "-",
          quantity: AssetQuantity(
            divisible: divivisible,
            quantity: BigInt.from(quantityInt ?? 0),
          ));
    case "dividend":
      final asset = _asString(info["asset"]);
      final dividendAsset = _asString(info["dividend_asset"]);
      final quantityPerUnitInt = _asInt(info["quantity_per_unit"]);
      final dividendAssetDivisibility =
          _asBool(info["dividend_asset_divisibility"]);

      return Dividend(
          asset: asset ?? "-",
          dividendAsset: dividendAsset ?? "",
          quantityPerUnit: AssetQuantity(
            divisible: dividendAssetDivisibility,
            quantity: BigInt.from(quantityPerUnitInt ?? 0),
          ));
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
        rpc: true,
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
          rpc: true,
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
          rpc: true,
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
          rpc: true,
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
        rpc: true,
        asset: asset ?? "-",
        transferDestination: transferDestination ?? "-",
      );
    case "change-description":
      final asset = _asString(info["asset"]);
      final description = _asString(info["description"]);

      return ChangeDescription(
        rpc: true,
        asset: asset ?? "-",
        description: description ?? "",
      );
    case "lock-description":
      final asset = _asString(info["asset"]);
      final description = _asString(info["description"]);

      return LockDescription(
        rpc: true,
        asset: asset ?? "-",
        description: description ?? "",
      );
    case "lock-quantity":
      final asset = _asString(info["asset"]);
      final quantityInt = _asInt(info["quantity"]);
      final lock = _asBool(info["lock"]);
      final assetDivisibility = _asBool(info["asset_divisibility"]);

      return LockQuantity(
        rpc: true,
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
        rpc: true,
        asset: asset ?? "-",
        quantity: AssetQuantity(
          divisible: assetDivisibility,
          quantity: BigInt.from(quantityInt ?? 0),
        ),
        tag: tag ?? "",
      );
    case "move":
      final destination = _asString(info["destination"]);
      return UtxoMove(rpc: true, destination: destination ?? "-");
    case "sweep":
      final destination = _asString(info["destination"]);
      return Sweep(rpc: true, destination: destination ?? "-");
    case "order-create":
      final giveAsset = _asString(info["give_asset"]);
      final giveQuantityInt = _asInt(info["give_quantity"]);
      final giveAssetDivisibility = _asBool(info["give_asset_divisibility"]);
      final getAsset = _asString(info["get_asset"]);
      final getQuantityInt = _asInt(info["get_quantity"]);
      final getAssetDivisibility = _asBool(info["get_asset_divisibility"]);

      return OrderPsbt(
        rpc: true,
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
        rpc: true,
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
          rpc: true,
          asset: asset ?? "-",
          quantity: AssetQuantity(
            divisible: assetDivisibility,
            quantity: BigInt.from(quantityInt ?? 0),
          ));
    case "detach":
      return DetachPsbt(
        rpc: true,
      );
    case "send":
      final asset = _asString(info["asset"]);
      final quantityInt = _asInt(info["quantity"]);
      final divisibility = _asBool(info["asset_divisibility"]);

      final destination = _asString(info["destination"]);

      if (asset == null || quantityInt == null || destination == null) {
        return OpaquePsbt(rpc: true);
      }

      if (asset.toLowerCase() == "btc") {
        // we should never hit this case actually
        return BtcSendPsbt(
          toAddress: destination,
          sats: BigInt.from(quantityInt),
        );
      } else {
        return XCPSendPsbt(
          rpc: true,
          toAddress: destination,
          asset: asset,
          quantity: AssetQuantity(
              quantity: BigInt.from(quantityInt), divisible: divisibility),
        );
      }

    // Deriving PsbtType for type='mpma', info={sends: [{destination: tb1qc4vz9tzte3rcg8urgkvw0tqn2ka943qnlqhuq7, asset: XCP, quantitie: 1000000, asset_divisibility: true}, {destination: tb1qc4vz9tzte3rcg8urgkvw0tqn2ka943qnlqhuq7, asset: A2977114591417842298, quantitie: 100, asset_divisibility: false}]}
    case "mpma":
      final sends_ = info["sends"];
      final List<XCPSendPsbt> sends = [];
      for (var info in sends_) {
        final asset = _asString(info["asset"]);
        final quantityInt = _asInt(info[
            "quantitie"]); // this is intentionally mispelled for some reason
        final divisibility = _asBool(info["asset_divisibility"]);

        final destination = _asString(info["destination"]);

        sends.add(XCPSendPsbt(
          rpc: true,
          toAddress: destination ?? "-",
          asset: asset ?? "-",
          quantity: AssetQuantity(
              quantity: BigInt.from(quantityInt ?? 0), divisible: divisibility),
        ));
      }
      return Mpma(rpc: true, sends: sends);

    case "swap-buy":
      final royaltyInt = _asInt(info["royalty"]);
      final royalty = royaltyInt == null
          ? null
          : AssetQuantity(divisible: true, quantity: BigInt.from(royaltyInt));
      return AtomicSwapBuyPsbt(rpc: true, royalty: royalty);
    case "swap-multi-buy":
      final royaltyInt = _asInt(info["royalty"]);
      final royalty = royaltyInt == null
          ? null
          : AssetQuantity(divisible: true, quantity: BigInt.from(royaltyInt));
      return AtomicSwapBuyPsbt(rpc: true, royalty: royalty);
    case "swap-create-fee":
      return AtomicSwapListingFee(rpc: true);
    case "swap-create":
      return AtomicSwapSellPsbt(rpc: true);

    default:
      return OpaquePsbt(rpc: true);
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

      case 'signMessageBLS':
        if (parts.length < 7 || parts.length > 10) {
          throw Exception(
              'signMessageBLS expects 7-10 fields, got ${parts.length}');
        }
        final msgField = Uri.decodeComponent(parts[6]);
        final dstField =
            parts.length >= 8 ? Uri.decodeComponent(parts[7]) : null;
        final msgHexField =
            parts.length >= 9 ? Uri.decodeComponent(parts[8]) : null;
        final addrField =
            parts.length >= 10 ? Uri.decodeComponent(parts[9]) : null;
        return RPCSignMessageBLSAction(
          int.parse(parts[1]),
          parts[2],
          Uri.decodeComponent(parts[3]),
          Uri.decodeComponent(parts[4]),
          Uri.decodeComponent(parts[5]),
          msgField,
          dstField != null && dstField.isNotEmpty ? dstField : null,
          msgHexField != null && msgHexField.isNotEmpty ? msgHexField : null,
          addrField != null && addrField.isNotEmpty ? addrField : null,
        );

      case 'getBLSPoP':
        if (parts.length != 7) {
          throw Exception(
              'getBLSPoP expects 7 fields, got ${parts.length}');
        }
        return RPCGetBLSPoPAction(
          int.parse(parts[1]),
          parts[2],
          Uri.decodeComponent(parts[3]),
          Uri.decodeComponent(parts[4]),
          Uri.decodeComponent(parts[5]),
          Uri.decodeComponent(parts[6]),
        );

      case 'exportEncryptedBlsPrivateKey':
        if (parts.length < 6 || parts.length > 7) {
          throw Exception(
              'exportEncryptedBlsPrivateKey expects 6-7 fields, got ${parts.length}');
        }
        final exportAddrField =
            parts.length >= 7 ? Uri.decodeComponent(parts[6]) : null;
        return RPCExportEncryptedBlsPrivateKeyAction(
          int.parse(parts[1]),
          parts[2],
          Uri.decodeComponent(parts[3]),
          Uri.decodeComponent(parts[4]),
          Uri.decodeComponent(parts[5]),
          exportAddrField != null && exportAddrField.isNotEmpty
              ? exportAddrField
              : null,
        );

      default:
        throw Exception('Unknown action: ${parts[0]}');
    }
  }

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
}
