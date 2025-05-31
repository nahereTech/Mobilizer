// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_tree_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationTreeResponse _$OrganizationTreeResponseFromJson(
        Map<String, dynamic> json) =>
    OrganizationTreeResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrganizationTreeResponseToJson(
        OrganizationTreeResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      level: (json['level'] as num).toInt(),
      level_name: json['level_name'] as String,
      parent_id: json['parent_id'],
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => Data.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'level': instance.level,
      'level_name': instance.level_name,
      'parent_id': instance.parent_id,
      'children': instance.children,
    };
