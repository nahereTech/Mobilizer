// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_image_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileImageResponse _$ProfileImageResponseFromJson(
        Map<String, dynamic> json) =>
    ProfileImageResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: UserData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileImageResponseToJson(
        ProfileImageResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      photo_path: json['photo_path'] as String,
      photo_path_mid: json['photo_path_mid'] as String,
      photo_path_lg: json['photo_path_lg'] as String,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'photo_path': instance.photo_path,
      'photo_path_mid': instance.photo_path_mid,
      'photo_path_lg': instance.photo_path_lg,
    };
