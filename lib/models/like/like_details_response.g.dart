// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LikeDetailsResponse _$LikeDetailsResponseFromJson(Map<String, dynamic> json) =>
    LikeDetailsResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : FData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LikeDetailsResponseToJson(
        LikeDetailsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

FData _$FDataFromJson(Map<String, dynamic> json) => FData(
      post_id: json['post_id'],
      post_message: json['post_message'],
      post_unique_id: json['post_unique_id'],
      post_group_id: json['post_group_id'],
      posted_by: json['posted_by'],
      like_count: json['like_count'],
      comment_count: json['comment_count'],
      post_update_by: json['post_update_by'],
      is_liked: json['is_liked'],
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
      post_videos: (json['post_videos'] as List<dynamic>?)
          ?.map((e) => FeedVideosData.fromJson(e as Map<String, dynamic>))
          .toList(),
      liker: (json['liker'] as List<dynamic>?)
          ?.map((e) => LikeData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FDataToJson(FData instance) => <String, dynamic>{
      'post_id': instance.post_id,
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
      'post_videos': instance.post_videos,
      'liker': instance.liker,
    };

FeedImagesData _$FeedImagesDataFromJson(Map<String, dynamic> json) =>
    FeedImagesData(
      name: json['name'],
      id: json['id'],
      created_at: json['created_at'],
      created_at_iso_time: json['created_at_iso_time'],
      imagenameonly: json['imagenameonly'],
      image_link: json['image_link'],
      type: json['type'],
    );

Map<String, dynamic> _$FeedImagesDataToJson(FeedImagesData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'created_at': instance.created_at,
      'created_at_iso_time': instance.created_at_iso_time,
      'imagenameonly': instance.imagenameonly,
      'image_link': instance.image_link,
      'type': instance.type,
    };

FeedVideosData _$FeedVideosDataFromJson(Map<String, dynamic> json) =>
    FeedVideosData(
      name: json['name'],
      id: json['id'],
      created_at: json['created_at'],
      created_at_iso_time: json['created_at_iso_time'],
      type: json['type'],
      videonameonly: json['videonameonly'],
      video_link: json['video_link'],
    );

Map<String, dynamic> _$FeedVideosDataToJson(FeedVideosData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'created_at': instance.created_at,
      'created_at_iso_time': instance.created_at_iso_time,
      'type': instance.type,
      'videonameonly': instance.videonameonly,
      'video_link': instance.video_link,
    };

LikeData _$LikeDataFromJson(Map<String, dynamic> json) => LikeData(
      liked_by: json['liked_by'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      time_of_like: json['time_of_like'],
      profile_photo: json['profile_photo'],
      username: json['username'],
    );

Map<String, dynamic> _$LikeDataToJson(LikeData instance) => <String, dynamic>{
      'liked_by': instance.liked_by,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'time_of_like': instance.time_of_like,
      'profile_photo': instance.profile_photo,
      'username': instance.username,
    };
