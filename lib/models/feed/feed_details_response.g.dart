// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedDetailsResponse _$FeedDetailsResponseFromJson(Map<String, dynamic> json) =>
    FeedDetailsResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : FData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeedDetailsResponseToJson(
        FeedDetailsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

FData _$FDataFromJson(Map<String, dynamic> json) => FData(
      post_id: json['post_id'],
      username: json['username'],
      post_message: json['post_message'],
      post_unique_id: json['post_unique_id'],
      post_group_id: json['post_group_id'],
      posted_by: json['posted_by'],
      like_count: json['like_count'],
      comment_count: json['comment_count'],
      post_update_by: json['post_update_by'],
      is_liked: json['is_liked'] as bool,
      can_delete: json['can_delete'],
      noticeboard_msg: json['noticeboard_msg'],
      post_updated_time: json['post_updated_time'],
      post_updated_iso_time: json['post_updated_iso_time'],
      org_id: json['org_id'],
      townhall_id: json['townhall_id'],
      org_name: json['org_name'],
      designation: json['designation'],
      post_alignment: json['post_alignment'],
      sharelink: json['sharelink'],
      post_iso_time: json['post_iso_time'],
      post_profile_pics: json['post_profile_pics'],
      post_images: (json['post_images'] as List<dynamic>?)
          ?.map((e) => FeedImagesData.fromJson(e as Map<String, dynamic>))
          .toList(),
      post_comments: (json['post_comments'] as List<dynamic>?)
          ?.map((e) => CommentsData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FDataToJson(FData instance) => <String, dynamic>{
      'post_id': instance.post_id,
      'username': instance.username,
      'post_message': instance.post_message,
      'post_unique_id': instance.post_unique_id,
      'post_group_id': instance.post_group_id,
      'posted_by': instance.posted_by,
      'like_count': instance.like_count,
      'comment_count': instance.comment_count,
      'post_update_by': instance.post_update_by,
      'is_liked': instance.is_liked,
      'can_delete': instance.can_delete,
      'noticeboard_msg': instance.noticeboard_msg,
      'post_updated_time': instance.post_updated_time,
      'post_updated_iso_time': instance.post_updated_iso_time,
      'org_id': instance.org_id,
      'townhall_id': instance.townhall_id,
      'org_name': instance.org_name,
      'designation': instance.designation,
      'post_alignment': instance.post_alignment,
      'sharelink': instance.sharelink,
      'post_iso_time': instance.post_iso_time,
      'post_profile_pics': instance.post_profile_pics,
      'post_images': instance.post_images,
      'post_comments': instance.post_comments,
    };

FeedImagesData _$FeedImagesDataFromJson(Map<String, dynamic> json) =>
    FeedImagesData(
      name: json['name'],
      thumbnail: json['thumbnail'],
      id: json['id'],
      created_at: json['created_at'],
      type: json['type'],
    );

Map<String, dynamic> _$FeedImagesDataToJson(FeedImagesData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'thumbnail': instance.thumbnail,
      'id': instance.id,
      'created_at': instance.created_at,
      'type': instance.type,
    };

CommentsData _$CommentsDataFromJson(Map<String, dynamic> json) => CommentsData(
      id: json['id'],
      message: json['message'],
      comment_unique_id: json['comment_unique_id'],
      post_unique_id: json['post_unique_id'],
      updated_at: json['updated_at'],
      created_at: json['created_at'],
      commented_by: json['commented_by'],
      commented_by_fullname: json['commented_by_fullname'],
      commented_by_profile_pics: json['commented_by_profile_pics'],
    );

Map<String, dynamic> _$CommentsDataToJson(CommentsData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'comment_unique_id': instance.comment_unique_id,
      'post_unique_id': instance.post_unique_id,
      'updated_at': instance.updated_at,
      'created_at': instance.created_at,
      'commented_by': instance.commented_by,
      'commented_by_fullname': instance.commented_by_fullname,
      'commented_by_profile_pics': instance.commented_by_profile_pics,
    };
