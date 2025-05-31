// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_short_profile_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetShortProfileInfoResponse _$GetShortProfileInfoResponseFromJson(
        Map<String, dynamic> json) =>
    GetShortProfileInfoResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : ProfileData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetShortProfileInfoResponseToJson(
        GetShortProfileInfoResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) => ProfileData(
      user_id: json['user_id'],
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      photo_path: json['photo_path'],
      photo_path_mid: json['photo_path_mid'],
      photo_path_lg: json['photo_path_lg'],
      country_id: json['country_id'],
      country_name: json['country_name'],
      state_id: json['state_id'],
      state_name: json['state_name'],
      lga_id: json['lga_id'],
      lga_name: json['lga_name'],
      ward_id: json['ward_id'],
      ward_name: json['ward_name'],
      pu_id: json['pu_id'],
      pu_name: json['pu_name'],
      self_view: json['self_view'],
      share_link: json['share_link'],
      is_following: json['is_following'],
      followers: json['followers'],
      followings: json['followings'],
      townhalls: json['townhalls'],
      blocked_or_not: json['blocked_or_not'],
      profession: json['profession'],
      profession_category: json['profession_category'],
      device_tokens: (json['device_tokens'] as List<dynamic>?)
          ?.map((e) => DeviceTokensData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'username': instance.username,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'email': instance.email,
      'photo_path': instance.photo_path,
      'photo_path_mid': instance.photo_path_mid,
      'photo_path_lg': instance.photo_path_lg,
      'country_id': instance.country_id,
      'country_name': instance.country_name,
      'state_id': instance.state_id,
      'state_name': instance.state_name,
      'lga_id': instance.lga_id,
      'lga_name': instance.lga_name,
      'ward_id': instance.ward_id,
      'ward_name': instance.ward_name,
      'pu_id': instance.pu_id,
      'pu_name': instance.pu_name,
      'self_view': instance.self_view,
      'share_link': instance.share_link,
      'is_following': instance.is_following,
      'followers': instance.followers,
      'followings': instance.followings,
      'townhalls': instance.townhalls,
      'blocked_or_not': instance.blocked_or_not,
      'profession': instance.profession,
      'profession_category': instance.profession_category,
      'device_tokens': instance.device_tokens,
    };

DeviceTokensData _$DeviceTokensDataFromJson(Map<String, dynamic> json) =>
    DeviceTokensData(
      device_token: json['device_token'],
    );

Map<String, dynamic> _$DeviceTokensDataToJson(DeviceTokensData instance) =>
    <String, dynamic>{
      'device_token': instance.device_token,
    };
