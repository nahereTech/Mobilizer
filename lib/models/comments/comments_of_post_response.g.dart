// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_of_post_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentsOfPostResponse _$CommentsOfPostResponseFromJson(
        Map<String, dynamic> json) =>
    CommentsOfPostResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CommentOfPostData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CommentsOfPostResponseToJson(
        CommentsOfPostResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

CommentOfPostData _$CommentOfPostDataFromJson(Map<String, dynamic> json) =>
    CommentOfPostData(
      id: (json['id'] as num).toInt(),
      message: json['message'] as String,
      comment_alignment: json['comment_alignment'] as String,
      like_count: (json['like_count'] as num).toInt(),
      user_liked: json['user_liked'] as bool,
      updated_at: json['updated_at'] as String?,
      created_at: json['created_at'] as String,
      commented_by: json['commented_by'],
      commented_by_fullname: json['commented_by_fullname'] as String,
      commented_by_username: json['commented_by_username'] as String,
      commented_by_profile_pics: json['commented_by_profile_pics'] as String,
      comment_count: (json['comment_count'] as num).toInt(),
      can_delete: json['can_delete'] as bool,
      share_count: (json['share_count'] as num).toInt(),
      share_link: json['share_link'] as String,
    );

Map<String, dynamic> _$CommentOfPostDataToJson(CommentOfPostData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'comment_alignment': instance.comment_alignment,
      'like_count': instance.like_count,
      'user_liked': instance.user_liked,
      'updated_at': instance.updated_at,
      'created_at': instance.created_at,
      'commented_by': instance.commented_by,
      'commented_by_fullname': instance.commented_by_fullname,
      'commented_by_username': instance.commented_by_username,
      'commented_by_profile_pics': instance.commented_by_profile_pics,
      'comment_count': instance.comment_count,
      'can_delete': instance.can_delete,
      'share_count': instance.share_count,
      'share_link': instance.share_link,
    };
