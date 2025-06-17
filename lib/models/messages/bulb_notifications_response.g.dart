// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulb_notifications_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BulbNotificationsResponse _$BulbNotificationsResponseFromJson(
        Map<String, dynamic> json) =>
    BulbNotificationsResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BulbNotificationsResponseToJson(
        BulbNotificationsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      messages: (json['messages'] as num?)?.toInt(),
      notifications: (json['notifications'] as num?)?.toInt(),
      events: (json['events'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'messages': instance.messages,
      'notifications': instance.notifications,
      'events': instance.events,
    };
