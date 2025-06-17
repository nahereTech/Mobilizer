// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_update_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileUpdateResponse _$ProfileUpdateResponseFromJson(
        Map<String, dynamic> json) =>
    ProfileUpdateResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$ProfileUpdateResponseToJson(
        ProfileUpdateResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
