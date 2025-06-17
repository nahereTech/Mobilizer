// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_custom_organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteCustomOrganizationResponse _$DeleteCustomOrganizationResponseFromJson(
        Map<String, dynamic> json) =>
    DeleteCustomOrganizationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$DeleteCustomOrganizationResponseToJson(
        DeleteCustomOrganizationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
