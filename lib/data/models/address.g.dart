// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      address: json['address'] as String,
      walletUuid: json['walletUuid'] as String,
      derivationPath: json['derivationPath'] as String,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'address': instance.address,
      'walletUuid': instance.walletUuid,
      'derivationPath': instance.derivationPath,
    };
