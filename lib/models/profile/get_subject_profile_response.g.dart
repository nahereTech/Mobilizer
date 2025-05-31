// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_subject_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetSubjectProfileResponse _$GetSubjectProfileResponseFromJson(
        Map<String, dynamic> json) =>
    GetSubjectProfileResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : ProfileData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetSubjectProfileResponseToJson(
        GetSubjectProfileResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) => ProfileData(
      user_id: json['user_id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      username: json['username'],
      about_me: json['about_me'],
      phone: json['phone'],
      othernames: json['othernames'],
      gender: json['gender'],
      edu_level_id: json['edu_level_id'],
      edu_level_txt: json['edu_level_txt'],
      country_id: json['country_id'],
      country_name: json['country_name'],
      state_id: json['state_id'],
      state_name: json['state_name'],
      state_origin_id: json['state_origin_id'],
      state_origin_name: json['state_origin_name'],
      lga_id: json['lga_id'],
      lga_name: json['lga_name'],
      ward_id: json['ward_id'],
      ward_name: json['ward_name'],
      dob: json['dob'],
      profession: json['profession'],
      profession_category: json['profession_category'],
      profession_category_txt: json['profession_category_txt'],
      photo_path: json['photo_path'],
      photo_path_mid: json['photo_path_mid'],
      photo_path_lg: json['photo_path_lg'],
      pu_id: json['pu_id'],
      pu_name: json['pu_name'],
      party_name: json['party_name'],
      party_accronym: json['party_accronym'],
      show_polling_unit: json['show_polling_unit'],
      party_id: json['party_id'],
      blocked_or_not: json['blocked_or_not'],
      support_group_id: json['support_group_id'],
      support_group_name: json['support_group_name'],
      share_link: json['share_link'],
      is_following: json['is_following'],
      followers: (json['followers'] as num).toInt(),
      followings: (json['followings'] as num).toInt(),
      townhalls: (json['townhalls'] as num).toInt(),
      self_view: json['self_view'],
    );

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'email': instance.email,
      'phone': instance.phone,
      'othernames': instance.othernames,
      'username': instance.username,
      'about_me': instance.about_me,
      'gender': instance.gender,
      'country_id': instance.country_id,
      'country_name': instance.country_name,
      'state_id': instance.state_id,
      'state_name': instance.state_name,
      'state_origin_id': instance.state_origin_id,
      'state_origin_name': instance.state_origin_name,
      'lga_id': instance.lga_id,
      'lga_name': instance.lga_name,
      'ward_id': instance.ward_id,
      'ward_name': instance.ward_name,
      'pu_id': instance.pu_id,
      'pu_name': instance.pu_name,
      'show_polling_unit': instance.show_polling_unit,
      'party_id': instance.party_id,
      'party_name': instance.party_name,
      'party_accronym': instance.party_accronym,
      'dob': instance.dob,
      'edu_level_id': instance.edu_level_id,
      'edu_level_txt': instance.edu_level_txt,
      'profession': instance.profession,
      'profession_category': instance.profession_category,
      'profession_category_txt': instance.profession_category_txt,
      'photo_path': instance.photo_path,
      'photo_path_mid': instance.photo_path_mid,
      'photo_path_lg': instance.photo_path_lg,
      'blocked_or_not': instance.blocked_or_not,
      'support_group_id': instance.support_group_id,
      'share_link': instance.share_link,
      'is_following': instance.is_following,
      'followings': instance.followings,
      'followers': instance.followers,
      'townhalls': instance.townhalls,
      'self_view': instance.self_view,
      'support_group_name': instance.support_group_name,
    };
