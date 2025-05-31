// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      email: json['email'],
      app_name: json['app_name'],
      password: json['password'],
      device_type: json['device_type'],
      device_token: json['device_token'],
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'app_name': instance.app_name,
      'password': instance.password,
      'device_type': instance.device_type,
      'device_token': instance.device_token,
    };
