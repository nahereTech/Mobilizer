// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'landing_group_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LandingGroupResponse _$LandingGroupResponseFromJson(
        Map<String, dynamic> json) =>
    LandingGroupResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : LandingData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LandingGroupResponseToJson(
        LandingGroupResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

LandingData _$LandingDataFromJson(Map<String, dynamic> json) => LandingData(
      org_id: json['org_id'],
      townhall_id: json['townhall_id'],
      is_leader: json['is_leader'] as String,
      org_name: json['org_name'] as String,
    );

Map<String, dynamic> _$LandingDataToJson(LandingData instance) =>
    <String, dynamic>{
      'org_id': instance.org_id,
      'townhall_id': instance.townhall_id,
      'is_leader': instance.is_leader,
      'org_name': instance.org_name,
    };
