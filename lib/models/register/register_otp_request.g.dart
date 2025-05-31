// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_otp_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterOTPRequest _$RegisterOTPRequestFromJson(Map<String, dynamic> json) =>
    RegisterOTPRequest(
      email: json['email'],
      code: json['code'],
    );

Map<String, dynamic> _$RegisterOTPRequestToJson(RegisterOTPRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'code': instance.code,
    };
