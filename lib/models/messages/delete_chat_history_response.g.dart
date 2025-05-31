// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_chat_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteChatHistoryResponse _$DeleteChatHistoryResponseFromJson(
        Map<String, dynamic> json) =>
    DeleteChatHistoryResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$DeleteChatHistoryResponseToJson(
        DeleteChatHistoryResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
