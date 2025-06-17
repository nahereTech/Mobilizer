// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_followed_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetVerifyFollowedResponse _$GetVerifyFollowedResponseFromJson(
        Map<String, dynamic> json) =>
    GetVerifyFollowedResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : FollowData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetVerifyFollowedResponseToJson(
        GetVerifyFollowedResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

FollowData _$FollowDataFromJson(Map<String, dynamic> json) => FollowData(
      isFollowed: json['isFollowed'] as String,
    );

Map<String, dynamic> _$FollowDataToJson(FollowData instance) =>
    <String, dynamic>{
      'isFollowed': instance.isFollowed,
    };
