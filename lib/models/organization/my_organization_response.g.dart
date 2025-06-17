// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyOrganizationResponse _$MyOrganizationResponseFromJson(
        Map<String, dynamic> json) =>
    MyOrganizationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => OrganizationData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MyOrganizationResponseToJson(
        MyOrganizationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

OrganizationData _$OrganizationDataFromJson(Map<String, dynamic> json) =>
    OrganizationData(
      org_id: (json['org_id'] as num?)?.toInt(),
      org_name: json['org_name'] as String?,
      org_desc: json['org_desc'] as String?,
      org_username: json['org_username'] as String?,
      org_image: json['org_image'] as String?,
      org_banner: json['org_banner'] as String,
      org_plan: (json['org_plan'] as num?)?.toInt(),
      org_plan_name: json['org_plan_name'] as String?,
      org_full_url: json['org_full_url'] as String?,
      org_member_count: (json['org_member_count'] as num).toInt(),
      active_status: json['active_status'] as String?,
      created_by_user: json['created_by_user'] as String?,
      requires_confirmation: json['requires_confirmation'] as String?,
      org_privacy: json['org_privacy'] as String?,
      available_townhalls: (json['available_townhalls'] as List<dynamic>?)
          ?.map(
              (e) => AvailableTownhallData.fromJson(e as Map<String, dynamic>))
          .toList(),
      postable_townhalls: (json['postable_townhalls'] as List<dynamic>?)
          ?.map((e) => PostableTownhallData.fromJson(e as Map<String, dynamic>))
          .toList(),
      custom_townhall_tree: (json['custom_townhall_tree'] as List<dynamic>)
          .map((e) => CustomTownhallData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrganizationDataToJson(OrganizationData instance) =>
    <String, dynamic>{
      'org_id': instance.org_id,
      'org_name': instance.org_name,
      'org_desc': instance.org_desc,
      'org_username': instance.org_username,
      'org_image': instance.org_image,
      'org_banner': instance.org_banner,
      'org_plan': instance.org_plan,
      'org_plan_name': instance.org_plan_name,
      'org_full_url': instance.org_full_url,
      'org_member_count': instance.org_member_count,
      'active_status': instance.active_status,
      'created_by_user': instance.created_by_user,
      'requires_confirmation': instance.requires_confirmation,
      'org_privacy': instance.org_privacy,
      'available_townhalls': instance.available_townhalls,
      'postable_townhalls': instance.postable_townhalls,
      'custom_townhall_tree': instance.custom_townhall_tree,
    };

AvailableTownhallData _$AvailableTownhallDataFromJson(
        Map<String, dynamic> json) =>
    AvailableTownhallData(
      name: json['name'] as String,
      pic: json['pic'] as String,
      is_checked: json['is_checked'] as String,
      circle_reduction_percentage:
          (json['circle_reduction_percentage'] as num).toInt(),
    );

Map<String, dynamic> _$AvailableTownhallDataToJson(
        AvailableTownhallData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pic': instance.pic,
      'is_checked': instance.is_checked,
      'circle_reduction_percentage': instance.circle_reduction_percentage,
    };

PostableTownhallData _$PostableTownhallDataFromJson(
        Map<String, dynamic> json) =>
    PostableTownhallData(
      name: json['name'] as String,
      pic: json['pic'] as String,
      is_checked: json['is_checked'] as String,
      circle_reduction_percentage:
          (json['circle_reduction_percentage'] as num).toInt(),
    );

Map<String, dynamic> _$PostableTownhallDataToJson(
        PostableTownhallData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pic': instance.pic,
      'is_checked': instance.is_checked,
      'circle_reduction_percentage': instance.circle_reduction_percentage,
    };

CustomTownhallData _$CustomTownhallDataFromJson(Map<String, dynamic> json) =>
    CustomTownhallData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      parent_id: (json['parent_id'] as num).toInt(),
      level: json['level'] as String?,
      level_name: json['level_name'] as String?,
    );

Map<String, dynamic> _$CustomTownhallDataToJson(CustomTownhallData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parent_id': instance.parent_id,
      'level': instance.level,
      'level_name': instance.level_name,
    };
