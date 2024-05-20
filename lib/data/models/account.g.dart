// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      uuid: json['uuid'] as String,
      defaultWalletUUID: json['defaultWalletUUID'] as String?,
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'defaultWalletUUID': instance.defaultWalletUUID,
    };
