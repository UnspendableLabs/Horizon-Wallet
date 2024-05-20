// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wallet _$WalletFromJson(Map<String, dynamic> json) => Wallet(
      uuid: json['uuid'] as String,
      accountUuid: json['accountUuid'] as String,
      name: json['name'] as String,
      wif: json['wif'] as String,
    );

Map<String, dynamic> _$WalletToJson(Wallet instance) => <String, dynamic>{
      'accountUuid': instance.accountUuid,
      'uuid': instance.uuid,
      'name': instance.name,
      'wif': instance.wif,
    };
