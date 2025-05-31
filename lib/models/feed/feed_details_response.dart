import 'package:json_annotation/json_annotation.dart';
part 'feed_details_response.g.dart';

@JsonSerializable()
class FeedDetailsResponse {
  FeedDetailsResponse({
    required this.status,
    this.msg,
    this.data,
  });

  int status;
  String? msg;
  FData? data;

  factory FeedDetailsResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$FeedDetailsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FeedDetailsResponseToJson(this);
}

@JsonSerializable()
class FData {
  FData(
      {this.post_id,
      this.username,
      this.post_message,
      this.post_unique_id,
      this.post_group_id,
      this.posted_by,
      this.like_count,
      this.comment_count,
      this.post_update_by,
      required this.is_liked,
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
      this.post_comments});

  dynamic post_id;
  dynamic username;
  dynamic post_message;
  dynamic post_unique_id;
  dynamic post_group_id;
  dynamic posted_by;
  dynamic like_count;
  dynamic comment_count;
  dynamic post_update_by;
  bool is_liked;

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
  List<CommentsData>? post_comments;

  factory FData.fromJson(Map<String, dynamic> json) => _$FDataFromJson(json);

  Map<String, dynamic> toJson() => _$FDataToJson(this);
}

@JsonSerializable()
class FeedImagesData {
  FeedImagesData({
    this.name,
    this.thumbnail,
    this.id,
    this.created_at,
    this.type,
  });

  dynamic name;
  dynamic thumbnail;
  dynamic id;
  dynamic created_at;
  dynamic type;

  factory FeedImagesData.fromJson(Map<String, dynamic> json) =>
      _$FeedImagesDataFromJson(json);

  Map<String, dynamic> toJson() => _$FeedImagesDataToJson(this);
}

@JsonSerializable()
class CommentsData {
  CommentsData({
    this.id,
    this.message,
    this.comment_unique_id,
    this.post_unique_id,
    this.updated_at,
    this.created_at,
    this.commented_by,
    this.commented_by_fullname,
    this.commented_by_profile_pics,
  });

  dynamic id;
  dynamic message;
  dynamic comment_unique_id;
  dynamic post_unique_id;
  dynamic updated_at;
  dynamic created_at;
  dynamic commented_by;
  dynamic commented_by_fullname;
  dynamic commented_by_profile_pics;

  factory CommentsData.fromJson(Map<String, dynamic> json) =>
      _$CommentsDataFromJson(json);

  Map<String, dynamic> toJson() => _$CommentsDataToJson(this);
}
