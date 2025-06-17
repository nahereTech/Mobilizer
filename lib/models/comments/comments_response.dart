import 'package:json_annotation/json_annotation.dart';
import 'package:mobilizer/models/messages/chat_history_response.dart';

part 'comments_response.g.dart';

@JsonSerializable()
class CommentsResponse {
  CommentsResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  CommentDataOBJ? data;

  factory CommentsResponse.fromJson(Map<String, dynamic> json) {
    // print(json);
    return _$CommentsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CommentsResponseToJson(this);
}

@JsonSerializable()
class CommentDataOBJ {
  CommentDataOBJ({
    required this.data,
  });

  CommentTwoDataOBJ data;

  factory CommentDataOBJ.fromJson(Map<String, dynamic> json) =>
      _$CommentDataOBJFromJson(json);

  Map<String, dynamic> toJson() => _$CommentDataOBJToJson(this);
}

@JsonSerializable()
class CommentTwoDataOBJ {
  CommentTwoDataOBJ({
    required this.post_comments,
  });

  List<CommentData> post_comments;

  factory CommentTwoDataOBJ.fromJson(Map<String, dynamic> json) =>
      _$CommentTwoDataOBJFromJson(json);

  Map<String, dynamic> toJson() => _$CommentTwoDataOBJToJson(this);
}

@JsonSerializable()
class CommentData {
  CommentData({
    required this.id,
    required this.message,
    required this.comment_unique_id,
    required this.post_unique_id,
    required this.updated_at,
    required this.created_at,
    required this.can_delete,
    required this.commented_by,
    required this.commented_by_fullname,
    required this.commented_by_profile_pics,
  });

  String id;
  String message;
  String comment_unique_id;
  String post_unique_id;
  String updated_at;
  String created_at;
  String commented_by;
  String can_delete;
  String commented_by_fullname;
  String commented_by_profile_pics;

  factory CommentData.fromJson(Map<String, dynamic> json) =>
      _$CommentDataFromJson(json);

  Map<String, dynamic> toJson() => _$CommentDataToJson(this);
}
