// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationResponse _$OrganizationResponseFromJson(
        Map<String, dynamic> json) =>
    OrganizationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => OrganizationData.fromJson(e as Map<String, dynamic>))
          .toList(),
      max_follow: json['max_follow'],
    );

Map<String, dynamic> _$OrganizationResponseToJson(
        OrganizationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'max_follow': instance.max_follow,
      'data': instance.data,
    };

OrganizationData _$OrganizationDataFromJson(Map<String, dynamic> json) =>
    OrganizationData(
      org_id: (json['org_id'] as num?)?.toInt(),
      townhall_id: json['townhall_id'] as String?,
      org_name: json['org_name'] as String?,
      org_bg: json['org_bg'] as String?,
      org_member_count: json['org_member_count'] as String?,
      join_status: json['join_status'] as String?,
      org_username: json['org_username'] as String?,
      org_about: json['org_about'] as String?,
      missing_custom_org_townhalls:
          json['missing_custom_org_townhalls'] as bool,
      picture: json['picture'] as String?,
      member: json['member'] as String?,
      is_leader: json['is_leader'] as String?,
      verified: json['verified'] as String?,
      can_update_subtownhalls: json['can_update_subtownhalls'] as bool,
      unread: (json['unread'] as num?)?.toInt(),
      pinned: json['pinned'] as String?,
    );

Map<String, dynamic> _$OrganizationDataToJson(OrganizationData instance) =>
    <String, dynamic>{
      'org_id': instance.org_id,
      'townhall_id': instance.townhall_id,
      'org_name': instance.org_name,
      'org_bg': instance.org_bg,
      'org_member_count': instance.org_member_count,
      'join_status': instance.join_status,
      'org_username': instance.org_username,
      'org_about': instance.org_about,
      'missing_custom_org_townhalls': instance.missing_custom_org_townhalls,
      'picture': instance.picture,
      'verified': instance.verified,
      'is_leader': instance.is_leader,
      'member': instance.member,
      'unread': instance.unread,
      'pinned': instance.pinned,
      'can_update_subtownhalls': instance.can_update_subtownhalls,
    };
