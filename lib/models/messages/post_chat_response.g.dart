// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostChatResponse _$PostChatResponseFromJson(Map<String, dynamic> json) =>
    PostChatResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : ChatData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostChatResponseToJson(PostChatResponse instance) =>
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
      message_images: (json['message_images'] as List<dynamic>?)
          ?.map((e) => ImageData.fromJson(e as Map<String, dynamic>))
          .toList(),
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
