// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_feed_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteFeedResponse _$DeleteFeedResponseFromJson(Map<String, dynamic> json) =>
    DeleteFeedResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$DeleteFeedResponseToJson(DeleteFeedResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
