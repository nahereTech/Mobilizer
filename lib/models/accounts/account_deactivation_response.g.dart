// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_deactivation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountDeactivationResponse _$AccountDeactivationResponseFromJson(
        Map<String, dynamic> json) =>
    AccountDeactivationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$AccountDeactivationResponseToJson(
        AccountDeactivationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
