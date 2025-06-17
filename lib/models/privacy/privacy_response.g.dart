// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacyResponse _$PrivacyResponseFromJson(Map<String, dynamic> json) =>
    PrivacyResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : PrivacyData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PrivacyResponseToJson(PrivacyResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

PrivacyData _$PrivacyDataFromJson(Map<String, dynamic> json) => PrivacyData(
      privacy: json['privacy'] as String,
    );

Map<String, dynamic> _$PrivacyDataToJson(PrivacyData instance) =>
    <String, dynamic>{
      'privacy': instance.privacy,
    };
