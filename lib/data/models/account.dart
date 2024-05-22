import 'package:floor/floor.dart';
import 'package:uniparty/domain/entities/account.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable()
@Entity(tableName: 'account', primaryKeys: ['uuid'])
class AccountModel extends Account {
  AccountModel({required super.uuid, required super.defaultWalletUUID}) : super();

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountModelToJson(this);


  factory AccountModel.fromEntity(Account entity) {
    return AccountModel(uuid: entity.uuid, defaultWalletUUID: entity.defaultWalletUUID);
  }


}
