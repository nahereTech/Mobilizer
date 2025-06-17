// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationsResponse _$NotificationsResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationsResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => NotificationsData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NotificationsResponseToJson(
        NotificationsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

NotificationsData _$NotificationsDataFromJson(Map<String, dynamic> json) =>
    NotificationsData(
      id: (json['id'] as num).toInt(),
      post_id: (json['post_id'] as num).toInt(),
      notification_txt: json['notification_txt'] as String?,
      notification_type: json['notification_type'] as String,
      app_id: json['app_id'] as String?,
      notification_image: json['notification_image'] as String?,
      click_leads_to: json['click_leads_to'] as String?,
      subjects_id: json['subjects_id'] as String?,
      sender_id: json['sender_id'] as String,
      notifierProfile: json['notifierProfile'] as String,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$NotificationsDataToJson(NotificationsData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notification_txt': instance.notification_txt,
      'notification_type': instance.notification_type,
      'notification_image': instance.notification_image,
      'click_leads_to': instance.click_leads_to,
      'subjects_id': instance.subjects_id,
      'post_id': instance.post_id,
      'app_id': instance.app_id,
      'date': instance.date,
      'sender_id': instance.sender_id,
      'notifierProfile': instance.notifierProfile,
    };
