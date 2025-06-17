// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetProfileResponse _$GetProfileResponseFromJson(Map<String, dynamic> json) =>
    GetProfileResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : ProfileData.fromJson(json['data'] as Map<String, dynamic>),
      compulsory: json['compulsory'] == null
          ? null
          : CompulsoryData.fromJson(json['compulsory'] as Map<String, dynamic>),
      visible: VisibleData.fromJson(json['visible'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetProfileResponseToJson(GetProfileResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
      'compulsory': instance.compulsory,
      'visible': instance.visible,
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
      can_opt_out: json['can_opt_out'],
      support_group_name: json['support_group_name'],
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
      'can_opt_out': instance.can_opt_out,
      'support_group_name': instance.support_group_name,
    };

CompulsoryData _$CompulsoryDataFromJson(Map<String, dynamic> json) =>
    CompulsoryData(
      profile_image: json['profile_image'],
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      phone: json['phone'],
      about: json['about'],
      gender: json['gender'],
      dob: json['dob'],
      edu: json['edu'],
      prof_cat: json['prof_cat'],
      prof_desc: json['prof_desc'],
      email: json['email'],
      state: json['state'],
      state_origin: json['state_origin'],
      country: json['country'],
      lga: json['lga'],
      ward: json['ward'],
      pu: json['pu'],
      supportg: json['supportg'],
    );

Map<String, dynamic> _$CompulsoryDataToJson(CompulsoryData instance) =>
    <String, dynamic>{
      'profile_image': instance.profile_image,
      'username': instance.username,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'phone': instance.phone,
      'about': instance.about,
      'gender': instance.gender,
      'dob': instance.dob,
      'edu': instance.edu,
      'prof_cat': instance.prof_cat,
      'prof_desc': instance.prof_desc,
      'email': instance.email,
      'state': instance.state,
      'state_origin': instance.state_origin,
      'country': instance.country,
      'lga': instance.lga,
      'ward': instance.ward,
      'pu': instance.pu,
      'supportg': instance.supportg,
    };

VisibleData _$VisibleDataFromJson(Map<String, dynamic> json) => VisibleData(
      profile_image: json['profile_image'] as bool,
      username: json['username'] as bool,
      firstname: json['firstname'] as bool,
      lastname: json['lastname'] as bool,
      phone: json['phone'] as bool,
      about: json['about'] as bool,
      gender: json['gender'] as bool,
      dob: json['dob'] as bool,
      edu: json['edu'] as bool,
      prof_cat: json['prof_cat'] as bool,
      prof_desc: json['prof_desc'] as bool,
      email: json['email'] as bool,
      state: json['state'] as bool,
      state_origin: json['state_origin'] as bool,
      country: json['country'] as bool,
      lga: json['lga'] as bool,
      ward: json['ward'] as bool,
      pu: json['pu'] as bool,
      supportg: json['supportg'] as bool,
    );

Map<String, dynamic> _$VisibleDataToJson(VisibleData instance) =>
    <String, dynamic>{
      'profile_image': instance.profile_image,
      'username': instance.username,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'phone': instance.phone,
      'about': instance.about,
      'gender': instance.gender,
      'dob': instance.dob,
      'edu': instance.edu,
      'prof_cat': instance.prof_cat,
      'prof_desc': instance.prof_desc,
      'email': instance.email,
      'state': instance.state,
      'state_origin': instance.state_origin,
      'country': instance.country,
      'lga': instance.lga,
      'ward': instance.ward,
      'pu': instance.pu,
      'supportg': instance.supportg,
    };
