// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedResponse _$FeedResponseFromJson(Map<String, dynamic> json) => FeedResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => FeedData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FeedResponseToJson(FeedResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

FeedData _$FeedDataFromJson(Map<String, dynamic> json) => FeedData(
      post_id: json['post_id'],
      post_message: json['post_message'],
      post_unique_id: json['post_unique_id'],
      post_group_id: json['post_group_id'],
      post_alignment: json['post_alignment'],
      posted_by: json['posted_by'],
      like_count: json['like_count'],
      share_count: json['share_count'],
      comment_count: json['comment_count'],
      post_update_by: json['post_update_by'],
      username: json['username'],
      sharelink: json['sharelink'],
      is_liked: json['is_liked'],
      can_delete: json['can_delete'],
      noticeboard_msg: json['noticeboard_msg'],
      designation: json['designation'],
      post_updated_time: json['post_updated_time'],
      post_updated_time_utc: json['post_updated_time_utc'],
      current_time: json['current_time'],
      post_updated_iso_time: json['post_updated_iso_time'],
      post_iso_time: json['post_iso_time'],
      post_profile_pics: json['post_profile_pics'],
      poll: json['poll'],
      poll_end: json['poll_end'],
      poll_details: (json['poll_details'] as List<dynamic>?)
          ?.map((e) => PollOptions.fromJson(e as Map<String, dynamic>))
          .toList(),
      user_voted: json['user_voted'] as bool,
      total_votes: (json['total_votes'] as num).toInt(),
      user_option: json['user_option'],
      post_images: (json['post_images'] as List<dynamic>?)
          ?.map((e) => FeedImagesData.fromJson(e as Map<String, dynamic>))
          .toList(),
      reference_post: json['reference_post'] == null
          ? null
          : ReferencePost.fromJson(
              json['reference_post'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeedDataToJson(FeedData instance) => <String, dynamic>{
      'post_id': instance.post_id,
      'post_message': instance.post_message,
      'post_alignment': instance.post_alignment,
      'post_unique_id': instance.post_unique_id,
      'post_group_id': instance.post_group_id,
      'posted_by': instance.posted_by,
      'like_count': instance.like_count,
      'comment_count': instance.comment_count,
      'share_count': instance.share_count,
      'post_update_by': instance.post_update_by,
      'username': instance.username,
      'is_liked': instance.is_liked,
      'can_delete': instance.can_delete,
      'noticeboard_msg': instance.noticeboard_msg,
      'designation': instance.designation,
      'sharelink': instance.sharelink,
      'post_updated_time': instance.post_updated_time,
      'post_updated_time_utc': instance.post_updated_time_utc,
      'current_time': instance.current_time,
      'post_updated_iso_time': instance.post_updated_iso_time,
      'post_iso_time': instance.post_iso_time,
      'post_profile_pics': instance.post_profile_pics,
      'poll': instance.poll,
      'poll_end': instance.poll_end,
      'poll_details': instance.poll_details,
      'user_voted': instance.user_voted,
      'total_votes': instance.total_votes,
      'user_option': instance.user_option,
      'post_images': instance.post_images,
      'reference_post': instance.reference_post,
    };

ReferencePost _$ReferencePostFromJson(Map<String, dynamic> json) =>
    ReferencePost(
      post_id: json['post_id'],
      post_update_by: json['post_update_by'],
      username: json['username'],
      post_message: json['post_message'],
      post_alignment: json['post_alignment'],
      post_unique_id: json['post_unique_id'],
      posted_by: json['posted_by'],
      like_count: json['like_count'],
      can_delete: json['can_delete'],
      post_group_id: json['post_group_id'],
      post_org_id: json['post_org_id'],
      noticeboard_msg: json['noticeboard_msg'],
      designation: json['designation'],
      is_liked: json['is_liked'],
      comment_count: json['comment_count'],
      group_id: json['group_id'],
      post_updated_iso_time: json['post_updated_iso_time'],
      post_updated_time: json['post_updated_time'],
      current_time: json['current_time'],
      post_updated_time_utc: json['post_updated_time_utc'],
      post_profile_pics_main: json['post_profile_pics_main'],
      post_profile_pics: json['post_profile_pics'],
      sharelink: json['sharelink'],
      poll: json['poll'],
      poll_end: json['poll_end'],
      poll_status: json['poll_status'],
      total_votes: json['total_votes'],
      poll_details: (json['poll_details'] as List<dynamic>?)
          ?.map((e) => PollOptions.fromJson(e as Map<String, dynamic>))
          .toList(),
      post_images: (json['post_images'] as List<dynamic>?)
          ?.map((e) => FeedImagesData.fromJson(e as Map<String, dynamic>))
          .toList(),
      user_voted: json['user_voted'] as bool,
      user_option: json['user_option'],
    );

Map<String, dynamic> _$ReferencePostToJson(ReferencePost instance) =>
    <String, dynamic>{
      'post_id': instance.post_id,
      'post_update_by': instance.post_update_by,
      'username': instance.username,
      'post_message': instance.post_message,
      'post_alignment': instance.post_alignment,
      'post_unique_id': instance.post_unique_id,
      'posted_by': instance.posted_by,
      'like_count': instance.like_count,
      'can_delete': instance.can_delete,
      'post_group_id': instance.post_group_id,
      'post_org_id': instance.post_org_id,
      'noticeboard_msg': instance.noticeboard_msg,
      'designation': instance.designation,
      'is_liked': instance.is_liked,
      'comment_count': instance.comment_count,
      'group_id': instance.group_id,
      'post_updated_time': instance.post_updated_time,
      'post_updated_iso_time': instance.post_updated_iso_time,
      'current_time': instance.current_time,
      'post_updated_time_utc': instance.post_updated_time_utc,
      'post_profile_pics_main': instance.post_profile_pics_main,
      'post_profile_pics': instance.post_profile_pics,
      'sharelink': instance.sharelink,
      'poll': instance.poll,
      'poll_end': instance.poll_end,
      'poll_status': instance.poll_status,
      'total_votes': instance.total_votes,
      'poll_details': instance.poll_details,
      'post_images': instance.post_images,
      'user_voted': instance.user_voted,
      'user_option': instance.user_option,
    };

FeedImagesData _$FeedImagesDataFromJson(Map<String, dynamic> json) =>
    FeedImagesData(
      name: json['name'],
      mp4_video: json['mp4_video'],
      thumbnail: json['thumbnail'],
      id: json['id'],
      created_at: json['created_at'],
      type: json['type'],
    );

Map<String, dynamic> _$FeedImagesDataToJson(FeedImagesData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mp4_video': instance.mp4_video,
      'thumbnail': instance.thumbnail,
      'id': instance.id,
      'created_at': instance.created_at,
      'type': instance.type,
    };

PollOptions _$PollOptionsFromJson(Map<String, dynamic> json) => PollOptions(
      option_id: json['option_id'],
      option_value: json['option_value'] as String,
      votes: (json['votes'] as num).toInt(),
    );

Map<String, dynamic> _$PollOptionsToJson(PollOptions instance) =>
    <String, dynamic>{
      'option_id': instance.option_id,
      'option_value': instance.option_value,
      'votes': instance.votes,
    };
