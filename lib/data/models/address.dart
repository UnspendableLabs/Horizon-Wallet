import 'package:floor/floor.dart';
import 'package:uniparty/domain/entities/address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
@Entity(tableName: 'address', primaryKeys: ['address'])
class AddressModel extends Address {
  AddressModel(
      {required super.address,
      required super.derivationPath}): super();

  factory AddressModel.fromJson(Map<String, dynamic> json) => _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  factory AddressModel.fromEntity(Address entity) {
    return AddressModel(
        address: entity.address,
        derivationPath: entity.derivationPath);
  }
}

