// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_update_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForgotPasswordUpdateResponse _$ForgotPasswordUpdateResponseFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordUpdateResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$ForgotPasswordUpdateResponseToJson(
        ForgotPasswordUpdateResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
