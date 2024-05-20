import 'package:floor/floor.dart';
import 'package:uniparty/domain/entities/wallet_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet.g.dart';

@JsonSerializable()
@Entity(tableName: 'wallet', primaryKeys: ['uuid'])
class Wallet extends WalletEntity {
  Wallet(
      {required super.uuid,
      required super.accountUuid,
      required super.name,
      required super.wif})
      : super();

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

  Map<String, dynamic> toJson() => _$WalletToJson(this);

  factory Wallet.fromEntity(WalletEntity entity) {
    return Wallet(
        uuid: entity.uuid,
        accountUuid: entity.accountUuid,
        name: entity.name,
        wif: entity.wif);
  }
}
