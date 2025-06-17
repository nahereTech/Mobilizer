// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentsResponse _$CommentsResponseFromJson(Map<String, dynamic> json) =>
    CommentsResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : CommentDataOBJ.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommentsResponseToJson(CommentsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

CommentDataOBJ _$CommentDataOBJFromJson(Map<String, dynamic> json) =>
    CommentDataOBJ(
      data: CommentTwoDataOBJ.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommentDataOBJToJson(CommentDataOBJ instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

CommentTwoDataOBJ _$CommentTwoDataOBJFromJson(Map<String, dynamic> json) =>
    CommentTwoDataOBJ(
      post_comments: (json['post_comments'] as List<dynamic>)
          .map((e) => CommentData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CommentTwoDataOBJToJson(CommentTwoDataOBJ instance) =>
    <String, dynamic>{
      'post_comments': instance.post_comments,
    };

CommentData _$CommentDataFromJson(Map<String, dynamic> json) => CommentData(
      id: json['id'] as String,
      message: json['message'] as String,
      comment_unique_id: json['comment_unique_id'] as String,
      post_unique_id: json['post_unique_id'] as String,
      updated_at: json['updated_at'] as String,
      created_at: json['created_at'] as String,
      can_delete: json['can_delete'] as String,
      commented_by: json['commented_by'] as String,
      commented_by_fullname: json['commented_by_fullname'] as String,
      commented_by_profile_pics: json['commented_by_profile_pics'] as String,
    );

Map<String, dynamic> _$CommentDataToJson(CommentData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'comment_unique_id': instance.comment_unique_id,
      'post_unique_id': instance.post_unique_id,
      'updated_at': instance.updated_at,
      'created_at': instance.created_at,
      'commented_by': instance.commented_by,
      'can_delete': instance.can_delete,
      'commented_by_fullname': instance.commented_by_fullname,
      'commented_by_profile_pics': instance.commented_by_profile_pics,
    };
