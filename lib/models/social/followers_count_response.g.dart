// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'followers_count_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowersResponseCount _$FollowersResponseCountFromJson(
        Map<String, dynamic> json) =>
    FollowersResponseCount(
      status: json['status'] as String,
      msg: json['msg'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$FollowersResponseCountToJson(
        FollowersResponseCount instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'count': instance.count,
    };
