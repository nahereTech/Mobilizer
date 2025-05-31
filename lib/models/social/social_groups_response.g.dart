// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_groups_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialGroupsResponse _$SocialGroupsResponseFromJson(
        Map<String, dynamic> json) =>
    SocialGroupsResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => SocialData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SocialGroupsResponseToJson(
        SocialGroupsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

SocialData _$SocialDataFromJson(Map<String, dynamic> json) => SocialData(
      id: json['id'],
      parent_org_id: json['parent_org_id'],
      name: json['name'],
      app_id: json['app_id'],
      users_permitted: json['users_permitted'],
      active_status: json['active_status'],
      del_status: json['del_status'],
    );

Map<String, dynamic> _$SocialDataToJson(SocialData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent_org_id': instance.parent_org_id,
      'name': instance.name,
      'app_id': instance.app_id,
      'users_permitted': instance.users_permitted,
      'active_status': instance.active_status,
      'del_status': instance.del_status,
    };
