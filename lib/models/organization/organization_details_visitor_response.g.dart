// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_details_visitor_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationDetailsResponse _$OrganizationDetailsResponseFromJson(
        Map<String, dynamic> json) =>
    OrganizationDetailsResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : OrgData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrganizationDetailsResponseToJson(
        OrganizationDetailsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

OrgData _$OrgDataFromJson(Map<String, dynamic> json) => OrgData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      username: json['username'] as String,
      description: json['description'] as String,
      verified: json['verified'] as String,
      logo: json['logo'] as String,
      banner: json['banner'] as String,
      membership_count: (json['membership_count'] as num).toInt(),
    );

Map<String, dynamic> _$OrgDataToJson(OrgData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'description': instance.description,
      'verified': instance.verified,
      'logo': instance.logo,
      'banner': instance.banner,
      'membership_count': instance.membership_count,
    };
