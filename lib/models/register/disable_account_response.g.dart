// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disable_account_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DisableAccountResponse _$DisableAccountResponseFromJson(
        Map<String, dynamic> json) =>
    DisableAccountResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      tag: json['tag'] as String,
    );

Map<String, dynamic> _$DisableAccountResponseToJson(
        DisableAccountResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'tag': instance.tag,
    };
