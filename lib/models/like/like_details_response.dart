import 'package:json_annotation/json_annotation.dart';
part 'like_details_response.g.dart';

@JsonSerializable()
class LikeDetailsResponse {
  LikeDetailsResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String? msg;
  FData? data;

  factory LikeDetailsResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$LikeDetailsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LikeDetailsResponseToJson(this);
}

@JsonSerializable()
class FData {
  FData(
      {this.post_id,
      this.post_message,
      this.post_unique_id,
      this.post_group_id,
      this.posted_by,
      this.like_count,
      this.comment_count,
      this.post_update_by,
      this.is_liked,
      this.can_delete,
      this.noticeboard_msg,
      this.post_updated_time,
      this.post_updated_iso_time,
      this.org_id,
      this.townhall_id,
      this.org_name,
      this.designation,
      this.post_alignment,
      this.sharelink,
      this.post_iso_time,
      this.post_profile_pics,
      this.post_images,
      this.post_videos,
      this.liker});

  dynamic post_id;
  dynamic post_message;
  dynamic post_unique_id;
  dynamic post_group_id;
  dynamic posted_by;
  dynamic like_count;
  dynamic comment_count;
  dynamic post_update_by;
  dynamic is_liked;
  dynamic can_delete;
  dynamic noticeboard_msg;
  dynamic post_updated_time;
  dynamic post_updated_iso_time;
  dynamic org_id;
  dynamic townhall_id;
  dynamic org_name;
  dynamic designation;
  dynamic post_alignment;
  dynamic sharelink;
  dynamic post_iso_time;
  dynamic post_profile_pics;
  List<FeedImagesData>? post_images;
  List<FeedVideosData>? post_videos;
  List<LikeData>? liker;

  factory FData.fromJson(Map<String, dynamic> json) => _$FDataFromJson(json);

  Map<String, dynamic> toJson() => _$FDataToJson(this);
}

@JsonSerializable()
class FeedImagesData {
  FeedImagesData({
    this.name,
    this.id,
    this.created_at,
    this.created_at_iso_time,
    this.imagenameonly,
    this.image_link,
    this.type,
  });

  dynamic name;
  dynamic id;
  dynamic created_at;
  dynamic created_at_iso_time;
  dynamic imagenameonly;
  dynamic image_link;
  dynamic type;

  factory FeedImagesData.fromJson(Map<String, dynamic> json) =>
      _$FeedImagesDataFromJson(json);

  Map<String, dynamic> toJson() => _$FeedImagesDataToJson(this);
}

@JsonSerializable()
class FeedVideosData {
  FeedVideosData({
    this.name,
    this.id,
    this.created_at,
    this.created_at_iso_time,
    this.type,
    this.videonameonly,
    this.video_link,
  });

  dynamic name;
  dynamic id;
  dynamic created_at;
  dynamic created_at_iso_time;
  dynamic type;
  dynamic videonameonly;
  dynamic video_link;

  factory FeedVideosData.fromJson(Map<String, dynamic> json) =>
      _$FeedVideosDataFromJson(json);

  Map<String, dynamic> toJson() => _$FeedVideosDataToJson(this);
}

@JsonSerializable()
class LikeData {
  LikeData({
    this.liked_by,
    this.firstname,
    this.lastname,
    this.time_of_like,
    this.profile_photo,
    this.username,
  });

  dynamic liked_by;
  dynamic firstname;
  dynamic lastname;
  dynamic time_of_like;
  dynamic profile_photo;
  dynamic username;

  factory LikeData.fromJson(Map<String, dynamic> json) =>
      _$LikeDataFromJson(json);

  Map<String, dynamic> toJson() => _$LikeDataToJson(this);
}
