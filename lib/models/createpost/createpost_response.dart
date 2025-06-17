// import 'package:json_annotation/json_annotation.dart';

// part 'createpost_response.g.dart';

// @JsonSerializable()
// class CreatePostResponse {
//   CreatePostResponse({
//     required this.status,
//     required this.msg,
//     this.data,
//   });

//   int status;
//   String msg;
//   PostData? data;

//   factory CreatePostResponse.fromJson(Map<String, dynamic> json) =>
//       _$CreatePostResponseFromJson(json);

//   Map<String, dynamic> toJson() => _$CreatePostResponseToJson(this);
// }

// @JsonSerializable()
// class PostData {
//   PostData({
//     required this.postID,
//     this.town_hall_files,
//     this.town_hall_filenames,
//     required this.townHallMessage,
//   });

//   int postID;
//   List<String>? town_hall_files;
//   List<String>? town_hall_filenames;
//   String townHallMessage;

//   factory PostData.fromJson(Map<String, dynamic> json) {
//     print(json);
//     return _$PostDataFromJson(json);
//   }

//   Map<String, dynamic> toJson() => _$PostDataToJson(this);
// }

import 'package:json_annotation/json_annotation.dart';
part 'createpost_response.g.dart';

@JsonSerializable()
class CreatePostResponse {
  CreatePostResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  int status;
  String msg;
  PostData? data;
  factory CreatePostResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$CreatePostResponseFromJson(json);
  }
  Map<String, dynamic> toJson() => _$CreatePostResponseToJson(this);
}

@JsonSerializable()
class PostData {
  PostData(
      {required this.post_id,
      required this.parent_id,
      required this.posted_by,
      required this.post_message,
      required this.post_alignment,
      required this.post_update_by,
      required this.post_updated_time,
      required this.username,
      required this.like_count,
      required this.comment_count,
      required this.post_profile_pics,
      required this.can_delete,
      required this.noticeboard_msg,
      required this.designation,
      required this.poll,
      this.poll_end,
      this.poll_status,
      required this.total_votes,
      this.poll_details,
      required this.user_voted,
      required this.user_option,
      required this.user_liked,
      required this.share_link});
  int post_id;
  int parent_id;
  String posted_by;
  String post_message;
  String post_alignment;
  String post_update_by;
  String post_updated_time;
  String username;
  int like_count;
  int comment_count;
  String post_profile_pics;
  String can_delete;
  String noticeboard_msg;
  String designation;
  bool user_voted;
  dynamic user_option;
  dynamic poll;
  dynamic poll_end;
  dynamic poll_status;
  dynamic total_votes;
  bool user_liked;
  String share_link;
  List<PollOptions>? poll_details;

  factory PostData.fromJson(Map<String, dynamic> json) =>
      _$PostDataFromJson(json);

  Map<String, dynamic> toJson() => _$PostDataToJson(this);
}

@JsonSerializable()
class PollOptions {
  PollOptions({
    required this.option_id,
    required this.option_value,
    //required this.votes,
  });

  dynamic option_id;
  String option_value;
  //int votes;

  factory PollOptions.fromJson(Map<String, dynamic> json) =>
      _$PollOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$PollOptionsToJson(this);
}
