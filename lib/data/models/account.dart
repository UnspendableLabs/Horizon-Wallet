import 'package:floor/floor.dart';
import 'package:uniparty/domain/entities/account_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable()
@Entity(tableName: 'account', primaryKeys: ['uuid'])
class Account extends AccountEntity {
  Account({required super.uuid, required super.defaultWalletUUID}) : super();

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);


  factory Account.fromEntity(AccountEntity entity) {
    return Account(uuid: entity.uuid, defaultWalletUUID: entity.defaultWalletUUID);
  }


}
