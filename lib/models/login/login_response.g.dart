// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      status: json['status'],
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : UserData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      user_id: json['user_id'] as String,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      username: json['username'] as String?,
      landing_page: json['landing_page'] as String?,
      profile_photo: json['profile_photo'] as String?,
      photo_path: json['photo_path'] as String,
      photo_path_mid: json['photo_path_mid'] as String,
      photo_path_lg: json['photo_path_lg'] as String,
      token: json['token'] as String,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'user_id': instance.user_id,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'username': instance.username,
      'landing_page': instance.landing_page,
      'profile_photo': instance.profile_photo,
      'photo_path': instance.photo_path,
      'photo_path_mid': instance.photo_path_mid,
      'photo_path_lg': instance.photo_path_lg,
      'token': instance.token,
    };
