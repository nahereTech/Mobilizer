// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileUpdateRequest _$ProfileUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    ProfileUpdateRequest(
      username: json['username'],
      about: json['about'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      phone: json['phone'],
      gender: json['gender'],
      dob: json['dob'],
      edu_level_id: json['edu_level_id'],
      profession_category: json['profession_category'],
      user_profession: json['user_profession'],
      country: json['country'],
      state: json['state'],
      state_origin: json['state_origin'],
      lga: json['lga'],
      ward: json['ward'],
      pu: json['pu'],
      party: json['party'],
      support_group_id: json['support_group_id'],
    );

Map<String, dynamic> _$ProfileUpdateRequestToJson(
        ProfileUpdateRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'about': instance.about,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'phone': instance.phone,
      'gender': instance.gender,
      'dob': instance.dob,
      'edu_level_id': instance.edu_level_id,
      'profession_category': instance.profession_category,
      'user_profession': instance.user_profession,
      'country': instance.country,
      'state': instance.state,
      'state_origin': instance.state_origin,
      'lga': instance.lga,
      'ward': instance.ward,
      'pu': instance.pu,
      'party': instance.party,
      'support_group_id': instance.support_group_id,
    };
