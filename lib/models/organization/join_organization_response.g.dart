// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinOrganizationResponse _$JoinOrganizationResponseFromJson(
        Map<String, dynamic> json) =>
    JoinOrganizationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$JoinOrganizationResponseToJson(
        JoinOrganizationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
