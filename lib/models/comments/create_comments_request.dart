import 'package:json_annotation/json_annotation.dart';

part 'create_comments_request.g.dart';

@JsonSerializable()
class CreateCommentsRequest {
  CreateCommentsRequest({
    required this.party_townhall,
    required this.post_id,
    required this.message,
    //required this.reply_to_comment,
    required this.group,
    required this.org_id,
    required this.parent_id,
    // required this.with_file,
  });

  String post_id;
  String message;
  String party_townhall;
  String group;
  String org_id;
  String parent_id;
  // String with_file;

  factory CreateCommentsRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCommentsRequestToJson(this);
}
