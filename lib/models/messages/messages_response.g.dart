// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessagesResponse _$MessagesResponseFromJson(Map<String, dynamic> json) =>
    MessagesResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => MessageData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MessagesResponseToJson(MessagesResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

MessageData _$MessageDataFromJson(Map<String, dynamic> json) => MessageData(
      message_with: json['message_with'],
      message_with_name: json['message_with_name'],
      message: json['message'],
      unread_count: json['unread_count'],
      has_new: json['has_new'],
      lastest_message_time: json['lastest_message_time'],
      profile_image: json['profile_image'],
    );

Map<String, dynamic> _$MessageDataToJson(MessageData instance) =>
    <String, dynamic>{
      'message_with': instance.message_with,
      'message_with_name': instance.message_with_name,
      'message': instance.message,
      'unread_count': instance.unread_count,
      'has_new': instance.has_new,
      'lastest_message_time': instance.lastest_message_time,
      'profile_image': instance.profile_image,
    };
