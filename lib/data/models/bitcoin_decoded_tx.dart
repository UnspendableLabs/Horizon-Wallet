import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bitcoin_decoded_tx.g.dart';

@JsonSerializable(fieldRename: FieldRename.none)
class DecodedTxModel {
  final String txid;
  final String hash;
  final int version;
  final int size;
  final int vsize;
  final int weight;
  final int locktime;
  final List<VinModel> vin;
  final List<VoutModel> vout;

  const DecodedTxModel({
    required this.txid,
    required this.hash,
    required this.version,
    required this.size,
    required this.vsize,
    required this.weight,
    required this.locktime,
    required this.vin,
    required this.vout,
  });

  factory DecodedTxModel.fromJson(Map<String, dynamic> json) =>
      _$DecodedTxModelFromJson(json);

  Map<String, dynamic> toJson() => _$DecodedTxModelToJson(this);

  DecodedTx toDomain() => DecodedTx(
        txid: txid,
        hash: hash,
        version: version,
        size: size,
        vsize: vsize,
        weight: weight,
        locktime: locktime,
        vin: vin.map((e) => e.toDomain()).toList(),
        vout: vout.map((e) => e.toDomain()).toList(),
      );
}

@JsonSerializable(fieldRename: FieldRename.none)
class VinModel {
  final String txid;
  final int vout;
  final ScriptSigModel scriptSig;
  final List<String>? txinwitness;
  final int sequence;

  const VinModel({
    required this.txid,
    required this.vout,
    required this.scriptSig,
    this.txinwitness,
    required this.sequence,
  });

  factory VinModel.fromJson(Map<String, dynamic> json) =>
      _$VinModelFromJson(json);
  Map<String, dynamic> toJson() => _$VinModelToJson(this);

  Vin toDomain() => Vin(
        txid: txid,
        vout: vout,
        scriptSig: scriptSig.toDomain(),
        txinwitness: txinwitness,
        sequence: sequence,
      );
}

@JsonSerializable(fieldRename: FieldRename.none)
class VoutModel {
  final double value;
  final int n;
  final ScriptPubKeyModel scriptPubKey;

  const VoutModel({
    required this.value,
    required this.n,
    required this.scriptPubKey,
  });

  factory VoutModel.fromJson(Map<String, dynamic> json) =>
      _$VoutModelFromJson(json);
  Map<String, dynamic> toJson() => _$VoutModelToJson(this);

  Vout toDomain() => Vout(
        value: value,
        n: n,
        scriptPubKey: scriptPubKey.toDomain(),
      );
}

@JsonSerializable(fieldRename: FieldRename.none)
class ScriptSigModel {
  final String asm;
  final String hex;

  const ScriptSigModel({
    required this.asm,
    required this.hex,
  });

  factory ScriptSigModel.fromJson(Map<String, dynamic> json) =>
      _$ScriptSigModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScriptSigModelToJson(this);

  ScriptSig toDomain() => ScriptSig(
        asm: asm,
        hex: hex,
      );
}

@JsonSerializable(fieldRename: FieldRename.none)
class ScriptPubKeyModel {
  final String asm;
  final String desc;
  final String hex;
  final String? address;
  final String type;

  const ScriptPubKeyModel({
    required this.asm,
    required this.desc,
    required this.hex,
    this.address,
    required this.type,
  });

  factory ScriptPubKeyModel.fromJson(Map<String, dynamic> json) =>
      _$ScriptPubKeyModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScriptPubKeyModelToJson(this);

  ScriptPubKey toDomain() => ScriptPubKey(
        asm: asm,
        desc: desc,
        hex: hex,
        address: address,
        type: type,
      );
}
