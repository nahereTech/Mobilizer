// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rename_custom_organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RenameCustomOrganizationResponse _$RenameCustomOrganizationResponseFromJson(
        Map<String, dynamic> json) =>
    RenameCustomOrganizationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$RenameCustomOrganizationResponseToJson(
        RenameCustomOrganizationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
