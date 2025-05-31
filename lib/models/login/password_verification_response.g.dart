// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_verification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordVerificationResponse _$PasswordVerificationResponseFromJson(
        Map<String, dynamic> json) =>
    PasswordVerificationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$PasswordVerificationResponseToJson(
        PasswordVerificationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
