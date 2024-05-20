import 'package:floor/floor.dart';
import 'package:uniparty/domain/entities/address_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
@Entity(tableName: 'address', primaryKeys: ['address'])
class Address extends AddressEntity {
  Address(
      {required super.address,
      required super.walletUuid,
      required super.derivationPath}): super();

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);

  factory Address.fromEntity(AddressEntity entity) {
    return Address(
        address: entity.address,
        walletUuid: entity.walletUuid,
        derivationPath: entity.derivationPath);
  }
}

