// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatHistoryResponse _$ChatHistoryResponseFromJson(Map<String, dynamic> json) =>
    ChatHistoryResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => ChatData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatHistoryResponseToJson(
        ChatHistoryResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

ChatData _$ChatDataFromJson(Map<String, dynamic> json) => ChatData(
      message_id: json['message_id'],
      message_from: json['message_from'],
      message_to: json['message_to'],
      from_me: json['from_me'],
      message: json['message'],
      message_time: json['message_time'],
      message_images: json['message_images'],
    );

Map<String, dynamic> _$ChatDataToJson(ChatData instance) => <String, dynamic>{
      'message_id': instance.message_id,
      'message_from': instance.message_from,
      'message_to': instance.message_to,
      'from_me': instance.from_me,
      'message': instance.message,
      'message_time': instance.message_time,
      'message_images': instance.message_images,
    };

ImageData _$ImageDataFromJson(Map<String, dynamic> json) => ImageData(
      image_filepath: json['image_filepath'],
      image_filename: json['image_filename'],
    );

Map<String, dynamic> _$ImageDataToJson(ImageData instance) => <String, dynamic>{
      'image_filepath': instance.image_filepath,
      'image_filename': instance.image_filename,
    };
