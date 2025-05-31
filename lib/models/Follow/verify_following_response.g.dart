// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_following_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetVerifyFollowingResponse _$GetVerifyFollowingResponseFromJson(
        Map<String, dynamic> json) =>
    GetVerifyFollowingResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : FollowData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetVerifyFollowingResponseToJson(
        GetVerifyFollowingResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

FollowData _$FollowDataFromJson(Map<String, dynamic> json) => FollowData(
      isFollowing: json['isFollowing'] as String,
    );

Map<String, dynamic> _$FollowDataToJson(FollowData instance) =>
    <String, dynamic>{
      'isFollowing': instance.isFollowing,
    };
