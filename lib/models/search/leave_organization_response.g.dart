// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveOrganizationResponse _$LeaveOrganizationResponseFromJson(
        Map<String, dynamic> json) =>
    LeaveOrganizationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$LeaveOrganizationResponseToJson(
        LeaveOrganizationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
