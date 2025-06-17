// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'createpost_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePostResponse _$CreatePostResponseFromJson(Map<String, dynamic> json) =>
    CreatePostResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : PostData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreatePostResponseToJson(CreatePostResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

PostData _$PostDataFromJson(Map<String, dynamic> json) => PostData(
      post_id: (json['post_id'] as num).toInt(),
      parent_id: (json['parent_id'] as num).toInt(),
      posted_by: json['posted_by'] as String,
      post_message: json['post_message'] as String,
      post_alignment: json['post_alignment'] as String,
      post_update_by: json['post_update_by'] as String,
      post_updated_time: json['post_updated_time'] as String,
      username: json['username'] as String,
      like_count: (json['like_count'] as num).toInt(),
      comment_count: (json['comment_count'] as num).toInt(),
      post_profile_pics: json['post_profile_pics'] as String,
      can_delete: json['can_delete'] as String,
      noticeboard_msg: json['noticeboard_msg'] as String,
      designation: json['designation'] as String,
      poll: json['poll'],
      poll_end: json['poll_end'],
      poll_status: json['poll_status'],
      total_votes: json['total_votes'],
      poll_details: (json['poll_details'] as List<dynamic>?)
          ?.map((e) => PollOptions.fromJson(e as Map<String, dynamic>))
          .toList(),
      user_voted: json['user_voted'] as bool,
      user_option: json['user_option'],
      user_liked: json['user_liked'] as bool,
      share_link: json['share_link'] as String,
    );

Map<String, dynamic> _$PostDataToJson(PostData instance) => <String, dynamic>{
      'post_id': instance.post_id,
      'parent_id': instance.parent_id,
      'posted_by': instance.posted_by,
      'post_message': instance.post_message,
      'post_alignment': instance.post_alignment,
      'post_update_by': instance.post_update_by,
      'post_updated_time': instance.post_updated_time,
      'username': instance.username,
      'like_count': instance.like_count,
      'comment_count': instance.comment_count,
      'post_profile_pics': instance.post_profile_pics,
      'can_delete': instance.can_delete,
      'noticeboard_msg': instance.noticeboard_msg,
      'designation': instance.designation,
      'user_voted': instance.user_voted,
      'user_option': instance.user_option,
      'poll': instance.poll,
      'poll_end': instance.poll_end,
      'poll_status': instance.poll_status,
      'total_votes': instance.total_votes,
      'user_liked': instance.user_liked,
      'share_link': instance.share_link,
      'poll_details': instance.poll_details,
    };

PollOptions _$PollOptionsFromJson(Map<String, dynamic> json) => PollOptions(
      option_id: json['option_id'],
      option_value: json['option_value'] as String,
    );

Map<String, dynamic> _$PollOptionsToJson(PollOptions instance) =>
    <String, dynamic>{
      'option_id': instance.option_id,
      'option_value': instance.option_value,
    };
