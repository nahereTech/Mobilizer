// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_following_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyFollowingResponse _$VerifyFollowingResponseFromJson(
        Map<String, dynamic> json) =>
    VerifyFollowingResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => FollowingData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VerifyFollowingResponseToJson(
        VerifyFollowingResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

FollowingData _$FollowingDataFromJson(Map<String, dynamic> json) =>
    FollowingData(
      isFollowing: json['isFollowing'] as String?,
    );

Map<String, dynamic> _$FollowingDataToJson(FollowingData instance) =>
    <String, dynamic>{
      'isFollowing': instance.isFollowing,
    };
