// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_password_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmPasswordResponse _$ConfirmPasswordResponseFromJson(
        Map<String, dynamic> json) =>
    ConfirmPasswordResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      tag: json['tag'] as String,
    );

Map<String, dynamic> _$ConfirmPasswordResponseToJson(
        ConfirmPasswordResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'tag': instance.tag,
    };
