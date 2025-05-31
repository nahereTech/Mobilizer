// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_otp_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForgotPasswordOTPResponse _$ForgotPasswordOTPResponseFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordOTPResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$ForgotPasswordOTPResponseToJson(
        ForgotPasswordOTPResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
