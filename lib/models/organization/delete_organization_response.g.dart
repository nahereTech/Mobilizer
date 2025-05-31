// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteOrganizationResponse _$DeleteOrganizationResponseFromJson(
        Map<String, dynamic> json) =>
    DeleteOrganizationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$DeleteOrganizationResponseToJson(
        DeleteOrganizationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
