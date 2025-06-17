// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_otp_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterOTPResponse _$RegisterOTPResponseFromJson(Map<String, dynamic> json) =>
    RegisterOTPResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : UserData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegisterOTPResponseToJson(
        RegisterOTPResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      user_id: json['user_id'] as String,
      landing_page: json['landing_page'] as String,
      last_visted: json['last_visted'] as String?,
      landing_page_id: json['landing_page_id'] as String,
      token: json['token'] as String,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'user_id': instance.user_id,
      'last_visted': instance.last_visted,
      'landing_page': instance.landing_page,
      'landing_page_id': instance.landing_page_id,
      'token': instance.token,
    };
