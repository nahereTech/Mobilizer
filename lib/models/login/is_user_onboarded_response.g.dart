// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_user_onboarded_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserOnboardedResponse _$UserOnboardedResponseFromJson(
        Map<String, dynamic> json) =>
    UserOnboardedResponse(
      status: json['status'],
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserOnboardedResponseToJson(
        UserOnboardedResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      build_number: json['build_number'],
      email: json['email'],
      action: json['action'] as String,
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'build_number': instance.build_number,
      'email': instance.email,
      'action': instance.action,
    };
