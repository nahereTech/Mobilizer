// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventsResponse _$EventsResponseFromJson(Map<String, dynamic> json) =>
    EventsResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => EventsData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventsResponseToJson(EventsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

EventsData _$EventsDataFromJson(Map<String, dynamic> json) => EventsData(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      event_desc: json['event_desc'] as String?,
      event_desc_complete: json['event_desc_complete'] as String?,
      can_delete: json['can_delete'] as String?,
      event_time_fulltxt: json['event_time_fulltxt'] as String?,
      event_time_only: json['event_time_only'] as String?,
      event_date_only: json['event_date_only'] as String?,
      event_icon: json['event_icon'] as String?,
      posted_in: json['posted_in'] as String?,
      posted_by: json['posted_by'] as String?,
      name: json['name'] as String?,
      event_venue: json['event_venue'] as String?,
      event_graphics: (json['event_graphics'] as List<dynamic>?)
          ?.map((e) => EventImagesData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventsDataToJson(EventsData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'event_desc': instance.event_desc,
      'event_desc_complete': instance.event_desc_complete,
      'can_delete': instance.can_delete,
      'event_time_fulltxt': instance.event_time_fulltxt,
      'event_time_only': instance.event_time_only,
      'event_date_only': instance.event_date_only,
      'event_icon': instance.event_icon,
      'posted_in': instance.posted_in,
      'posted_by': instance.posted_by,
      'name': instance.name,
      'event_venue': instance.event_venue,
      'event_graphics': instance.event_graphics,
    };

EventImagesData _$EventImagesDataFromJson(Map<String, dynamic> json) =>
    EventImagesData(
      id: json['id'] as String,
      image_name: json['image_name'] as String,
      thumbnail: json['thumbnail'] as String?,
      type: json['type'] as String,
    );

Map<String, dynamic> _$EventImagesDataToJson(EventImagesData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image_name': instance.image_name,
      'thumbnail': instance.thumbnail,
      'type': instance.type,
    };
