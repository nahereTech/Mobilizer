import 'package:json_annotation/json_annotation.dart';

part 'delete_comment_response.g.dart';

@JsonSerializable()
class DeleteCommentResponse {
  DeleteCommentResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory DeleteCommentResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteCommentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteCommentResponseToJson(this);
}
