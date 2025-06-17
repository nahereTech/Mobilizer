import 'package:json_annotation/json_annotation.dart';
part 'create_comments_response.g.dart';

@JsonSerializable()
class CreateCommentsResponse {
  CreateCommentsResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  int status;
  String msg;
  CommentData? data;
  factory CreateCommentsResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$CreateCommentsResponseFromJson(json);
  }
  Map<String, dynamic> toJson() => _$CreateCommentsResponseToJson(this);
}

@JsonSerializable()
class CommentData {
  CommentData({
    required this.commentID,
    required this.comment_txt,
    required this.comment_alignment,
    required this.like_count,
    required this.user_liked,
    // required this.updated_at,
    required this.created_at,
    required this.commented_by,
    required this.commented_by_fullname,
    required this.commented_by_username,
    required this.commented_by_profile_pics,
    required this.comment_count,
    required this.can_delete,
    required this.share_count,
    required this.share_link,
  });

  int commentID;
  String comment_txt;
  String comment_alignment;
  int like_count;
  bool user_liked;
  //String updated_at;
  String created_at;
  dynamic commented_by;
  String commented_by_fullname;
  String commented_by_username;
  String commented_by_profile_pics;
  int comment_count;
  bool can_delete;
  int share_count;
  String share_link;

  factory CommentData.fromJson(Map<String, dynamic> json) =>
      _$CommentDataFromJson(json);

  Map<String, dynamic> toJson() => _$CommentDataToJson(this);
}
