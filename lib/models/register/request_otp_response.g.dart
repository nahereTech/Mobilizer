// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_otp_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestOTPResponse _$RequestOTPResponseFromJson(Map<String, dynamic> json) =>
    RequestOTPResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$RequestOTPResponseToJson(RequestOTPResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
