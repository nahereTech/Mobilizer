// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'following_count_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowingResponseCount _$FollowingResponseCountFromJson(
        Map<String, dynamic> json) =>
    FollowingResponseCount(
      status: json['status'] as String,
      msg: json['msg'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$FollowingResponseCountToJson(
        FollowingResponseCount instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'count': instance.count,
    };
