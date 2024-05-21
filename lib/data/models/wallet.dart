import 'package:floor/floor.dart';
import 'package:uniparty/domain/entities/wallet.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet.g.dart';

@JsonSerializable()
@Entity(tableName: 'wallet', primaryKeys: ['uuid'])
class WalletModel extends Wallet {
  WalletModel(
      {required super.uuid,
      required super.accountUuid,
      required super.name,
      required super.wif})
      : super();

  factory WalletModel.fromJson(Map<String, dynamic> json) => _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);

  factory WalletModel.fromEntity(Wallet entity) {
    return WalletModel(
        uuid: entity.uuid,
        accountUuid: entity.accountUuid,
        name: entity.name,
        wif: entity.wif);
  }
}
