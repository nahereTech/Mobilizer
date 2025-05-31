// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateEventResponse _$CreateEventResponseFromJson(Map<String, dynamic> json) =>
    CreateEventResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : EventData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateEventResponseToJson(
        CreateEventResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

EventData _$EventDataFromJson(Map<String, dynamic> json) => EventData(
      event_id: (json['event_id'] as num).toInt(),
      title: json['title'] as String,
      desc: json['desc'] as String,
      event_type: json['event_type'] as String,
      event_time_full: json['event_time_full'] as String,
      meeting_point: json['meeting_point'] as String,
    );

Map<String, dynamic> _$EventDataToJson(EventData instance) => <String, dynamic>{
      'event_id': instance.event_id,
      'title': instance.title,
      'desc': instance.desc,
      'event_type': instance.event_type,
      'event_time_full': instance.event_time_full,
      'meeting_point': instance.meeting_point,
    };
