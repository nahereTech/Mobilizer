// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_custom_organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCustomOrganizationResponse _$CreateCustomOrganizationResponseFromJson(
        Map<String, dynamic> json) =>
    CreateCustomOrganizationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$CreateCustomOrganizationResponseToJson(
        CreateCustomOrganizationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
