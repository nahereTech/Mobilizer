// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_custom_organization_child_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCustomOrganizationChildResponse
    _$CreateCustomOrganizationChildResponseFromJson(
            Map<String, dynamic> json) =>
        CreateCustomOrganizationChildResponse(
          status: (json['status'] as num).toInt(),
          msg: json['msg'] as String,
          data: json['data'] == null
              ? null
              : Data.fromJson(json['data'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$CreateCustomOrganizationChildResponseToJson(
        CreateCustomOrganizationChildResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      townhall_id: (json['townhall_id'] as num).toInt(),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'townhall_id': instance.townhall_id,
    };
