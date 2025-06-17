// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_comment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteCommentResponse _$DeleteCommentResponseFromJson(
        Map<String, dynamic> json) =>
    DeleteCommentResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$DeleteCommentResponseToJson(
        DeleteCommentResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
