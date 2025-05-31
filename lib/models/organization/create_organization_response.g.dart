// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrganizationResponse _$CreateOrganizationResponseFromJson(
        Map<String, dynamic> json) =>
    CreateOrganizationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$CreateOrganizationResponseToJson(
        CreateOrganizationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
