// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteAccountResponse _$DeleteAccountResponseFromJson(
        Map<String, dynamic> json) =>
    DeleteAccountResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      tag: json['tag'] as String,
    );

Map<String, dynamic> _$DeleteAccountResponseToJson(
        DeleteAccountResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'tag': instance.tag,
    };
