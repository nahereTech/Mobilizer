// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_ccf_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationCCFResponse _$OrganizationCCFResponseFromJson(
        Map<String, dynamic> json) =>
    OrganizationCCFResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      another_one: json['another_one'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Data.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrganizationCCFResponseToJson(
        OrganizationCCFResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'another_one': instance.another_one,
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      townhall_id: (json['townhall_id'] as num).toInt(),
      name: json['name'] as String,
      level_id: (json['level_id'] as num?)?.toInt(),
      level_name: json['level_name'] as String?,
      children_count: (json['children_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'townhall_id': instance.townhall_id,
      'name': instance.name,
      'level_id': instance.level_id,
      'level_name': instance.level_name,
      'children_count': instance.children_count,
    };
