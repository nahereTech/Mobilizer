// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinOrganizationResponse _$JoinOrganizationResponseFromJson(
        Map<String, dynamic> json) =>
    JoinOrganizationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      tag: json['tag'] as String?,
      dropdown: (json['dropdown'] as List<dynamic>?)
          ?.map((e) => DropData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$JoinOrganizationResponseToJson(
        JoinOrganizationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'tag': instance.tag,
      'dropdown': instance.dropdown,
    };

DropData _$DropDataFromJson(Map<String, dynamic> json) => DropData(
      id: (json['id'] as num).toInt(),
      selected: (json['selected'] as num).toInt(),
      required: json['required'] as bool,
      level_list: (json['level_list'] as List<dynamic>?)
          ?.map((e) => LevelData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DropDataToJson(DropData instance) => <String, dynamic>{
      'id': instance.id,
      'selected': instance.selected,
      'required': instance.required,
      'level_list': instance.level_list,
    };

LevelData _$LevelDataFromJson(Map<String, dynamic> json) => LevelData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$LevelDataToJson(LevelData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
