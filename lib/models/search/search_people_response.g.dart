// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_people_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchPeopleResponse _$SearchPeopleResponseFromJson(
        Map<String, dynamic> json) =>
    SearchPeopleResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) =>
              SearchPeopleResponseData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchPeopleResponseToJson(
        SearchPeopleResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

SearchPeopleResponseData _$SearchPeopleResponseDataFromJson(
        Map<String, dynamic> json) =>
    SearchPeopleResponseData(
      user_id: json['user_id'] as String,
      pics: json['pics'] as String,
      photo_path: json['photo_path'] as String,
      photo_path_lg: json['photo_path_lg'] as String,
      fullname: json['fullname'] as String,
      username: json['username'] as String,
      is_following: json['is_following'] as String,
      state_name: json['state_name'],
      lga_name: json['lga_name'],
    )..country_name = json['country_name'];

Map<String, dynamic> _$SearchPeopleResponseDataToJson(
        SearchPeopleResponseData instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'pics': instance.pics,
      'photo_path': instance.photo_path,
      'photo_path_lg': instance.photo_path_lg,
      'fullname': instance.fullname,
      'username': instance.username,
      'is_following': instance.is_following,
      'country_name': instance.country_name,
      'state_name': instance.state_name,
      'lga_name': instance.lga_name,
    };
