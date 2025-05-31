import 'package:json_annotation/json_annotation.dart';
import 'package:mobilizer/models/messages/chat_history_response.dart';

part 'comments_of_post_response.g.dart';

@JsonSerializable()
class CommentsOfPostResponse {
  CommentsOfPostResponse({
    required this.status,
    required this.msg,
    List<CommentOfPostData>? data,
  }) : data = data ?? [];

  int status;
  String msg;
  List<CommentOfPostData>? data;

  factory CommentsOfPostResponse.fromJson(Map<String, dynamic> json) {
    // print(json);
    return _$CommentsOfPostResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CommentsOfPostResponseToJson(this);
}

@JsonSerializable()
class CommentOfPostData {
  CommentOfPostData({
    required this.id,
    required this.message,
    required this.comment_alignment,
    required this.like_count,
    required this.user_liked,
    this.updated_at,
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

  int id;
  String message;
  String comment_alignment;
  int like_count;
  bool user_liked;
  String? updated_at;
  String created_at;
  dynamic commented_by;
  String commented_by_fullname;
  String commented_by_username;
  String commented_by_profile_pics;
  int comment_count;
  bool can_delete;
  int share_count;
  String share_link;
  factory CommentOfPostData.fromJson(Map<String, dynamic> json) =>
      _$CommentOfPostDataFromJson(json);

  Map<String, dynamic> toJson() => _$CommentOfPostDataToJson(this);
}
