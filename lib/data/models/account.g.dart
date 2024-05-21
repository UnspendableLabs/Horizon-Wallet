// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountModel _$AccountModelFromJson(Map<String, dynamic> json) => AccountModel(
      uuid: json['uuid'] as String,
      defaultWalletUUID: json['defaultWalletUUID'] as String?,
    );

Map<String, dynamic> _$AccountModelToJson(AccountModel instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'defaultWalletUUID': instance.defaultWalletUUID,
    };
