// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_organization_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchOrganizationResponse _$SearchOrganizationResponseFromJson(
        Map<String, dynamic> json) =>
    SearchOrganizationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => OrganizationData.fromJson(e as Map<String, dynamic>))
          .toList(),
      max_follow: json['max_follow'],
    );

Map<String, dynamic> _$SearchOrganizationResponseToJson(
        SearchOrganizationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'max_follow': instance.max_follow,
      'data': instance.data,
    };

OrganizationData _$OrganizationDataFromJson(Map<String, dynamic> json) =>
    OrganizationData(
      org_id: json['org_id'],
      org_name: json['org_name'] as String?,
      org_bg: json['org_bg'] as String?,
      org_member_count: json['org_member_count'] as String?,
      join_status: json['join_status'] as String?,
      org_username: json['org_username'] as String?,
      org_about: json['org_about'] as String?,
      picture: json['picture'] as String?,
      is_member: json['is_member'] as String?,
      is_leader: json['is_leader'] as String?,
      verified: json['verified'] as String?,
      unread: (json['unread'] as num?)?.toInt(),
      pinned: json['pinned'] as String?,
      requires_confirmation: json['requires_confirmation'] as String,
    );

Map<String, dynamic> _$OrganizationDataToJson(OrganizationData instance) =>
    <String, dynamic>{
      'org_id': instance.org_id,
      'org_name': instance.org_name,
      'org_bg': instance.org_bg,
      'org_member_count': instance.org_member_count,
      'join_status': instance.join_status,
      'org_username': instance.org_username,
      'org_about': instance.org_about,
      'picture': instance.picture,
      'verified': instance.verified,
      'is_leader': instance.is_leader,
      'is_member': instance.is_member,
      'unread': instance.unread,
      'pinned': instance.pinned,
      'requires_confirmation': instance.requires_confirmation,
    };
