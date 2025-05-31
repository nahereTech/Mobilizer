// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_delete_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventDeleteResponse _$EventDeleteResponseFromJson(Map<String, dynamic> json) =>
    EventDeleteResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$EventDeleteResponseToJson(
        EventDeleteResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
