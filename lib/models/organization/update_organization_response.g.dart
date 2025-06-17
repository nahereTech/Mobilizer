// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateOrganizationResponse _$UpdateOrganizationResponseFromJson(
        Map<String, dynamic> json) =>
    UpdateOrganizationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$UpdateOrganizationResponseToJson(
        UpdateOrganizationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
