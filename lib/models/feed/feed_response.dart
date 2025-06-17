import 'package:json_annotation/json_annotation.dart';

part 'feed_response.g.dart';

@JsonSerializable()
class FeedResponse {
  FeedResponse({
    required this.status,
    required this.msg,
    //required this.inputed_data,
    List<FeedData>? data,
  }) : data = data ?? [];

  int status;
  String? msg;
  // InputedData? inputed_data;
  List<FeedData>? data;

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    //print(json);
    return _$FeedResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FeedResponseToJson(this);
}

@JsonSerializable()
class FeedData {
  FeedData(
      {required this.post_id,
      this.post_message,
      this.post_unique_id,
      this.post_group_id,
      this.post_alignment,
      this.posted_by,
      this.like_count,
      this.share_count,
      this.comment_count,
      this.post_update_by,
      this.username,
      this.sharelink,
      this.is_liked,
      this.can_delete,
      this.noticeboard_msg,
      this.designation,
      this.post_updated_time,
      this.post_updated_time_utc,
      this.current_time,
      this.post_updated_iso_time,
      this.post_iso_time,
      this.post_profile_pics,
      required this.poll,
      required this.poll_end,
      this.poll_details,
      required this.user_voted,
      required this.total_votes,
      required this.user_option,
      this.post_images,
      this.reference_post});

  dynamic post_id;
  dynamic post_message;
  dynamic post_alignment;
  dynamic post_unique_id;
  dynamic post_group_id;
  dynamic posted_by;
  dynamic like_count;
  dynamic comment_count;
  dynamic share_count;
  dynamic post_update_by;
  dynamic username;
  dynamic is_liked;
  dynamic can_delete;
  dynamic noticeboard_msg;
  dynamic designation;
  dynamic sharelink;
  dynamic post_updated_time;
  dynamic post_updated_time_utc;
  dynamic current_time;
  dynamic post_updated_iso_time;
  dynamic post_iso_time;
  dynamic post_profile_pics;
  dynamic poll;
  dynamic poll_end;
  List<PollOptions>? poll_details;
  bool user_voted;
  int total_votes;
  dynamic user_option;
  List<FeedImagesData>? post_images;
  //List<FeedVideosData>? post_videos;
  final ReferencePost? reference_post;

  factory FeedData.fromJson(Map<String, dynamic> json) =>
      _$FeedDataFromJson(json);
  Map<String, dynamic> toJson() => _$FeedDataToJson(this);
}

@JsonSerializable()
class ReferencePost {
  ReferencePost(
      {required this.post_id,
      this.post_update_by,
      this.username,
      this.post_message,
      this.post_alignment,
      this.post_unique_id,
      this.posted_by,
      this.like_count,
      this.can_delete,
      this.post_group_id,
      this.post_org_id,
      this.noticeboard_msg,
      this.designation,
      this.is_liked,
      this.comment_count,
      this.group_id,
      this.post_updated_iso_time,
      this.post_updated_time,
      this.current_time,
      this.post_updated_time_utc,
      this.post_profile_pics_main,
      this.post_profile_pics,
      this.sharelink,
      this.poll,
      this.poll_end,
      this.poll_status,
      required this.total_votes,
      this.poll_details,
      this.post_images,
      required this.user_voted,
      required this.user_option});

  dynamic post_id;
  dynamic post_update_by;
  dynamic username;
  dynamic post_message;
  dynamic post_alignment;
  dynamic post_unique_id;
  dynamic posted_by;
  dynamic like_count;
  dynamic can_delete;
  dynamic post_group_id;
  dynamic post_org_id;
  dynamic noticeboard_msg;
  dynamic designation;
  dynamic is_liked;
  dynamic comment_count;
  dynamic group_id;
  dynamic post_updated_time;
  dynamic post_updated_iso_time;
  dynamic current_time;
  dynamic post_updated_time_utc;
  dynamic post_profile_pics_main;
  dynamic post_profile_pics;
  dynamic sharelink;
  dynamic poll;
  dynamic poll_end;
  dynamic poll_status;
  dynamic total_votes;
  List<PollOptions>? poll_details;
  List<FeedImagesData>? post_images;
  bool user_voted;
  dynamic user_option;

  factory ReferencePost.fromJson(Map<String, dynamic> json) =>
      _$ReferencePostFromJson(json);

  Map<String, dynamic> toJson() => _$ReferencePostToJson(this);
}

@JsonSerializable()
class FeedImagesData {
  FeedImagesData({
    this.name,
    this.mp4_video,
    this.thumbnail,
    this.id,
    this.created_at,
    this.type,
  });

  dynamic name;
  dynamic mp4_video;
  dynamic thumbnail;
  dynamic id;
  dynamic created_at;
  dynamic type;

  factory FeedImagesData.fromJson(Map<String, dynamic> json) =>
      _$FeedImagesDataFromJson(json);

  Map<String, dynamic> toJson() => _$FeedImagesDataToJson(this);
}

// @JsonSerializable()
// class FeedVideosData {
//   FeedVideosData(
//       {this.name,
//       this.id,
//       this.created_at_iso_time,
//       this.created_at,
//       this.type,
//       this.videonameonly,
//       this.video_link});

//   dynamic name;
//   dynamic id;
//   dynamic created_at;
//   dynamic created_at_iso_time;
//   dynamic type;
//   dynamic videonameonly;
//   dynamic video_link;

//   factory FeedVideosData.fromJson(Map<String, dynamic> json) =>
//       _$FeedVideosDataFromJson(json);

//   Map<String, dynamic> toJson() => _$FeedVideosDataToJson(this);
// }
@JsonSerializable()
class PollOptions {
  PollOptions({
    required this.option_id,
    required this.option_value,
    required this.votes,
  });

  dynamic option_id;
  String option_value;
  int votes;

  factory PollOptions.fromJson(Map<String, dynamic> json) =>
      _$PollOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$PollOptionsToJson(this);
}
