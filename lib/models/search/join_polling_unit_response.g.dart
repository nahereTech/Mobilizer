// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_polling_unit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinPollingUnitResponse _$JoinPollingUnitResponseFromJson(
        Map<String, dynamic> json) =>
    JoinPollingUnitResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$JoinPollingUnitResponseToJson(
        JoinPollingUnitResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
