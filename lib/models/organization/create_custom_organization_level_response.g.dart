// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_custom_organization_level_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCustomOrganizationLevelResponse
    _$CreateCustomOrganizationLevelResponseFromJson(
            Map<String, dynamic> json) =>
        CreateCustomOrganizationLevelResponse(
          status: (json['status'] as num).toInt(),
          msg: json['msg'] as String,
          townhall_id: json['townhall_id'] as String,
        );

Map<String, dynamic> _$CreateCustomOrganizationLevelResponseToJson(
        CreateCustomOrganizationLevelResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'townhall_id': instance.townhall_id,
    };
